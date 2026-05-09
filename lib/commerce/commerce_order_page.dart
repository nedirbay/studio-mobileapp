import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config.dart';
import '../widgets/top_bar.dart';
import '../widgets/app_header.dart';

class CommerceOrderPage extends StatefulWidget {
  final String productName;
  final double price;
  const CommerceOrderPage({super.key, required this.productName, required this.price});

  @override
  State<CommerceOrderPage> createState() => _CommerceOrderPageState();
}

class _CommerceOrderPageState extends State<CommerceOrderPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  bool isSubmitting = false;

  Future<void> _submitOrder() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isSubmitting = true);

    try {
      final response = await http.post(
        Uri.parse('${Config.apiBaseUrl}/commerce/orders/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'customer_name': _nameController.text,
          'customer_phone': _phoneController.text,
          'items': [
            {
              'product_name': widget.productName,
              'quantity': 1,
              'price': widget.price,
            }
          ],
          'status': 'pending',
        }),
      );

      if (response.statusCode == 201) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sargydyňyz kabul edildi!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      } else {
        throw Exception('Sargyt ugradyp bolmady');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ýalňyşlyk ýüze çykdy: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const TopBar(),
              const AppHeader(),
              
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Haryt sargydy',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Haryt: ${widget.productName}',
                        style: const TextStyle(color: Color(0xFF6B7280)),
                      ),
                      Text(
                        'Baha: \$${widget.price}',
                        style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 32),
                      
                      const Text('Adyňyz', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          hintText: 'Mysal üçin: Myrat',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: const Color(0xFFF9FAFB),
                        ),
                        validator: (value) => value!.isEmpty ? 'Adyňyzy ýazyň' : null,
                      ),
                      
                      const SizedBox(height: 20),
                      
                      const Text('Telefon belgiňiz', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          hintText: '+993 6...',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: const Color(0xFFF9FAFB),
                        ),
                        validator: (value) => value!.isEmpty ? 'Telefon belgiňizi ýazyň' : null,
                      ),
                      
                      const SizedBox(height: 40),
                      
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: isSubmitting ? null : _submitOrder,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: isSubmitting 
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('Sargyt et', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
