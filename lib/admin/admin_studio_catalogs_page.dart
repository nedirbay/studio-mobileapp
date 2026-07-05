import 'package:flutter/material.dart';
import '../services/admin_service.dart';

class AdminStudioCatalogsPage extends StatefulWidget {
  const AdminStudioCatalogsPage({super.key});

  @override
  State<AdminStudioCatalogsPage> createState() => _AdminStudioCatalogsPageState();
}

class _AdminStudioCatalogsPageState extends State<AdminStudioCatalogsPage> {
  bool _isLoading = true;
  List<dynamic> _services = [];
  List<dynamic> _equipments = [];
  List<dynamic> _orderTypes = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAllCatalogs();
  }

  Future<void> _loadAllCatalogs() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final sData = await AdminService.listStudioServices();
      final eData = await AdminService.listStudioEquipments();
      final oData = await AdminService.listStudioOrderTypes();
      setState(() {
        _services = sData;
        _equipments = eData;
        _orderTypes = oData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<bool> _confirmDelete(String name) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Öçürmek isleýäñizmi?'),
        content: Text('"$name" öçüriler. Bu amaly yzyna gaýtaryp bolmaz.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Ýatyr'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Öçür'),
          ),
        ],
      ),
    );
    return result == true;
  }

  // --- CRUD Services ---
  Future<void> _deleteService(int id, String name) async {
    if (!await _confirmDelete(name)) return;
    try {
      await AdminService.deleteStudioService(id);
      _loadAllCatalogs();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
    }
  }

  void _showServiceEditor([dynamic svc]) {
    final bool isEdit = svc != null;
    final nameController = TextEditingController(text: isEdit ? svc['name'] ?? '' : '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEdit ? 'Hyzmaty üýtgetmek' : 'Täze hyzmat goşmak'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: 'Ady'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Ýatyr')),
          TextButton(
            onPressed: () async {
              final payload = {'name': nameController.text};
              try {
                if (isEdit) {
                  await AdminService.updateStudioService(svc['id'], payload);
                } else {
                  await AdminService.createStudioService(payload);
                }
                Navigator.pop(context);
                _loadAllCatalogs();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
              }
            },
            child: const Text('Ýatda sakla'),
          ),
        ],
      ),
    );
  }

  // --- CRUD Equipments ---
  Future<void> _deleteEquipment(int id, String name) async {
    if (!await _confirmDelete(name)) return;
    try {
      await AdminService.deleteStudioEquipment(id);
      _loadAllCatalogs();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
    }
  }

  void _showEquipmentEditor([dynamic eq]) {
    final bool isEdit = eq != null;
    final nameController = TextEditingController(text: isEdit ? eq['name'] ?? '' : '');
    final descController = TextEditingController(text: isEdit ? eq['description'] ?? '' : '');
    final priceController = TextEditingController(text: isEdit ? (eq['daily_price'] ?? '').toString() : '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEdit ? 'Enjamy üýtgetmek' : 'Täze enjam goşmak'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Ady')),
            TextField(controller: descController, decoration: const InputDecoration(labelText: 'Düşündiriş')),
            TextField(controller: priceController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Gündelik kärendesi (TMT)')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Ýatyr')),
          TextButton(
            onPressed: () async {
              final payload = {
                'name': nameController.text,
                'description': descController.text,
                'daily_price': double.tryParse(priceController.text) ?? 0.0,
              };
              try {
                if (isEdit) {
                  await AdminService.updateStudioEquipment(eq['id'], payload);
                } else {
                  await AdminService.createStudioEquipment(payload);
                }
                Navigator.pop(context);
                _loadAllCatalogs();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
              }
            },
            child: const Text('Ýatda sakla'),
          ),
        ],
      ),
    );
  }

  // --- CRUD Order Types ---
  Future<void> _deleteOrderType(int id, String name) async {
    if (!await _confirmDelete(name)) return;
    try {
      await AdminService.deleteStudioOrderType(id);
      _loadAllCatalogs();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
    }
  }

  void _showOrderTypeEditor([dynamic ot]) {
    final bool isEdit = ot != null;
    final nameController = TextEditingController(text: isEdit ? ot['name'] ?? '' : '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEdit ? 'Görnüşi üýtgetmek' : 'Täze görnüş goşmak'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: 'Ady'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Ýatyr')),
          TextButton(
            onPressed: () async {
              final payload = {'name': nameController.text};
              try {
                if (isEdit) {
                  await AdminService.updateStudioOrderType(ot['id'], payload);
                } else {
                  await AdminService.createStudioOrderType(payload);
                }
                Navigator.pop(context);
                _loadAllCatalogs();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
              }
            },
            child: const Text('Ýatda sakla'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF9FAFB),
        appBar: AppBar(
          title: const Text('Studio Sözlükleri', style: TextStyle(fontWeight: FontWeight.bold)),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Hyzmatlar'),
              Tab(text: 'Görnüşler'),
            ],
            indicatorColor: Color(0xFFDC2626),
            labelColor: Color(0xFFDC2626),
            unselectedLabelColor: Colors.grey,
          ),
          actions: [
            IconButton(icon: const Icon(Icons.refresh), onPressed: _loadAllCatalogs),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFFDC2626)))
            : _error != null
                ? Center(child: Text(_error!))
                : TabBarView(
                    children: [
                      _buildServicesTab(),
                      _buildOrderTypesTab(),
                    ],
                  ),
      ),
    );
  }

  Widget _buildServicesTab() {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: _services.isEmpty
          ? const Center(child: Text('Hyzmat tapylmady'))
          : ListView.builder(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(context).padding.bottom + 82,
              ),
              itemCount: _services.length,
              itemBuilder: (context, index) {
                final s = _services[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  color: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                  child: ListTile(
                    title: Text(s['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(icon: const Icon(Icons.edit_outlined, color: Colors.blue), onPressed: () => _showServiceEditor(s)),
                        IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red), onPressed: () => _deleteService(s['id'], s['name'] ?? '')),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        onPressed: () => _showServiceEditor(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEquipmentsTab() {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: _equipments.isEmpty
          ? const Center(child: Text('Enjam tapylmady'))
          : ListView.builder(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(context).padding.bottom + 82,
              ),
              itemCount: _equipments.length,
              itemBuilder: (context, index) {
                final eq = _equipments[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  color: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                  child: ListTile(
                    title: Text(eq['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${eq['description'] ?? ''}\nKärende: ${eq['daily_price'] ?? 0} TMT'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(icon: const Icon(Icons.edit_outlined, color: Colors.blue), onPressed: () => _showEquipmentEditor(eq)),
                        IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red), onPressed: () => _deleteEquipment(eq['id'], eq['name'] ?? '')),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        onPressed: () => _showEquipmentEditor(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildOrderTypesTab() {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: _orderTypes.isEmpty
          ? const Center(child: Text('Sargyt görnüşi tapylmady'))
          : ListView.builder(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(context).padding.bottom + 82,
              ),
              itemCount: _orderTypes.length,
              itemBuilder: (context, index) {
                final ot = _orderTypes[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  color: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                  child: ListTile(
                    title: Text(ot['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(icon: const Icon(Icons.edit_outlined, color: Colors.blue), onPressed: () => _showOrderTypeEditor(ot)),
                        IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red), onPressed: () => _deleteOrderType(ot['id'], ot['name'] ?? '')),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        onPressed: () => _showOrderTypeEditor(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
