import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../services/admin_service.dart';

const Map<String, String> tailwindColorNames = {
  'from-blue-900/80': 'Gök (Dark Blue)',
  'from-red-900/80': 'Gyzyl (Dark Red)',
  'from-emerald-900/80': 'Ýaşyl (Dark Green)',
  'from-cyan-900/80': 'Mawy (Cyan)',
  'from-slate-900/80': 'Gara (Black)',
  'from-indigo-900/80': 'Benewşe (Indigo)',
};

const Map<String, Color> tailwindColors = {
  'from-blue-900/80': Color(0xFF0D47A1),
  'from-red-900/80': Color(0xFFB71C1C),
  'from-emerald-900/80': Color(0xFF065F46),
  'from-cyan-900/80': Color(0xFF006064),
  'from-slate-900/80': Color(0xFF0F172A),
  'from-indigo-900/80': Color(0xFF311B92),
};

Color getBannerBgColor(String? bgClass) {
  if (bgClass == null) return Colors.grey;
  return tailwindColors[bgClass] ?? Colors.grey;
}

class AdminBannersPage extends StatefulWidget {
  const AdminBannersPage({super.key});

  @override
  State<AdminBannersPage> createState() => _AdminBannersPageState();
}

class _AdminBannersPageState extends State<AdminBannersPage> {
  bool _isLoading = true;
  List<dynamic> _banners = [];
  List<dynamic> _products = [];
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
      final bannersData = await AdminService.listBanners();
      final productsData = await AdminService.listProducts();
      setState(() {
        _banners = bannersData;
        _products = productsData;
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
    final ctaTextController = TextEditingController(text: isEdit ? banner['ctaText'] ?? 'Söwda et' : 'Söwda et');

    String selectedBgColor = isEdit ? banner['bgColor'] ?? 'from-red-900/80' : 'from-red-900/80';
    int? selectedProductId = isEdit ? (banner['product_id'] ?? banner['productId']) : null;

    // Image state
    String? uploadedImageUrl = isEdit ? banner['image'] ?? '' : null;
    PlatformFile? pickedImageFile;
    bool isUploading = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            Future<void> pickImage() async {
              try {
                final result = await FilePicker.pickFiles(
                  type: FileType.image,
                );
                if (result != null && result.files.isNotEmpty) {
                  setModalState(() {
                    pickedImageFile = result.files.first;
                  });
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Surat saýlap bolmady: $e')),
                );
              }
            }

            return AlertDialog(
              title: Text(isEdit ? 'Banneri üýtgetmek' : 'Täze banner'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
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
                      maxLines: 2,
                      decoration: const InputDecoration(labelText: 'Düşündiriş'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: ctaTextController,
                      decoration: const InputDecoration(labelText: 'Düwmäniň ýazgysy (CTA Text)'),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: tailwindColorNames.containsKey(selectedBgColor) ? selectedBgColor : 'from-red-900/80',
                      decoration: const InputDecoration(labelText: 'Arka tarapyň reňki'),
                      isExpanded: true,
                      items: tailwindColorNames.entries.map((e) {
                        return DropdownMenuItem<String>(
                          value: e.key,
                          child: Row(
                            children: [
                              Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: tailwindColors[e.key],
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  e.value,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setModalState(() {
                            selectedBgColor = val;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<int?>(
                      value: _products.any((p) => p['id'] == selectedProductId) ? selectedProductId : null,
                      decoration: const InputDecoration(labelText: 'Baglanjak haryt (Product)'),
                      isExpanded: true,
                      items: [
                        const DropdownMenuItem<int?>(
                          value: null,
                          child: Text('Hiç haryt baglanmady', overflow: TextOverflow.ellipsis),
                        ),
                        ..._products.map((p) {
                          return DropdownMenuItem<int?>(
                            value: p['id'] as int?,
                            child: Text(
                              p['name']?.toString() ?? 'Nämälim haryt',
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }),
                      ],
                      onChanged: (val) {
                        setModalState(() {
                          selectedProductId = val;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    // Image preview and upload
                    const Text(
                      'Banner suraty',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    if (pickedImageFile != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: pickedImageFile!.bytes != null
                              ? Image.memory(
                                  pickedImageFile!.bytes!,
                                  height: 120,
                                  fit: BoxFit.cover,
                                )
                              : (pickedImageFile!.path != null
                                  ? Image.network(
                                      pickedImageFile!.path!,
                                      height: 120,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
                                    )
                                  : const SizedBox.shrink()),
                        ),
                      )
                    else if (uploadedImageUrl != null && uploadedImageUrl!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            uploadedImageUrl!,
                            height: 120,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
                          ),
                        ),
                      ),
                    ElevatedButton.icon(
                      onPressed: isUploading ? null : pickImage,
                      icon: const Icon(Icons.image_outlined),
                      label: Text(
                        pickedImageFile != null
                            ? (pickedImageFile!.name.length > 20
                                ? '${pickedImageFile!.name.substring(0, 17)}...'
                                : pickedImageFile!.name)
                            : (uploadedImageUrl != null && uploadedImageUrl!.isNotEmpty
                                ? 'Suraty üýtget'
                                : 'Surat saýlaň'),
                        overflow: TextOverflow.ellipsis,
                      ),
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
                  onPressed: isUploading
                      ? null
                      : () async {
                          if (titleController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Sözbaşy hökman doldurylmaly'), backgroundColor: Colors.orange),
                            );
                            return;
                          }

                          String? finalImageUrl = uploadedImageUrl;

                          // Upload if new image picked
                          if (pickedImageFile != null) {
                            setModalState(() => isUploading = true);
                            try {
                              finalImageUrl = await AdminService.uploadImage(
                                filePath: pickedImageFile!.path,
                                fileBytes: pickedImageFile!.bytes,
                                fileName: pickedImageFile!.name,
                              );
                            } catch (e) {
                              setModalState(() => isUploading = false);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Surat ýüklenip bolmady: $e'), backgroundColor: Colors.red),
                              );
                              return;
                            }
                            setModalState(() => isUploading = false);
                          }

                          if (finalImageUrl == null || finalImageUrl.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Surat hökman saýlanmaly'), backgroundColor: Colors.orange),
                            );
                            return;
                          }

                          final payload = {
                            if (isEdit) 'id': banner['id'],
                            'title': titleController.text,
                            'subtitle': subtitleController.text.isNotEmpty ? subtitleController.text : null,
                            'description': descController.text.isNotEmpty ? descController.text : null,
                            'bgColor': selectedBgColor,
                            'image': finalImageUrl,
                            'ctaText': ctaTextController.text.isNotEmpty ? ctaTextController.text : 'Söwda et',
                            'product_id': selectedProductId,
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
                  child: isUploading
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Ýatda sakla'),
                ),
              ],
            );
          },
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
                      padding: EdgeInsets.only(
                        left: 16,
                        right: 16,
                        top: 16,
                        bottom: MediaQuery.of(context).padding.bottom + 82,
                      ),
                      itemCount: _banners.length,
                      itemBuilder: (context, index) {
                        final banner = _banners[index];
                        final int id = banner['id'] ?? 0;
                        final String title = banner['title'] ?? '';
                        final String subtitle = banner['subtitle'] ?? '';
                        final String desc = banner['description'] ?? '';
                        final String image = banner['image'] ?? '';
                        final String bgColorStr = banner['bgColor'] ?? 'from-red-900/80';
                        Color bgColor = getBannerBgColor(bgColorStr);

                        final int? linkedId = banner['product_id'] ?? banner['productId'];
                        final String linkedProductName = _products.firstWhere(
                          (p) => p['id'] == linkedId,
                          orElse: () => null,
                        )?['name']?.toString() ?? 'Nämälim haryt';

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
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white70,
                                              ),
                                            ),
                                          const SizedBox(height: 4),
                                          Text(
                                            title,
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit_outlined, color: Colors.white),
                                          onPressed: () => _showBannerEditor(banner),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete_outline, color: Colors.white70),
                                          onPressed: () => _deleteBanner(id),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                if (desc.isNotEmpty) ...[
                                  const SizedBox(height: 6),
                                  Text(
                                    desc,
                                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                                  ),
                                ],
                                if (linkedId != null) ...[
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.link, size: 14, color: Colors.white),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            'Baglanan haryt: $linkedProductName',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
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
                                        color: Colors.white24,
                                        child: const Center(child: Icon(Icons.broken_image, color: Colors.white30)),
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
