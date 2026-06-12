import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';

/// Blog / news content. The backend exposes `/api/blogs` (paginated as
/// `{count, results, page, page_size}`) and `/api/blogs/{id}`.
class BlogService {
  static http.Client client = http.Client();

  static Future<List<dynamic>> list({int page = 1, int pageSize = 20}) async {
    final uri = Uri.parse('${Config.apiBaseUrl}/blogs').replace(queryParameters: {
      'page': '$page',
      'page_size': '$pageSize',
    });
    final res = await client.get(uri);
    if (res.statusCode != 200) {
      throw Exception('Failed to load blogs (${res.statusCode})');
    }
    final decoded = json.decode(utf8.decode(res.bodyBytes));
    if (decoded is List) return decoded;
    if (decoded is Map && decoded['results'] is List) return decoded['results'] as List;
    return const [];
  }

  static Future<Map<String, dynamic>> detail(int blogId) async {
    final res = await client.get(Uri.parse('${Config.apiBaseUrl}/blogs/$blogId'));
    if (res.statusCode != 200) {
      throw Exception('Failed to load blog (${res.statusCode})');
    }
    return Map<String, dynamic>.from(json.decode(utf8.decode(res.bodyBytes)) as Map);
  }
}
