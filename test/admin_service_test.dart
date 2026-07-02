import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:doganlarfoto/services/admin_service.dart';

void main() {
  tearDown(() => AdminService.client = http.Client());

  test('listProducts hits /commerce/products', () async {
    Uri? captured;
    AdminService.client = MockClient((req) async {
      captured = req.url;
      return http.Response(json.encode([{'id': 1, 'name': 'Camera'}]), 200);
    });

    final products = await AdminService.listProducts();
    expect(captured?.path, endsWith('/commerce/products'));
    expect(products.single['name'], 'Camera');
  });

  test('deleteProduct hits /commerce/products/{id}', () async {
    Uri? captured;
    AdminService.client = MockClient((req) async {
      captured = req.url;
      expect(req.method, 'DELETE');
      return http.Response('', 204);
    });

    await AdminService.deleteProduct(99);
    expect(captured?.path, endsWith('/commerce/products/99'));
  });

  test('listCommerceOrders hits /commerce/orders', () async {
    Uri? captured;
    AdminService.client = MockClient((req) async {
      captured = req.url;
      return http.Response(json.encode([{'id': 12, 'total_price': '150.00'}]), 200);
    });

    final orders = await AdminService.listCommerceOrders();
    expect(captured?.path, endsWith('/commerce/orders'));
    expect(orders.single['id'], 12);
  });

  test('listStudioOrders hits /management/orders', () async {
    Uri? captured;
    AdminService.client = MockClient((req) async {
      captured = req.url;
      return http.Response(json.encode([{'id': 5, 'customer_name': 'Aman'}]), 200);
    });

    final bookings = await AdminService.listStudioOrders();
    expect(captured?.path, endsWith('/management/orders'));
    expect(bookings.single['customer_name'], 'Aman');
  });

  test('listCampaigns hits /gifts/campaigns/', () async {
    Uri? captured;
    AdminService.client = MockClient((req) async {
      captured = req.url;
      return http.Response(json.encode([{'id': 2, 'title': 'Giveaway 2026'}]), 200);
    });

    final campaigns = await AdminService.listCampaigns();
    expect(captured?.path, endsWith('/gifts/campaigns/'));
    expect(campaigns.single['title'], 'Giveaway 2026');
  });

  test('listMessages hits /commerce/messages', () async {
    Uri? captured;
    AdminService.client = MockClient((req) async {
      captured = req.url;
      return http.Response(json.encode([{'id': 7, 'subject': 'Inquiry'}]), 200);
    });

    final msgs = await AdminService.listMessages();
    expect(captured?.path, endsWith('/commerce/messages'));
    expect(msgs.single['subject'], 'Inquiry');
  });
}
