import 'package:flutter/material.dart';
import '../services/settings_service.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = SettingsService();
    final isDark = settings.isDarkMode;
    final primaryRed = const Color(0xFFDC2626);
    final cardBg = isDark ? const Color(0xFF1F2937) : Colors.white;
    final borderColor = isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF111827) : const Color(0xFFF9FAFB),
      body: CustomScrollView(
        slivers: [
          // Custom Header image with back button
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            stretch: true,
            backgroundColor: isDark ? const Color(0xFF111827) : Colors.white,
            foregroundColor: isDark ? Colors.white : Colors.black,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                settings.translate('about_us'),
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                  fontWeight: FontWeight.w900,
                  shadows: [
                    if (!isDark)
                      const Shadow(
                        color: Colors.white,
                        blurRadius: 10,
                      ),
                  ],
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'assets/images/doganlar.png',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: isDark ? const Color(0xFF1F2937) : Colors.grey[300],
                      child: Icon(
                        Icons.camera_alt_outlined,
                        color: isDark ? Colors.white24 : Colors.black26,
                        size: 64,
                      ),
                    ),
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          isDark ? const Color(0xFF111827).withOpacity(0.9) : const Color(0xFFF9FAFB).withOpacity(0.9),
                          isDark ? const Color(0xFF111827) : const Color(0xFFF9FAFB),
                        ],
                        stops: const [0.3, 0.85, 1.0],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Hero Tagline Badge & Description
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: borderColor, width: 1.5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: primaryRed.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(50),
                          border: Border.all(color: primaryRed.withOpacity(0.2)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.camera_rounded, color: primaryRed, size: 14),
                            const SizedBox(width: 6),
                            Text(
                              settings.translate('about_hero_tagline').toUpperCase(),
                              style: TextStyle(
                                color: primaryRed,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'DOGANLAR FOTO MERKEZI',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: isDark ? Colors.white : const Color(0xFF111827),
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        settings.translate('about_hero_desc'),
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.5,
                          color: isDark ? Colors.grey[300] : const Color(0xFF4B5563),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Core Services Title
                Text(
                  settings.translate('about_services_title'),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : const Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 16),

                // Core Services List
                _buildServiceCard(
                  icon: Icons.camera_alt_outlined,
                  iconColor: primaryRed,
                  title: settings.translate('about_service1_title'),
                  description: settings.translate('about_service1_desc'),
                  cardBg: cardBg,
                  borderColor: borderColor,
                  isDark: isDark,
                ),
                const SizedBox(height: 12),
                _buildServiceCard(
                  icon: Icons.videocam_outlined,
                  iconColor: Colors.blue,
                  title: settings.translate('about_service2_title'),
                  description: settings.translate('about_service2_desc'),
                  cardBg: cardBg,
                  borderColor: borderColor,
                  isDark: isDark,
                ),
                const SizedBox(height: 12),
                _buildServiceCard(
                  icon: Icons.photo_library_outlined,
                  iconColor: Colors.green,
                  title: settings.translate('about_service3_title'),
                  description: settings.translate('about_service3_desc'),
                  cardBg: cardBg,
                  borderColor: borderColor,
                  isDark: isDark,
                ),
                const SizedBox(height: 28),

                // Detailed Biz barada has giňişleýin Section
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: borderColor, width: 1.5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            settings.translate('about_details_title'),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: isDark ? Colors.white : const Color(0xFF111827),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: primaryRed,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              children: [
                                const Text(
                                  '10+',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  settings.translate('about_experience_badge').toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 6,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildInfoItem(
                        icon: Icons.location_on_outlined,
                        label: settings.translate('about_address_label'),
                        value: settings.translate('about_address_val'),
                        isDark: isDark,
                      ),
                      const Divider(height: 24, thickness: 1),
                      _buildInfoItem(
                        icon: Icons.phone_outlined,
                        label: settings.translate('about_contact_label'),
                        value: '+993 64 30-12-57\n+993 61 24-69-37',
                        isDark: isDark,
                      ),
                      const Divider(height: 24, thickness: 1),
                      _buildInfoItem(
                        icon: Icons.email_outlined,
                        label: settings.translate('about_email_label'),
                        value: 'doganlarfotomerkez@gmail.com',
                        isDark: isDark,
                      ),
                      const Divider(height: 24, thickness: 1),
                      _buildInfoItem(
                        icon: Icons.access_time_outlined,
                        label: settings.translate('about_work_hours_label'),
                        value: settings.translate('about_work_hours_val'),
                        isDark: isDark,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // Why choose us Title
                Text(
                  settings.translate('about_why_choose_us'),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : const Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 16),

                // Why choose us Cards (Grid simulated with Rows)
                Row(
                  children: [
                    Expanded(
                      child: _buildWhyCard(
                        icon: Icons.star_rounded,
                        title: settings.translate('about_why1_title'),
                        desc: settings.translate('about_why1_desc'),
                        cardBg: cardBg,
                        borderColor: borderColor,
                        isDark: isDark,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildWhyCard(
                        icon: Icons.emoji_events_rounded,
                        title: settings.translate('about_why2_title'),
                        desc: settings.translate('about_why2_desc'),
                        cardBg: cardBg,
                        borderColor: borderColor,
                        isDark: isDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildWhyCard(
                        icon: Icons.check_circle_rounded,
                        title: settings.translate('about_why3_title'),
                        desc: settings.translate('about_why3_desc'),
                        cardBg: cardBg,
                        borderColor: borderColor,
                        isDark: isDark,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildWhyCard(
                        icon: Icons.chat_bubble_rounded,
                        title: settings.translate('about_why4_title'),
                        desc: settings.translate('about_why4_desc'),
                        cardBg: cardBg,
                        borderColor: borderColor,
                        isDark: isDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
    required Color cardBg,
    required Color borderColor,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    color: isDark ? Colors.grey[400] : const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
    required bool isDark,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color(0xFFDC2626), size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF9CA3AF),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF111827),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildWhyCard({
    required IconData icon,
    required String title,
    required String desc,
    required Color cardBg,
    required Color borderColor,
    required bool isDark,
  }) {
    return Container(
      height: 165,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFFDC2626), size: 28),
          const SizedBox(height: 10),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: Text(
              desc,
              style: TextStyle(
                fontSize: 12,
                height: 1.3,
                color: isDark ? Colors.grey[400] : const Color(0xFF6B7280),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
