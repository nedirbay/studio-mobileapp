import 'package:flutter/material.dart';
import '../services/admin_service.dart';

class AdminPhotoStudioPage extends StatefulWidget {
  const AdminPhotoStudioPage({super.key});

  @override
  State<AdminPhotoStudioPage> createState() => _AdminPhotoStudioPageState();
}

class _AdminPhotoStudioPageState extends State<AdminPhotoStudioPage> {
  bool _isLoading = true;
  List<dynamic> _collections = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCollections();
  }

  Future<void> _loadCollections() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final data = await AdminService.listCollections();
      setState(() {
        _collections = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteCollection(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kolleksiýany pozmak'),
        content: const Text('Hakykatdan hem bu galereýa kolleksiýasyny pozmak isleýärsiňizmi?'),
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
      await AdminService.deleteCollection(id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kolleksiýa pozuldy'), backgroundColor: Colors.green),
      );
      _loadCollections();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    }
  }

  void _showCollectionEditor([dynamic col]) {
    final bool isEdit = col != null;
    final nameController = TextEditingController(text: isEdit ? col['name'] ?? '' : '');
    String kind = isEdit ? col['kind'] ?? 'image' : 'image';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              title: Text(isEdit ? 'Kolleksiýany üýtgetmek' : 'Täze kolleksiýa'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Kolleksiýa ady'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: kind,
                    decoration: const InputDecoration(labelText: 'Görnüşi (Kind)'),
                    items: const [
                      DropdownMenuItem(value: 'image', child: Text('Surat (Image)')),
                      DropdownMenuItem(value: 'video', child: Text('Wideo (Video / Reel)')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setModalState(() {
                          kind = val;
                        });
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Ýatyr')),
                TextButton(
                  onPressed: () async {
                    if (nameController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Ady dolduryň'), backgroundColor: Colors.orange),
                      );
                      return;
                    }

                    final payload = {
                      'name': nameController.text,
                      'kind': kind,
                    };

                    try {
                      if (isEdit) {
                        await AdminService.updateCollection(col['id'], payload);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Kolleksiýa täzelendi'), backgroundColor: Colors.green),
                        );
                      } else {
                        await AdminService.createCollection(payload);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Täze kolleksiýa döredildi'), backgroundColor: Colors.green),
                        );
                      }
                      Navigator.pop(context);
                      _loadCollections();
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
      },
    );
  }

  void _showItemsPage(dynamic col) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdminCollectionItemsPage(
          collectionId: col['id'],
          collectionName: col['name'] ?? '',
          collectionKind: col['kind'] ?? 'image',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text('Foto Galereýa & Wideo', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadCollections),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFDC2626)))
          : _error != null
              ? Center(child: Text(_error!))
              : _collections.isEmpty
                  ? const Center(child: Text('Kolleksiýa tapylmady'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _collections.length,
                      itemBuilder: (context, index) {
                        final col = _collections[index];
                        final int id = col['id'] ?? 0;
                        final String name = col['name'] ?? '';
                        final String kind = col['kind'] ?? 'image';
                        final int count = col['items_count'] ?? 0;

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          color: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: const BorderSide(color: Color(0xFFE5E7EB)),
                          ),
                          child: ListTile(
                            leading: Icon(
                              kind == 'video' ? Icons.play_circle_outline_rounded : Icons.photo_outlined,
                              color: kind == 'video' ? Colors.red : Colors.blue,
                              size: 28,
                            ),
                            title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('Görnüşi: ${kind == "video" ? "Wideo/Reel" : "Surat"} | San: $count'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.collections_outlined, color: Colors.teal),
                                  onPressed: () => _showItemsPage(col),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                                  onPressed: () => _showCollectionEditor(col),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                                  onPressed: () => _deleteCollection(id),
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
        onPressed: () => _showCollectionEditor(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class AdminCollectionItemsPage extends StatefulWidget {
  final int collectionId;
  final String collectionName;
  final String collectionKind;

  const AdminCollectionItemsPage({
    super.key,
    required this.collectionId,
    required this.collectionName,
    required this.collectionKind,
  });

  @override
  State<AdminCollectionItemsPage> createState() => _AdminCollectionItemsPageState();
}

class _AdminCollectionItemsPageState extends State<AdminCollectionItemsPage> {
  bool _isLoading = true;
  List<dynamic> _items = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final data = await AdminService.listCollectionItems(widget.collectionId);
      setState(() {
        _items = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteItem(int itemId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Suraty pozmak'),
        content: const Text('Bu suraty galereýadan pozmak isleýärsiňizmi?'),
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
      await AdminService.deleteCollectionItem(widget.collectionId, itemId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Surat pozuldy'), backgroundColor: Colors.green),
      );
      _loadItems();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    }
  }

  void _showItemAdder() {
    final urlController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Galereýa surat/wideo goşmak'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: urlController,
                decoration: const InputDecoration(labelText: 'Media URL'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descController,
                decoration: const InputDecoration(labelText: 'Düşündiriş'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Ýatyr')),
            TextButton(
              onPressed: () async {
                if (urlController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('URL doldurylmalydyr!'), backgroundColor: Colors.orange),
                  );
                  return;
                }

                final payload = {
                  'url': urlController.text,
                  'description': descController.text.isNotEmpty ? descController.text : null,
                  'kind': widget.collectionKind,
                };

                try {
                  await AdminService.createCollectionItem(widget.collectionId, payload);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Täze media goşuldy!'), backgroundColor: Colors.green),
                  );
                  _loadItems();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
                  );
                }
              },
              child: const Text('Goş'),
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
        title: Text(widget.collectionName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadItems),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFDC2626)))
          : _error != null
              ? Center(child: Text(_error!))
              : _items.isEmpty
                  ? const Center(child: Text('Media tapylmady'))
                  : GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.9,
                      ),
                      itemCount: _items.length,
                      itemBuilder: (context, index) {
                        final item = _items[index];
                        final int id = item['id'] ?? 0;
                        final String url = item['url'] ?? '';

                        return Card(
                          color: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: const BorderSide(color: Color(0xFFE5E7EB)),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: url.isNotEmpty
                                    ? Image.network(
                                        url,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Container(
                                          color: Colors.grey[200],
                                          child: const Icon(Icons.broken_image),
                                        ),
                                      )
                                    : Container(color: Colors.grey[200], child: const Icon(Icons.image)),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        item['description'] ?? '',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ),
                                    IconButton(
                                      constraints: const BoxConstraints(),
                                      padding: EdgeInsets.zero,
                                      icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                                      onPressed: () => _deleteItem(id),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        onPressed: _showItemAdder,
        child: const Icon(Icons.add),
      ),
    );
  }
}
