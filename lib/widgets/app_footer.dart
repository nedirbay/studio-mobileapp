import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AppFooter extends StatelessWidget {
  const AppFooter({super.key});

  Future<void> _makeCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber.replaceAll(RegExp(r'[\s-]'), ''),
    );
    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      }
    } catch (e) {
      debugPrint('Could not launch $launchUri');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFF3F4F6), width: 1))
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Brand Section
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.camera_alt_rounded, color: Colors.black, size: 24),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Doganlar',
                    style: TextStyle(
                      fontSize: 20,
                    fontWeight: FontWeight.w900,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    'FOTO MERKEZI',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFEF4444),
                      letterSpacing: 2.0,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Doganlar foto merkezi Mary şäherinde ýerleşip, foto söýüjiler we professional fotograflar üçin ähli amatlyklary döredýär.',
            style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 13, height: 1.6),
          ),
          const SizedBox(height: 32),
          
          _buildSectionTitle('Biz bilen habarlaşyň'),
          _buildContactItem(Icons.location_on_rounded, 'Mary şäheri, Mollanepes kelte köçesi'),
          
          // Split phone numbers to make them individually clickable
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.phone_rounded, color: Color(0xFFEF4444), size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: () => _makeCall('+993 64 30-12-57'),
                        child: const Text(
                          '+993 64 30-12-57',
                          style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 13, height: 1.4),
                        ),
                      ),
                      InkWell(
                        onTap: () => _makeCall('+993 61 24-69-37'),
                        child: const Text(
                          '+993 61 24-69-37',
                          style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 13, height: 1.4),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          _buildContactItem(Icons.email_rounded, 'doganlarfoto@gmail.com'),
          _buildContactItem(Icons.access_time_filled_rounded, 'Iş wagty: 8:00 – 19:00'),
          
          const SizedBox(height: 32),
          const Divider(color: Color(0xFF374151), thickness: 1),
          const SizedBox(height: 16),
          
          Text(
            '© ${DateTime.now().year} Doganlar foto merkezi.\nÄhli hukuklar goralan.',
            style: TextStyle(color: Colors.black.withValues(alpha: 0.4), fontSize: 11, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: Colors.black,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFFEF4444), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 13, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
