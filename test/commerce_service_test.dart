import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:studioapp/services/commerce_service.dart';

void main() {
  tearDown(() => CommerceService.client = http.Client());

  test('categories hits /commerce/categories and returns a list', () async {
    late Uri captured;
    CommerceService.client = MockClient((req) async {
      captured = req.url;
      return http.Response(json.encode([{'id': 1, 'name': 'Cameras'}]), 200);
    });

    final result = await CommerceService.categories();
    expect(captured.path, endsWith('/commerce/categories'));
    expect(result.length, 1);
    expect(result.first['name'], 'Cameras');
  });

  test('products unwraps a paginated {results:[]} response', () async {
    CommerceService.client = MockClient((req) async {
      return http.Response(json.encode({'results': [{'id': 9}]}), 200);
    });
    final result = await CommerceService.products();
    expect(result.single['id'], 9);
  });

  test('banners hits /banners (storefront root, not /commerce)', () async {
    late Uri captured;
    CommerceService.client = MockClient((req) async {
      captured = req.url;
      return http.Response('[]', 200);
    });
    await CommerceService.banners();
    expect(captured.path, endsWith('/banners'));
    expect(captured.path.contains('/commerce/banners'), false);
  });

  test('productDetail hits /commerce/products/{id} and returns a map', () async {
    late Uri captured;
    CommerceService.client = MockClient((req) async {
      captured = req.url;
      return http.Response(json.encode({'id': 7, 'name': 'X'}), 200);
    });
    final product = await CommerceService.productDetail(7);
    expect(captured.path, endsWith('/commerce/products/7'));
    expect(product['name'], 'X');
  });

  test('reviews hits /commerce/products/{id}/reviews', () async {
    late Uri captured;
    CommerceService.client = MockClient((req) async {
      captured = req.url;
      return http.Response('[]', 200);
    });
    await CommerceService.reviews(7);
    expect(captured.path, endsWith('/commerce/products/7/reviews'));
  });

  test('throws on non-200', () async {
    CommerceService.client = MockClient((req) async => http.Response('err', 500));
    expect(CommerceService.products(), throwsA(isA<Exception>()));
  });
}
