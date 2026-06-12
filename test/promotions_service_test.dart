import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:studioapp/services/promotions_service.dart';

void main() {
  tearDown(() {
    // Restore the real client between tests.
    PromotionsService.client = http.Client();
  });

  group('PromotionsService.listCampaigns', () {
    test('requests the campaigns endpoint with status filter and parses a list', () async {
      late Uri captured;
      PromotionsService.client = MockClient((req) async {
        captured = req.url;
        return http.Response(
          json.encode([
            {'id': 1, 'type': 'giveaway', 'title': 'A', 'starts_at': '', 'status': 'active'},
            {'id': 2, 'type': 'gift', 'title': 'B', 'starts_at': '', 'status': 'active'},
          ]),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      });

      final result = await PromotionsService.listCampaigns(status: 'active');

      expect(captured.path, endsWith('/gifts/campaigns/'));
      expect(captured.queryParameters['status'], 'active');
      expect(captured.queryParameters.containsKey('type'), false);
      expect(result.length, 2);
      expect(result.first.title, 'A');
    });

    test('forwards the type filter when provided', () async {
      late Uri captured;
      PromotionsService.client = MockClient((req) async {
        captured = req.url;
        return http.Response('[]', 200);
      });

      await PromotionsService.listCampaigns(type: 'promotion', status: 'active');

      expect(captured.queryParameters['type'], 'promotion');
      expect(captured.queryParameters['status'], 'active');
    });

    test('unwraps a paginated {results: [...]} response', () async {
      PromotionsService.client = MockClient((req) async {
        return http.Response(
          json.encode({
            'count': 1,
            'results': [
              {'id': 9, 'type': 'promotion', 'title': 'Paginated', 'starts_at': '', 'status': 'active'}
            ],
          }),
          200,
        );
      });

      final result = await PromotionsService.listCampaigns();
      expect(result.single.title, 'Paginated');
    });

    test('throws on a non-200 response', () async {
      PromotionsService.client = MockClient((req) async => http.Response('boom', 500));
      expect(PromotionsService.listCampaigns(), throwsA(isA<Exception>()));
    });
  });

  group('PromotionsService.featured', () {
    test('hits the featured endpoint', () async {
      late Uri captured;
      PromotionsService.client = MockClient((req) async {
        captured = req.url;
        return http.Response('[]', 200);
      });

      await PromotionsService.featured();
      expect(captured.path, endsWith('/gifts/campaigns/featured/'));
    });
  });

  group('PromotionsService.join', () {
    test('posts required fields and omits empty optionals', () async {
      late http.Request captured;
      PromotionsService.client = MockClient((req) async {
        captured = req;
        return http.Response('{}', 201);
      });

      await PromotionsService.join(3, fullName: 'Ali', phone: '+99312', email: '', note: '');

      expect(captured.method, 'POST');
      expect(captured.url.path, endsWith('/gifts/campaigns/3/join/'));
      final body = json.decode(captured.body) as Map<String, dynamic>;
      expect(body['full_name'], 'Ali');
      expect(body['phone'], '+99312');
      expect(body.containsKey('email'), false);
      expect(body.containsKey('note'), false);
    });

    test('includes optional fields when present', () async {
      late http.Request captured;
      PromotionsService.client = MockClient((req) async {
        captured = req;
        return http.Response('{}', 200);
      });

      await PromotionsService.join(3, fullName: 'Ali', phone: '+99312', email: 'a@b.c', note: 'hi');

      final body = json.decode(captured.body) as Map<String, dynamic>;
      expect(body['email'], 'a@b.c');
      expect(body['note'], 'hi');
    });

    test('throws with the backend detail message on error', () async {
      PromotionsService.client = MockClient((req) async {
        return http.Response(json.encode({'detail': 'Already joined'}), 400);
      });

      expect(
        PromotionsService.join(3, fullName: 'Ali', phone: '+99312'),
        throwsA(predicate((e) => e.toString().contains('Already joined'))),
      );
    });
  });
}
