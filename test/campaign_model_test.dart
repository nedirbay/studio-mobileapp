import 'package:flutter_test/flutter_test.dart';
import 'package:studioapp/models/campaign.dart';

void main() {
  group('Campaign.fromJson', () {
    test('parses a full campaign payload', () {
      final c = Campaign.fromJson({
        'id': 5,
        'type': 'giveaway',
        'title': 'Win a camera',
        'subtitle': 'Free entry',
        'image_url': '/media/c.jpg',
        'banner_url': '/media/b.jpg',
        'prize_title': 'Sony A7',
        'prize_value': '12000',
        'starts_at': '2026-06-01T00:00:00Z',
        'ends_at': '2026-07-01T00:00:00Z',
        'discount_percent': 5,
        'promo_code': 'SAVE5',
        'is_featured': true,
        'status': 'active',
        'participants_count': 42,
        'is_active': true,
        'joined_by_me': false,
        'time_left_seconds': 3600,
        'rules_list': [
          {'id': 1, 'text': 'First rule', 'order': 0},
          {'id': 2, 'text': 'Second rule', 'order': 1},
        ],
      });

      expect(c.id, 5);
      expect(c.type, 'giveaway');
      expect(c.title, 'Win a camera');
      expect(c.prizeValue, 12000);
      expect(c.discountPercent, 5);
      expect(c.promoCode, 'SAVE5');
      expect(c.isFeatured, true);
      expect(c.isActive, true);
      expect(c.participantsCount, 42);
      expect(c.timeLeftSeconds, 3600);
      expect(c.rulesList.length, 2);
      expect(c.rulesList.first.text, 'First rule');
    });

    test('handles missing/null fields with safe defaults', () {
      final c = Campaign.fromJson({'id': 1, 'title': 'Bare', 'starts_at': '', 'status': 'draft'});

      expect(c.id, 1);
      expect(c.type, 'promotion'); // default
      expect(c.subtitle, isNull);
      expect(c.discountPercent, isNull);
      expect(c.isFeatured, false);
      expect(c.isActive, false);
      expect(c.joinedByMe, false);
      expect(c.participantsCount, 0);
      expect(c.rulesList, isEmpty);
    });

    test('coerces numeric strings and non-list rules safely', () {
      final c = Campaign.fromJson({
        'id': '7',
        'title': 'Coerce',
        'starts_at': '',
        'status': 'active',
        'discount_percent': '10',
        'participants_count': '3',
        'prize_value': 'not-a-number',
        'rules_list': 'oops-not-a-list',
      });

      expect(c.id, 7);
      expect(c.discountPercent, 10);
      expect(c.participantsCount, 3);
      expect(c.prizeValue, isNull);
      expect(c.rulesList, isEmpty);
    });
  });

  group('Campaign.resolveMedia', () {
    test('returns null for empty/null', () {
      expect(Campaign.resolveMedia(null), isNull);
      expect(Campaign.resolveMedia(''), isNull);
    });

    test('passes absolute urls through unchanged', () {
      expect(Campaign.resolveMedia('http://x/y.jpg'), 'http://x/y.jpg');
      expect(Campaign.resolveMedia('data:image/png;base64,AA'), 'data:image/png;base64,AA');
    });

    test('prefixes relative paths with the media base url', () {
      final resolved = Campaign.resolveMedia('/media/a.jpg')!;
      expect(resolved.endsWith('/media/a.jpg'), true);
      expect(resolved.startsWith('http'), true);
      // adds a leading slash when missing
      final noSlash = Campaign.resolveMedia('media/a.jpg')!;
      expect(noSlash.endsWith('/media/a.jpg'), true);
    });
  });
}
