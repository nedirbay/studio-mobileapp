import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'widgets/top_bar.dart';
import 'widgets/app_header.dart';
import 'widgets/app_footer.dart';
import 'config.dart';

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

  @override
  void initState() {
    super.initState();
    fetchProduct();
    fetchReviews();
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
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildBreadcrumbItem('Baş sahypa'),
                      _buildBreadcrumbDivider(),
                      _buildBreadcrumbItem('Harytlar'),
                      _buildBreadcrumbDivider(),
                      _buildBreadcrumbItem(product!['category_name'] ?? 'Kategoriýa'),
                      _buildBreadcrumbDivider(),
                      Text(
                        product!['name'] ?? '', 
                        style: const TextStyle(color: Color(0xFF111827), fontSize: 11, fontWeight: FontWeight.bold)
                      ),
                    ],
                  ),
                ),
              ),

              // Image Gallery
              Stack(
                children: [
                  Container(
                    height: 380,
                    width: double.infinity,
                    color: const Color(0xFFF9FAFB),
                    child: PageView.builder(
                      onPageChanged: (i) => setState(() => _currentImageIndex = i),
                      itemCount: images.length,
                      itemBuilder: (context, index) {
                        final url = images[index].startsWith('http') ? images[index] : '${Config.mediaBaseUrl}${images[index]}';
                        return InteractiveViewer(
                          child: Image.network(
                            url, 
                            fit: BoxFit.contain,
                            errorBuilder: (c, e, s) => const Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                          ),
                        );
                      },
                    ),
                  ),
                  if (images.length > 1)
                    Positioned(
                      bottom: 20,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(images.length, (i) => Container(
                          width: _currentImageIndex == i ? 20 : 6,
                          height: 6,
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3),
                            color: _currentImageIndex == i ? const Color(0xFFDC2626) : Colors.grey[300],
                          ),
                        )),
                      ),
                    ),
                  if (product!['badge'] != null)
                    Positioned(
                      top: 16,
                      left: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDC2626),
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4)
                          ]
                        ),
                        child: Text(
                          product!['badge'].toString().toUpperCase(), 
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)
                        ),
                      ),
                    ),
                ],
              ),

              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${product!['marka'] ?? ''} · ${product!['category_name'] ?? ''}', 
                      style: TextStyle(color: Colors.grey[500], fontSize: 13, fontWeight: FontWeight.w500)
                    ),
                    const SizedBox(height: 12),
                    Text(
                      product!['name'] ?? '', 
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF111827), height: 1.2)
                    ),
                    const SizedBox(height: 16),
                    
                    // Price Row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text('\$${product!['price']}', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Color(0xFFDC2626))),
                        if (product!['original_price'] != null) ...[
                          const SizedBox(width: 12),
                          Text(
                            '\$${product!['original_price']}', 
                            style: const TextStyle(fontSize: 18, color: Color(0xFF9CA3AF), decoration: TextDecoration.lineThrough)
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Tygyşytlaň \$${(product!['original_price'] - product!['price']).toStringAsFixed(2)}',
                            style: const TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ],
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Description
                    const Text('Düşündiriş', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF111827))),
                    const SizedBox(height: 12),
                    Text(
                      product!['description'] ?? 'Düşündiriş ýok.', 
                      style: const TextStyle(color: Color(0xFF4B5563), fontSize: 15, height: 1.6)
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Tabs
                    Container(
                      decoration: const BoxDecoration(
                        border: Border(bottom: BorderSide(color: Color(0xFFF3F4F6), width: 2))
                      ),
                      child: Row(
                        children: [
                          _buildTab('Tehniki aýratynlyklar', 'specs'),
                          _buildTab('Synlar (${reviews.length})', 'reviews'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    if (activeTab == 'specs') _buildSpecs() else _buildReviews(),
                    
                    const SizedBox(height: 48),
                    
                    // Add to Cart
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFDC2626),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 8,
                          shadowColor: const Color(0xFFDC2626).withValues(alpha: 0.3),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.shopping_cart_outlined),
                            SizedBox(width: 12),
                            Text('Sebede goş', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
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

  Widget _buildBreadcrumbItem(String label) {
    return Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 11));
  }

  Widget _buildBreadcrumbDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Icon(Icons.chevron_right, size: 12, color: Colors.grey[400]),
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
}
