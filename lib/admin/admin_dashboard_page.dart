import 'package:flutter/material.dart';
import '../services/admin_service.dart';
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

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
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
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text(
          'Müdirlik Paneli',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22, letterSpacing: -0.5),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadStats,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFDC2626)))
          : _error != null
              ? Center(
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
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStatsGrid(),
                      const SizedBox(height: 28),
                      _buildRecentProducts(),
                      const SizedBox(height: 28),
                      _buildSectionTitle('Söwda Dolandyryşy'),
                      const SizedBox(height: 12),
                      _buildCommerceGrid(),
                      const SizedBox(height: 24),
                      _buildSectionTitle('Studio Dolandyryşy'),
                      const SizedBox(height: 12),
                      _buildStudioGrid(),
                      const SizedBox(height: 24),
                      _buildSectionTitle('Aksiýa we Bloglar'),
                      const SizedBox(height: 12),
                      _buildPromoGrid(),
                      const SizedBox(height: 24),
                      _buildSectionTitle('Ulgam Sazlamalary'),
                      const SizedBox(height: 12),
                      _buildSystemGrid(),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
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
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.04),
            blurRadius: 10,
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
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF6B7280)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF111827)),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentProducts() {
    final list = _stats['recentProducts'] as List? ?? [];
    if (list.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Soňky Goşulan Harytlar'),
        const SizedBox(height: 12),
        SizedBox(
          height: 100,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final product = list[index];
              final String imageUrl = product['image'] ?? '';
              final String name = product['name'] ?? '';
              final double price = double.tryParse(product['price'].toString()) ?? 0.0;
              return Container(
                width: 250,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: imageUrl.isNotEmpty
                          ? Image.network(
                              imageUrl,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 60,
                                height: 60,
                                color: const Color(0xFFF3F4F6),
                                child: const Icon(Icons.image, color: Colors.grey),
                              ),
                            )
                          : Container(
                              width: 60,
                              height: 60,
                              color: const Color(0xFFF3F4F6),
                              child: const Icon(Icons.image, color: Colors.grey),
                            ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$price TMT',
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFFDC2626)),
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

  Widget _buildCommerceGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.6,
      children: [
        _buildNavCard(
          'Harytlar',
          Icons.shopping_bag_outlined,
          const Color(0xFFDC2626),
          const AdminProductsPage(),
        ),
        _buildNavCard(
          'Kategoriýalar',
          Icons.category_outlined,
          Colors.orange,
          const AdminCategoriesPage(),
        ),
        _buildNavCard(
          'Brendler',
          Icons.copyright_rounded,
          Colors.blue,
          const AdminBrandsPage(),
        ),
        _buildNavCard(
          'Sargytlar',
          Icons.receipt_long_outlined,
          Colors.purple,
          const AdminOrdersPage(),
        ),
        _buildNavCard(
          'Teswirler',
          Icons.rate_review_outlined,
          Colors.teal,
          const AdminReviewsPage(),
        ),
      ],
    );
  }

  Widget _buildStudioGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.6,
      children: [
        _buildNavCard(
          'Studio Sargytlar',
          Icons.camera_outdoor_outlined,
          Colors.indigo,
          const AdminStudioOrdersPage(),
        ),
        _buildNavCard(
          'Galereýa',
          Icons.photo_library_outlined,
          Colors.amber,
          const AdminPhotoStudioPage(),
        ),
        _buildNavCard(
          'Kataloglar',
          Icons.menu_book_rounded,
          Colors.pink,
          const AdminStudioCatalogsPage(),
        ),
      ],
    );
  }

  Widget _buildPromoGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.6,
      children: [
        _buildNavCard(
          'Bannerler',
          Icons.view_carousel_outlined,
          Colors.cyan,
          const AdminBannersPage(),
        ),
        _buildNavCard(
          'Sowgatlar',
          Icons.card_giftcard_rounded,
          Colors.deepOrange,
          const AdminGiftsPage(),
        ),
        _buildNavCard(
          'Bloglar',
          Icons.article_outlined,
          Colors.brown,
          const AdminBlogsPage(),
        ),
      ],
    );
  }

  Widget _buildSystemGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.6,
      children: [
        _buildNavCard(
          'Ulanyjylar',
          Icons.people_alt_outlined,
          Colors.blueGrey,
          const AdminUsersPage(),
        ),
        _buildNavCard(
          'Hatlar',
          Icons.mail_outline_rounded,
          Colors.green,
          const AdminMessagesPage(),
        ),
        _buildNavCard(
          'Pul birlikleri',
          Icons.attach_money_rounded,
          Colors.orangeAccent,
          const AdminCurrenciesPage(),
        ),
        _buildNavCard(
          'Programmalar',
          Icons.system_update_rounded,
          Colors.redAccent,
          const AdminMobileAppsPage(),
        ),
      ],
    );
  }

  Widget _buildNavCard(String title, IconData icon, Color color, Widget destination) {
    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => destination)).then((_) => _loadStats());
      },
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFE5E7EB)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.01),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: color, size: 28),
            Text(
              title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
            ),
          ],
        ),
      ),
    );
  }
}
