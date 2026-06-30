import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartService extends ChangeNotifier {
  static final CartService _instance = CartService._internal();
  factory CartService() => _instance;
  CartService._internal() {
    loadCart();
  }

  List<Map<String, dynamic>> _items = [];
  List<Map<String, dynamic>> get items => _items;

  int get count => _items.fold(0, (sum, item) => sum + (item['quantity'] as int));
  
  double get total => _items.fold(0.0, (sum, item) {
    final price = (item['product']['price'] as num).toDouble();
    final qty = item['quantity'] as int;
    return sum + (price * qty);
  });

  Future<void> loadCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dataStr = prefs.getString('cart_items');
      if (dataStr != null) {
        final List decoded = json.decode(dataStr);
        _items = decoded.map((e) => Map<String, dynamic>.from(e)).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading cart: $e');
    }
  }

  Future<void> saveCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('cart_items', json.encode(_items));
    } catch (e) {
      debugPrint('Error saving cart: $e');
    }
  }

  void addToCart(Map<String, dynamic> product, {int quantity = 1}) {
    final existingIndex = _items.indexWhere((item) => item['product']['id'].toString() == product['id'].toString());
    if (existingIndex >= 0) {
      _items[existingIndex]['quantity'] += quantity;
    } else {
      _items.add({
        'id': product['id'].toString(),
        'product': product,
        'quantity': quantity,
      });
    }
    saveCart();
    notifyListeners();
  }

  void updateQuantity(dynamic productId, int quantity) {
    final index = _items.indexWhere((item) => item['product']['id'].toString() == productId.toString());
    if (index >= 0) {
      if (quantity <= 0) {
        _items.removeAt(index);
      } else {
        _items[index]['quantity'] = quantity;
      }
      saveCart();
      notifyListeners();
    }
  }

  void removeFromCart(dynamic productId) {
    _items.removeWhere((item) => item['product']['id'].toString() == productId.toString());
    saveCart();
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    saveCart();
    notifyListeners();
  }
}
