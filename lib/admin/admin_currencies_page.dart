import 'package:flutter/material.dart';
import '../services/admin_service.dart';

class AdminCurrenciesPage extends StatefulWidget {
  const AdminCurrenciesPage({super.key});

  @override
  State<AdminCurrenciesPage> createState() => _AdminCurrenciesPageState();
}

class _AdminCurrenciesPageState extends State<AdminCurrenciesPage> {
  bool _isLoading = true;
  List<dynamic> _currencies = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCurrencies();
  }

  Future<void> _loadCurrencies() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final data = await AdminService.listCurrencies();
      setState(() {
        _currencies = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteCurrency(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pul birligini pozmak'),
        content: const Text('Hakykatdan hem bu pul birligini pozmak isleýärsiňizmi?'),
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
      await AdminService.deleteCurrency(id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Walýuta pozuldy'), backgroundColor: Colors.green),
      );
      _loadCurrencies();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _activateCurrency(int id) async {
    try {
      await AdminService.activateCurrency(id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Walýuta işjeňleşdirildi'), backgroundColor: Colors.green),
      );
      _loadCurrencies();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    }
  }

  void _showCurrencyEditor([dynamic currency]) {
    final bool isEdit = currency != null;
    final nameController = TextEditingController(text: isEdit ? currency['name'] ?? '' : '');
    final codeController = TextEditingController(text: isEdit ? currency['code'] ?? '' : '');
    final symbolController = TextEditingController(text: isEdit ? currency['symbol'] ?? '' : '');
    final rateController = TextEditingController(text: isEdit ? (currency['exchange_rate'] ?? '1').toString() : '1');

    bool isActive = isEdit ? (currency['is_active'] == true || currency['is_active'] == 1) : false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              title: Text(isEdit ? 'Pul birligini üýtgetmek' : 'Täze pul birligi goşmak'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Ady (Name)'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: codeController,
                      decoration: const InputDecoration(labelText: 'Kody (Code, mes: USD)'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: symbolController,
                      decoration: const InputDecoration(labelText: 'Belgisi (Symbol, mes: \$)'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: rateController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Kursy (Exchange Rate)'),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Işjeň status (Active)'),
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
                    if (nameController.text.isEmpty || codeController.text.isEmpty || symbolController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Ähli öýjükleri dolduryň'), backgroundColor: Colors.orange),
                      );
                      return;
                    }

                    final payload = {
                      'name': nameController.text,
                      'code': codeController.text,
                      'symbol': symbolController.text,
                      'exchange_rate': double.tryParse(rateController.text) ?? 1.0,
                      'is_active': isActive,
                    };

                    try {
                      if (isEdit) {
                        await AdminService.updateCurrency(currency['id'], payload);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Walýuta täzelendi'), backgroundColor: Colors.green),
                        );
                      } else {
                        await AdminService.createCurrency(payload);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Walýuta döredildi'), backgroundColor: Colors.green),
                        );
                      }
                      Navigator.pop(context);
                      _loadCurrencies();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text('Pul birlikleri', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadCurrencies),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFDC2626)))
          : _error != null
              ? Center(child: Text(_error!))
              : _currencies.isEmpty
                  ? const Center(child: Text('Walýuta tapylmady'))
                  : ListView.builder(
                      padding: EdgeInsets.only(
                        left: 16,
                        right: 16,
                        top: 16,
                        bottom: MediaQuery.of(context).padding.bottom + 82,
                      ),
                      itemCount: _currencies.length,
                      itemBuilder: (context, index) {
                        final cur = _currencies[index];
                        final int id = cur['id'] ?? 0;
                        final String name = cur['name'] ?? '';
                        final String code = cur['code'] ?? '';
                        final String symbol = cur['symbol'] ?? '';
                        final double rate = double.tryParse((cur['exchange_rate'] ?? '1').toString()) ?? 1.0;
                        final bool active = cur['is_active'] == true || cur['is_active'] == 1;

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          color: active ? const Color(0xFFECFDF5) : Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(color: active ? Colors.green : const Color(0xFFE5E7EB)),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: active ? Colors.green.withOpacity(0.2) : const Color(0xFFF3F4F6),
                              child: Text(symbol, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            ),
                            title: Text('$name ($code)', style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('Kurs: $rate | ${active ? "Işjeň" : "Işjeň däl"}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (!active)
                                  IconButton(
                                    icon: const Icon(Icons.check_circle_outline, color: Colors.green),
                                    onPressed: () => _activateCurrency(id),
                                  ),
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                                  onPressed: () => _showCurrencyEditor(cur),
                                ),
                                if (!active)
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                                    onPressed: () => _deleteCurrency(id),
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
        onPressed: () => _showCurrencyEditor(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
