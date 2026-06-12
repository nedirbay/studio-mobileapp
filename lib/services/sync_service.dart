import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../config.dart';
import 'notification_service.dart';

class SyncService {
  static Future<void> checkForUpdates() async {
    // Check for new products
    await _checkNewItems(
      apiUrl: '${Config.apiBaseUrl}/commerce/products',
      prefsKey: 'last_product_count',
      notifId: 101,
      notifTitle: 'Täze haryt!',
      notifBody: 'Söwdada täze harytlar bar. Göz aýlap görüň!',
    );

    // Check for new media in Photo Studio (videos gallery)
    await _checkNewItems(
      apiUrl: '${Config.apiBaseUrl}/photostudio/videos/',
      prefsKey: 'last_studio_media_count',
      notifId: 102,
      notifTitle: 'Täze foto studio mazmuny!',
      notifBody: 'Foto studio täze wideo goşdy. Görüp bilersiňiz!',
    );
  }

  /// Extracts an item count from either a plain list response or a paginated
  /// DRF response (`{count, results}` / `{count, ...}`).
  static int _countFrom(dynamic decoded) {
    if (decoded is List) return decoded.length;
    if (decoded is Map) {
      if (decoded['count'] is int) return decoded['count'] as int;
      if (decoded['results'] is List) return (decoded['results'] as List).length;
    }
    return 0;
  }

  static Future<void> _checkNewItems({
    required String apiUrl,
    required String prefsKey,
    required int notifId,
    required String notifTitle,
    required String notifBody,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final response = await http.get(Uri.parse(apiUrl));
      
      if (response.statusCode == 200) {
        final decoded = json.decode(utf8.decode(response.bodyBytes));
        final int currentCount = _countFrom(decoded);
        final int lastCount = prefs.getInt(prefsKey) ?? currentCount;

        if (currentCount > lastCount) {
          await NotificationService.showNotification(
            id: notifId,
            title: notifTitle,
            body: notifBody,
          );
        }
        
        // Update last known count
        await prefs.setInt(prefsKey, currentCount);
      }
    } catch (e) {
      debugPrint('Sync Error ($prefsKey): $e');
    }
  }
}
