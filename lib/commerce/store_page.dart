import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../widgets/top_bar.dart';
import '../widgets/app_header.dart';
import '../widgets/app_footer.dart';
import 'product_detail_page.dart';
import 'category_page.dart';
import 'commerce_blog_page.dart';
import '../config.dart';
import '../identity/profile_page.dart';
import '../services/sync_service.dart';

class StorePage extends StatefulWidget {
  const StorePage({super.key});

  @override
  State<StorePage> createState() => _StorePageState();
}

class _StorePageState extends State<StorePage> {

  List<dynamic> categories = [];
  List<dynamic> products = [];
  List<dynamic> banners = [];
  List<dynamic> brands = [];
  bool isLoading = true;
  int selectedProductTab = 0;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final catResponse = await http.get(Uri.parse('${Config.apiBaseUrl}/commerce/categories'));
      final prodResponse = await http.get(Uri.parse('${Config.apiBaseUrl}/commerce/products'));
      final bannerResponse = await http.get(Uri.parse('${Config.apiBaseUrl}/banners'));
      final brandResponse = await http.get(Uri.parse('${Config.apiBaseUrl}/commerce/brands'));

      if (catResponse.statusCode == 200 && prodResponse.statusCode == 200 && 
          bannerResponse.statusCode == 200 && brandResponse.statusCode == 200) {
        setState(() {
          categories = json.decode(utf8.decode(catResponse.bodyBytes)) ?? [];
          products = json.decode(utf8.decode(prodResponse.bodyBytes)) ?? [];
          banners = json.decode(utf8.decode(bannerResponse.bodyBytes)) ?? [];
          brands = json.decode(utf8.decode(brandResponse.bodyBytes)) ?? [];
          isLoading = false;
        });
        SyncService.checkForUpdates();
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      debugPrint('Error fetching data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

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
              const AppHeader(),
              
              // Hero Banner
              if (banners.isNotEmpty)
                HeroBanner(banners: banners, apiBaseUrl: Config.apiBaseUrl)
              else if (!isLoading)
                const SizedBox(height: 20),
              
              // Categories
              _buildSectionHeader('Kategoriýalar', 'Hemmesini gör'),
              _buildCategoriesList(),
              
              const SizedBox(height: 10),
              
              // Tabs for Products
              _buildProductTabs(),
              
              // Products List
              _buildProductsList(),
              
              // Main Brands
              if (brands.isNotEmpty) ...[
                _buildSectionHeader('Esasy brendler', 'Hemmesini gör'),
                _buildBrandsSection(),
              ],
              
              const SizedBox(height: 40),
              const AppFooter(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildSectionHeader(String title, String action) {

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Text(
            action,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF9CA3AF),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesList() {
    if (isLoading) {
      return const SizedBox(
        height: 110,
        child: Center(child: CircularProgressIndicator(color: Colors.orange)),
      );
    }
    if (categories.isEmpty) {
      return const SizedBox(
        height: 110,
        child: Center(child: Text('Kategoriýa tapylmady')),
      );
    }

    return SizedBox(
      height: 130,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          final String iconUrl = cat['icon'] != null 
              ? (cat['icon'].toString().startsWith('http') ? cat['icon'] : '${Config.mediaBaseUrl}${cat['icon']}')
              : '';

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CategoryPage(
                    categoryId: cat['id'],
                    categoryName: cat['name'],
                    apiBaseUrl: Config.apiBaseUrl,
                  ),
                ),
              );
            },
            child: Container(
              width: 80,
              margin: const EdgeInsets.only(right: 12, bottom: 10, top: 5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: iconUrl.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              iconUrl, 
                              width: 30, 
                              height: 30, 
                              fit: BoxFit.contain,
                              errorBuilder: (c, e, s) => const Icon(Icons.category_outlined, color: Colors.orange, size: 24),
                            ),
                          )
                        : const Icon(Icons.category_outlined, color: Colors.orange, size: 24),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      cat['name'] ?? 'Kategoriýa',
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          _buildTabItem(0, 'Meşhur harytlar'),
          const SizedBox(width: 15),
          _buildTabItem(1, 'Arzanlaşykdaky harytlar'),
        ],
      ),
    );
  }

  Widget _buildTabItem(int index, String title) {
    bool isSelected = selectedProductTab == index;
    return GestureDetector(
      onTap: () => setState(() => selectedProductTab = index),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: isSelected ? 18 : 14,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? Colors.black : Colors.grey,
            ),
          ),
          if (isSelected)
            Container(
              margin: const EdgeInsets.only(top: 4),
              width: 20,
              height: 3,
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProductsList() {
    if (isLoading) {
      return const SizedBox(
        height: 240,
        child: Center(child: CircularProgressIndicator(color: Colors.orange)),
      );
    }

    // Filter products based on tab
    List<dynamic> filteredProducts = products;
    if (selectedProductTab == 1) {
      // Arzanlaşykdaky = On Sale (original_price > price)
      filteredProducts = products.where((p) => (p['original_price'] != null && (p['original_price'] as num) > (p['price'] as num))).toList();
    }

    if (filteredProducts.isEmpty) {
      return const SizedBox(
        height: 240,
        child: Center(child: Text('Haryt tapylmady')),
      );
    }

    return SizedBox(
      height: 260,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: filteredProducts.length,
        itemBuilder: (context, index) {
          final prod = filteredProducts[index];
          final String imageUrl = (prod['media'] != null && prod['media'].isNotEmpty)
              ? (prod['media'][0]['url'].toString().startsWith('http') 
                  ? prod['media'][0]['url'] 
                  : '${Config.mediaBaseUrl}${prod['media'][0]['url']}')
              : 'https://via.placeholder.com/150';

          return Container(
            width: 170,
            margin: const EdgeInsets.only(right: 16, bottom: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFF3F4F6), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductDetailPage(
                      productId: prod['id'],
                      apiBaseUrl: Config.apiBaseUrl,
                    ),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
                        child: Image.network(
                          imageUrl,
                          height: 150,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            height: 150,
                            color: const Color(0xFFF3F4F6),
                            child: const Icon(Icons.image_not_supported_outlined, color: Color(0xFF9CA3AF)),
                          ),
                        ),
                      ),
                      if (prod['badge'] != null || (prod['original_price'] != null && (prod['original_price'] as num) > (prod['price'] as num)))
                        Positioned(
                          top: 10,
                          left: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              prod['badge'] ?? 'SALE',
                              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          prod['name'] ?? 'Haryt',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Text(
                              '${prod['price']} TMT',
                              style: const TextStyle(
                                color: Colors.orange,
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                              ),
                            ),
                            if (prod['original_price'] != null && (prod['original_price'] as num) > (prod['price'] as num)) ...[
                              const SizedBox(width: 6),
                              Text(
                                '${prod['original_price']}',
                                style: const TextStyle(
                                  color: Color(0xFF9CA3AF),
                                  fontSize: 11,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBrandsSection() {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: brands.length,
        itemBuilder: (context, index) {
          final brand = brands[index];
          final logoUrl = brand['logo_url'] != null && brand['logo_url'].toString().isNotEmpty
              ? (brand['logo_url'].toString().startsWith('http') ? brand['logo_url'] : '${Config.mediaBaseUrl}${brand['logo_url']}')
              : '';

          return GestureDetector(
            onTap: () {
              // Navigation to brand page if needed
            },
            child: Container(
              width: 120,
              margin: const EdgeInsets.only(right: 12, bottom: 10, top: 5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFF3F4F6), width: 1.5),
              ),
              child: Center(
                child: logoUrl.isNotEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(12),
                        child: Image.network(
                          logoUrl,
                          fit: BoxFit.contain,
                          errorBuilder: (c, e, s) => Text(
                            brand['name'] ?? '',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
                          ),
                        ),
                      )
                    : Text(
                        brand['name'] ?? '',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
                      ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: BottomNavigationBar(
        onTap: (index) {
          if (index == 2) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const CommerceBlogPage()));
          } else if (index == 3) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfilePage()));
          }
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.orange,
        unselectedItemColor: const Color(0xFF9CA3AF),
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        elevation: 0,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home_rounded), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.assignment_outlined), activeIcon: Icon(Icons.assignment_rounded), label: 'Orders'),
          BottomNavigationBarItem(icon: Icon(Icons.article_outlined), activeIcon: Icon(Icons.article_rounded), label: 'Blog'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person_rounded), label: 'Profile'),
        ],
      ),
    );
  }
}

class HeroBanner extends StatefulWidget {
  final List<dynamic> banners;
  final String apiBaseUrl;

  const HeroBanner({super.key, required this.banners, required this.apiBaseUrl});

  @override
  State<HeroBanner> createState() => _HeroBannerState();
}

class _HeroBannerState extends State<HeroBanner> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SInitialSectionSpacing(),
        SizedBox(
          height: 300,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemCount: widget.banners.length,
            itemBuilder: (context, index) {
              final banner = widget.banners[index];
              final imageUrl = banner['image'].toString().startsWith('http') 
                  ? banner['image'] 
                  : '${Config.mediaBaseUrl}${banner['image']}';

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (c, e, s) => Container(color: Colors.grey[200]),
                        ),
                      ),
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.black.withValues(alpha: 0.8),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (banner['subtitle'] != null)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFDC2626),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  banner['subtitle'].toString().toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ),
                            const SizedBox(height: 10),
                            Text(
                              banner['title'] ?? '',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                                height: 1.1,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              banner['description'] ?? '',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontSize: 13,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: Colors.black,
                                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    elevation: 0,
                                  ),
                                  child: Text(
                                    banner['ctaText'] ?? 'Söwda et',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                InkWell(
                                  onTap: () {},
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 1.5),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Text(
                                      'Ählisini gör',
                                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.banners.length, (index) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: _currentPage == index ? 20 : 6,
              height: 6,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                color: _currentPage == index ? const Color(0xFFDC2626) : Colors.grey[300],
                borderRadius: BorderRadius.circular(3),
              ),
            );
          }),
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}

class SInitialSectionSpacing extends StatelessWidget {
  const SInitialSectionSpacing({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(height: 8);
  }
}
