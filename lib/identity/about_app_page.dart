import 'package:flutter/material.dart';
import '../services/settings_service.dart';
import 'privacy_policy_page.dart';

class AboutAppPage extends StatelessWidget {
  const AboutAppPage({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = SettingsService();
    final isDark = settings.isDarkMode;
    final bgColor = isDark ? const Color(0xFF111827) : const Color(0xFFF9FAFB);
    final cardColor = isDark ? const Color(0xFF1F2937) : Colors.white;
    final borderColor = isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6);
    final titleColor = isDark ? Colors.white : const Color(0xFF111827);
    final bodyColor = isDark ? const Color(0xFFD1D5DB) : const Color(0xFF4B5563);

    String appName = 'Doganlar Foto Merkezi';
    
    // Multi-language descriptions
    String appDesc = '';
    if (settings.languageCode == 'TM') {
      appDesc = 'Bu programma kömegi bilen siz harytlary aňsatlyk bilen sargyt edip, foto studio hyzmatlaryna ýazylyp we aksiýalara gatnaşyp bilersiňiz.';
    } else if (settings.languageCode == 'RU') {
      appDesc = 'С помощью этого приложения вы можете легко заказывать товары, записываться на услуги фотостудии и участвовать в акциях.';
    } else {
      appDesc = 'With this app, you can easily order products, book photo studio services, and participate in promotions.';
    }

    String developerLabel = settings.languageCode == 'TM' ? 'Dörediji' : (settings.languageCode == 'RU' ? 'Разработчик' : 'Developer');
    String versionLabel = settings.languageCode == 'TM' ? 'Wersiýa' : (settings.languageCode == 'RU' ? 'Версия' : 'Version');
    String privacyLabel = settings.languageCode == 'TM' ? 'Gizlinlik syýasaty' : (settings.languageCode == 'RU' ? 'Политика конфиденциальности' : 'Privacy Policy');

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF111827) : Colors.white,
        foregroundColor: titleColor,
        elevation: 0,
        title: Text(
          settings.translate('about_app'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 16),
            // Logo / Icon
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFFDC2626),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFDC2626).withOpacity(0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.camera_roll_rounded,
                color: Colors.white,
                size: 50,
              ),
            ),
            const SizedBox(height: 24),
            // App Name
            Text(
              appName,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: titleColor,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            // App Version Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'v1.0.0',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.grey[300] : const Color(0xFF4B5563),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Description Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: borderColor, width: 1.5),
              ),
              child: Text(
                appDesc,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.6,
                  color: bodyColor,
                ),
              ),
            ),
            const SizedBox(height: 20),
            // App Specs Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: borderColor, width: 1.5),
              ),
              child: Column(
                children: [
                  _buildSpecRow(developerLabel, 'Doganlar Foto Merkezi', titleColor, bodyColor),
                  const Divider(height: 24),
                  _buildSpecRow(versionLabel, '1.0.0 (Build 1)', titleColor, bodyColor),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Privacy Policy Action Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const PrivacyPolicyPage()),
                  );
                },
                icon: const Icon(Icons.security_rounded, size: 20),
                label: Text(
                  privacyLabel,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? Colors.white : Colors.black,
                  foregroundColor: isDark ? Colors.black : Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecRow(String label, String value, Color labelColor, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: labelColor,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
