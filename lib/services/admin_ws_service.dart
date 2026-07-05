import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../config.dart';

/// Admin WebSocket üçin event tipler
enum AdminWsEventType {
  messageCreated,
  messageUpdated,
  messageDeleted,
  other,
}

class AdminWsEvent {
  final AdminWsEventType type;
  final Map<String, dynamic> data;
  AdminWsEvent(this.type, this.data);
}

/// Django Channels `ws/orders/` endpointine birikýän singleton servis.
/// `message.created` eventini dinleýär we StreamController arkaly ýaýradýar.
class AdminWsService {
  AdminWsService._();
  static final AdminWsService instance = AdminWsService._();

  WebSocketChannel? _channel;
  Timer? _reconnectTimer;
  bool _disposed = false;

  final _controller = StreamController<AdminWsEvent>.broadcast();

  Stream<AdminWsEvent> get stream => _controller.stream;

  /// Birikme başladýar
  void connect() {
    _disposed = false;
    _doConnect();
  }

  void _doConnect() {
    if (_disposed) return;
    try {
      final uri = Uri.parse('${Config.wsBaseUrl}/ws/orders/');
      _channel = WebSocketChannel.connect(uri);
      _channel!.stream.listen(
        _onData,
        onError: _onError,
        onDone: _onDone,
        cancelOnError: false,
      );
    } catch (e) {
      _scheduleReconnect();
    }
  }

  void _onData(dynamic raw) {
    try {
      final data = jsonDecode(raw as String) as Map<String, dynamic>;
      final type = _parseType(data['type'] as String? ?? '');
      _controller.add(AdminWsEvent(type, data));
    } catch (_) {}
  }

  void _onError(dynamic err) {
    _scheduleReconnect();
  }

  void _onDone() {
    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    if (_disposed) return;
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 5), _doConnect);
  }

  AdminWsEventType _parseType(String type) {
    switch (type) {
      case 'message.created':
        return AdminWsEventType.messageCreated;
      case 'message.updated':
        return AdminWsEventType.messageUpdated;
      case 'message.deleted':
        return AdminWsEventType.messageDeleted;
      default:
        return AdminWsEventType.other;
    }
  }

  /// Birikýäni ýapýar
  void disconnect() {
    _disposed = true;
    _reconnectTimer?.cancel();
    _channel?.sink.close();
    _channel = null;
  }
}
