import 'package:flutter/material.dart';
import '../services/admin_service.dart';

class AdminCategoriesPage extends StatefulWidget {
  const AdminCategoriesPage({super.key});

  @override
  State<AdminCategoriesPage> createState() => _AdminCategoriesPageState();
}

class _AdminCategoriesPageState extends State<AdminCategoriesPage> {
  bool _isLoading = true;
  List<dynamic> _categories = [];
  List<dynamic> _filteredCategories = [];
  String _searchQuery = '';
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final data = await AdminService.listCategories();
      setState(() {
        _categories = data;
        _filterCategories();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  void _filterCategories() {
    setState(() {
      _filteredCategories = _categories.where((c) {
        return (c['name'] ?? '').toString().toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    });
  }

  Future<void> _deleteCategory(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kategoriýany pozmak'),
        content: const Text('Hakykatdan hem bu kategoriýany pozmak isleýärsiňizmi?'),
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
      await AdminService.deleteCategory(id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kategoriýa pozuldy'), backgroundColor: Colors.green),
      );
      _loadCategories();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    }
  }

  void _showCategoryEditor([dynamic category]) {
    final bool isEdit = category != null;
    final nameController = TextEditingController(text: isEdit ? category['name'] ?? '' : '');
    final iconController = TextEditingController(text: isEdit ? category['icon'] ?? '📁' : '📁');
    final slugController = TextEditingController(text: isEdit ? category['slug'] ?? '' : '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isEdit ? 'Kategoriýany üýtgetmek' : 'Täze kategoriýa'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Ady'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: iconController,
                decoration: const InputDecoration(labelText: 'Belgi (Emoji/Icon)'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: slugController,
                decoration: const InputDecoration(labelText: 'Slug'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Ýatyr'),
            ),
            TextButton(
              onPressed: () async {
                if (nameController.text.isEmpty || slugController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Ady we Slug hökman doldurylmaly'), backgroundColor: Colors.orange),
                  );
                  return;
                }

                final payload = {
                  'name': nameController.text,
                  'icon': iconController.text,
                  'slug': slugController.text,
                };

                try {
                  if (isEdit) {
                    await AdminService.updateCategory(category['id'], payload);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Kategoriýa täzelendi'), backgroundColor: Colors.green),
                    );
                  } else {
                    await AdminService.createCategory(payload);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Täze kategoriýa döredildi'), backgroundColor: Colors.green),
                    );
                  }
                  Navigator.pop(context);
                  _loadCategories();
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
        title: const Text('Kategoriýalar', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadCategories),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Kategoriýa gözle...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (val) {
                _searchQuery = val;
                _filterCategories();
              },
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFFDC2626)))
                : _error != null
                    ? Center(child: Text(_error!))
                    : _filteredCategories.isEmpty
                        ? const Center(child: Text('Kategoriýa tapylmady'))
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _filteredCategories.length,
                            itemBuilder: (context, index) {
                              final category = _filteredCategories[index];
                              final int id = category['id'] ?? 0;
                              final String name = category['name'] ?? '';
                              final String icon = category['icon'] ?? '📁';
                              final String slug = category['slug'] ?? '';
                              final int count = category['count'] ?? 0;

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
                                    child: Text(icon, style: const TextStyle(fontSize: 20)),
                                  ),
                                  title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  subtitle: Text('Slug: $slug | Haryt sany: $count'),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                                        onPressed: () => _showCategoryEditor(category),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                                        onPressed: () => _deleteCategory(id),
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
        onPressed: () => _showCategoryEditor(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
