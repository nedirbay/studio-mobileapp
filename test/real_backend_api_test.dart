import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studioapp/config.dart';
import 'package:studioapp/services/auth_service.dart';
import 'package:studioapp/services/commerce_service.dart';
import 'package:studioapp/services/orders_service.dart';
import 'package:studioapp/services/studio_order_service.dart';
import 'package:studioapp/services/promotions_service.dart';

void main() {
  setUpAll(() {
    // Override backendHost to point to real localhost
    Config.backendHost = '127.0.0.1:8000';
    SharedPreferences.setMockInitialValues({});
  });

  group('Real Backend API Integration Tests', () {
    test('1. Authentication login and change password', () async {
      final auth = AuthService();
      
      // Perform real login
      final loginRes = await auth.login('test_user', 'test_user_pass123');
      expect(auth.isAuthenticated, isTrue);
      expect(auth.user?['username'], 'test_user');
      expect(loginRes['jwt'], isNotEmpty);

      // Perform password change (from old to new)
      await auth.changePassword('test_user_pass123', 'test_user_newpass456');
      
      // Change it back so the account state remains identical for future test runs!
      await auth.changePassword('test_user_newpass456', 'test_user_pass123');
    });

    test('2. Commerce products, categories, banners, promos', () async {
      final cats = await CommerceService.categories();
      expect(cats, isA<List>());
      expect(cats.isNotEmpty, isTrue);

      final prods = await CommerceService.products();
      expect(prods, isA<List>());
      expect(prods.isNotEmpty, isTrue);

      final banners = await CommerceService.banners();
      expect(banners, isA<List>());

      final promos = await CommerceService.promos();
      expect(promos, isA<List>());
    });

    test('3. Submit Commerce Cart Order', () async {
      // Find a real product ID to submit
      final prods = await CommerceService.products();
      expect(prods.isNotEmpty, isTrue);
      final prodId = prods.first['id'];

      final orderRes = await OrdersService.createCartOrder(
        fullName: 'Test Customer Integration',
        phoneNumber: '+99361234567',
        items: [
          {'product': prodId, 'quantity': 2}
        ],
      );
      expect(orderRes['id'], isNotNull);
    });

    test('4. Studio Order Catalogs and Booking creation/deletion', () async {
      final auth = AuthService();
      await auth.login('test_user', 'test_user_pass123');
      print('Token loaded in memory: ${auth.token}');

      // Fetch catalogs
      final orderTypes = await StudioOrderService.listOrderTypes();
      expect(orderTypes, isA<List>());

      final services = await StudioOrderService.listServices();
      expect(services, isA<List>());
      expect(services.isNotEmpty, isTrue);

      final serviceId = services.first['id'];

      // Create a studio order booking
      final payload = {
        'customer_name': 'Test Integration Studio',
        'customer_phone': '+99367654321',
        'order_type_id': orderTypes.isNotEmpty ? orderTypes.first['id'] : null,
        'total_amount': 0,
        'paid_amount': 0,
        'days': [
          {
            'date': '2026-07-01',
            'time': '14:30',
            'address': 'Test Studio Address',
            'daily_price': 0,
            'services': [
              {'service_id': serviceId, 'count': 1}
            ],
            'equipments': [],
          }
        ],
        'staff': [],
      };

      final orderRes = await StudioOrderService.createOrder(payload);
      final orderId = orderRes['id'];
      print('Created Order ID: $orderId');
      expect(orderId, isNotNull);

      // Verify it is in list
      final list = await StudioOrderService.listOrders();
      print('Orders returned in list: $list');
      expect(list.any((o) => o['id'] == orderId), isTrue);

      // Clean up by deleting the created order
      await StudioOrderService.deleteOrder(orderId);
    });

    test('5. Promotions list and joining campaign', () async {
      final campaigns = await PromotionsService.listCampaigns(status: 'active');
      expect(campaigns, isA<List>());
      print('Active Campaigns returned: ${campaigns.map((c) => 'ID: ${c.id}, Title: ${c.title}, IsActive: ${c.isActive}').toList()}');
      
      if (campaigns.isNotEmpty) {
        final campaign = campaigns.first;
        print('Attempting to join Campaign: ${campaign.id}');
        // Join campaign
        await PromotionsService.join(
          campaign.id,
          fullName: 'Test Promotion Customer',
          phone: '+99369876543',
          email: 'test@promo.com',
          note: 'Integration testing',
        );
      }
    });
  });
}
