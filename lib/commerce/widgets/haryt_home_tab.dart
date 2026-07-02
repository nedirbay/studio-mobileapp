import 'dart:async';
import 'package:flutter/material.dart';
import '../../services/commerce_service.dart';
import '../../services/cart_service.dart';
import '../product_detail/product_detail_page.dart';
import '../../config.dart';
import '../../services/settings_service.dart';

class HarytHomeTab extends StatefulWidget {
  final Function(String? brand) onNavigateToCategories;

  const HarytHomeTab({super.key, required this.onNavigateToCategories});

  @override
  State<HarytHomeTab> createState() => _HarytHomeTabState();
}

class _HarytHomeTabState extends State<HarytHomeTab> {
  List<dynamic> banners = [];
  List<dynamic> categories = [];
  List<dynamic> products = [];
  List<dynamic> promos = [];
  List<dynamic> brands = [];
  bool isLoading = true;
  int selectedProductTab = 0; // 0: featured, 1: deals

  // Deals countdown timer
  int hours = 11;
  int minutes = 45;
  int seconds = 30;
  Timer? _countdownTimer;

  // Banner slide index
  int _currentBannerIndex = 0;
  final PageController _bannerController = PageController();

  void _onCartChanged() {
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _fetchHomeData();
    _startTimer();
    CartService().addListener(_onCartChanged);
  }

  @override
  void dispose() {
    CartService().removeListener(_onCartChanged);
    _countdownTimer?.cancel();
    _bannerController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if (seconds > 0) {
          seconds--;
        } else {
          if (minutes > 0) {
            minutes--;
            seconds = 59;
          } else {
            if (hours > 0) {
              hours--;
              minutes = 59;
              seconds = 59;
            } else {
              _countdownTimer?.cancel();
            }
          }
        }
      });
    });
  }

  Future<void> _fetchHomeData() async {
    try {
      final results = await Future.wait([
        CommerceService.banners(),
        CommerceService.categories(),
        CommerceService.products(),
        CommerceService.promos(),
        CommerceService.brands(),
      ]);

      if (!mounted) return;
      setState(() {
        banners = results[0];
        categories = results[1];
        products = results[2];
        promos = results[3];
        brands = results[4];
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching homepage data: $e');
      if (mounted) setState(() => isLoading = false);
    }
  }

  String _pad(int n) => n.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: SettingsService(),
      builder: (context, _) {
        final settings = SettingsService();
        if (isLoading) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFFDC2626)));
        }

        return RefreshIndicator(
          onRefresh: _fetchHomeData,
          color: const Color(0xFFDC2626),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Hero Banner
                if (banners.isNotEmpty) _buildHeroBanner(),
                
                // 2. Category Grid
                _buildCategoryGrid(settings),
                
                // 3. Home Product Tabs
                _buildHomeProductTabs(settings),
                
                // 4. Promo Section
                // if (promos.isNotEmpty) _buildPromoSection(),
                
                // 5. Brands Section
                if (brands.isNotEmpty) _buildBrandsSection(settings),
                
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeroBanner() {
    return Column(
      children: [
        SizedBox(
          height: 240,
          child: PageView.builder(
            controller: _bannerController,
            onPageChanged: (idx) => setState(() => _currentBannerIndex = idx),
            itemCount: banners.length,
            itemBuilder: (context, index) {
              final banner = banners[index];
              final imgRelative = banner['image']?.toString() ?? '';
              final imageUrl = imgRelative.startsWith('http')
                  ? imgRelative
                  : '${Config.mediaBaseUrl}${imgRelative.startsWith('/') ? '' : '/'}$imgRelative';

              return Container(
                margin: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => Container(color: const Color(0xFFF3F4F6)),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (banner['subtitle'] != null)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFDC2626),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  banner['subtitle'].toString().toUpperCase(),
                                  style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1),
                                ),
                              ),
                            const SizedBox(height: 8),
                            Text(
                              banner['title'] ?? '',
                              style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900, height: 1.1),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              banner['description'] ?? '',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 12),
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
          children: List.generate(banners.length, (index) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: _currentBannerIndex == index ? 16 : 6,
              height: 6,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                color: _currentBannerIndex == index ? const Color(0xFFDC2626) : const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(3),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildCategoryGrid(SettingsService settings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, top: 24, bottom: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                settings.translate('categories'),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF111827)),
              ),
              GestureDetector(
                onTap: () => widget.onNavigateToCategories(null),
                child: Row(
                  children: [
                    Text(settings.translate('view_all'), style: const TextStyle(fontSize: 13, color: Color(0xFFDC2626), fontWeight: FontWeight.bold)),
                    const SizedBox(width: 2),
                    const Icon(Icons.chevron_right, size: 16, color: Color(0xFFDC2626)),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final cat = categories[index];
              return GestureDetector(
                onTap: () => widget.onNavigateToCategories(null),
                child: Container(
                  width: 84,
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFF3F4F6)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        cat['icon']?.toString() ?? '📦',
                        style: const TextStyle(fontSize: 28),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Text(
                          cat['name'] ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF374151)),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHomeProductTabs(SettingsService settings) {
    // Filter items based on active tab
    List<dynamic> filtered = [];
    if (selectedProductTab == 0) {
      filtered = products.take(8).toList();
    } else {
      filtered = products
          .where((p) => (p['original_price'] != null && (p['original_price'] as num) > (p['price'] as num)) || p['badge'] == 'sale')
          .take(8)
          .toList();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tabs Header
        Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, top: 32, bottom: 16),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildTabButton(0, Icons.star_border_rounded, settings.translate('featured_products')),
                const SizedBox(width: 12),
                _buildTabButton(1, Icons.local_offer_outlined, settings.translate('on_sale')),
              ],
            ),
          ),
        ),
        
        // Countdown timer for deals
        if (selectedProductTab == 1)
          const Padding(
            padding: EdgeInsets.only(left: 20, right: 20, bottom: 16),
          ),

        // Product Grid
        if (filtered.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Center(child: Text(settings.translate('no_products_found'), style: const TextStyle(color: Colors.grey))),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.68,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
            ),
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final prod = filtered[index];
              return _buildProductCard(prod, settings);
            },
          ),
      ],
    );
  }

  Widget _buildTabButton(int index, IconData icon, String label) {
    bool active = selectedProductTab == index;
    return GestureDetector(
      onTap: () => setState(() => selectedProductTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: active ? Colors.black : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: active ? Colors.white : const Color(0xFF6B7280)),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: active ? Colors.white : const Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimerBox(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12, fontFamily: 'monospace'),
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> prod, SettingsService settings) {
    final inCart = CartService().items.any((item) => item['product']['id'].toString() == prod['id'].toString());
    String relativeUrl = '';
    if (prod['media'] != null && prod['media'] is List && prod['media'].isNotEmpty) {
      relativeUrl = prod['media'][0]['url'].toString();
    } else if (prod['image'] != null) {
      relativeUrl = prod['image'].toString();
    }
    final imageUrl = relativeUrl.isNotEmpty
        ? (relativeUrl.startsWith('http') ? relativeUrl : '${Config.mediaBaseUrl}${relativeUrl.startsWith('/') ? '' : '/'}$relativeUrl')
        : 'https://via.placeholder.com/150';

    final hasSale = prod['original_price'] != null && (prod['original_price'] as num) > (prod['price'] as num);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
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
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(18.5)),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => Container(color: const Color(0xFFF3F4F6)),
                    ),
                    if (hasSale || prod['badge'] != null)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDC2626),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            prod['badge']?.toString().toUpperCase() ?? 'SALE',
                            style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    prod['name'] ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF111827)),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        '${prod['price']} ${Config.activeCurrencySymbol}',
                        style: const TextStyle(color: Color(0xFFDC2626), fontWeight: FontWeight.w900, fontSize: 14),
                      ),
                      if (hasSale)
                        Text(
                          '${prod['original_price']} ${Config.activeCurrencySymbol}',
                          style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 11, decoration: TextDecoration.lineThrough),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    height: 32,
                    child: OutlinedButton(
                      onPressed: () {
                        if (inCart) {
                          CartService().removeFromCart(prod['id']);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${prod['name']} ${settings.translate('cart_remove_snack')}'),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        } else {
                          CartService().addToCart(prod);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${prod['name']} ${settings.translate('cart_add_snack')}'),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: inCart ? Colors.grey : const Color(0xFFDC2626)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: EdgeInsets.zero,
                      ),
                      child: Text(
                        inCart ? settings.translate('remove_btn') : settings.translate('add_to_cart_btn'),
                        style: TextStyle(
                          color: inCart ? Colors.grey : const Color(0xFFDC2626),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPromoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 20, right: 20, top: 32, bottom: 16),
          child: Text(
            'Ýörite Aksiýalar',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF111827)),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: promos.length,
          itemBuilder: (context, index) {
            final promo = promos[index];
            final imgRelative = promo['image']?.toString() ?? '';
            final imageUrl = imgRelative.startsWith('http')
                ? imgRelative
                : '${Config.mediaBaseUrl}${imgRelative.startsWith('/') ? '' : '/'}$imgRelative';

            return Container(
              height: 120,
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => Container(color: const Color(0xFFF3F4F6)),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            Colors.black.withOpacity(0.75),
                            Colors.black.withOpacity(0.2),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (promo['badge'] != null && promo['badge'].toString().isNotEmpty)
                            Text(
                              promo['badge'].toString().toUpperCase(),
                              style: const TextStyle(color: Colors.redAccent, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.8),
                            ),
                          const SizedBox(height: 4),
                          Text(
                            promo['title'] ?? '',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(color: const Color(0xFFDC2626), borderRadius: BorderRadius.circular(6)),
                            child: const Text('Ählisini gör', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
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
      ],
    );
  }

  Widget _buildBrandsSection(SettingsService settings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, top: 24, bottom: 16),
          child: Text(
            settings.translate('top_brands'),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF111827)),
          ),
        ),
        SizedBox(
          height: 60,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            itemCount: brands.length,
            itemBuilder: (context, index) {
              final brand = brands[index];
              final logoRelative = brand['logo_url']?.toString() ?? '';
              final logoUrl = logoRelative.startsWith('http')
                  ? logoRelative
                  : '${Config.mediaBaseUrl}${logoRelative.startsWith('/') ? '' : '/'}$logoRelative';

              return GestureDetector(
                onTap: () => widget.onNavigateToCategories(brand['name']?.toString()),
                child: Container(
                  width: 100,
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFF3F4F6)),
                  ),
                  child: logoRelative.isNotEmpty
                      ? Image.network(logoUrl, fit: BoxFit.contain, errorBuilder: (c, e, s) => Center(child: Text(brand['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10))))
                      : Center(child: Text(brand['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10))),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
