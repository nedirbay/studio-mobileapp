import 'package:flutter/material.dart';
import '../services/admin_service.dart';

class AdminStudioOrdersPage extends StatefulWidget {
  const AdminStudioOrdersPage({super.key});

  @override
  State<AdminStudioOrdersPage> createState() => _AdminStudioOrdersPageState();
}

class _AdminStudioOrdersPageState extends State<AdminStudioOrdersPage> {
  bool _isLoading = true;
  List<dynamic> _studioOrders = [];
  List<dynamic> _filteredOrders = [];
  List<dynamic> _orderTypes = [];
  String _selectedStatus = 'All';
  String? _error;

  final List<String> _statuses = ['All', 'pending', 'approved', 'rejected'];

  @override
  void initState() {
    super.initState();
    _loadStudioOrders();
    _loadOrderTypes();
  }

  Future<void> _loadStudioOrders() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final data = await AdminService.listStudioOrders();
      setState(() {
        _studioOrders = data;
        _filterOrders();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _loadOrderTypes() async {
    try {
      final data = await AdminService.listStudioOrderTypes();
      setState(() {
        _orderTypes = data;
      });
    } catch (_) {}
  }

  void _filterOrders() {
    if (_selectedStatus == 'All') {
      _filteredOrders = _studioOrders;
    } else {
      _filteredOrders = _studioOrders.where((o) => (o['status'] ?? 'pending').toString().toLowerCase() == _selectedStatus.toLowerCase()).toList();
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Garaşylýar';
      case 'approved':
        return 'Tassyklandy';
      case 'rejected':
        return 'Ret edildi';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Future<void> _deleteStudioOrder(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sargydy pozmak'),
        content: const Text('Bu studiýa sargydyny pozmak isleýärsiňizmi?'),
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
      await AdminService.deleteStudioOrder(id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sargyt pozuldy'), backgroundColor: Colors.green),
      );
      _loadStudioOrders();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _updateStatus(int id, String status) async {
    try {
      await AdminService.setStudioOrderStatus(id, status);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sargyt ${status == "approved" ? "tassyklandy" : "ret edildi"}'), backgroundColor: Colors.green),
      );
      _loadStudioOrders();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    }
  }

  void _showEditSheet(dynamic order) {
    final int id = order['id'];
    final nameController = TextEditingController(text: order['customer_name'] ?? '');
    final phoneController = TextEditingController(text: order['customer_phone'] ?? '');
    final totalController = TextEditingController(text: (order['total_amount'] ?? '0').toString());
    final paidController = TextEditingController(text: (order['paid_amount'] ?? '0').toString());
    int? selectedOrderTypeId = order['order_type_id'] ?? order['order_type']?['id'];

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
                const Text('Sargydy üýtgetmek', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Müşderiniň ady', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: 'Telefon belgisi', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  value: selectedOrderTypeId,
                  decoration: const InputDecoration(labelText: 'Sargyt görnüşi', border: OutlineInputBorder()),
                  items: _orderTypes
                      .map((t) => DropdownMenuItem<int>(
                            value: t['id'],
                            child: Text(t['name'] ?? ''),
                          ))
                      .toList(),
                  onChanged: (val) => selectedOrderTypeId = val,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: totalController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Jemi töleg', border: OutlineInputBorder()),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: paidController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Tölenen mukdar', border: OutlineInputBorder()),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () async {
                      try {
                        await AdminService.updateStudioOrder(id, {
                          'customer_name': nameController.text,
                          'customer_phone': phoneController.text,
                          'order_type_id': selectedOrderTypeId,
                          'total_amount': double.tryParse(totalController.text) ?? 0.0,
                          'paid_amount': double.tryParse(paidController.text) ?? 0.0,
                        });
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Sargyt üstünlikli üýtgedildi'), backgroundColor: Colors.green),
                        );
                        _loadStudioOrders();
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

  void _showOrderDetails(dynamic order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (context) {
        final int id = order['id'] ?? 0;
        final String status = order['status'] ?? 'pending';
        final days = order['days'] as List? ?? [];
        final double total = double.tryParse((order['total_amount'] ?? '0').toString()) ?? 0.0;
        final double paid = double.tryParse((order['paid_amount'] ?? '0').toString()) ?? 0.0;

        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          maxChildSize: 0.9,
          minChildSize: 0.5,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Sargyt #$id', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                            onPressed: () {
                              Navigator.pop(context);
                              _showEditSheet(order);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.red),
                            onPressed: () {
                              Navigator.pop(context);
                              _deleteStudioOrder(id);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text('Müşderi maglumaty', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Ady: ${order['customer_name'] ?? 'Nomalym'}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text('Telefon: ${order['customer_phone'] ?? ''}'),
                        const SizedBox(height: 4),
                        Text('Sargyt görnüşi: ${order['order_type'] != null ? order['order_type']['name'] : ''}'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('Günde/Wagtda meýilleşdirme', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: days.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, idx) {
                      final day = days[idx];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text('Sene: ${day['date'] ?? ''} - Sagat: ${day['time'] ?? 'Doly gün'}'),
                        subtitle: Text('Salgysy: ${day['address'] ?? 'Studiýa'}'),
                        trailing: Text('${day['daily_price'] ?? 0} TMT', style: const TextStyle(fontWeight: FontWeight.bold)),
                      );
                    },
                  ),
                  const Divider(thickness: 1.5),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Jemi töleg', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      Text('$total TMT', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Tölenen mukdar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green)),
                      Text('$paid TMT', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.green)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  if (status == 'pending') ...[
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              _updateStatus(id, 'approved');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              minimumSize: const Size.fromHeight(50),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('Tassykla', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              _updateStatus(id, 'rejected');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              minimumSize: const Size.fromHeight(50),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('Ret et', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    Center(
                      child: Text(
                        'Bu sargyt eýýäm ${status == "approved" ? "tassyklandy" : "ret edildi"}.',
                        style: TextStyle(fontWeight: FontWeight.bold, color: _getStatusColor(status)),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                ],
              ),
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
        title: const Text('Studio Sargytlary', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadStudioOrders),
        ],
      ),
      body: Column(
        children: [
          // Filter horizontal list
          SizedBox(
            height: 60,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: _statuses.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final status = _statuses[index];
                final isSelected = _selectedStatus == status;
                return ChoiceChip(
                  label: Text(status == 'All' ? 'Ählisi' : _getStatusText(status)),
                  selected: isSelected,
                  selectedColor: const Color(0xFFDC2626),
                  labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
                  backgroundColor: Colors.white,
                  checkmarkColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedStatus = status;
                        _filterOrders();
                      });
                    }
                  },
                );
              },
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFFDC2626)))
                : _error != null
                    ? Center(child: Text(_error!))
                    : _filteredOrders.isEmpty
                        ? const Center(child: Text('Studiýa sargydy tapylmady'))
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _filteredOrders.length,
                            itemBuilder: (context, index) {
                              final order = _filteredOrders[index];
                              final int id = order['id'] ?? 0;
                              final String name = order['customer_name'] ?? 'Nomalym';
                              final String status = order['status'] ?? 'pending';
                              final double total = double.tryParse((order['total_amount'] ?? '0').toString()) ?? 0.0;
                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                color: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  side: const BorderSide(color: Color(0xFFE5E7EB)),
                                ),
                                child: InkWell(
                                  onTap: () => _showOrderDetails(order),
                                  borderRadius: BorderRadius.circular(20),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Sargyt #$id',
                                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(name, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                                            const SizedBox(height: 8),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: _getStatusColor(status).withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                _getStatusText(status),
                                                style: TextStyle(
                                                  color: _getStatusColor(status),
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Text(
                                          '$total TMT',
                                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFFDC2626)),
                                        ),
                                      ],
                                    ),
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
