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
      color: const Color(0xFF111827),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          _buildPhoneItem('+993 64 30-12-57'),
          const SizedBox(width: 12),
          _buildPhoneItem('+993 61 24-69-37'),
          const Spacer(),
          const Icon(Icons.email_outlined, size: 12, color: Color(0xFFD1D5DB)),
          const SizedBox(width: 4),
          const Text(
            'doganlarfoto@gmail.com',
            style: TextStyle(color: Color(0xFFD1D5DB), fontSize: 10, fontWeight: FontWeight.w500),
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
          const Icon(Icons.phone, size: 12, color: Color(0xFFD1D5DB)),
          const SizedBox(width: 4),
          Text(
            phoneNumber,
            style: const TextStyle(
              color: Color(0xFFD1D5DB), 
              fontSize: 10, 
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
