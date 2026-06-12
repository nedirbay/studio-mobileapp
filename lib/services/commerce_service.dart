import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';

/// Read access to the commerce + storefront endpoints used by the store,
/// category, brand and product-detail screens. Uses an injectable client so
/// the network layer can be mocked in tests.
class CommerceService {
  static http.Client client = http.Client();

  static dynamic _decode(http.Response res, String what) {
    if (res.statusCode != 200) {
      throw Exception('Failed to load $what (${res.statusCode})');
    }
    return json.decode(utf8.decode(res.bodyBytes));
  }

  static List<dynamic> _asList(dynamic decoded) {
    if (decoded is List) return decoded;
    if (decoded is Map && decoded['results'] is List) return decoded['results'] as List;
    return const [];
  }

  static Future<List<dynamic>> categories() async {
    final res = await client.get(Uri.parse('${Config.apiBaseUrl}/commerce/categories'));
    return _asList(_decode(res, 'categories'));
  }

  static Future<List<dynamic>> products() async {
    final res = await client.get(Uri.parse('${Config.apiBaseUrl}/commerce/products'));
    return _asList(_decode(res, 'products'));
  }

  static Future<List<dynamic>> brands() async {
    final res = await client.get(Uri.parse('${Config.apiBaseUrl}/commerce/brands'));
    return _asList(_decode(res, 'brands'));
  }

  static Future<List<dynamic>> banners() async {
    final res = await client.get(Uri.parse('${Config.apiBaseUrl}/banners'));
    return _asList(_decode(res, 'banners'));
  }

  static Future<Map<String, dynamic>> productDetail(int productId) async {
    final res = await client.get(Uri.parse('${Config.apiBaseUrl}/commerce/products/$productId'));
    final decoded = _decode(res, 'product');
    return Map<String, dynamic>.from(decoded as Map);
  }

  static Future<List<dynamic>> reviews(int productId) async {
    final res = await client.get(Uri.parse('${Config.apiBaseUrl}/commerce/products/$productId/reviews'));
    return _asList(_decode(res, 'reviews'));
  }
}
