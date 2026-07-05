import 'package:flutter/material.dart';
import '../services/admin_service.dart';
import '../identity/profile_page.dart';

// Import Admin screens
import 'admin_products_page.dart';
import 'admin_categories_page.dart';
import 'admin_brands_page.dart';
import 'admin_orders_page.dart';
import 'admin_reviews_page.dart';
import 'admin_studio_orders_page.dart';
import 'admin_photostudio_page.dart';
import 'admin_studio_catalogs_page.dart';
import 'admin_banners_page.dart';
import 'admin_gifts_page.dart';
import 'admin_blogs_page.dart';
import 'admin_messages_page.dart';
import 'admin_users_page.dart';
import 'admin_currencies_page.dart';
import 'admin_mobile_apps_page.dart';
import 'admin_logs_page.dart';

import 'dart:async';
import '../services/admin_ws_service.dart';

class AdminMainLayoutPage extends StatefulWidget {
  const AdminMainLayoutPage({super.key});

  @override
  State<AdminMainLayoutPage> createState() => _AdminMainLayoutPageState();
}

class _AdminMainLayoutPageState extends State<AdminMainLayoutPage> {
  int _currentIndex = 0;
  StreamSubscription? _wsSubscription;

  @override
  void initState() {
    super.initState();
    AdminWsService.instance.connect();
    _wsSubscription = AdminWsService.instance.stream.listen((event) {
      if (event.type == AdminWsEventType.messageCreated) {
        final message = event.data['message'] ?? {};
        final sender = message['username'] ?? 'Myhman';
        final subject = message['subject'] ?? '';
        final content = message['message'] ?? '';
        final String previewText = subject.isNotEmpty
            ? subject
            : (content.length > 50 ? '${content.substring(0, 50)}...' : content);

        if (mounted) {
          // Clear any current snackbars first
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.mail_outline, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Täze sorag geldi ($sender):',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        Text(
                          previewText,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.orange[800],
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 6),
              action: SnackBarAction(
                label: 'Oka',
                textColor: Colors.white,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AdminMessagesPage()),
                  );
                },
              ),
            ),
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _wsSubscription?.cancel();
    AdminWsService.instance.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      const AdminUmumyTab(),
      const AdminFotoMerkezTab(),
      const AdminFotoStudioTab(),
    ];

    final List<String> titles = [
      'Umumy Dolandyryş',
      'Foto Merkez',
      'Foto Studio',
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          titles[_currentIndex],
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 22, letterSpacing: -0.5),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_pin, size: 28),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfilePage()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFFDC2626),
          unselectedItemColor: const Color(0xFF9CA3AF),
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontSize: 11),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard_rounded),
              label: 'Umumy',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.storefront_outlined),
              activeIcon: Icon(Icons.storefront_rounded),
              label: 'Foto merkez',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.camera_alt_outlined),
              activeIcon: Icon(Icons.camera_alt_rounded),
              label: 'Foto studio',
            ),
          ],
        ),
      ),
    );
  }
}

// --- TAB 1: UMUMY (Dashboard + System Options) ---
class AdminUmumyTab extends StatefulWidget {
  const AdminUmumyTab({super.key});

  @override
  State<AdminUmumyTab> createState() => _AdminUmumyTabState();
}

class _AdminUmumyTabState extends State<AdminUmumyTab> {
  bool _isLoading = true;
  Map<String, dynamic> _stats = {};
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final stats = await AdminService.fetchDashboardStats();
      setState(() {
        _stats = stats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFFDC2626)));
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded, size: 48, color: Color(0xFFDC2626)),
              const SizedBox(height: 16),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Color(0xFF4B5563)),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loadStats,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white),
                child: const Text('Gaýtadan synanyş'),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadStats,
      color: const Color(0xFFDC2626),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatsGrid(),
            const SizedBox(height: 24),
            _buildSectionTitle('Ulgam sazlamalary & Loglar'),
            const SizedBox(height: 12),
            _buildSystemGrid(),
            const SizedBox(height: 24),
            _buildRecentProducts(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w900,
        color: Color(0xFF111827),
        letterSpacing: -0.2,
      ),
    );
  }

  Widget _buildStatsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(
          'Haryt Sany',
          _stats['totalProducts']?.toString() ?? '0',
          Icons.inventory_2_outlined,
          const Color(0xFF3B82F6),
        ),
        _buildStatCard(
          'Kategoriýalar',
          _stats['totalCategories']?.toString() ?? '0',
          Icons.category_outlined,
          const Color(0xFF8B5CF6),
        ),
        _buildStatCard(
          'Galyndy Ýok',
          _stats['outOfStock']?.toString() ?? '0',
          Icons.warning_amber_rounded,
          const Color(0xFFF59E0B),
        ),
        _buildStatCard(
          'Ortaça Reýting',
          (_stats['averageRating'] as double?)?.toStringAsFixed(1) ?? '0.0',
          Icons.star_outline_rounded,
          const Color(0xFF10B981),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF6B7280)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF111827)),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildSystemGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.6,
      children: [
        _buildNavCard(
          'Ulanyjylar',
          Icons.people_alt_outlined,
          Colors.blueGrey,
          const AdminUsersPage(),
        ),
        _buildNavCard(
          'Ulgam loglary',
          Icons.terminal_rounded,
          const Color(0xFFDC2626),
          const AdminLogsPage(),
        ),
        _buildNavCard(
          'Pul birlikleri',
          Icons.attach_money_rounded,
          Colors.orangeAccent,
          const AdminCurrenciesPage(),
        ),
        _buildNavCard(
          'Aksiýalar & Sowgatlar',
          Icons.card_giftcard_rounded,
          Colors.deepOrange,
          const AdminGiftsPage(),
        ),
        _buildNavCard(
          'Mobil Goşundy',
          Icons.system_update_rounded,
          Colors.indigo,
          const AdminMobileAppsPage(),
        ),
      ],
    );
  }

  Widget _buildRecentProducts() {
    final list = _stats['recentProducts'] as List? ?? [];
    if (list.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        _buildSectionTitle('Soňky Goşulan Harytlar'),
        const SizedBox(height: 12),
        SizedBox(
          height: 85,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final product = list[index];
              final String imageUrl = product['image'] ?? '';
              final String name = product['name'] ?? '';
              final double price = double.tryParse(product['price'].toString()) ?? 0.0;
              return Container(
                width: 220,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: imageUrl.isNotEmpty
                          ? Image.network(
                              imageUrl,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 50,
                                height: 50,
                                color: const Color(0xFFF3F4F6),
                                child: const Icon(Icons.image, color: Colors.grey, size: 20),
                              ),
                            )
                          : Container(
                              width: 50,
                              height: 50,
                              color: const Color(0xFFF3F4F6),
                              child: const Icon(Icons.image, color: Colors.grey, size: 20),
                            ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$price TMT',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Color(0xFFDC2626)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNavCard(String title, IconData icon, Color color, Widget destination) {
    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => destination)).then((_) => _loadStats());
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: color, size: 26),
            Text(
              title,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
            ),
          ],
        ),
      ),
    );
  }
}

// --- TAB 2: FOTO MERKEZ ---
class AdminFotoMerkezTab extends StatelessWidget {
  const AdminFotoMerkezTab({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      padding: const EdgeInsets.all(16.0),
      crossAxisCount: 2,
      crossAxisSpacing: 14,
      mainAxisSpacing: 14,
      childAspectRatio: 1.45,
      children: [
        _buildNavCard(context, 'Harytlar', Icons.shopping_bag_outlined, const Color(0xFFDC2626), const AdminProductsPage()),
        _buildNavCard(context, 'Kategoriýalar', Icons.category_outlined, Colors.orange, const AdminCategoriesPage()),
        _buildNavCard(context, 'Brendler', Icons.copyright_rounded, Colors.blue, const AdminBrandsPage()),
        _buildNavCard(context, 'Sargytlar', Icons.receipt_long_outlined, Colors.purple, const AdminOrdersPage()),
        _buildNavCard(context, 'Hatlar we Soraglar', Icons.mail_outline_rounded, Colors.green, const AdminMessagesPage()),
        _buildNavCard(context, 'Teswirler', Icons.rate_review_outlined, Colors.teal, const AdminReviewsPage()),
        _buildNavCard(context, 'Bannerler', Icons.view_carousel_outlined, Colors.cyan, const AdminBannersPage()),
        _buildNavCard(context, 'Täzelikler', Icons.article_outlined, Colors.brown, const AdminBlogsPage()),
      ],
    );
  }

  Widget _buildNavCard(BuildContext context, String title, IconData icon, Color color, Widget destination) {
    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => destination));
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: color, size: 28),
            Text(
              title,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Color(0xFF1F2937)),
            ),
          ],
        ),
      ),
    );
  }
}

// --- TAB 3: FOTO STUDIO ---
class AdminFotoStudioTab extends StatelessWidget {
  const AdminFotoStudioTab({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      padding: const EdgeInsets.all(16.0),
      crossAxisCount: 2,
      crossAxisSpacing: 14,
      mainAxisSpacing: 14,
      childAspectRatio: 1.45,
      children: [
        _buildNavCard(context, 'Studio Sargytlar', Icons.camera_outdoor_outlined, Colors.indigo, const AdminStudioOrdersPage()),
        _buildNavCard(context, 'Foto Studiýa (Reels)', Icons.photo_library_outlined, Colors.amber, const AdminPhotoStudioPage()),
        _buildNavCard(context, 'Studio Sözlükleri', Icons.menu_book_rounded, Colors.pink, const AdminStudioCatalogsPage()),
      ],
    );
  }

  Widget _buildNavCard(BuildContext context, String title, IconData icon, Color color, Widget destination) {
    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => destination));
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: color, size: 28),
            Text(
              title,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Color(0xFF1F2937)),
            ),
          ],
        ),
      ),
    );
  }
}
