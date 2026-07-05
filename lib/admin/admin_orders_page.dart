import 'package:flutter/material.dart';
import '../services/admin_service.dart';

class AdminOrdersPage extends StatefulWidget {
  const AdminOrdersPage({super.key});

  @override
  State<AdminOrdersPage> createState() => _AdminOrdersPageState();
}

class _AdminOrdersPageState extends State<AdminOrdersPage> {
  bool _isLoading = true;
  List<dynamic> _orders = [];
  List<dynamic> _filteredOrders = [];
  String _selectedStatus = 'All';
  String? _error;

  final List<String> _statuses = ['All', 'pending', 'completed', 'cancelled'];

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final data = await AdminService.listCommerceOrders();
      setState(() {
        _orders = data;
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

  void _filterOrders() {
    if (_selectedStatus == 'All') {
      _filteredOrders = _orders;
    } else {
      _filteredOrders = _orders.where((o) => (o['status'] ?? 'pending').toString().toLowerCase() == _selectedStatus.toLowerCase()).toList();
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Garaşylýar';
      case 'completed':
        return 'Tamamlandy';
      case 'cancelled':
        return 'Ýatyryldy';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;    
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Future<void> _deleteOrder(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sargydy pozmak'),
        content: const Text('Hakykatdan hem bu sargydy pozmak isleýärsiňizmi?'),
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
      await AdminService.deleteCommerceOrder(id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sargyt pozuldy'), backgroundColor: Colors.green),
      );
      _loadOrders();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _updateStatus(int id, String newStatus) async {
    try {
      await AdminService.updateCommerceOrderStatus(id, newStatus);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sargyt statusy üýtgedildi'), backgroundColor: Colors.green),
      );
      _loadOrders();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    }
  }

  void _showOrderDetails(dynamic order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (context) {
        final items = order['items'] as List? ?? [];
        final int id = order['id'] ?? 0;
        String status = order['status'] ?? 'pending';

        return StatefulBuilder(
          builder: (context, setModalState) {
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
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.red),
                            onPressed: () {
                              Navigator.pop(context);
                              _deleteOrder(id);
                            },
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
                            Text('Ady: ${order['full_name'] ?? order['customer_name'] ?? 'Nomalym'}',
                                style: const TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text('Telefon: ${order['phone_number'] ?? order['customer_phone'] ?? ''}'),
                            const SizedBox(height: 4),
                            Text('Sene: ${order['created_at'] != null ? order['created_at'].toString().split('T')[0] : ''}'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text('Status dolandyryşy', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        value: status,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: const Color(0xFFF9FAFB),
                        ),
                        items: _statuses
                            .where((s) => s != 'All')
                            .map((s) => DropdownMenuItem(
                                  value: s,
                                  child: Text(_getStatusText(s)),
                                ))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setModalState(() {
                              status = val;
                            });
                            _updateStatus(id, val);
                          }
                        },
                      ),
                      const SizedBox(height: 24),
                      const Text('Harytlar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: items.length,
                        separatorBuilder: (_, __) => const Divider(),
                        itemBuilder: (context, idx) {
                          final item = items[idx];
                          // product may be an int (ID) or a Map — use product_name directly
                          final String pName = item['product_name']?.toString()
                              ?? (item['product'] is Map ? (item['product']['name'] ?? 'Haryt') : 'Haryt');
                          final int qty = item['quantity'] ?? 1;
                          final double price = double.tryParse(item['price']?.toString() ?? '0') ?? 0.0;
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(pName, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('$qty sany x $price TMT'),
                            trailing: Text('${(qty * price).toStringAsFixed(2)} TMT', style: const TextStyle(fontWeight: FontWeight.w900)),
                          );
                        },
                      ),
                      const Divider(thickness: 1.5),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Jemi töleg', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            Text(
                              '${order['total_price'] ?? order['total_amount'] ?? 0.0} TMT',
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFFDC2626)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                );
              },
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
        title: const Text('Sargytlar', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadOrders),
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
                        ? const Center(child: Text('Sargyt tapylmady'))
                        : ListView.builder(
                            padding: EdgeInsets.only(
                              left: 16,
                              right: 16,
                              top: 8,
                              bottom: MediaQuery.of(context).padding.bottom + 16,
                            ),
                            itemCount: _filteredOrders.length,
                            itemBuilder: (context, index) {
                              final order = _filteredOrders[index];
                              final int id = order['id'] ?? 0;
                              final String name = order['full_name'] ?? order['customer_name'] ?? 'Nomalym';
                              final String status = order['status'] ?? 'pending';
                              final double total = double.tryParse((order['total_price'] ?? order['total_amount'] ?? '0').toString()) ?? 0.0;
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
