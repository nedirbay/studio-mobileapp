import 'package:flutter/material.dart';
import '../../services/cart_service.dart';
import '../../services/orders_service.dart';
import '../../config.dart';
import '../../services/settings_service.dart';

class CartTab extends StatefulWidget {
  final VoidCallback onContinueShopping;

  const CartTab({super.key, required this.onContinueShopping});

  @override
  State<CartTab> createState() => _CartTabState();
}

class _CartTabState extends State<CartTab> {
  int _checkoutStep = 1; // 1: Cart, 2: Info form
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController(text: '+993');
  final _noteController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _handleCheckout(CartService cart) async {
    if (!_formKey.currentState!.validate()) return;
    final settings = SettingsService();

    setState(() => _isSubmitting = true);
    try {
      final itemsPayload = cart.items.map((item) => {
        'product': int.parse(item['product']['id'].toString()),
        'quantity': item['quantity'] as int,
      }).toList();

      final res = await OrdersService.createCartOrder(
        fullName: _nameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        items: itemsPayload,
      );

      final orderId = res['id'] ?? '';
      
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 28),
              const SizedBox(width: 12),
              Text(settings.translate('order_received_title'), style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          content: Text('${settings.translate('order_received_body_prefix')}$orderId${settings.translate('order_received_body_suffix')}'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                cart.clearCart();
                setState(() {
                  _checkoutStep = 1;
                  _nameController.clear();
                  _phoneController.text = '+993';
                  _noteController.clear();
                });
              },
              child: Text(settings.translate('close_btn'), style: const TextStyle(color: Color(0xFFDC2626), fontWeight: FontWeight.bold)),
            )
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${settings.translate('error_prefix')}$e'),
          backgroundColor: const Color(0xFFDC2626),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = CartService();

    return ListenableBuilder(
      listenable: SettingsService(),
      builder: (context, _) {
        final settings = SettingsService();
        return ListenableBuilder(
          listenable: cart,
          builder: (context, _) {
            return Scaffold(
              backgroundColor: settings.isDarkMode ? const Color(0xFF111827) : const Color(0xFFF9FAFB),
              appBar: AppBar(
                title: Text(
                  _checkoutStep == 1 ? settings.translate('my_cart') : settings.translate('order_info'),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                leading: _checkoutStep == 2
                    ? IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                        onPressed: () => setState(() => _checkoutStep = 1),
                      )
                    : null,
              ),
              body: cart.items.isEmpty
                  ? _buildEmptyState(settings)
                  : _checkoutStep == 1
                      ? _buildCartStep(cart, settings)
                      : _buildInfoStep(cart, settings),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState(SettingsService settings) {
    final isDark = settings.isDarkMode;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF371C1C) : const Color(0xFFFEE2E2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.shopping_cart_outlined, size: 44, color: Color(0xFFDC2626)),
            ),
            const SizedBox(height: 24),
            Text(
              settings.translate('cart_empty'),
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: isDark ? Colors.white : const Color(0xFF111827)),
            ),
            const SizedBox(height: 8),
            Text(
              settings.translate('cart_empty_subtitle'),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: isDark ? Colors.grey[400] : const Color(0xFF6B7280)),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: widget.onContinueShopping,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFDC2626),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: Text(settings.translate('continue_shopping_btn'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartStep(CartService cart, SettingsService settings) {
    final isDark = settings.isDarkMode;
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: cart.items.length,
            itemBuilder: (context, index) {
              final item = cart.items[index];
              final prod = item['product'];
              String relativeUrl = '';
              if (prod['media'] != null && prod['media'] is List && prod['media'].isNotEmpty) {
                relativeUrl = prod['media'][0]['url'].toString();
              } else if (prod['image'] != null) {
                relativeUrl = prod['image'].toString();
              }
              final imageUrl = relativeUrl.isNotEmpty
                  ? (relativeUrl.startsWith('http') ? relativeUrl : '${Config.mediaBaseUrl}${relativeUrl.startsWith('/') ? '' : '/'}$relativeUrl')
                  : 'https://via.placeholder.com/150';

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1F2937) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        imageUrl,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => Container(
                          width: 80,
                          height: 80,
                          color: isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6),
                          child: const Icon(Icons.image_not_supported_outlined, color: Colors.grey),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      prod['name'] ?? '',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                        color: isDark ? Colors.white : const Color(0xFF111827),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      prod['marka'] ?? 'Doganlar',
                                      style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFF9CA3AF), size: 22),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: () => cart.removeFromCart(prod['id']),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${prod['price']} ${Config.activeCurrencySymbol}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFFDC2626),
                                  fontSize: 16,
                                ),
                              ),
                              Container(
                                height: 32,
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF111827) : const Color(0xFFF3F4F6),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    InkWell(
                                      onTap: () => cart.updateQuantity(prod['id'], item['quantity'] - 1),
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(16),
                                        bottomLeft: Radius.circular(16),
                                      ),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10),
                                        alignment: Alignment.center,
                                        child: Icon(
                                          Icons.remove_rounded,
                                          size: 16,
                                          color: isDark ? Colors.white70 : Colors.black87,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 4),
                                      child: Text(
                                        '${item['quantity']}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          color: isDark ? Colors.white : Colors.black,
                                        ),
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () => cart.updateQuantity(prod['id'], item['quantity'] + 1),
                                      borderRadius: const BorderRadius.only(
                                        topRight: Radius.circular(16),
                                        bottomRight: Radius.circular(16),
                                      ),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10),
                                        alignment: Alignment.center,
                                        child: const Icon(
                                          Icons.add_rounded,
                                          size: 16,
                                          color: Color(0xFFDC2626),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        
        // Checkout Section
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1F2937) : Colors.white,
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(isDark ? 0.3 : 0.1), blurRadius: 10, offset: const Offset(0, -2)),
            ],
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(settings.translate('total_items_label'), style: const TextStyle(color: Color(0xFF6B7280))),
                  Text('${cart.count}${settings.translate('pcs')}', style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(settings.translate('total_price_label'), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: isDark ? Colors.white : const Color(0xFF111827))),
                  Text('${cart.total} ${Config.activeCurrencySymbol}', style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFFDC2626), fontSize: 20)),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => setState(() => _checkoutStep = 2),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDC2626),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(settings.translate('checkout_btn'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward, size: 18),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: cart.clearCart,
                icon: const Icon(Icons.delete_sweep_outlined, size: 18, color: Color(0xFF9CA3AF)),
                label: Text(settings.translate('clear_cart'), style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoStep(CartService cart, SettingsService settings) {
    final isDark = settings.isDarkMode;
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF371C1C) : const Color(0xFFFEE2E2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isDark ? const Color(0xFF5E2A2A) : const Color(0xFFFCA5A5)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(settings.translate('order_details_title'), style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? const Color(0xFFFCA5A5) : const Color(0xFF991B1B), fontSize: 14)),
                        const SizedBox(height: 4),
                        Text(settings.translate('order_details_subtitle'), style: TextStyle(color: isDark ? Colors.grey[300] : const Color(0xFFB91C1C), fontSize: 12)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Name Field
                  Text(settings.translate('full_name_label'), style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? Colors.grey[300] : const Color(0xFF4B5563))),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _nameController,
                    style: TextStyle(color: isDark ? Colors.white : Colors.black),
                    decoration: InputDecoration(
                      hintText: settings.translate('name_placeholder'),
                      hintStyle: const TextStyle(color: Colors.grey),
                      prefixIcon: const Icon(Icons.person_outline, size: 20),
                      filled: true,
                      fillColor: isDark ? const Color(0xFF1F2937) : Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB))),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFDC2626))),
                    ),
                    validator: (value) => value!.isEmpty ? settings.translate('write_name_error') : null,
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Phone Field
                  Text(settings.translate('phone_label'), style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? Colors.grey[300] : const Color(0xFF4B5563))),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    style: TextStyle(color: isDark ? Colors.white : Colors.black),
                    decoration: InputDecoration(
                      hintText: '+993 6...',
                      hintStyle: const TextStyle(color: Colors.grey),
                      prefixIcon: const Icon(Icons.phone_outlined, size: 20),
                      filled: true,
                      fillColor: isDark ? const Color(0xFF1F2937) : Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB))),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFDC2626))),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) return settings.translate('write_phone_error');
                      if (!value.startsWith('+993')) return settings.translate('phone_format_error');
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Note Field
                  Text(settings.translate('note_label'), style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? Colors.grey[300] : const Color(0xFF4B5563))),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _noteController,
                    maxLines: 3,
                    style: TextStyle(color: isDark ? Colors.white : Colors.black),
                    decoration: InputDecoration(
                      hintText: settings.translate('note_placeholder'),
                      hintStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: isDark ? const Color(0xFF1F2937) : Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB))),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFDC2626))),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Summary Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1F2937) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(settings.translate('order_summary'), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF9CA3AF), letterSpacing: 0.8)),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(settings.translate('product_count_label'), style: const TextStyle(color: Color(0xFF6B7280))),
                            Text('${cart.count}${settings.translate('pcs')}', style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Divider(color: isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6)),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(settings.translate('total_price_label'), style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF111827))),
                            Text('${cart.total} ${Config.activeCurrencySymbol}', style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFFDC2626), fontSize: 18)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        
        // Checkout Action Button
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1F2937) : Colors.white,
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(isDark ? 0.3 : 0.1), blurRadius: 10, offset: const Offset(0, -2)),
            ],
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : () => _handleCheckout(cart),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626),
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey[300],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(settings.translate('place_order_btn'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(width: 8),
                        const Icon(Icons.shopping_cart_outlined, size: 18),
                      ],
                    ),
            ),
          ),
        ),
      ],
    );
  }
}
