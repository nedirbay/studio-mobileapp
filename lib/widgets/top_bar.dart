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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF111827) : const Color(0xFFF9FAFB);
    final textColor = isDark ? Colors.grey[400]! : const Color(0xFF6B7280);

    return Container(
      color: bgColor,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          _buildPhoneItem('+993 64 30-12-57', textColor),
          const SizedBox(width: 12),
          _buildPhoneItem('+993 61 24-69-37', textColor),
          const Spacer(),
          InkWell(
            onTap: () => _sendEmail('doganlarfoto@gmail.com'),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.email_outlined, size: 12, color: textColor),
                const SizedBox(width: 4),
                Text(
                  'doganlarfoto@gmail.com',
                  style: TextStyle(color: textColor, fontSize: 10, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneItem(String phoneNumber, Color textColor) {
    return InkWell(
      onTap: () => _makeCall(phoneNumber),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.phone, size: 12, color: textColor),
          const SizedBox(width: 4),
          Text(
            phoneNumber,
            style: TextStyle(
              color: textColor, 
              fontSize: 10, 
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
