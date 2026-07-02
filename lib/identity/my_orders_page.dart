import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../config.dart';
import '../services/orders_service.dart';
import '../services/settings_service.dart';

class MyOrdersPage extends StatefulWidget {
  const MyOrdersPage({super.key});

  @override
  State<MyOrdersPage> createState() => _MyOrdersPageState();
}

class _MyOrdersPageState extends State<MyOrdersPage> {
  List<dynamic> _orders = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final orders = await OrdersService.listCommerceOrders();
      if (!mounted) return;
      setState(() {
        _orders = orders;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Map<String, dynamic> _getStatusDetails(String status, String langCode) {
    final Map<String, Map<String, dynamic>> translation = {
      'TM': {
        'completed': {'text': 'Tamamlandy', 'color': const Color(0xFF10B981)},
        'processing': {'text': 'Taýýarlanýar', 'color': const Color(0xFF3B82F6)},
        'cancelled': {'text': 'Goýbolsun edildi', 'color': const Color(0xFFEF4444)},
        'pending': {'text': 'Garaşylýar', 'color': const Color(0xFFF59E0B)},
      },
      'RU': {
        'completed': {'text': 'Выполнен', 'color': const Color(0xFF10B981)},
        'processing': {'text': 'В обработке', 'color': const Color(0xFF3B82F6)},
        'cancelled': {'text': 'Отменен', 'color': const Color(0xFFEF4444)},
        'pending': {'text': 'В ожидании', 'color': const Color(0xFFF59E0B)},
      },
      'EN': {
        'completed': {'text': 'Completed', 'color': const Color(0xFF10B981)},
        'processing': {'text': 'Processing', 'color': const Color(0xFF3B82F6)},
        'cancelled': {'text': 'Cancelled', 'color': const Color(0xFFEF4444)},
        'pending': {'text': 'Pending', 'color': const Color(0xFFF59E0B)},
      }
    };
    
    return translation[langCode]?[status] ?? translation[langCode]?['pending']!;
  }

  String _formatDate(String dateStr, String langCode) {
    try {
      final date = DateTime.parse(dateStr);
      final locale = langCode == 'TM' ? 'tk' : (langCode == 'RU' ? 'ru' : 'en');
      return DateFormat.yMMMd(locale).add_Hm().format(date);
    } catch (_) {
      return dateStr;
    }
  }

  String _formatPrice(dynamic price) {
    final double val = double.tryParse(price.toString()) ?? 0.0;
    return '${val.toStringAsFixed(2)} ${Config.activeCurrencySymbol}';
  }

  @override
  Widget build(BuildContext context) {
    final settings = SettingsService();
    final isDark = settings.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          settings.translate('my_orders'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: _fetchOrders,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFDC2626)))
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
                        const SizedBox(height: 16),
                        Text(
                          _error!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _fetchOrders,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text(settings.translate('login')),
                        )
                      ],
                    ),
                  ),
                )
              : _orders.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.shopping_bag_outlined,
                            size: 80,
                            color: isDark ? Colors.grey[700] : Colors.grey[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            settings.translate('no_orders'),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.grey[400] : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: _orders.length,
                      itemBuilder: (context, index) {
                        final order = _orders[index];
                        final items = order['items'] as List<dynamic>? ?? [];
                        final statusInfo = _getStatusDetails(
                          (order['status'] ?? 'pending').toString().toLowerCase(),
                          settings.languageCode,
                        );

                        return Card(
                          margin: const EdgeInsets.only(bottom: 16.0),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                              color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
                              width: 1.5,
                            ),
                          ),
                          color: isDark ? const Color(0xFF1F2937) : Colors.white,
                          child: Theme(
                            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                            child: ExpansionTile(
                              title: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${settings.translate('order_id')}: #${order['id']}',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: (statusInfo['color'] as Color).withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      statusInfo['text'] as String,
                                      style: TextStyle(
                                        color: statusInfo['color'] as Color,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _formatDate(order['created_at'] ?? '', settings.languageCode),
                                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Text(
                                          '${settings.translate('total_amount')}: ',
                                          style: const TextStyle(fontSize: 13, color: Colors.grey),
                                        ),
                                        Text(
                                          _formatPrice(order['total_price'] ?? order['total_amount'] ?? 0),
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w900,
                                            color: Color(0xFFDC2626),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              children: [
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(16.0),
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF111827) : const Color(0xFFF9FAFB),
                                    borderRadius: const BorderRadius.vertical(
                                      bottom: Radius.circular(16),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        settings.translate('items_list').toUpperCase(),
                                        style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w900,
                                          color: Colors.grey,
                                          letterSpacing: 0.8,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      ...items.map((item) {
                                        final qty = int.tryParse(item['quantity'].toString()) ?? 1;
                                        final price = double.tryParse(item['price'].toString()) ?? 0.0;
                                        final name = item['product_name'] ?? '';

                                        return Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 6.0),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      name,
                                                      style: const TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 13,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 2),
                                                    Text(
                                                      '$qty ${settings.translate('quantity')} x ${_formatPrice(price)}',
                                                      style: const TextStyle(
                                                        fontSize: 11,
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Text(
                                                _formatPrice(qty * price),
                                                style: const TextStyle(fontWeight: FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                        );
                                      }),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}
