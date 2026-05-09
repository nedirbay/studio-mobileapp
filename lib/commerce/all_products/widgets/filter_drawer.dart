import 'package:flutter/material.dart';

class FilterDrawer extends StatelessWidget {
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
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.85,
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Filterler', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
                  TextButton(
                    onPressed: onClear,
                    child: const Text('Arassala', style: TextStyle(color: Color(0xFFDC2626), fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  // Categories
                  _buildSectionTitle('Kategoriýalar'),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: categories.map((cat) => _buildChip(cat, selectedCategories.contains(cat), () => onCategoryToggle(cat))).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Brands
                  _buildSectionTitle('Brendler'),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: brands.map((brand) => _buildChip(brand, selectedBrands.contains(brand), () => onBrandToggle(brand))).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Price Range
                  _buildSectionTitle('Baha aralygy (TMT)'),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: minPriceController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: 'Min',
                            filled: true,
                            fillColor: Colors.grey[100],
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          onChanged: (val) {
                            double? min = double.tryParse(val);
                            if (min != null) onPriceRangeChanged(RangeValues(min, priceRange.end));
                          },
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Text('-'),
                      ),
                      Expanded(
                        child: TextField(
                          controller: maxPriceController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: 'Max',
                            filled: true,
                            fillColor: Colors.grey[100],
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
                  _buildSectionTitle('Reýting'),
                  Wrap(
                    spacing: 8,
                    children: [5, 4, 3, 2, 1].map((star) => _buildRatingChip(star)).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Toggles
                  _buildToggleRow('Diňe ammarda bar', inStockOnly, onStockToggle),
                  _buildToggleRow('Arzanlaşykdaky harytlar', onSaleOnly, onSaleToggle),
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
                  child: const Text('Gözle', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
    );
  }

  Widget _buildChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFDC2626) : Colors.grey[100],
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          label,
          style: TextStyle(color: isSelected ? Colors.white : Colors.grey[600], fontSize: 13, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildRatingChip(int star) {
    bool isSelected = selectedRatings.contains(star);
    return GestureDetector(
      onTap: () => onRatingToggle(star),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFDC2626) : Colors.grey[100],
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('$star', style: TextStyle(color: isSelected ? Colors.white : Colors.grey[600], fontWeight: FontWeight.bold)),
            const SizedBox(width: 4),
            Icon(Icons.star_rounded, size: 16, color: isSelected ? Colors.white : Colors.amber),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleRow(String title, bool value, Function(bool) onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: const Color(0xFFDC2626),
        ),
      ],
    );
  }
}
