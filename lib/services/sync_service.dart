import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config.dart';
import 'notification_service.dart';

class SyncService {
  static Future<void> checkForUpdates() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Check for new products
    await _checkNewItems(
      apiUrl: '${Config.apiBaseUrl}/commerce/products',
      prefsKey: 'last_product_count',
      notifId: 101,
      notifTitle: 'Täze haryt!',
      notifBody: 'Söwdada täze harytlar bar. Göz aýlap görüň!',
    );

    // Check for new blogs in Photo Studio
    await _checkNewItems(
      apiUrl: '${Config.apiBaseUrl}/photostudio/blogs/',
      prefsKey: 'last_blog_count',
      notifId: 102,
      notifTitle: 'Täze blog ýazgysy!',
      notifBody: 'Foto studio täze portfoliýa goşdy. Görüp bilersiňiz!',
    );
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
        final List items = json.decode(utf8.decode(response.bodyBytes));
        final int currentCount = items.length;
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
      print('Sync Error ($prefsKey): $e');
    }
  }
}
