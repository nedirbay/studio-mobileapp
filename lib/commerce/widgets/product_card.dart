import 'package:flutter/material.dart';
import '../../config.dart';
import '../product_detail/product_detail_page.dart';

class ProductCard extends StatelessWidget {
  final Map<String, dynamic> prod;

  const ProductCard({super.key, required this.prod});

  @override
  Widget build(BuildContext context) {
    String relativeUrl = '';
    if (prod['media'] != null && prod['media'] is List && prod['media'].isNotEmpty) {
      relativeUrl = prod['media'][0]['url'].toString();
    }
    
    final String imageUrl = relativeUrl.isNotEmpty
        ? (relativeUrl.startsWith('http') ? relativeUrl : '${Config.mediaBaseUrl}${relativeUrl.startsWith('/') ? '' : '/'}$relativeUrl')
        : 'https://via.placeholder.com/150';

    bool isOnSale = prod['original_price'] != null && (prod['original_price'] as num) > (prod['price'] as num);

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 5))
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
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => Container(
                          color: Colors.grey[100],
                          child: const Icon(Icons.image_not_supported, color: Colors.grey),
                        ),
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
                          style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    prod['marka'] ?? 'Doganlar',
                    style: TextStyle(color: Colors.grey[400], fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    prod['name'] ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, height: 1.2),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        '${prod['price']} TMT',
                        style: const TextStyle(color: Color(0xFFDC2626), fontWeight: FontWeight.w900, fontSize: 16),
                      ),
                      if (isOnSale) ...[
                        const SizedBox(width: 6),
                        Text(
                          '${prod['original_price']}',
                          style: TextStyle(color: Colors.grey[400], fontSize: 11, decoration: TextDecoration.lineThrough),
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
