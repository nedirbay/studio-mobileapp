import 'package:flutter/material.dart';
import 'commerce/harytlar_main_page.dart';
import 'photostudio/studio_main_page.dart';
import 'promotions/sowgatlar_main_page.dart';
import 'widgets/top_bar.dart';
import 'identity/profile_page.dart';
import 'services/settings_service.dart';

class SelectionPage extends StatelessWidget {
  const SelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: SettingsService(),
      builder: (context, _) {
        final settings = SettingsService();
        final isDark = settings.isDarkMode;

        return Scaffold(
          backgroundColor: isDark ? const Color(0xFF111827) : const Color(0xFFF9FAFB),
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
                            Text(
                              settings.translate('welcome'),
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : const Color(0xFF111827),
                                letterSpacing: -0.5,
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.person_outline,
                                size: 28,
                                color: isDark ? Colors.white70 : Colors.black,
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const ProfilePage()),
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          settings.translate('what_looking_for'),
                          style: TextStyle(
                              fontSize: 18,
                              color: isDark ? Colors.grey[400] : const Color(0xFF6B7280),
                          ),
                        ),
                        const SizedBox(height: 40),

                        // Harytlar bolumi card
                        SelectionCard(
                          title: settings.translate('products_card_title'),
                          subtitle: settings.translate('products_card_subtitle'),
                          backgroundColor: isDark ? const Color(0xFF1F2937) : Colors.white,
                          borderColor: isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6),
                          iconData: Icons.print_outlined,
                          iconColor: isDark ? Colors.white70 : Colors.black,
                          arrowColor: isDark ? Colors.white70 : Colors.black,
                          isDark: isDark,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const HarytlarMainPage()),
                            );
                          },
                        ),

                        const SizedBox(height: 20),

                        // Foto studio card
                        SelectionCard(
                          title: settings.translate('studio_card_title'),
                          subtitle: settings.translate('studio_card_subtitle'),
                          backgroundColor: isDark ? const Color(0xFF1F2937) : Colors.white,
                          borderColor: isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6),
                          iconData: Icons.camera,
                          iconColor: isDark ? Colors.white70 : Colors.black,
                          arrowColor: isDark ? Colors.white70 : Colors.black,
                          isDark: isDark,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const StudioMainPage()),
                            );
                          },
                        ),

                        const SizedBox(height: 20),

                        // Aksiýalar we sowgatlar card
                        SelectionCard(
                          title: settings.translate('promo_card_title'),
                          subtitle: settings.translate('promo_card_subtitle'),
                          backgroundColor: isDark ? const Color(0xFF1F2937) : Colors.white,
                          borderColor: isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6),
                          iconData: Icons.card_giftcard_outlined,
                          iconColor: const Color(0xFFDC2626),
                          arrowColor: isDark ? Colors.white70 : Colors.black,
                          isDark: isDark,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const SowgatlarMainPage()),
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
      },
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
  final bool isDark;
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
    required this.isDark,
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
          border: Border.all(color: borderColor, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Left icon placeholder
            Positioned(
              left: 24,
              top: 0,
              bottom: 0,
              child: Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF111827) : const Color(0xFFF3F4F6),
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
              top: 32,
              right: 24,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : const Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.grey[450] ?? Colors.grey[400] : const Color(0xFF4B5563),
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
