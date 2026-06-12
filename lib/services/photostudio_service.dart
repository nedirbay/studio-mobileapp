import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';
import '../models/studio_media.dart';

/// Photo-studio media gallery. The backend exposes paginated `videos/` and
/// `images/` endpoints (DRF `{count, next, previous, results}`).
class PhotoStudioService {
  static http.Client client = http.Client();

  static List<Map<String, dynamic>> _rawResults(http.Response res, String what) {
    if (res.statusCode != 200) {
      throw Exception('Failed to load $what (${res.statusCode})');
    }
    final decoded = json.decode(utf8.decode(res.bodyBytes));
    final List raw = decoded is List ? decoded : (decoded['results'] ?? []);
    return raw.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
  }

  static Future<List<StudioMedia>> videos({String? search}) async {
    final uri = Uri.parse('${Config.apiBaseUrl}/photostudio/videos/').replace(
      queryParameters: (search != null && search.isNotEmpty) ? {'search': search} : null,
    );
    final res = await client.get(uri);
    return _rawResults(res, 'videos').map(StudioMedia.fromVideoJson).toList();
  }

  static Future<List<StudioMedia>> images({String? search}) async {
    final uri = Uri.parse('${Config.apiBaseUrl}/photostudio/images/').replace(
      queryParameters: (search != null && search.isNotEmpty) ? {'search': search} : null,
    );
    final res = await client.get(uri);
    return _rawResults(res, 'images').map(StudioMedia.fromImageJson).toList();
  }

  /// Convenience: all gallery media (videos first, then images).
  static Future<List<StudioMedia>> gallery() async {
    final results = await Future.wait([videos(), images()]);
    return [...results[0], ...results[1]];
  }
}
