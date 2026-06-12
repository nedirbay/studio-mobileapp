import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';
import '../models/campaign.dart';

/// Talks to the `gifts/campaigns/` backend. Mobile mirror of the web
/// project's giftsService / GiftsRepository.
class PromotionsService {
  /// HTTP client used for requests. Overridable in tests (e.g. MockClient).
  static http.Client client = http.Client();

  static List<Campaign> _parseList(http.Response res) {
    final decoded = json.decode(utf8.decode(res.bodyBytes));
    final List raw = decoded is List ? decoded : (decoded['results'] ?? []);
    return raw
        .whereType<Map>()
        .map((e) => Campaign.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  /// Fetches campaigns. By default only active ones are requested so the
  /// Promotions section shows currently-running campaigns.
  static Future<List<Campaign>> listCampaigns({
    String? type,
    String status = 'active',
  }) async {
    final params = <String, String>{};
    if (type != null && type.isNotEmpty) params['type'] = type;
    if (status.isNotEmpty) params['status'] = status;

    final uri = Uri.parse('${Config.apiBaseUrl}/gifts/campaigns/')
        .replace(queryParameters: params.isEmpty ? null : params);

    final res = await client.get(uri);
    if (res.statusCode != 200) {
      throw Exception('Failed to load campaigns (${res.statusCode})');
    }
    return _parseList(res);
  }

  static Future<List<Campaign>> featured() async {
    final res =
        await client.get(Uri.parse('${Config.apiBaseUrl}/gifts/campaigns/featured/'));
    if (res.statusCode != 200) {
      throw Exception('Failed to load featured campaigns (${res.statusCode})');
    }
    return _parseList(res);
  }

  /// Joins/participates in a campaign.
  static Future<void> join(
    int campaignId, {
    required String fullName,
    required String phone,
    String? email,
    String? note,
  }) async {
    final res = await client.post(
      Uri.parse('${Config.apiBaseUrl}/gifts/campaigns/$campaignId/join/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'full_name': fullName,
        'phone': phone,
        if (email != null && email.isNotEmpty) 'email': email,
        if (note != null && note.isNotEmpty) 'note': note,
      }),
    );
    if (res.statusCode < 200 || res.statusCode >= 300) {
      String message = 'Gatnaşmak başartmady';
      try {
        final body = json.decode(utf8.decode(res.bodyBytes));
        if (body is Map && body['detail'] != null) message = body['detail'].toString();
      } catch (_) {}
      throw Exception(message);
    }
  }
}
