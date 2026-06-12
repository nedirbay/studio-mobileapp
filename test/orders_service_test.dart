import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:studioapp/services/orders_service.dart';

void main() {
  tearDown(() => OrdersService.client = http.Client());

  group('createProductOrder', () {
    test('posts to /commerce/orders (no trailing slash) with product item', () async {
      late http.Request captured;
      OrdersService.client = MockClient((req) async {
        captured = req;
        return http.Response(json.encode({'id': 1}), 201);
      });

      await OrdersService.createProductOrder(
        fullName: 'Ali',
        phoneNumber: '+99312',
        productId: 7,
        quantity: 2,
      );

      expect(captured.method, 'POST');
      expect(captured.url.path, endsWith('/commerce/orders'));
      expect(captured.url.path.endsWith('/commerce/orders/'), false);
      final body = json.decode(captured.body) as Map<String, dynamic>;
      expect(body['full_name'], 'Ali');
      expect(body['phone_number'], '+99312');
      expect((body['items'] as List).first['product'], 7);
      expect((body['items'] as List).first['quantity'], 2);
    });

    test('throws backend detail on error', () async {
      OrdersService.client = MockClient((req) async {
        return http.Response(json.encode({'detail': 'Out of stock'}), 400);
      });
      expect(
        OrdersService.createProductOrder(fullName: 'A', phoneNumber: 'B', productId: 1),
        throwsA(predicate((e) => e.toString().contains('Out of stock'))),
      );
    });
  });

  group('createStudioOrder', () {
    test('posts to /orders with customer fields and amounts', () async {
      late http.Request captured;
      OrdersService.client = MockClient((req) async {
        captured = req;
        return http.Response(json.encode({'id': 5}), 201);
      });

      await OrdersService.createStudioOrder(customerName: 'Maya', customerPhone: '+99361');

      expect(captured.url.path, endsWith('/orders'));
      final body = json.decode(captured.body) as Map<String, dynamic>;
      expect(body['customer_name'], 'Maya');
      expect(body['customer_phone'], '+99361');
      // total_amount / paid_amount are required by the backend.
      expect(body.containsKey('total_amount'), true);
      expect(body.containsKey('paid_amount'), true);
    });

    test('throws on error response', () async {
      OrdersService.client = MockClient((req) async => http.Response('{}', 500));
      expect(
        OrdersService.createStudioOrder(customerName: 'A', customerPhone: 'B'),
        throwsA(isA<Exception>()),
      );
    });
  });
}
