import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../widgets/top_bar.dart';
import '../widgets/app_header.dart';
import '../services/orders_service.dart';
import '../services/studio_order_service.dart';
import '../services/auth_service.dart';

class PhotoOrderPage extends StatefulWidget {
  final String serviceName;
  const PhotoOrderPage({super.key, required this.serviceName});

  @override
  State<PhotoOrderPage> createState() => _PhotoOrderPageState();
}

class _PhotoOrderPageState extends State<PhotoOrderPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController(text: '+993');
  final _addressController = TextEditingController();
  
  List<dynamic> _orderTypes = [];
  List<dynamic> _services = [];
  int? _selectedOrderTypeId;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 12, minute: 0);
  bool _isLoadingCatalogs = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final user = AuthService().user;
    if (user != null) {
      _nameController.text = user['username'] ?? '';
    }
    _loadCatalogs();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _loadCatalogs() async {
    try {
      final results = await Future.wait([
        StudioOrderService.listOrderTypes(),
        StudioOrderService.listServices(),
      ]);
      setState(() {
        _orderTypes = results[0];
        _services = results[1];
      });
    } catch (e) {
      debugPrint('Error loading catalogs in PhotoOrderPage: $e');
    } finally {
      setState(() => _isLoadingCatalogs = false);
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  Future<void> _submitOrder() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      // Try to find the matching service ID by name
      int? matchingServiceId;
      for (final s in _services) {
        if (s['name']?.toString().toLowerCase() == widget.serviceName.toLowerCase()) {
          matchingServiceId = s['id'] as int;
          break;
        }
      }
      if (matchingServiceId == null && _services.isNotEmpty) {
        // Fallback to photographer (Suratcy) if it exists, or just use the first service
        final firstServ = _services.firstWhere(
          (s) => s['name']?.toString().toLowerCase().contains('surat') ?? false,
          orElse: () => _services.first,
        );
        matchingServiceId = firstServ['id'] as int;
      }

      final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
      final timeStr = '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}';
      
      final daysPayload = [
        {
          'date': dateStr,
          'time': timeStr,
          'address': _addressController.text.trim(),
          'daily_price': 0,
          'services': matchingServiceId != null ? [
            {'service_id': matchingServiceId, 'count': 1}
          ] : [],
          'equipments': [],
        }
      ];

      await OrdersService.createStudioOrder(
        customerName: _nameController.text.trim(),
        customerPhone: _phoneController.text.trim(),
        orderTypeId: _selectedOrderTypeId,
        days: daysPayload,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sargydyňyz üstünlikli kabul edildi!'), backgroundColor: Colors.green),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ýalňyşlyk ýüze çykdy: ${e.toString().replaceFirst('Exception: ', '')}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('dd.MM.yyyy').format(_selectedDate);
    final formattedTime = '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const TopBar(),
            const AppHeader(),
            Expanded(
              child: _isLoadingCatalogs
                ? const Center(child: CircularProgressIndicator(color: Colors.black))
                : SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Sargyt formasy',
                              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Hyzmat: ${widget.serviceName}',
                              style: const TextStyle(color: Color(0xFF6B7280), fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 32),
                            
                            // Name field
                            const Text('Adyňyz *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF4B5563))),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _nameController,
                              decoration: InputDecoration(
                                hintText: 'Myrat',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                                filled: true,
                                fillColor: const Color(0xFFF9FAFB),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              ),
                              validator: (value) => value!.isEmpty ? 'Adyňyzy ýazyň' : null,
                            ),
                            const SizedBox(height: 20),
                            
                            // Phone field
                            const Text('Telefon belgiňiz *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF4B5563))),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              decoration: InputDecoration(
                                hintText: '+993 6...',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                                filled: true,
                                fillColor: const Color(0xFFF9FAFB),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              ),
                              validator: (value) => value!.isEmpty ? 'Telefon belgiňizi ýazyň' : null,
                            ),
                            const SizedBox(height: 20),

                            // Order Type Dropdown
                            const Text('Sargyt görnüşi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF4B5563))),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<int>(
                              value: _selectedOrderTypeId,
                              hint: const Text('Saýlaň'),
                              decoration: InputDecoration(
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                                filled: true,
                                fillColor: const Color(0xFFF9FAFB),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              ),
                              items: _orderTypes.map((type) {
                                return DropdownMenuItem<int>(
                                  value: type['id'] as int,
                                  child: Text(type['name']?.toString() ?? ''),
                                );
                              }).toList(),
                              onChanged: (val) => setState(() => _selectedOrderTypeId = val),
                            ),
                            const SizedBox(height: 20),

                            // Date & Time pickers
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('Sene *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF4B5563))),
                                      const SizedBox(height: 8),
                                      InkWell(
                                        onTap: _selectDate,
                                        child: InputDecorator(
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                                            filled: true,
                                            fillColor: const Color(0xFFF9FAFB),
                                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(formattedDate),
                                              const Icon(Icons.calendar_today, size: 18, color: Colors.grey),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('Wagt *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF4B5563))),
                                      const SizedBox(height: 8),
                                      InkWell(
                                        onTap: _selectTime,
                                        child: InputDecorator(
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                                            filled: true,
                                            fillColor: const Color(0xFFF9FAFB),
                                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(formattedTime),
                                              const Icon(Icons.access_time, size: 18, color: Colors.grey),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),

                            // Address field
                            const Text('Salgy / mekan *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF4B5563))),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _addressController,
                              maxLines: 2,
                              decoration: InputDecoration(
                                hintText: 'Ýaşalýan salgyňyz ýa-da dabaranyň geçjek ýeri',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                                filled: true,
                                fillColor: const Color(0xFFF9FAFB),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              ),
                              validator: (value) => value!.trim().isEmpty ? 'Salgyny ýazyň' : null,
                            ),
                            
                            const SizedBox(height: 40),
                            
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton(
                                onPressed: _isSubmitting ? null : _submitOrder,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black,
                                  foregroundColor: Colors.white,
                                  disabledBackgroundColor: Colors.grey[300],
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                child: _isSubmitting 
                                  ? const CircularProgressIndicator(color: Colors.white)
                                  : const Text('Sargyt et', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
