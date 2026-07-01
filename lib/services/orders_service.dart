import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';

/// Order/booking creation for anonymous customers.
///
/// - Product purchases go to the commerce `OrderViewSet` (`/commerce/orders`,
///   anonymous create allowed) which prices items server-side from the product.
/// - Photo-studio service bookings go to the main `/orders` endpoint, which
///   takes a free-form customer name/phone and amounts (no product required).
class OrdersService {
  static http.Client client = http.Client();

  static String _errorMessage(http.Response res, String fallback) {
    try {
      final body = json.decode(utf8.decode(res.bodyBytes));
      if (body is Map) {
        if (body['detail'] != null) return body['detail'].toString();
        if (body['error'] != null) return body['error'].toString();
      }
    } catch (_) {}
    return fallback;
  }

  /// Creates a commerce order for a single product (quantity defaults to 1).
  static Future<Map<String, dynamic>> createProductOrder({
    required String fullName,
    required String phoneNumber,
    required int productId,
    int quantity = 1,
  }) async {
    final res = await client.post(
      Uri.parse('${Config.apiBaseUrl}/commerce/orders'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'full_name': fullName,
        'phone_number': phoneNumber,
        'status': 'pending',
        'items': [
          {'product': productId, 'quantity': quantity},
        ],
      }),
    );
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception(_errorMessage(res, 'Sargyt ugradyp bolmady'));
    }
    return Map<String, dynamic>.from(json.decode(utf8.decode(res.bodyBytes)) as Map);
  }

  /// Creates a commerce order for multiple items.
  static Future<Map<String, dynamic>> createCartOrder({
    required String fullName,
    required String phoneNumber,
    required List<Map<String, dynamic>> items,
  }) async {
    final res = await client.post(
      Uri.parse('${Config.apiBaseUrl}/commerce/orders'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'full_name': fullName,
        'phone_number': phoneNumber,
        'status': 'pending',
        'items': items,
      }),
    );
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception(_errorMessage(res, 'Sargyt ugradyp bolmady'));
    }
    return Map<String, dynamic>.from(json.decode(utf8.decode(res.bodyBytes)) as Map);
  }

  /// Creates a photo-studio service booking.
  static Future<Map<String, dynamic>> createStudioOrder({
    required String customerName,
    required String customerPhone,
    int? orderTypeId,
    List<Map<String, dynamic>>? days,
    num totalAmount = 0,
    num paidAmount = 0,
  }) async {
    final res = await client.post(
      Uri.parse('${Config.apiBaseUrl}/orders'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'customer_name': customerName,
        'customer_phone': customerPhone,
        'order_type_id': orderTypeId,
        'total_amount': totalAmount,
        'paid_amount': paidAmount,
        if (days != null) 'days': days,
      }),
    );
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception(_errorMessage(res, 'Sargyt ugradyp bolmady'));
    }
    return Map<String, dynamic>.from(json.decode(utf8.decode(res.bodyBytes)) as Map);
  }
}
