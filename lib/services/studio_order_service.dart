import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';
import 'auth_service.dart';

class StudioOrderService {
  static http.Client client = http.Client();

  static Map<String, String> _headers() {
    final token = AuthService().token;
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static List<dynamic> _asList(dynamic decoded) {
    if (decoded is List) return decoded;
    if (decoded is Map && decoded['results'] is List) return decoded['results'] as List;
    return const [];
  }

  static dynamic _decode(http.Response res, String what) {
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('Failed to $what (${res.statusCode})');
    }
    return json.decode(utf8.decode(res.bodyBytes));
  }

  // --- Orders CRUD ---
  static Future<List<dynamic>> listOrders() async {
    final res = await client.get(
      Uri.parse('${Config.apiBaseUrl}/management/orders'),
      headers: _headers(),
    );
    return _asList(_decode(res, 'list orders'));
  }

  static Future<Map<String, dynamic>> createOrder(Map<String, dynamic> payload) async {
    final res = await client.post(
      Uri.parse('${Config.apiBaseUrl}/management/orders'),
      headers: _headers(),
      body: json.encode(payload),
    );
    return Map<String, dynamic>.from(_decode(res, 'create order') as Map);
  }

  static Future<Map<String, dynamic>> updateOrder(int id, Map<String, dynamic> payload) async {
    final res = await client.put(
      Uri.parse('${Config.apiBaseUrl}/management/orders/$id'),
      headers: _headers(),
      body: json.encode(payload),
    );
    return Map<String, dynamic>.from(_decode(res, 'update order') as Map);
  }

  static Future<void> deleteOrder(int id) async {
    final res = await client.delete(
      Uri.parse('${Config.apiBaseUrl}/management/orders/$id'),
      headers: _headers(),
    );
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('Failed to delete order (${res.statusCode})');
    }
  }

  // --- Catalogs ---
  static Future<List<dynamic>> listEquipments() async {
    final res = await client.get(
      Uri.parse('${Config.apiBaseUrl}/management/equipments'),
      headers: _headers(),
    );
    return _asList(_decode(res, 'list equipments'));
  }

  static Future<List<dynamic>> listServices() async {
    final res = await client.get(
      Uri.parse('${Config.apiBaseUrl}/management/services'),
      headers: _headers(),
    );
    return _asList(_decode(res, 'list services'));
  }

  static Future<List<dynamic>> listOrderTypes() async {
    final res = await client.get(
      Uri.parse('${Config.apiBaseUrl}/management/order-types'),
      headers: _headers(),
    );
    return _asList(_decode(res, 'list order types'));
  }
}
