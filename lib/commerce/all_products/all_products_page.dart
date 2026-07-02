import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../widgets/top_bar.dart';
import '../../widgets/app_header.dart';
import '../widgets/product_card.dart';
import '../widgets/commerce_bottom_nav.dart';
import './widgets/filter_drawer.dart';
import '../../services/settings_service.dart';
import '../../services/commerce_service.dart';

class AllProductsPage extends StatefulWidget {
  final String apiBaseUrl;
  final bool isEmbedded;
  final String? initialBrand;

  const AllProductsPage({
    super.key,
    required this.apiBaseUrl,
    this.isEmbedded = false,
    this.initialBrand,
  });

  @override
  State<AllProductsPage> createState() => _AllProductsPageState();
}

class _AllProductsPageState extends State<AllProductsPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<dynamic> allProducts = [];
  List<dynamic> filteredProducts = [];
  bool isLoading = true;
  String searchQuery = "";
  
  // Filter state
  Set<String> selectedCategories = {};
  Set<String> selectedBrands = {};
  RangeValues priceRange = const RangeValues(0, 10000);
  Set<int> selectedRatings = {};
  bool inStockOnly = false;
  bool onSaleOnly = false;
  
  List<String> categories = [];
  List<String> brands = [];

  final TextEditingController minPriceController = TextEditingController();
  final TextEditingController maxPriceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialBrand != null) {
      selectedBrands.add(widget.initialBrand!);
    }
    fetchProducts();
    minPriceController.text = priceRange.start.toInt().toString();
    maxPriceController.text = priceRange.end.toInt().toString();
  }

  @override
  void didUpdateWidget(covariant AllProductsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialBrand != oldWidget.initialBrand && widget.initialBrand != null) {
      setState(() {
        selectedBrands.clear();
        selectedBrands.add(widget.initialBrand!);
      });
      _filterProducts();
    }
  }

  @override
  void dispose() {
    minPriceController.dispose();
    maxPriceController.dispose();
    super.dispose();
  }

  Future<void> fetchProducts() async {
    try {
      final results = await Future.wait([
        http.get(Uri.parse('${widget.apiBaseUrl}/commerce/products')),
        CommerceService.categories(),
        CommerceService.brands(),
      ]);

      final response = results[0] as http.Response;
      final fetchedCategories = results[1] as List<dynamic>;
      final fetchedBrands = results[2] as List<dynamic>;

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        setState(() {
          allProducts = data;
          categories = fetchedCategories.map((c) => c['name'].toString()).toList();
          brands = fetchedBrands.map((b) => b['name'].toString()).toList();
          isLoading = false;
          _filterProducts();
        });
      }
    } catch (e) {
      debugPrint('Error: $e');
      setState(() => isLoading = false);
    }
  }

  void _filterProducts() {
    setState(() {
      filteredProducts = allProducts.where((prod) {
        final matchesSearch = prod['name'].toString().toLowerCase().contains(searchQuery.toLowerCase());
        final matchesCategory = selectedCategories.isEmpty || selectedCategories.contains(prod['category_name']);
        final matchesBrand = selectedBrands.isEmpty || selectedBrands.contains(prod['marka']);
        final matchesPrice = (prod['price'] as num) >= priceRange.start && (prod['price'] as num) <= priceRange.end;
        final matchesRating = selectedRatings.isEmpty || selectedRatings.contains(4); // Mock rating match
        final matchesStock = !inStockOnly || (prod['stock'] != null && (prod['stock'] as num) > 0);
        final matchesSale = !onSaleOnly || (prod['original_price'] != null && (prod['original_price'] as num) > (prod['price'] as num));

        return matchesSearch && matchesCategory && matchesBrand && matchesPrice && matchesRating && matchesStock && matchesSale;
      }).toList();
    });
  }

  void _clearFilters() {
    setState(() {
      selectedCategories.clear();
      selectedBrands.clear();
      priceRange = const RangeValues(0, 10000);
      selectedRatings.clear();
      inStockOnly = false;
      onSaleOnly = false;
      minPriceController.text = "0";
      maxPriceController.text = "10000";
    });
    _filterProducts();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: SettingsService(),
      builder: (context, _) {
        final settings = SettingsService();
        int activeFiltersCount = 0;
        if (selectedCategories.isNotEmpty) activeFiltersCount++;
        if (selectedBrands.isNotEmpty) activeFiltersCount++;
        if (priceRange.start > 0 || priceRange.end < 10000) activeFiltersCount++;
        if (selectedRatings.isNotEmpty) activeFiltersCount++;
        if (inStockOnly) activeFiltersCount++;
        if (onSaleOnly) activeFiltersCount++;

        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: const Color(0xFFF9FAFB),
          drawer: FilterDrawer(
            settings: settings,
            categories: categories,
            brands: brands,
            selectedCategories: selectedCategories,
            selectedBrands: selectedBrands,
            priceRange: priceRange,
            selectedRatings: selectedRatings,
            inStockOnly: inStockOnly,
            onSaleOnly: onSaleOnly,
            minPriceController: minPriceController,
            maxPriceController: maxPriceController,
            onCategoryToggle: (cat) {
              setState(() {
                if (selectedCategories.contains(cat)) {
                  selectedCategories.remove(cat);
                } else {
                  selectedCategories.add(cat);
                }
              });
            },
            onBrandToggle: (brand) {
              setState(() {
                if (selectedBrands.contains(brand)) {
                  selectedBrands.remove(brand);
                } else {
                  selectedBrands.add(brand);
                }
              });
            },
            onPriceRangeChanged: (range) {
              setState(() => priceRange = range);
            },
            onRatingToggle: (star) {
              setState(() {
                if (selectedRatings.contains(star)) {
                  selectedRatings.remove(star);
                } else {
                  selectedRatings.add(star);
                }
              });
            },
            onStockToggle: (val) => setState(() => inStockOnly = val),
            onSaleToggle: (val) => setState(() => onSaleOnly = val),
            onClear: _clearFilters,
            onApply: _filterProducts,
          ),
          body: SafeArea(
            child: Column(
              children: [
                if (!widget.isEmbedded) ...[
                  const TopBar(),
                  AppHeader(),
                ],
                
                // Search and Filter Bar
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          if (!widget.isEmbedded) ...[
                            // Back button
                            IconButton(
                              icon: const Icon(Icons.arrow_back, color: Color(0xFF111827)),
                              onPressed: () => Navigator.pop(context),
                            ),
                            const SizedBox(width: 8),
                          ],
                          // Filter button
                          Stack(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.tune_rounded, color: Color(0xFF111827)),
                                  onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                                ),
                              ),
                              if (activeFiltersCount > 0)
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(color: Color(0xFFDC2626), shape: BoxShape.circle),
                                    child: Text('$activeFiltersCount', style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(width: 12),
                          // Search field
                          Expanded(
                            child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: TextField(
                                onChanged: (val) {
                                  setState(() => searchQuery = val);
                                  _filterProducts();
                                },
                                decoration: InputDecoration(
                                  hintText: settings.translate('search_product'),
                                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(vertical: 15),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),

                Expanded(
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator(color: Color(0xFFDC2626)))
                      : filteredProducts.isEmpty
                          ? Center(child: Text(settings.translate('no_products_found')))
                          : GridView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.58,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                              ),
                              itemCount: filteredProducts.length,
                              itemBuilder: (context, index) => ProductCard(prod: filteredProducts[index]),
                            ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: widget.isEmbedded ? null : CommerceBottomNav(currentIndex: 1),
        );
      },
    );
  }
}
