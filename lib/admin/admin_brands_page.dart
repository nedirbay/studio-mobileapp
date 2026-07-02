import 'package:flutter/material.dart';
import '../services/admin_service.dart';

class AdminBrandsPage extends StatefulWidget {
  const AdminBrandsPage({super.key});

  @override
  State<AdminBrandsPage> createState() => _AdminBrandsPageState();
}

class _AdminBrandsPageState extends State<AdminBrandsPage> {
  bool _isLoading = true;
  List<dynamic> _brands = [];
  List<dynamic> _filteredBrands = [];
  String _searchQuery = '';
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadBrands();
  }

  Future<void> _loadBrands() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final data = await AdminService.listBrands();
      setState(() {
        _brands = data;
        _filterBrands();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  void _filterBrands() {
    setState(() {
      _filteredBrands = _brands.where((b) {
        return (b['name'] ?? '').toString().toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    });
  }

  Future<void> _deleteBrand(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Brendi pozmak'),
        content: const Text('Hakykatdan hem bu brendi pozmak isleýärsiňizmi?'),
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
      await AdminService.deleteBrand(id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Brend pozuldy'), backgroundColor: Colors.green),
      );
      _loadBrands();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    }
  }

  void _showBrandEditor([dynamic brand]) {
    final bool isEdit = brand != null;
    final nameController = TextEditingController(text: isEdit ? brand['name'] ?? '' : '');
    final logoController = TextEditingController(text: isEdit ? brand['logo'] ?? '' : '');
    final siteController = TextEditingController(text: isEdit ? brand['site'] ?? '' : '');
    final descController = TextEditingController(text: isEdit ? brand['description'] ?? '' : '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isEdit ? 'Brendi üýtgetmek' : 'Täze brend'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Ady'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: logoController,
                  decoration: const InputDecoration(labelText: 'Logo URL'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: siteController,
                  decoration: const InputDecoration(labelText: 'Web saýty'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descController,
                  maxLines: 2,
                  decoration: const InputDecoration(labelText: 'Düşündiriş'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Ýatyr'),
            ),
            TextButton(
              onPressed: () async {
                if (nameController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Ady hökman doldurylmaly'), backgroundColor: Colors.orange),
                  );
                  return;
                }

                final payload = {
                  'name': nameController.text,
                  'logo': logoController.text.isNotEmpty ? logoController.text : null,
                  'site': siteController.text.isNotEmpty ? siteController.text : null,
                  'description': descController.text.isNotEmpty ? descController.text : null,
                };

                try {
                  if (isEdit) {
                    await AdminService.updateBrand(brand['id'], payload);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Brend täzelendi'), backgroundColor: Colors.green),
                    );
                  } else {
                    await AdminService.createBrand(payload);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Täze brend döredildi'), backgroundColor: Colors.green),
                    );
                  }
                  Navigator.pop(context);
                  _loadBrands();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
                  );
                }
              },
              child: const Text('Ýatda sakla'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text('Brendler', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadBrands),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Brend gözle...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (val) {
                _searchQuery = val;
                _filterBrands();
              },
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFFDC2626)))
                : _error != null
                    ? Center(child: Text(_error!))
                    : _filteredBrands.isEmpty
                        ? const Center(child: Text('Brend tapylmady'))
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _filteredBrands.length,
                            itemBuilder: (context, index) {
                              final brand = _filteredBrands[index];
                              final int id = brand['id'] ?? 0;
                              final String name = brand['name'] ?? '';
                              final String logo = brand['logo'] ?? '';
                              final String site = brand['site'] ?? '';

                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                color: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  side: const BorderSide(color: Color(0xFFE5E7EB)),
                                ),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: const Color(0xFFF3F4F6),
                                    backgroundImage: logo.isNotEmpty ? NetworkImage(logo) : null,
                                    child: logo.isEmpty ? const Icon(Icons.copyright) : null,
                                  ),
                                  title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  subtitle: Text(site.isNotEmpty ? site : 'Web saýt ýok'),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                                        onPressed: () => _showBrandEditor(brand),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                                        onPressed: () => _deleteBrand(id),
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
        onPressed: () => _showBrandEditor(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
