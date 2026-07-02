import 'package:flutter/material.dart';
import '../services/admin_service.dart';

class AdminProductsPage extends StatefulWidget {
  const AdminProductsPage({super.key});

  @override
  State<AdminProductsPage> createState() => _AdminProductsPageState();
}

class _AdminProductsPageState extends State<AdminProductsPage> {
  bool _isLoading = true;
  List<dynamic> _products = [];
  List<dynamic> _filteredProducts = [];
  List<dynamic> _categories = [];
  String _searchQuery = '';
  int? _selectedCategoryId;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProductsAndCategories();
  }

  Future<void> _loadProductsAndCategories() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final products = await AdminService.listProducts();
      final categories = await AdminService.listCategories();
      setState(() {
        _products = products;
        _categories = categories;
        _filterProducts();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  void _filterProducts() {
    setState(() {
      _filteredProducts = _products.where((p) {
        final matchesSearch = (p['name'] ?? '').toString().toLowerCase().contains(_searchQuery.toLowerCase());
        final matchesCategory = _selectedCategoryId == null || p['category'] == _selectedCategoryId || p['category_id'] == _selectedCategoryId;
        return matchesSearch && matchesCategory;
      }).toList();
    });
  }

  Future<void> _deleteProduct(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Haryt pozmak'),
        content: const Text('Hakykatdan hem bu harydy pozmak isleýärsiňizmi?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Ýok')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Poz'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await AdminService.deleteProduct(id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Haryt pozuldy'), backgroundColor: Colors.green),
      );
      _loadProductsAndCategories();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    }
  }

  void _showProductEditor([dynamic product]) {
    final bool isEdit = product != null;
    final nameController = TextEditingController(text: isEdit ? product['name'] ?? '' : '');
    final priceController = TextEditingController(text: isEdit ? (product['price'] ?? '').toString() : '');
    final originalPriceController = TextEditingController(text: isEdit ? (product['original_price'] ?? '').toString() : '');
    final brandController = TextEditingController(text: isEdit ? product['marka'] ?? '' : '');
    final descController = TextEditingController(text: isEdit ? product['description'] ?? '' : '');
    final badgeController = TextEditingController(text: isEdit ? product['badge'] ?? '' : '');
    final imageController = TextEditingController(text: isEdit ? (product['image'] ?? (product['media'] != null && product['media'].isNotEmpty ? product['media'][0]['url'] : '')) : '');
    
    int? categoryId = isEdit ? (product['category'] is Map ? product['category']['id'] : product['category_id'] ?? product['category']) : null;
    bool inStock = isEdit ? (product['instock'] == true || product['instock'] == 1) : true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 24,
            left: 24,
            right: 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isEdit ? 'Haryt maglumatlary' : 'Täze Haryt goşmak',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Haryt ady', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: priceController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Bahasy (TMT)', border: OutlineInputBorder()),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: originalPriceController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Köne bahasy (TMT)', border: OutlineInputBorder()),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  value: categoryId,
                  decoration: const InputDecoration(labelText: 'Kategoriýa', border: OutlineInputBorder()),
                  items: _categories
                      .map((c) => DropdownMenuItem<int>(
                            value: c['id'],
                            child: Text(c['name'] ?? ''),
                          ))
                      .toList(),
                  onChanged: (val) => categoryId = val,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: brandController,
                  decoration: const InputDecoration(labelText: 'Brend / Marka', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: imageController,
                  decoration: const InputDecoration(labelText: 'Surat URL', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: badgeController,
                  decoration: const InputDecoration(labelText: 'Badge (mes: Arzanlaşyk, Täze)', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descController,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Düşündiriş', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Galyndyda bar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Switch(
                      value: inStock,
                      activeColor: const Color(0xFFDC2626),
                      onChanged: (val) {
                        inStock = val;
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (nameController.text.isEmpty || priceController.text.isEmpty || categoryId == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Ady, bahasy we kategoriýa hökmany doldurylmalydyr!'), backgroundColor: Colors.orange),
                        );
                        return;
                      }

                      final payload = {
                        'name': nameController.text,
                        'price': double.tryParse(priceController.text) ?? 0.0,
                        'original_price': originalPriceController.text.isNotEmpty ? double.tryParse(originalPriceController.text) : null,
                        'category': categoryId,
                        'marka': brandController.text.isNotEmpty ? brandController.text : null,
                        'description': descController.text.isNotEmpty ? descController.text : null,
                        'badge': badgeController.text.isNotEmpty ? badgeController.text : null,
                        'instock': inStock,
                        if (imageController.text.isNotEmpty)
                          'media': [
                            {'kind': 'image', 'url': imageController.text}
                          ]
                      };

                      try {
                        if (isEdit) {
                          await AdminService.updateProduct(product['id'], payload);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Haryt täzelendi!'), backgroundColor: Colors.green),
                          );
                        } else {
                          await AdminService.createProduct(payload);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Täze haryt goşuldy!'), backgroundColor: Colors.green),
                          );
                        }
                        Navigator.pop(context);
                        _loadProductsAndCategories();
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white),
                    child: const Text('Ýatda sakla'),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text('Harytlar', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadProductsAndCategories),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Haryt gözle...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    onChanged: (val) {
                      _searchQuery = val;
                      _filterProducts();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int?>(
                      value: _selectedCategoryId,
                      hint: const Text('Kategoriýa'),
                      items: [
                        const DropdownMenuItem<int?>(
                          value: null,
                          child: Text('Ählisi'),
                        ),
                        ..._categories.map((c) => DropdownMenuItem<int?>(
                              value: c['id'],
                              child: Text(c['name'] ?? ''),
                            ))
                      ],
                      onChanged: (val) {
                        setState(() {
                          _selectedCategoryId = val;
                          _filterProducts();
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFFDC2626)))
                : _error != null
                    ? Center(child: Text(_error!))
                    : _filteredProducts.isEmpty
                        ? const Center(child: Text('Haryt tapylmady'))
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _filteredProducts.length,
                            itemBuilder: (context, index) {
                              final product = _filteredProducts[index];
                              final int id = product['id'] ?? 0;
                              final String name = product['name'] ?? '';
                              final double price = double.tryParse(product['price']?.toString() ?? '0') ?? 0.0;
                              final String imageUrl = product['image'] ?? '';
                              final bool inStock = product['instock'] == true || product['instock'] == 1;

                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                color: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  side: const BorderSide(color: Color(0xFFE5E7EB)),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(16),
                                        child: imageUrl.isNotEmpty
                                            ? Image.network(
                                                imageUrl,
                                                width: 70,
                                                height: 70,
                                                fit: BoxFit.cover,
                                                errorBuilder: (_, __, ___) => Container(
                                                  width: 70,
                                                  height: 70,
                                                  color: const Color(0xFFF3F4F6),
                                                  child: const Icon(Icons.image, color: Colors.grey),
                                                ),
                                              )
                                            : Container(
                                                width: 70,
                                                height: 70,
                                                color: const Color(0xFFF3F4F6),
                                                child: const Icon(Icons.image, color: Colors.grey),
                                              ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              name,
                                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '$price TMT',
                                              style: const TextStyle(color: Color(0xFFDC2626), fontWeight: FontWeight.w900),
                                            ),
                                            const SizedBox(height: 6),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: inStock ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                inStock ? 'Galyndyda bar' : 'Galyndy ýok',
                                                style: TextStyle(
                                                  color: inStock ? Colors.green : Colors.red,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 11,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                                        onPressed: () => _showProductEditor(product),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                                        onPressed: () => _deleteProduct(id),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        onPressed: () => _showProductEditor(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
