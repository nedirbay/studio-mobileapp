import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class TopBar extends StatelessWidget {
  const TopBar({super.key});

  Future<void> _makeCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber.replaceAll(RegExp(r'[\s-]'), ''),
    );
    try {
      await launchUrl(launchUri);
    } catch (e) {
      debugPrint('Could not launch $launchUri: $e');
    }
  }

  Future<void> _sendEmail(String emailAddress) async {
    final Uri launchUri = Uri(
      scheme: 'mailto',
      path: emailAddress,
    );
    try {
      await launchUrl(launchUri);
    } catch (e) {
      debugPrint('Could not launch $launchUri: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF9FAFB),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          _buildPhoneItem('+993 64 30-12-57'),
          const SizedBox(width: 12),
          _buildPhoneItem('+993 61 24-69-37'),
          const Spacer(),
          InkWell(
            onTap: () => _sendEmail('doganlarfoto@gmail.com'),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.email_outlined, size: 12, color: Color(0xFF6B7280)),
                SizedBox(width: 4),
                Text(
                  'doganlarfoto@gmail.com',
                  style: TextStyle(color: Color(0xFF6B7280), fontSize: 10, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneItem(String phoneNumber) {
    return InkWell(
      onTap: () => _makeCall(phoneNumber),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.phone, size: 12, color: Color(0xFF6B7280)),
          const SizedBox(width: 4),
          Text(
            phoneNumber,
            style: const TextStyle(
              color: Color(0xFF6B7280), 
              fontSize: 10, 
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
