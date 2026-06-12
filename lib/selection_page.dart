import 'package:flutter/material.dart';
import 'commerce/store_page.dart';
import 'photostudio/photostudio_page.dart';
import 'promotions/promotions_page.dart';
import 'widgets/top_bar.dart';
import 'identity/profile_page.dart';

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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Hoş geldiňiz!',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF111827),
                            letterSpacing: -0.5,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.person_outline, size: 28),
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfilePage()));
                          },
                        ),
                      ],
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
                      backgroundColor: Colors.white,
                      borderColor: const Color(0xFFF3F4F6),
                      iconData: Icons.print_outlined,
                      iconColor: Colors.black,
                      arrowColor: Colors.black,
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
                      backgroundColor: Colors.white,
                      borderColor: const Color(0xFFF3F4F6),
                      iconData: Icons.camera,
                      iconColor: Colors.black,
                      arrowColor: Colors.black,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const PhotoStudioPage()),
                        );
                      },
                    ),

                    const SizedBox(height: 20),

                    // Aksiýalar we sowgatlar card
                    SelectionCard(
                      title: 'Aksiýalar we Sowgatlar',
                      subtitle: 'Açyk bäsleşiklere we aksiýalara gatnaşyp,\nsowgatlary gazanyň.',
                      backgroundColor: Colors.white,
                      borderColor: const Color(0xFFF3F4F6),
                      iconData: Icons.card_giftcard_outlined,
                      iconColor: const Color(0xFFDC2626),
                      arrowColor: Colors.black,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const PromotionsPage()),
                        );
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
  final Color borderColor;
  final IconData iconData;
  final Color iconColor;
  final Color arrowColor;
  final VoidCallback onTap;

  const SelectionCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.backgroundColor,
    required this.borderColor,
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
          border: Border.all(color: borderColor, width: 2),
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
                  decoration: const BoxDecoration(
                    color: Color(0xFFF3F4F6),
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
