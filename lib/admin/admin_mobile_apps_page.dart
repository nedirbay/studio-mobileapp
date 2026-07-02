import 'package:flutter/material.dart';
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
    final fileController = TextEditingController(text: isEdit ? ver['file_url'] ?? '' : '');
    final descController = TextEditingController(text: isEdit ? ver['description'] ?? '' : '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isEdit ? 'Wersiýany üýtgetmek' : 'Täze wersiýa goşmak'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Wersiýa ady (mes: 1.0.2)'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: codeController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Wersiýa kody (Version Code)'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: fileController,
                  decoration: const InputDecoration(labelText: 'Fakyl/APK URL'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descController,
                  maxLines: 2,
                  decoration: const InputDecoration(labelText: 'Düşündiriş / Üýtgeşmeler'),
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
                    const SnackBar(content: Text('Ady we kody dolduryň'), backgroundColor: Colors.orange),
                  );
                  return;
                }

                final payload = {
                  'version_name': nameController.text,
                  'version_code': int.tryParse(codeController.text) ?? 1,
                  'file_url': fileController.text.isNotEmpty ? fileController.text : null,
                  'description': descController.text.isNotEmpty ? descController.text : '',
                };

                try {
                  if (isEdit) {
                    await AdminService.updateAppVersion(ver['id'], payload);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Wersiýa täzelendi'), backgroundColor: Colors.green),
                    );
                  } else {
                    await AdminService.createAppVersion(payload);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Wersiýa döredildi'), backgroundColor: Colors.green),
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
                      padding: const EdgeInsets.all(16),
                      itemCount: _versions.length,
                      itemBuilder: (context, index) {
                        final ver = _versions[index];
                        final int id = ver['id'] ?? 0;
                        final String name = ver['version_name'] ?? '';
                        final int code = ver['version_code'] ?? 1;
                        final String desc = ver['description'] ?? '';
                        final bool active = ver['is_active'] == true || ver['is_active'] == 1;

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
                                Text(
                                  active ? 'Işjeň (Aktiw)' : 'Işjeň däl',
                                  style: TextStyle(color: active ? Colors.green : Colors.grey, fontWeight: FontWeight.bold),
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
