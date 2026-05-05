import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'widgets/top_bar.dart';
import 'widgets/app_header.dart';
import 'widgets/app_footer.dart';
import 'config.dart';

class BrandsPage extends StatefulWidget {
  final String apiBaseUrl;

  const BrandsPage({super.key, required this.apiBaseUrl});

  @override
  State<BrandsPage> createState() => _BrandsPageState();
}

class _BrandsPageState extends State<BrandsPage> {
  List<dynamic> brands = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchBrands();
  }

  Future<void> fetchBrands() async {
    try {
      final response = await http.get(Uri.parse('${Config.apiBaseUrl}/commerce/brands'));
      if (response.statusCode == 200) {
        setState(() {
          brands = json.decode(utf8.decode(response.bodyBytes)) ?? [];
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching brands: $e');
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const TopBar(),
              const AppHeader(),
              
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Bizniň markalarymyz', 
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF111827))
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
                    const SizedBox(height: 12),
                    Text(
                      'Dünýäniň iň gowy brendlerinden hilli harytlar', 
                      style: TextStyle(color: Colors.grey[500], fontSize: 14)
                    ),
                  ],
                ),
              ),

              if (isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 100),
                  child: Center(child: CircularProgressIndicator(color: Color(0xFFDC2626))),
                )
              else if (brands.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 100),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.business_outlined, size: 64, color: Color(0xFFD1D5DB)),
                        SizedBox(height: 16),
                        Text('Entek marka ýok.', style: TextStyle(color: Color(0xFF9CA3AF))),
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
                    childAspectRatio: 1.4,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: brands.length,
                  itemBuilder: (context, index) {
                    final brand = brands[index];
                    final logoUrl = brand['logo_url'] != null && brand['logo_url'].toString().isNotEmpty
                        ? (brand['logo_url'].toString().startsWith('http') ? brand['logo_url'] : '${Config.mediaBaseUrl}${brand['logo_url']}')
                        : '';

                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
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
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (logoUrl.isNotEmpty)
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Image.network(
                                  logoUrl, 
                                  fit: BoxFit.contain,
                                  errorBuilder: (c, e, s) => const Icon(Icons.business, size: 32, color: Color(0xFFD1D5DB)),
                                ),
                              ),
                            )
                          else
                            const Expanded(child: Icon(Icons.business, size: 40, color: Color(0xFFD1D5DB))),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: const BoxDecoration(
                              color: Color(0xFFF9FAFB),
                              borderRadius: BorderRadius.vertical(bottom: Radius.circular(15))
                            ),
                            child: Text(
                              brand['name'] ?? '', 
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF374151)), 
                              textAlign: TextAlign.center
                            ),
                          ),
                        ],
                      ),
                    );
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
}
