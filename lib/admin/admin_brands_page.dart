import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
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
    final descController = TextEditingController(text: isEdit ? brand['description'] ?? '' : '');

    // Logo state
    String? uploadedLogoUrl = isEdit ? (brand['logo_url'] ?? brand['logo'] ?? '') : null;
    PlatformFile? pickedLogoFile;
    bool isUploading = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            Future<void> pickLogo() async {
              try {
                final result = await FilePicker.pickFiles(
                  type: FileType.image,
                );
                if (result != null && result.files.isNotEmpty) {
                  setModalState(() {
                    pickedLogoFile = result.files.first;
                  });
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Surat saýlap bolmady: $e')),
                );
              }
            }

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
                    // Logo picker
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Preview
                        if (pickedLogoFile != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: pickedLogoFile!.bytes != null
                                  ? Image.memory(
                                      pickedLogoFile!.bytes!,
                                      height: 100,
                                      fit: BoxFit.cover,
                                    )
                                  : const SizedBox.shrink(),
                            ),
                          )
                        else if (uploadedLogoUrl != null && uploadedLogoUrl!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                uploadedLogoUrl!,
                                height: 100,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 48),
                              ),
                            ),
                          ),
                        ElevatedButton.icon(
                          onPressed: isUploading ? null : pickLogo,
                          icon: const Icon(Icons.image_outlined),
                          label: Text(
                            pickedLogoFile != null
                                ? pickedLogoFile!.name
                                : (uploadedLogoUrl != null && uploadedLogoUrl!.isNotEmpty
                                    ? 'Logoý üýtget'
                                    : 'Logo surat saýlaň'),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: pickedLogoFile != null
                                ? Colors.green[50]
                                : Colors.grey[200],
                            foregroundColor: pickedLogoFile != null
                                ? Colors.green[800]
                                : Colors.black87,
                            elevation: 0,
                          ),
                        ),
                      ],
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
                  onPressed: isUploading
                      ? null
                      : () async {
                          if (nameController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Ady hökman doldurylmaly'), backgroundColor: Colors.orange),
                            );
                            return;
                          }

                          String? finalLogoUrl = uploadedLogoUrl;

                          // Upload new logo if picked
                          if (pickedLogoFile != null) {
                            setModalState(() => isUploading = true);
                            try {
                              finalLogoUrl = await AdminService.uploadImage(
                                filePath: pickedLogoFile!.path,
                                fileBytes: pickedLogoFile!.bytes,
                                fileName: pickedLogoFile!.name,
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

                          final payload = {
                            'name': nameController.text,
                            'logo_url': finalLogoUrl ?? '',
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
        title: const Text('Brendler', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadBrands),
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
                const SizedBox(width: 10),
                SizedBox(
                  height: 52,
                  width: 52,
                  child: ElevatedButton(
                    onPressed: () => _showBrandEditor(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: const Icon(Icons.add, size: 26),
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
                    : _filteredBrands.isEmpty
                        ? const Center(child: Text('Brend tapylmady'))
                        : ListView.builder(
                            padding: EdgeInsets.fromLTRB(
                              16,
                              0,
                              16,
                              MediaQuery.of(context).padding.bottom + 16,
                            ),
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
    );
  }
}
