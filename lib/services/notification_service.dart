import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../config.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  static WebSocket? _webSocket;
  static bool _isConnecting = false;

  static Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _localNotifications.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse details) {
        debugPrint('Notification clicked: ${details.payload}');
      },
    );

    // Request permissions on Android 13+
    final androidImplementation = _localNotifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidImplementation != null) {
      await androidImplementation.requestNotificationsPermission();
    }

    connectWebSocket();
  }

  static void connectWebSocket() {
    if (_isConnecting || (_webSocket != null && _webSocket!.readyState == WebSocket.open)) {
      return;
    }
    _isConnecting = true;
    final wsUrl = 'ws://${Config.backendHost}/ws/orders/';
    debugPrint('Connecting to WebSocket: $wsUrl');

    WebSocket.connect(wsUrl).then((ws) {
      _webSocket = ws;
      _isConnecting = false;
      debugPrint('WebSocket connected successfully.');

      ws.listen(
        (data) {
          debugPrint('WebSocket message received: $data');
          _handleMessage(data);
        },
        onError: (err) {
          debugPrint('WebSocket error: $err');
          _reconnect();
        },
        onDone: () {
          debugPrint('WebSocket connection closed.');
          _reconnect();
        },
        cancelOnError: true,
      );
    }).catchError((err) {
      debugPrint('WebSocket connection failed: $err');
      _isConnecting = false;
      _reconnect();
    });
  }

  static void _reconnect() {
    _webSocket = null;
    Future.delayed(const Duration(seconds: 5), () {
      connectWebSocket();
    });
  }

  static void _handleMessage(dynamic data) {
    try {
      final Map<String, dynamic> parsed = json.decode(data.toString());
      final type = parsed['type']?.toString() ?? '';
      
      String title = 'Doganlar Foto';
      String body = 'Täze bildiriş bar!';

      if (type == 'order.created') {
        final order = parsed['order'] ?? {};
        title = 'Täze studio sargydy';
        body = 'Sargyt ID: ${order['id'] ?? '-'}, Müşderi: ${order['customer_name'] ?? '-'}';
      } else if (type == 'order.updated') {
        final order = parsed['order'] ?? {};
        title = 'Studio sargydy üýtgedi';
        body = 'Sargyt ID: ${order['id'] ?? '-'}, Ýagdaýy: ${order['status'] ?? '-'}';
      } else if (type == 'commerce_order.created') {
        final order = parsed['order'] ?? {};
        title = 'Täze haryt sargydy';
        body = 'Sargyt ID: ${order['id'] ?? '-'}, Jemi: ${order['total_amount'] ?? '-'} TMT';
      } else if (type == 'commerce_order.updated') {
        final order = parsed['order'] ?? {};
        title = 'Haryt sargydy üýtgedi';
        body = 'Sargyt ID: ${order['id'] ?? '-'}, Ýagdaýy: ${order['status'] ?? '-'}';
      } else if (type == 'message.created') {
        final message = parsed['message'] ?? {};
        title = 'Täze habar';
        body = '${message['name'] ?? 'Müşderi'}: ${message['message'] ?? ''}';
      } else if (type == 'review.created') {
        final review = parsed['review'] ?? {};
        title = 'Täze teswir';
        body = 'Haryt ID: ${review['product_id'] ?? '-'}, Teswir: ${review['text'] ?? ''}';
      } else {
        return; // ignore unknown or deleted events to avoid clutter
      }

      showNotification(
        id: DateTime.now().millisecond,
        title: title,
        body: body,
        payload: data.toString(),
      );
    } catch (e) {
      debugPrint('Error handling WebSocket message: $e');
    }
  }

  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'doganlar_channel_id',
      'Doganlar Notifications',
      channelDescription: 'Doganlar Studio push notifications and order alerts',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await _localNotifications.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: platformChannelSpecifics,
      payload: payload,
    );
  }
}
