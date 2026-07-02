import 'package:flutter/material.dart';
import '../../../services/settings_service.dart';

class FilterDrawer extends StatelessWidget {
  final SettingsService settings;
  final List<String> categories;
  final List<String> brands;
  final Set<String> selectedCategories;
  final Set<String> selectedBrands;
  final RangeValues priceRange;
  final Set<int> selectedRatings;
  final bool inStockOnly;
  final bool onSaleOnly;
  final TextEditingController minPriceController;
  final TextEditingController maxPriceController;
  
  final Function(String) onCategoryToggle;
  final Function(String) onBrandToggle;
  final Function(RangeValues) onPriceRangeChanged;
  final Function(int) onRatingToggle;
  final Function(bool) onStockToggle;
  final Function(bool) onSaleToggle;
  final VoidCallback onClear;
  final VoidCallback onApply;

  const FilterDrawer({
    super.key,
    required this.settings,
    required this.categories,
    required this.brands,
    required this.selectedCategories,
    required this.selectedBrands,
    required this.priceRange,
    required this.selectedRatings,
    required this.inStockOnly,
    required this.onSaleOnly,
    required this.minPriceController,
    required this.maxPriceController,
    required this.onCategoryToggle,
    required this.onBrandToggle,
    required this.onPriceRangeChanged,
    required this.onRatingToggle,
    required this.onStockToggle,
    required this.onSaleToggle,
    required this.onClear,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = settings.isDarkMode;
    final bgColor = isDark ? const Color(0xFF111827) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF111827);
    final fieldBg = isDark ? const Color(0xFF1F2937) : Colors.grey[100];
    final unselectedChipBg = isDark ? const Color(0xFF1F2937) : Colors.grey[100]!;
    final unselectedChipText = isDark ? Colors.grey[300]! : Colors.grey[600]!;

    return Drawer(
      width: MediaQuery.of(context).size.width * 0.85,
      backgroundColor: bgColor,
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    settings.translate('filters'),
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: textColor),
                  ),
                  TextButton(
                    onPressed: onClear,
                    child: Text(
                      settings.translate('clear_filter'),
                      style: const TextStyle(color: Color(0xFFDC2626), fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  // Categories
                  _buildSectionTitle(settings.translate('categories'), textColor),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: categories.map((cat) => _buildChip(cat, selectedCategories.contains(cat), () => onCategoryToggle(cat), unselectedChipBg, unselectedChipText)).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Brands
                  _buildSectionTitle(settings.translate('brands'), textColor),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: brands.map((brand) => _buildChip(brand, selectedBrands.contains(brand), () => onBrandToggle(brand), unselectedChipBg, unselectedChipText)).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Price Range
                  _buildSectionTitle(settings.translate('price_range'), textColor),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: minPriceController,
                          keyboardType: TextInputType.number,
                          style: TextStyle(color: textColor),
                          decoration: InputDecoration(
                            hintText: 'Min',
                            hintStyle: const TextStyle(color: Colors.grey),
                            filled: true,
                            fillColor: fieldBg,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          onChanged: (val) {
                            double? min = double.tryParse(val);
                            if (min != null) onPriceRangeChanged(RangeValues(min, priceRange.end));
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text('-', style: TextStyle(color: textColor)),
                      ),
                      Expanded(
                        child: TextField(
                          controller: maxPriceController,
                          keyboardType: TextInputType.number,
                          style: TextStyle(color: textColor),
                          decoration: InputDecoration(
                            hintText: 'Max',
                            hintStyle: const TextStyle(color: Colors.grey),
                            filled: true,
                            fillColor: fieldBg,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          onChanged: (val) {
                            double? max = double.tryParse(val);
                            if (max != null) onPriceRangeChanged(RangeValues(priceRange.start, max));
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Ratings
                  _buildSectionTitle(settings.translate('rating'), textColor),
                  Wrap(
                    spacing: 8,
                    children: [5, 4, 3, 2, 1].map((star) => _buildRatingChip(star, unselectedChipBg, unselectedChipText)).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Toggles
                  _buildToggleRow(settings.translate('only_in_stock'), inStockOnly, onStockToggle, textColor),
                  _buildToggleRow(settings.translate('on_sale_products'), onSaleOnly, onSaleToggle, textColor),
                  const SizedBox(height: 80),
                ],
              ),
            ),

            // Apply Button
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    onApply();
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDC2626),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: Text(settings.translate('search_btn'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, Color textColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
    );
  }

  Widget _buildChip(String label, bool isSelected, VoidCallback onTap, Color unselectedBg, Color unselectedText) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFDC2626) : unselectedBg,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          label,
          style: TextStyle(color: isSelected ? Colors.white : unselectedText, fontSize: 13, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildRatingChip(int star, Color unselectedBg, Color unselectedText) {
    bool isSelected = selectedRatings.contains(star);
    return GestureDetector(
      onTap: () => onRatingToggle(star),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFDC2626) : unselectedBg,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('$star', style: TextStyle(color: isSelected ? Colors.white : unselectedText, fontWeight: FontWeight.bold)),
            const SizedBox(width: 4),
            Icon(Icons.star_rounded, size: 16, color: isSelected ? Colors.white : Colors.amber),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleRow(String title, bool value, Function(bool) onChanged, Color textColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: TextStyle(fontWeight: FontWeight.w500, color: textColor)),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: const Color(0xFFDC2626),
        ),
      ],
    );
  }
}
