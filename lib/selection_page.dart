import 'package:flutter/material.dart';
import 'store_page.dart';
import 'widgets/top_bar.dart';

class SelectionPage extends StatelessWidget {
  const SelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const TopBar(),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    const Text(
                      'Hoş geldiňiz!',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111827),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Näme gözleýärsiniz?',
                      style: TextStyle(
                        fontSize: 18,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(height: 40),
                    
                    // Harytlar bolumi card
                    SelectionCard(
                      title: 'Harytlar bölümi',
                      subtitle: 'Fotoapparatlar, kameralar, printerler we ş.m.',
                      backgroundColor: const Color(0xFFF3F4F6),
                      iconData: Icons.print_outlined,
                      iconColor: const Color(0xFF9CA3AF),
                      arrowColor: const Color(0xFF4B5563),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const StorePage()),
                        );
                      },
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Foto studio card
                    SelectionCard(
                      title: 'Foto studio',
                      subtitle: 'Surat we video hyzmatlary.\nToýlar, belli günler we beýleki hyzmatlar.',
                      backgroundColor: const Color(0xFFFFEADD),
                      iconData: Icons.camera,
                      iconColor: const Color(0xFFE89A6A),
                      arrowColor: const Color(0xFFEA580C),
                      onTap: () {
                        // Navigate to Foto Studio
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SelectionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color backgroundColor;
  final IconData iconData;
  final Color iconColor;
  final Color arrowColor;
  final VoidCallback onTap;

  const SelectionCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.backgroundColor,
    required this.iconData,
    required this.iconColor,
    required this.arrowColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 160,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Stack(
          children: [
            // Left icon placeholder (replaces the images in the mockup for now)
            Positioned(
              left: 24,
              top: 0,
              bottom: 0,
              child: Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    iconData,
                    size: 40,
                    color: iconColor,
                  ),
                ),
              ),
            ),
            
            // Right content
            Positioned(
              left: 124,
              top: 36,
              right: 24,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF4B5563),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            
            // Bottom right arrow
            Positioned(
              bottom: 24,
              right: 24,
              child: Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: arrowColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
