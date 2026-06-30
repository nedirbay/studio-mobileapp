import 'package:flutter/material.dart';

class AppHeader extends StatelessWidget {
  const AppHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 20),
      width: double.infinity,
      child: GestureDetector(
        onTap: () => Navigator.popUntil(context, (route) => route.isFirst),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Doganlar',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: Color(0xFF111827),
                letterSpacing: -1.0,
                height: 1.0,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'FOTO MERKEZI',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Color(0xFFDC2626),
                letterSpacing: 4.0,
                height: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
