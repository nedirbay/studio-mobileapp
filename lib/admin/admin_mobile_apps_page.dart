import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/admin_service.dart';

class AdminMobileAppsPage extends StatefulWidget {
  const AdminMobileAppsPage({super.key});

  @override
  State<AdminMobileAppsPage> createState() => _AdminMobileAppsPageState();
}

class _AdminMobileAppsPageState extends State<AdminMobileAppsPage> {
  bool _isLoading = true;
  List<dynamic> _versions = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadVersions();
  }

  Future<void> _loadVersions() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final data = await AdminService.listAppVersions();
      setState(() {
        _versions = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteVersion(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Wersiýany pozmak'),
        content: const Text('Hakykatdan hem bu wersiýany pozmak isleýärsiňizmi?'),
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
      await AdminService.deleteAppVersion(id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Wersiýa pozuldy'), backgroundColor: Colors.green),
      );
      _loadVersions();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _activateVersion(int id) async {
    try {
      await AdminService.activateAppVersion(id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Wersiýa işjeňleşdirildi'), backgroundColor: Colors.green),
      );
      _loadVersions();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    }
  }

  void _showVersionEditor([dynamic ver]) {
    final bool isEdit = ver != null;
    final nameController = TextEditingController(text: isEdit ? ver['version_name'] ?? '' : '');
    final codeController = TextEditingController(text: isEdit ? (ver['version_code'] ?? '').toString() : '');
    final descController = TextEditingController(text: isEdit ? ver['description'] ?? '' : '');

    bool isActive = isEdit ? (ver['is_active'] == true || ver['is_active'] == 1) : false;
    bool hasNewFile = false;
    PlatformFile? pickedFile;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            Future<void> pickApkFile() async {
              try {
                final result = await FilePicker.pickFiles(
                  type: FileType.any,
                );
                if (result != null && result.files.isNotEmpty) {
                  setModalState(() {
                    pickedFile = result.files.first;
                    final fileName = pickedFile!.name;
                    if (fileName.endsWith('.apk')) {
                      final cleaned = fileName.replaceAll('.apk', '');
                      final verNameMatch = RegExp(r'v?(\d+\.\d+\.\d+)').firstMatch(cleaned);
                      if (verNameMatch != null) {
                        nameController.text = verNameMatch.group(1) ?? nameController.text;
                      }
                      final verCodeMatch = RegExp(r'[_](\d+)|[-](\d+)$').firstMatch(cleaned);
                      if (verCodeMatch != null) {
                        codeController.text = (verCodeMatch.group(1) ?? verCodeMatch.group(2)) ?? codeController.text;
                      }
                    }
                  });
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Faýl saýlap bolmady: $e')),
                );
              }
            }

            return AlertDialog(
              title: Text(isEdit ? 'Wersiýany redaktirlemek' : 'Täze wersiýa goşmak'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isEdit) ...[
                      ElevatedButton.icon(
                        onPressed: pickApkFile,
                        icon: const Icon(Icons.upload_file),
                        label: Text(pickedFile != null ? pickedFile!.name : 'Täze APK faýl saýlaň (Islege bagly)'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: pickedFile != null ? Colors.red[50] : Colors.grey[200],
                          foregroundColor: pickedFile != null ? Colors.red[800] : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 12),
                    ] else ...[
                      ElevatedButton.icon(
                        onPressed: pickApkFile,
                        icon: const Icon(Icons.upload_file),
                        label: Text(pickedFile != null ? pickedFile!.name : 'APK faýlyny saýlaň'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: pickedFile != null ? Colors.red[50] : Colors.grey[200],
                          foregroundColor: pickedFile != null ? Colors.red[800] : Colors.black,
                        ),
                      ),
                      if (pickedFile == null) ...[
                        const SizedBox(height: 4),
                        const Text(
                          'APK faýly saýlanmasa, ulgam tarapyndan awtomatiki mock APK faýly goşular.',
                          style: TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                      ],
                      const SizedBox(height: 12),
                    ],
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Wersiýa ady (Version Name, mes: 1.0.2)', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: codeController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Wersiýa kody (Version Code, mes: 3)', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descController,
                      maxLines: 4,
                      decoration: const InputDecoration(labelText: 'Ýazgy / Täzelikler (Release Notes)', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Işjeňleşdir (Active)', style: TextStyle(fontWeight: FontWeight.bold)),
                        Switch(
                          value: isActive,
                          onChanged: (val) {
                            setModalState(() {
                              isActive = val;
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Ýatyr')),
                TextButton(
                  onPressed: () async {
                    if (nameController.text.isEmpty || codeController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Haýyş, wersiýa adyny we wersiýa koduny ýazyň.'), backgroundColor: Colors.orange),
                      );
                      return;
                    }

                    final payload = {
                      'version_name': nameController.text,
                      'version_code': int.tryParse(codeController.text) ?? 1,
                      'description': descController.text,
                      'is_active': isActive,
                      'has_new_file': pickedFile != null,
                    };

                    try {
                      if (isEdit) {
                        await AdminService.updateAppVersion(
                          id: ver['id'],
                          payload: payload,
                          filePath: pickedFile?.path,
                          fileBytes: pickedFile?.bytes,
                          fileName: pickedFile?.name,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Wersiýa maglumatlary üstünlikli täzelendi!'), backgroundColor: Colors.green),
                        );
                      } else {
                        await AdminService.createAppVersion(
                          payload: payload,
                          filePath: pickedFile?.path,
                          fileBytes: pickedFile?.bytes,
                          fileName: pickedFile?.name,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Täze wersiýa üstünlikli ýüklendi!'), backgroundColor: Colors.green),
                        );
                      }
                      Navigator.pop(context);
                      _loadVersions();
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
                      );
                    }
                  },
                  child: const Text('Sakla'),
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
        title: const Text('Mobil Programma Wersiýalary', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadVersions),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFDC2626)))
          : _error != null
              ? Center(child: Text(_error!))
              : _versions.isEmpty
                  ? const Center(child: Text('Wersiýa tapylmady'))
                  : ListView.builder(
                      padding: EdgeInsets.only(
                        left: 16,
                        right: 16,
                        top: 16,
                        bottom: MediaQuery.of(context).padding.bottom + 82,
                      ),
                      itemCount: _versions.length,
                      itemBuilder: (context, index) {
                        final ver = _versions[index];
                        final int id = ver['id'] ?? 0;
                        final String name = ver['version_name'] ?? '';
                        final int code = ver['version_code'] ?? 1;
                        final String desc = ver['description'] ?? '';
                        final bool active = ver['is_active'] == true || ver['is_active'] == 1;
                        final String? fileUrl = ver['file_url'] as String?;

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          color: active ? const Color(0xFFECFDF5) : Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(color: active ? Colors.green : const Color(0xFFE5E7EB)),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Wersiýa: $name ($code)', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                    Row(
                                      children: [
                                        if (!active)
                                          IconButton(
                                            icon: const Icon(Icons.check_circle_outline, color: Colors.green),
                                            onPressed: () => _activateVersion(id),
                                          ),
                                        IconButton(
                                          icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                                          onPressed: () => _showVersionEditor(ver),
                                        ),
                                        if (!active)
                                          IconButton(
                                            icon: const Icon(Icons.delete_outline, color: Colors.red),
                                            onPressed: () => _deleteVersion(id),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                if (desc.isNotEmpty) Text(desc, style: TextStyle(color: Colors.grey[700])),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      active ? 'Işjeň (Aktiw)' : 'Işjeň däl',
                                      style: TextStyle(color: active ? Colors.green : Colors.grey, fontWeight: FontWeight.bold),
                                    ),
                                    if (fileUrl != null && fileUrl.isNotEmpty)
                                      OutlinedButton.icon(
                                        onPressed: () async {
                                          final uri = Uri.parse(fileUrl);
                                          if (await canLaunchUrl(uri)) {
                                            await launchUrl(uri, mode: LaunchMode.externalApplication);
                                          } else {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                content: Text('APK faýlyny açyp bolmady'),
                                                backgroundColor: Colors.red,
                                              ),
                                            );
                                          }
                                        },
                                        icon: const Icon(Icons.download_rounded, size: 18),
                                        label: const Text('APK ýükle'),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: const Color(0xFFDC2626),
                                          side: const BorderSide(color: Color(0xFFDC2626)),
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                          textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                        ),
                                      ),
                                  ],
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
        onPressed: () => _showVersionEditor(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
