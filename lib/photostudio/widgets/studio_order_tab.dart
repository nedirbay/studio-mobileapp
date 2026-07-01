import 'package:flutter/material.dart';
import '../../services/studio_order_service.dart';
import '../../services/auth_service.dart';
import 'package:intl/intl.dart';
import '../../config.dart';

class StudioOrderTab extends StatefulWidget {
  const StudioOrderTab({super.key});

  @override
  State<StudioOrderTab> createState() => _StudioOrderTabState();
}

class _StudioOrderTabState extends State<StudioOrderTab> {
  List<dynamic> _orders = [];
  List<dynamic> _orderTypes = [];
  List<dynamic> _services = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    AuthService().addListener(_onAuthChanged);
    _loadData();
  }

  @override
  void dispose() {
    AuthService().removeListener(_onAuthChanged);
    super.dispose();
  }

  void _onAuthChanged() {
    if (mounted) {
      _loadData();
    }
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      if (AuthService().isAuthenticated) {
        final results = await Future.wait([
          StudioOrderService.listOrders(),
          StudioOrderService.listOrderTypes(),
          StudioOrderService.listServices(),
        ]);
        setState(() {
          _orders = results[0];
          _orderTypes = results[1];
          _services = results[2];
        });
      } else {
        // Load only catalogs for booking
        final results = await Future.wait([
          StudioOrderService.listOrderTypes(),
          StudioOrderService.listServices(),
        ]);
        setState(() {
          _orderTypes = results[0];
          _services = results[1];
        });
      }
    } catch (e) {
      debugPrint('Error loading studio order data: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _openBookingDialog() {
    if (!AuthService().isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sargyt etmek üçin ilki hasabyňyza giriň.')),
      );
      return;
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _BookingFormSheet(
        orderTypes: _orderTypes,
        services: _services,
        onSuccess: _loadData,
      ),
    );
  }

  Future<void> _handleDelete(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tassyklaň'),
        content: const Text('Bu sargydy pozmakçymy?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Ýok', style: TextStyle(color: Colors.grey))),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Hawa', style: TextStyle(color: Color(0xFFDC2626)))),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await StudioOrderService.deleteOrder(id);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sargyt pozuldy')));
        _loadData();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ýalňyşlyk: $e')));
      }
    }
  }

  Widget _buildStatusTag(String? status, bool? isApproved) {
    if (isApproved == true) {
      return _tag('Tassyklandy', Colors.green);
    }
    final s = (status ?? '').toLowerCase();
    if (s == 'approved' || s == 'confirmed') {
      return _tag('Tassyklandy', Colors.green);
    } else if (s == 'rejected' || s == 'cancelled') {
      return _tag('Ret edildi', Colors.red);
    } else if (s == 'completed') {
      return _tag('Tamamlandy', Colors.blue);
    } else {
      return _tag('Garaşylýar', Colors.orange);
    }
  }

  Widget _tag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
      child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 11)),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Colors.black));
    }

    if (!AuthService().isAuthenticated) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.event_note_outlined, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text('Sargyt etmek', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Studio hyzmatlaryny sargyt etmek üçin ilki ulgama giriň.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loadData,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white),
                child: const Text('Täzele'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: _orders.isEmpty
            ? ListView(
                children: [
                  const SizedBox(height: 100),
                  const Icon(Icons.calendar_today_outlined, size: 64, color: Color(0xFFD1D5DB)),
                  const SizedBox(height: 16),
                  const Center(child: Text('Heniz sargyt ýok', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
                ],
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _orders.length,
                itemBuilder: (context, index) {
                  final order = _orders[index];
                  final createdDate = DateTime.tryParse(order['created_at']?.toString() ?? '') ?? DateTime.now();
                  final formattedDate = DateFormat('dd.MM.yyyy').format(createdDate);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE5E7EB), width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Sargyt #${order['id']}',
                              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF111827)),
                            ),
                            _buildStatusTag(order['status']?.toString(), order['is_approved'] as bool?),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(Icons.person_outline, size: 16, color: Colors.grey),
                            const SizedBox(width: 8),
                            Text(order['customer_name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.phone_outlined, size: 16, color: Colors.grey),
                            const SizedBox(width: 8),
                            Text(order['customer_phone'] ?? '', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.calendar_month_outlined, size: 16, color: Colors.grey),
                            const SizedBox(width: 8),
                            Text('Sene: $formattedDate', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Divider(color: Color(0xFFF3F4F6)),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Jemi baha', style: TextStyle(color: Colors.grey, fontSize: 11)),
                                const SizedBox(height: 2),
                                Text('${order['total_amount']} ${Config.activeCurrencySymbol}', style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFFDC2626), fontSize: 15)),
                              ],
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Color(0xFFDC2626)),
                              onPressed: () => _handleDelete(order['id'] as int),
                            )
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openBookingDialog,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Sargyt et', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}

class _BookingFormSheet extends StatefulWidget {
  final List<dynamic> orderTypes;
  final List<dynamic> services;
  final VoidCallback onSuccess;

  const _BookingFormSheet({
    required this.orderTypes,
    required this.services,
    required this.onSuccess,
  });

  @override
  State<_BookingFormSheet> createState() => _BookingFormSheetState();
}

class _BookingFormSheetState extends State<_BookingFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController(text: '+993');
  int? _selectedOrderTypeId;

  // Booking days list
  final List<Map<String, dynamic>> _days = [
    {
      'date': DateTime.now().add(const Duration(days: 1)),
      'time': const TimeOfDay(hour: 12, minute: 0),
      'address': '',
      'services': <Map<String, dynamic>>[],
    }
  ];

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final user = AuthService().user;
    if (user != null) {
      _nameController.text = user['username'] ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(int dayIndex) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _days[dayIndex]['date'] as DateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _days[dayIndex]['date'] = picked);
    }
  }

  Future<void> _selectTime(int dayIndex) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _days[dayIndex]['time'] as TimeOfDay,
    );
    if (picked != null) {
      setState(() => _days[dayIndex]['time'] = picked);
    }
  }

  void _addDay() {
    setState(() {
      _days.add({
        'date': DateTime.now().add(const Duration(days: 1)),
        'time': const TimeOfDay(hour: 12, minute: 0),
        'address': '',
        'services': <Map<String, dynamic>>[],
      });
    });
  }

  void _removeDay(int idx) {
    if (_days.length > 1) {
      setState(() => _days.removeAt(idx));
    }
  }

  void _addService(int dayIndex) {
    if (widget.services.isEmpty) return;
    setState(() {
      final list = _days[dayIndex]['services'] as List<Map<String, dynamic>>;
      list.add({
        'service_id': widget.services.first['id'],
        'count': 1,
      });
    });
  }

  void _removeService(int dayIndex, int serviceIndex) {
    setState(() {
      final list = _days[dayIndex]['services'] as List<Map<String, dynamic>>;
      list.removeAt(serviceIndex);
    });
  }

  Future<void> _submitBooking() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    try {
      final daysPayload = _days.map((day) {
        final DateTime dt = day['date'] as DateTime;
        final TimeOfDay t = day['time'] as TimeOfDay;
        final dateStr = DateFormat('yyyy-MM-dd').format(dt);
        final timeStr = '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
        final servList = day['services'] as List<Map<String, dynamic>>;

        return {
          'date': dateStr,
          'time': timeStr,
          'address': day['address'].toString().trim(),
          'daily_price': 0, // calculated backend-side or default
          'services': servList.map((s) => {
            'service_id': s['service_id'] as int,
            'count': s['count'] as int,
          }).toList(),
          'equipments': [],
        };
      }).toList();

      final payload = {
        'customer_name': _nameController.text.trim(),
        'customer_phone': _phoneController.text.trim(),
        'order_type_id': _selectedOrderTypeId,
        'total_amount': 0,
        'paid_amount': 0,
        'days': daysPayload,
        'staff': [],
      };

      await StudioOrderService.createOrder(payload);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sargyt üstünlikli iberildi!'), backgroundColor: Colors.green));
      Navigator.pop(context);
      widget.onSuccess();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ýalňyşlyk: $e'), backgroundColor: const Color(0xFFDC2626)));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        top: 24,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: FractionallySizedBox(
        heightFactor: 0.85,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Täze sargyt', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Customer Section
                      const Text('Adyňyz *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF4B5563))),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          hintText: 'Adyňyz we familiýaňyz',
                          filled: true,
                          fillColor: const Color(0xFFF9FAFB),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        ),
                        validator: (value) => value!.isEmpty ? 'Adyňyzy ýazyň' : null,
                      ),
                      const SizedBox(height: 16),
                      
                      const Text('Telefon *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF4B5563))),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _phoneController,
                        decoration: InputDecoration(
                          hintText: '+993 ...',
                          filled: true,
                          fillColor: const Color(0xFFF9FAFB),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        ),
                        validator: (value) => value!.isEmpty ? 'Telefon belgiňizi ýazyň' : null,
                      ),
                      const SizedBox(height: 16),

                      const Text('Sargyt görnüşi', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF4B5563))),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<int>(
                        value: _selectedOrderTypeId,
                        hint: const Text('Saýlaň'),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xFFF9FAFB),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        ),
                        items: widget.orderTypes.map((type) {
                          return DropdownMenuItem<int>(
                            value: type['id'] as int,
                            child: Text(type['name']?.toString() ?? ''),
                          );
                        }).toList(),
                        onChanged: (val) => setState(() => _selectedOrderTypeId = val),
                      ),
                      
                      const SizedBox(height: 24),
                      const Divider(),
                      const SizedBox(height: 12),
                      
                      // Days Editor
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Günler', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                          TextButton.icon(
                            onPressed: _addDay,
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text('Gün goş'),
                          ),
                        ],
                      ),
                      
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _days.length,
                        itemBuilder: (context, dIndex) {
                          final day = _days[dIndex];
                          final formattedDate = DateFormat('dd.MM.yyyy').format(day['date'] as DateTime);
                          final TimeOfDay t = day['time'] as TimeOfDay;
                          final formattedTime = '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
                          final dServices = day['services'] as List<Map<String, dynamic>>;

                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: const BorderSide(color: Color(0xFFE5E7EB)),
                            ),
                            elevation: 0,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('${dIndex + 1}-nji gün', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                      if (_days.length > 1)
                                        IconButton(
                                          icon: const Icon(Icons.delete, color: Color(0xFFDC2626), size: 20),
                                          onPressed: () => _removeDay(dIndex),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: InkWell(
                                          onTap: () => _selectDate(dIndex),
                                          child: InputDecorator(
                                            decoration: const InputDecoration(labelText: 'Sene', border: OutlineInputBorder()),
                                            child: Text(formattedDate),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: InkWell(
                                          onTap: () => _selectTime(dIndex),
                                          child: InputDecorator(
                                            decoration: const InputDecoration(labelText: 'Wagt', border: OutlineInputBorder()),
                                            child: Text(formattedTime),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    initialValue: day['address'].toString(),
                                    maxLines: 2,
                                    decoration: const InputDecoration(
                                      labelText: 'Salgy / mekan *',
                                      border: OutlineInputBorder(),
                                    ),
                                    validator: (val) => val!.trim().isEmpty ? 'Salgyny ýazyň' : null,
                                    onChanged: (val) => day['address'] = val,
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('Hyzmatlar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                      TextButton(onPressed: () => _addService(dIndex), child: const Text('Hyzmat goş')),
                                    ],
                                  ),
                                  
                                  // Services in day
                                  ...List.generate(dServices.length, (sIndex) {
                                    final sItem = dServices[sIndex];
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 12.0),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: DropdownButtonFormField<int>(
                                              value: sItem['service_id'] as int,
                                              decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 12)),
                                              items: widget.services.map((opt) {
                                                return DropdownMenuItem<int>(
                                                  value: opt['id'] as int,
                                                  child: Text(opt['name']?.toString() ?? '', style: const TextStyle(fontSize: 12)),
                                                );
                                              }).toList(),
                                              onChanged: (val) {
                                                if (val != null) {
                                                  setState(() => sItem['service_id'] = val);
                                                }
                                              },
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            width: 80,
                                            height: 48,
                                            decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(4)),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Expanded(
                                                  child: TextFormField(
                                                    initialValue: sItem['count'].toString(),
                                                    keyboardType: TextInputType.number,
                                                    textAlign: TextAlign.center,
                                                    decoration: const InputDecoration(border: InputBorder.none),
                                                    onChanged: (val) {
                                                      final count = int.tryParse(val) ?? 1;
                                                      sItem['count'] = count;
                                                    },
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.remove_circle_outline, color: Color(0xFFDC2626)),
                                            onPressed: () => _removeService(dIndex, sIndex),
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitBooking,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                  child: _isSubmitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Sargyt et', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
