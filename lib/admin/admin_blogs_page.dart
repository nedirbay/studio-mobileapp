import 'package:flutter/material.dart';
import '../services/admin_service.dart';

class AdminBlogsPage extends StatefulWidget {
  const AdminBlogsPage({super.key});

  @override
  State<AdminBlogsPage> createState() => _AdminBlogsPageState();
}

class _AdminBlogsPageState extends State<AdminBlogsPage> {
  bool _isLoading = true;
  List<dynamic> _blogs = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadBlogs();
  }

  Future<void> _loadBlogs() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final data = await AdminService.listBlogs();
      setState(() {
        _blogs = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteBlog(String slug) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Blogy pozmak'),
        content: const Text('Hakykatdan hem bu blogy pozmak isleýärsiňizmi?'),
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
      await AdminService.deleteBlog(slug);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Blog pozuldy'), backgroundColor: Colors.green),
      );
      _loadBlogs();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    }
  }

  void _showBlogEditor([dynamic blog]) {
    final bool isEdit = blog != null;
    final titleController = TextEditingController(text: isEdit ? blog['title'] ?? '' : '');
    final slugController = TextEditingController(text: isEdit ? blog['slug'] ?? '' : '');
    final imageController = TextEditingController(text: isEdit ? blog['image'] ?? '' : '');
    final tagsController = TextEditingController(text: isEdit ? (blog['tags'] is List ? (blog['tags'] as List).join(', ') : blog['tags'] ?? '') : '');
    final contentController = TextEditingController(text: isEdit ? blog['content'] ?? '' : '');

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
                  isEdit ? 'Blogy üýtgetmek' : 'Täze blog goşmak',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Mowzugy (Title)', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: slugController,
                  decoration: const InputDecoration(labelText: 'Slug (mes: taze-harytlar)', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: imageController,
                  decoration: const InputDecoration(labelText: 'Surat URL', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: tagsController,
                  decoration: const InputDecoration(labelText: 'Tegler (Taglar, otur bilen bölüň)', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: contentController,
                  maxLines: 6,
                  decoration: const InputDecoration(labelText: 'Mazmuny (Content)', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (titleController.text.isEmpty || slugController.text.isEmpty || contentController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Mowzugy, slug we mazmuny hökmany doldurylmalydyr!'), backgroundColor: Colors.orange),
                        );
                        return;
                      }

                      final List<String> tags = tagsController.text.split(',').map((t) => t.trim()).where((t) => t.isNotEmpty).toList();

                      final payload = {
                        'title': titleController.text,
                        'slug': slugController.text,
                        'content': contentController.text,
                        'image': imageController.text.isNotEmpty ? imageController.text : null,
                        'tags': tags,
                      };

                      try {
                        if (isEdit) {
                          await AdminService.updateBlog(blog['slug'], payload);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Blog täzelendi'), backgroundColor: Colors.green),
                          );
                        } else {
                          await AdminService.createBlog(payload);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Täze blog goşuldy'), backgroundColor: Colors.green),
                          );
                        }
                        Navigator.pop(context);
                        _loadBlogs();
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
        title: const Text('Blog Postlary', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadBlogs),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFDC2626)))
          : _error != null
              ? Center(child: Text(_error!))
              : _blogs.isEmpty
                  ? const Center(child: Text('Blog tapylmady'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _blogs.length,
                      itemBuilder: (context, index) {
                        final blog = _blogs[index];
                        final String title = blog['title'] ?? '';
                        final String slug = blog['slug'] ?? '';
                        final String image = blog['image'] ?? '';

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          color: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: const BorderSide(color: Color(0xFFE5E7EB)),
                          ),
                          child: ListTile(
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: image.isNotEmpty
                                  ? Image.network(
                                      image,
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(width: 50, height: 50, color: Colors.grey[200], child: const Icon(Icons.image)),
                                    )
                                  : Container(width: 50, height: 50, color: Colors.grey[200], child: const Icon(Icons.image)),
                            ),
                            title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('Slug: $slug'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                                  onPressed: () => _showBlogEditor(blog),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                                  onPressed: () => _deleteBlog(slug),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        onPressed: () => _showBlogEditor(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
