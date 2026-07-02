import 'package:flutter/material.dart';
import '../services/admin_service.dart';

class AdminBannersPage extends StatefulWidget {
  const AdminBannersPage({super.key});

  @override
  State<AdminBannersPage> createState() => _AdminBannersPageState();
}

class _AdminBannersPageState extends State<AdminBannersPage> {
  bool _isLoading = true;
  List<dynamic> _banners = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadBanners();
  }

  Future<void> _loadBanners() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final data = await AdminService.listBanners();
      setState(() {
        _banners = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteBanner(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Banneri pozmak'),
        content: const Text('Hakykatdan hem bu banneri pozmak isleýärsiňizmi?'),
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
      await AdminService.deleteBanner(id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Banner pozuldy'), backgroundColor: Colors.green),
      );
      _loadBanners();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    }
  }

  void _showBannerEditor([dynamic banner]) {
    final bool isEdit = banner != null;
    final titleController = TextEditingController(text: isEdit ? banner['title'] ?? '' : '');
    final subtitleController = TextEditingController(text: isEdit ? banner['subtitle'] ?? '' : '');
    final descController = TextEditingController(text: isEdit ? banner['description'] ?? '' : '');
    final bgColorController = TextEditingController(text: isEdit ? banner['bgColor'] ?? '#FFFFFF' : '#FFFFFF');
    final imageController = TextEditingController(text: isEdit ? banner['image'] ?? '' : '');
    final ctaTextController = TextEditingController(text: isEdit ? banner['ctaText'] ?? '' : '');
    final productIdController = TextEditingController(text: isEdit ? (banner['product_id'] ?? banner['productId'] ?? '').toString() : '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isEdit ? 'Banneri üýtgetmek' : 'Täze banner'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Sözbaşy (Title)'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: subtitleController,
                  decoration: const InputDecoration(labelText: 'Kiçi sözbaşy (Subtitle)'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(labelText: 'Düşündiriş'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: bgColorController,
                  decoration: const InputDecoration(labelText: 'Arka reňk (bgColor, hex format)'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: imageController,
                  decoration: const InputDecoration(labelText: 'Surat URL'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: ctaTextController,
                  decoration: const InputDecoration(labelText: 'CTA düwme ýazgysy (CTA Text)'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: productIdController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Degişli Haryt ID (Product ID)'),
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
                if (titleController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Sözbaşy hökman doldurylmaly'), backgroundColor: Colors.orange),
                  );
                  return;
                }

                final payload = {
                  if (isEdit) 'id': banner['id'],
                  'title': titleController.text,
                  'subtitle': subtitleController.text.isNotEmpty ? subtitleController.text : null,
                  'description': descController.text.isNotEmpty ? descController.text : null,
                  'bgColor': bgColorController.text,
                  'image': imageController.text.isNotEmpty ? imageController.text : null,
                  'ctaText': ctaTextController.text.isNotEmpty ? ctaTextController.text : null,
                  'product_id': productIdController.text.isNotEmpty ? int.tryParse(productIdController.text) : null,
                };

                try {
                  if (isEdit) {
                    await AdminService.updateBanner(payload);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Banner täzelendi'), backgroundColor: Colors.green),
                    );
                  } else {
                    await AdminService.createBanner(payload);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Täze banner goşuldy'), backgroundColor: Colors.green),
                    );
                  }
                  Navigator.pop(context);
                  _loadBanners();
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
        title: const Text('Bannerler', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadBanners),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFDC2626)))
          : _error != null
              ? Center(child: Text(_error!))
              : _banners.isEmpty
                  ? const Center(child: Text('Banner tapylmady'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _banners.length,
                      itemBuilder: (context, index) {
                        final banner = _banners[index];
                        final int id = banner['id'] ?? 0;
                        final String title = banner['title'] ?? '';
                        final String subtitle = banner['subtitle'] ?? '';
                        final String image = banner['image'] ?? '';
                        final String bgColorStr = banner['bgColor'] ?? '#FFFFFF';
                        Color bgColor = Colors.white;
                        try {
                          bgColor = Color(int.parse(bgColorStr.replaceFirst('#', '0xFF')));
                        } catch (_) {}

                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          color: bgColor,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: const BorderSide(color: Color(0xFFE5E7EB)),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          if (subtitle.isNotEmpty)
                                            Text(
                                              subtitle,
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          const SizedBox(height: 4),
                                          Text(
                                            title,
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                                          onPressed: () => _showBannerEditor(banner),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                                          onPressed: () => _deleteBanner(id),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                if (image.isNotEmpty) ...[
                                  const SizedBox(height: 12),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(
                                      image,
                                      width: double.infinity,
                                      height: 120,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(
                                        height: 120,
                                        color: Colors.grey[200],
                                        child: const Center(child: Icon(Icons.broken_image)),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      },
                    ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        onPressed: () => _showBannerEditor(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
