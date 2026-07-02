import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../services/settings_service.dart';

class AppHeader extends StatelessWidget {
  const AppHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: SettingsService(),
      builder: (context, _) {
        final settings = SettingsService();
        final isDark = settings.isDarkMode;
        final bgColor = isDark ? const Color(0xFF111827) : Colors.white;
        final strokeColor = isDark ? Colors.white : const Color(0xFF111827);
        final textColor = isDark ? Colors.white : const Color(0xFF111827);

        return Container(
          decoration: BoxDecoration(
            color: bgColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
          width: double.infinity,
          child: GestureDetector(
            onTap: () => Navigator.popUntil(context, (route) => route.isFirst),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CustomPaint(
                  size: const Size(72, 48),
                  painter: CameraLogoPainter(strokeColor: strokeColor),
                ),
                const SizedBox(width: 6),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'DOGANLAR',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: textColor,
                        letterSpacing: 1.0,
                        height: 0.95,
                      ),
                    ),
                    const SizedBox(height: 0),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 20,
                          height: 1.5,
                          color: const Color(0xFFDC2626),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'FOTO • MERKEZI',
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFDC2626),
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          width: 20,
                          height: 1.5,
                          color: const Color(0xFFDC2626),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class CameraLogoPainter extends CustomPainter {
  final Color strokeColor;

  CameraLogoPainter({required this.strokeColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Shutter button on top left
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(14, 7, 8, 4),
        const Radius.circular(1),
      ),
      paint,
    );

    // Camera body outline
    final path = Path()
      ..moveTo(14, 41)
      ..quadraticBezierTo(10, 41, 10, 37)
      ..lineTo(10, 17)
      ..quadraticBezierTo(10, 13, 14, 13)
      ..lineTo(21, 13)
      ..quadraticBezierTo(25, 13, 27, 8)
      ..lineTo(45, 8)
      ..quadraticBezierTo(47, 13, 51, 13)
      ..lineTo(58, 13)
      ..quadraticBezierTo(62, 13, 62, 17)
      ..lineTo(62, 37)
      ..quadraticBezierTo(62, 41, 58, 41)
      ..close();

    canvas.drawPath(path, paint);

    // Center lens circle (outer ring)
    final center = const Offset(36, 26);
    canvas.drawCircle(center, 13, paint);

    // Draw aperture blades inside the lens
    final bladePaint = Paint()..style = PaintingStyle.fill;
    const double R = 11.5; // outer radius
    const double r = 4.5;  // inner hole radius
    
    final colors = [
      const Color(0xFFDC2626), // Top (Red)
      const Color(0xFF4B5563), // Top-Right (Grey)
      const Color(0xFFDC2626), // Bottom-Right (Red)
      const Color(0xFF1F2937), // Bottom (Dark Grey)
      const Color(0xFF111827), // Bottom-Left (Black)
      const Color(0xFF111827), // Top-Left (Black)
    ];

    // 6 blades
    for (int i = 0; i < 6; i++) {
      final double angle1 = i * math.pi / 3;
      final double angle2 = (i + 1) * math.pi / 3;
      final double innerAngle = angle2 + math.pi / 6;

      final p1 = Offset(center.dx + R * math.cos(angle1), center.dy + R * math.sin(angle1));
      final p2 = Offset(center.dx + R * math.cos(angle2), center.dy + R * math.sin(angle2));
      final p3 = Offset(center.dx + r * math.cos(innerAngle), center.dy + r * math.sin(innerAngle));

      final bladePath = Path()
        ..moveTo(p1.dx, p1.dy)
        ..lineTo(p2.dx, p2.dy)
        ..lineTo(p3.dx, p3.dy)
        ..close();

      bladePaint.color = colors[i];
      canvas.drawPath(bladePath, bladePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CameraLogoPainter oldDelegate) =>
      oldDelegate.strokeColor != strokeColor;
}
