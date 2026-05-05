import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'widgets/top_bar.dart';
import 'widgets/app_header.dart';
import 'widgets/app_footer.dart';
import 'product_detail_page.dart';
import 'config.dart';

class CategoryPage extends StatefulWidget {
  final int categoryId;
  final String categoryName;
  final String apiBaseUrl;

  const CategoryPage({super.key, required this.categoryId, required this.categoryName, required this.apiBaseUrl});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  List<dynamic> products = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    try {
      final response = await http.get(Uri.parse('${Config.apiBaseUrl}/commerce/products'));
      if (response.statusCode == 200) {
        final allProducts = json.decode(utf8.decode(response.bodyBytes)) as List;
        setState(() {
          products = allProducts.where((p) => p['category_id'] == widget.categoryId).toList();
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching products: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const TopBar(),
              const AppHeader(),
              
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.categoryName, 
                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF111827))
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: const Color(0xFFDC2626),
                            borderRadius: BorderRadius.circular(2)
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(20)
                      ),
                      child: Text(
                        '${products.length} haryt', 
                        style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12, fontWeight: FontWeight.bold)
                      ),
                    ),
                  ],
                ),
              ),

              if (isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 100),
                  child: Center(child: CircularProgressIndicator(color: Color(0xFFDC2626))),
                )
              else if (products.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 100),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.inventory_2_outlined, size: 64, color: Color(0xFFD1D5DB)),
                        SizedBox(height: 16),
                        Text('Bu kategoriýada entek haryt ýok.', style: TextStyle(color: Color(0xFF9CA3AF))),
                      ],
                    ),
                  ),
                )
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.68,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final prod = products[index];
                    return _buildProductCard(prod);
                  },
                ),
              
              const SizedBox(height: 60),
              const AppFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductCard(dynamic prod) {
    final String imageUrl = (prod['media'] != null && prod['media'].isNotEmpty)
        ? (prod['media'][0]['url'].toString().startsWith('http') 
            ? prod['media'][0]['url'] 
            : '${Config.mediaBaseUrl}${prod['media'][0]['url']}')
        : 'https://via.placeholder.com/150';

    return InkWell(
      onTap: () {
        Navigator.push(
          context, 
          MaterialPageRoute(
            builder: (context) => ProductDetailPage(
              productId: prod['id'], 
              apiBaseUrl: Config.apiBaseUrl
            )
          )
        );
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFF3F4F6), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4)
            )
          ]
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                    child: Image.network(
                      imageUrl, 
                      fit: BoxFit.cover, 
                      width: double.infinity,
                      height: double.infinity,
                      errorBuilder: (c, e, s) => Container(
                        color: const Color(0xFFF9FAFB),
                        child: const Icon(Icons.image_not_supported_outlined, color: Color(0xFFD1D5DB)),
                      ),
                    ),
                  ),
                  if (prod['badge'] != null)
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDC2626),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          prod['badge'].toString().toUpperCase(), 
                          style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w900)
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    prod['name'] ?? '', 
                    maxLines: 1, 
                    overflow: TextOverflow.ellipsis, 
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Color(0xFF111827))
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        '\$${prod['price']}', 
                        style: const TextStyle(color: Color(0xFFDC2626), fontWeight: FontWeight.w900, fontSize: 16)
                      ),
                      if (prod['original_price'] != null) ...[
                        const SizedBox(width: 6),
                        Text(
                          '\$${prod['original_price']}', 
                          style: const TextStyle(
                            color: Color(0xFF9CA3AF), 
                            fontSize: 11, 
                            decoration: TextDecoration.lineThrough
                          )
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
  }
}
