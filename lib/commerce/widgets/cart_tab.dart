import 'package:flutter/material.dart';
import '../../services/cart_service.dart';
import '../../services/orders_service.dart';
import '../../config.dart';

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
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 28),
              SizedBox(width: 12),
              Text('Sargyt kabul edildi!', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          content: Text('Sargydyňyz üstünlikli kabul edildi! Sargyt belgisi: #$orderId.\nBiz ýakyn wagtda habarlaşarys.'),
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
              child: const Text('Ýap', style: TextStyle(color: Color(0xFFDC2626), fontWeight: FontWeight.bold)),
            )
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ýalňyşlyk ýüze çykdy: $e'),
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
      listenable: cart,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: const Color(0xFFF9FAFB),
          appBar: AppBar(
            title: Text(
              _checkoutStep == 1 ? 'Sebedim' : 'Sargyt maglumatlary',
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
              ? _buildEmptyState()
              : _checkoutStep == 1
                  ? _buildCartStep(cart)
                  : _buildInfoStep(cart),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: const BoxDecoration(
                color: Color(0xFFFEE2E2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.shopping_cart_outlined, size: 44, color: Color(0xFFDC2626)),
            ),
            const SizedBox(height: 24),
            const Text(
              'Sebediňiz boş',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF111827)),
            ),
            const SizedBox(height: 8),
            const Text(
              'Entek hiç haryt goşmadyňyz. Häzir söwda edip başlaň!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
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
                child: const Text('Söwda dowam et', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartStep(CartService cart) {
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
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE5E7EB), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        imageUrl,
                        width: 70,
                        height: 70,
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => Container(
                          width: 70,
                          height: 70,
                          color: const Color(0xFFF3F4F6),
                          child: const Icon(Icons.image_not_supported_outlined, color: Colors.grey),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            prod['name'] ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF111827)),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            prod['marka'] ?? 'Doganlar',
                            style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 12),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                               Text(
                                 '${prod['price']} ${Config.activeCurrencySymbol}',
                                 style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFFDC2626), fontSize: 15),
                               ),
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: const Color(0xFFE5E7EB)),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.remove, size: 14),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                                      onPressed: () => cart.updateQuantity(prod['id'], item['quantity'] - 1),
                                    ),
                                    Text(
                                      '${item['quantity']}',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.add, size: 14, color: Color(0xFFDC2626)),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                                      onPressed: () => cart.updateQuantity(prod['id'], item['quantity'] + 1),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFF9CA3AF)),
                      onPressed: () => cart.removeFromCart(prod['id']),
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
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2)),
            ],
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Jemi harytlar:', style: TextStyle(color: Color(0xFF6B7280))),
                  Text('${cart.count} sany', style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Umumy baha:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF111827))),
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
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Sargamak', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward, size: 18),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: cart.clearCart,
                icon: const Icon(Icons.delete_sweep_outlined, size: 18, color: Color(0xFF9CA3AF)),
                label: const Text('SEBEDI ARASSALA', style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoStep(CartService cart) {
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
                      color: const Color(0xFFFEE2E2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFFCA5A5)),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Sargyt etmek üçin maglumatlar', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF991B1B), fontSize: 14)),
                        SizedBox(height: 4),
                        Text('Sargydyňyzy tassyklamak üçin maglumatlary dolduryň. Biz gysga wagtda habarlaşarys.', style: TextStyle(color: Color(0xFFB91C1C), fontSize: 12)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Name Field
                  const Text('Doly adyňyz *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF4B5563))),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      hintText: 'At-familiýaňyz',
                      prefixIcon: const Icon(Icons.person_outline, size: 20),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFDC2626))),
                    ),
                    validator: (value) => value!.isEmpty ? 'Adyňyzy ýazyň' : null,
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Phone Field
                  const Text('Telefon belgiňiz *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF4B5563))),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      hintText: '+993 6...',
                      prefixIcon: const Icon(Icons.phone_outlined, size: 20),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFDC2626))),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) return 'Telefon belgiňizi ýazyň';
                      if (!value.startsWith('+993')) return 'Telefon belgi +993 bilen başlamaly';
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Note Field
                  const Text('Goşmaça bellik', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF4B5563))),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _noteController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Sargyt barada bellikleriňiz...',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFDC2626))),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Summary Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Sargyt jemlemesi', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF9CA3AF), letterSpacing: 0.8)),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Haryt sany:', style: TextStyle(color: Color(0xFF6B7280))),
                            Text('${cart.count} sany', style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Divider(color: Color(0xFFF3F4F6)),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Umumy baha:', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF111827))),
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
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2)),
            ],
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Sargyt etmek', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        SizedBox(width: 8),
                        Icon(Icons.shopping_cart_outlined, size: 18),
                      ],
                    ),
            ),
          ),
        ),
      ],
    );
  }
}
