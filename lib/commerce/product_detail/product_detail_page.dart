import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../widgets/top_bar.dart';
import '../widgets/app_header.dart';
import '../widgets/app_footer.dart';
import '../config.dart';
import '../commerce_order_page.dart';
import './widgets/image_gallery.dart';
import './widgets/full_screen_image.dart';

class ProductDetailPage extends StatefulWidget {
  final int productId;
  final String apiBaseUrl;

  const ProductDetailPage({super.key, required this.productId, required this.apiBaseUrl});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  Map<String, dynamic>? product;
  List<dynamic> reviews = [];
  bool isLoading = true;
  int _currentImageIndex = 0;
  String activeTab = 'specs'; // 'specs' or 'reviews'
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    fetchProduct();
    fetchReviews();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> fetchProduct() async {
    try {
      final response = await http.get(Uri.parse('${Config.apiBaseUrl}/commerce/products/${widget.productId}'));
      if (response.statusCode == 200) {
        setState(() {
          product = json.decode(utf8.decode(response.bodyBytes));
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching product: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> fetchReviews() async {
    try {
      final response = await http.get(Uri.parse('${Config.apiBaseUrl}/commerce/products/${widget.productId}/reviews'));
      if (response.statusCode == 200) {
        setState(() {
          reviews = json.decode(utf8.decode(response.bodyBytes)) ?? [];
        });
      }
    } catch (e) {
      debugPrint('Error fetching reviews: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Color(0xFFDC2626))),
      );
    }
    if (product == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Haryt tapylmady')),
        body: const Center(child: Text('Gözleýän harydyňyz ýok ýa-da öçürilipdir.')),
      );
    }

    final mediaList = product!['media'] as List;
    final images = mediaList.map((m) => m['url'].toString()).toList();
    if (images.isEmpty) images.add('https://via.placeholder.com/400');

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const TopBar(),
              const AppHeader(),
              
              // Breadcrumb
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      Text('Baş sahypa', style: TextStyle(color: Colors.grey[500], fontSize: 11)),
                      Icon(Icons.chevron_right, size: 14, color: Colors.grey[400]),
                      Text('Harytlar', style: TextStyle(color: Colors.grey[500], fontSize: 11)),
                      Icon(Icons.chevron_right, size: 14, color: Colors.grey[400]),
                      Text(product!['category_name'] ?? 'Kategoriýa', style: TextStyle(color: Colors.grey[900], fontSize: 11, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),

              ImageGallery(
                images: images,
                currentIndex: _currentImageIndex,
                pageController: _pageController,
                onPageChanged: (i) => setState(() => _currentImageIndex = i),
                onFullScreenTap: (index) => _openFullScreenImage(images, index),
                badge: product!['badge']?.toString(),
              ),

              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${product!['marka'] ?? 'Doganlar'} · ${product!['category_name'] ?? ''}', 
                      style: TextStyle(color: Colors.grey[500], fontSize: 13, fontWeight: FontWeight.w600)
                    ),
                    const SizedBox(height: 8),
                    Text(
                      product!['name'] ?? '', 
                      style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900, color: Color(0xFF111827), height: 1.2, letterSpacing: -0.5)
                    ),
                    const SizedBox(height: 16),
                    
                    // Rating
                    Row(
                      children: [
                        ...List.generate(5, (i) => Icon(Icons.star_rounded, size: 20, color: i < 4 ? const Color(0xFFFBBF24) : Colors.grey[200])),
                        const SizedBox(width: 8),
                        Text('(${reviews.length} syn)', style: TextStyle(color: Colors.grey[500], fontSize: 13, fontWeight: FontWeight.w500)),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Price Row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text('${product!['price']} TMT', style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w900, color: Color(0xFFDC2626))),
                        if (product!['original_price'] != null && (product!['original_price'] as num) > (product!['price'] as num)) ...[
                          const SizedBox(width: 12),
                          Text(
                            '${product!['original_price']}', 
                            style: const TextStyle(fontSize: 20, color: Color(0xFF9CA3AF), decoration: TextDecoration.lineThrough)
                          ),
                        ],
                      ],
                    ),
                    
                    const SizedBox(height: 32),

                    // Availability & Quantity
                    _buildAvailabilityAndQuantity(),

                    const SizedBox(height: 32),
                    
                    // Add to Cart
                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CommerceOrderPage(
                                productName: product!['name'] ?? 'Haryt',
                                price: (product!['price'] as num).toDouble(),
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFDC2626),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.shopping_cart_outlined, size: 22),
                            SizedBox(width: 12),
                            Text('Häzir sargyt et', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Description
                    const Text('Düşündiriş', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
                    const SizedBox(height: 12),
                    Text(
                      product!['description'] ?? 'Düşündiriş ýok.', 
                      style: const TextStyle(color: Color(0xFF4B5563), fontSize: 15, height: 1.6)
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Tabs
                    _buildTabs(),
                    const SizedBox(height: 24),
                    
                    if (activeTab == 'specs') _buildSpecs() else _buildReviews(),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              const AppFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvailabilityAndQuantity() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Sany', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFF3F4F6), width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {}, 
                    icon: const Icon(Icons.remove, size: 18),
                    padding: const EdgeInsets.all(8),
                    constraints: const BoxConstraints(),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text('1', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                  IconButton(
                    onPressed: () {}, 
                    icon: const Icon(Icons.add, size: 18, color: Color(0xFFDC2626)),
                    padding: const EdgeInsets.all(8),
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Text('Ýagdaýy', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  (product!['stock'] == null || (product!['stock'] as num) > 0) ? Icons.check_circle : Icons.cancel,
                  color: (product!['stock'] == null || (product!['stock'] as num) > 0) ? Colors.green : Colors.red,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Text(
                  (product!['stock'] == null || (product!['stock'] as num) > 0) ? 'Ammarda bar' : 'Ammarda ýok',
                  style: TextStyle(
                    color: (product!['stock'] == null || (product!['stock'] as num) > 0) ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTabs() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF3F4F6), width: 2))
      ),
      child: Row(
        children: [
          _buildTab('Aýratynlyklar', 'specs'),
          _buildTab('Synlar (${reviews.length})', 'reviews'),
        ],
      ),
    );
  }

  Widget _buildTab(String label, String id) {
    bool isActive = activeTab == id;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => activeTab = id),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                label, 
                style: TextStyle(
                  fontWeight: FontWeight.w800, 
                  fontSize: 14,
                  color: isActive ? const Color(0xFFDC2626) : const Color(0xFF9CA3AF)
                )
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 2, 
              color: isActive ? const Color(0xFFDC2626) : Colors.transparent
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecs() {
    final specs = product!['specifications'] as Map<String, dynamic>?;
    if (specs == null || specs.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 40),
          child: Text('Tehniki aýratynlyklar elýeterli däl.', style: TextStyle(color: Colors.grey)),
        ),
      );
    }
    return Column(
      children: specs.entries.map((e) => Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xFFF9FAFB)))
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(e.key, style: const TextStyle(color: Color(0xFF6B7280), fontWeight: FontWeight.w500)),
            Text(e.value.toString(), style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF111827))),
          ],
        ),
      )).toList(),
    );
  }

  Widget _buildReviews() {
    if (reviews.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 40),
          child: Text('Entek syn ýazylmady. Ilkinji boluň!', style: TextStyle(color: Colors.grey)),
        ),
      );
    }
    return Column(
      children: reviews.map((r) => Container(
        padding: const EdgeInsets.only(bottom: 24, top: 8),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xFFF9FAFB)))
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: const Color(0xFFFEE2E2), 
                  radius: 18, 
                  child: Text(
                    r['userName'][0].toUpperCase(), 
                    style: const TextStyle(color: Color(0xFFDC2626), fontWeight: FontWeight.bold)
                  )
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(r['userName'], style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF111827))),
                    const SizedBox(height: 2),
                    Row(
                      children: List.generate(5, (i) => Icon(
                        Icons.star_rounded, 
                        size: 16, 
                        color: i < (r['rating'] ?? 0) ? const Color(0xFFFBBF24) : Colors.grey[200]
                      )),
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  _formatDate(r['createdAt']), 
                  style: TextStyle(color: Colors.grey[400], fontSize: 11)
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (r['title'] != null && r['title'].isNotEmpty)
              Text(r['title'], style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: Color(0xFF1F2937))),
            const SizedBox(height: 4),
            Text(
              r['content'] ?? '', 
              style: const TextStyle(color: Color(0xFF4B5563), fontSize: 14, height: 1.5)
            ),
          ],
        ),
      )).toList(),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}.${date.month}.${date.year}';
    } catch (e) {
      return dateStr;
    }
  }

  void _openFullScreenImage(List<String> images, int initialIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenImagePage(
          images: images,
          initialIndex: initialIndex,
        ),
      ),
    );
  }
}
