import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../config.dart';
import 'auth_service.dart';

class AdminService {
  static http.Client client = http.Client();

  static Map<String, String> _headers() {
    final token = AuthService().token;
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static dynamic _decode(http.Response res, String context) {
    if (res.statusCode < 200 || res.statusCode >= 300) {
      String errMsg = 'Ýalňyşlyk ýüze çykdy (Status: ${res.statusCode})';
      try {
        final decoded = json.decode(utf8.decode(res.bodyBytes));
        if (decoded is Map) {
          if (decoded['detail'] != null) errMsg = decoded['detail'].toString();
          if (decoded['error'] != null) errMsg = decoded['error'].toString();
          if (decoded['message'] != null) errMsg = decoded['message'].toString();
        }
      } catch (_) {}
      throw Exception('$context: $errMsg');
    }
    if (res.body.isEmpty) return null;
    return json.decode(utf8.decode(res.bodyBytes));
  }

  // --- Dashboard Stats ---
  static Future<Map<String, dynamic>> fetchDashboardStats() async {
    // We can infer statistics by loading categories and products, or query the backend directly
    // Let's call commerce/products and commerce/categories to get totals
    final products = await listProducts();
    final categories = await listCategories();
    
    int outOfStock = products.where((p) => p['instock'] == false || p['instock'] == 0).length;
    double ratingSum = 0;
    int ratedCount = 0;
    for (var p in products) {
      var r = p['rating'];
      if (r != null) {
        ratingSum += double.tryParse(r.toString()) ?? 0.0;
        ratedCount++;
      }
    }
    double avgRating = ratedCount > 0 ? ratingSum / ratedCount : 0.0;

    return {
      'totalProducts': products.length,
      'totalCategories': categories.length,
      'outOfStock': outOfStock,
      'averageRating': avgRating,
      'recentProducts': products.reversed.take(5).toList(),
      'categories': categories,
      'products': products,
    };
  }

  // --- Products CRUD ---
  static Future<List<dynamic>> listProducts() async {
    final res = await client.get(
      Uri.parse('${Config.apiBaseUrl}/commerce/products'),
      headers: _headers(),
    );
    final data = _decode(res, 'Harytlary ýüklemek');
    if (data is List) return data;
    if (data is Map && data['results'] is List) return data['results'];
    return [];
  }

  static Future<Map<String, dynamic>> createProduct(Map<String, dynamic> payload) async {
    final res = await client.post(
      Uri.parse('${Config.apiBaseUrl}/commerce/products'),
      headers: _headers(),
      body: json.encode(payload),
    );
    return Map<String, dynamic>.from(_decode(res, 'Haryt döretmek'));
  }

  static Future<Map<String, dynamic>> updateProduct(int id, Map<String, dynamic> payload) async {
    final res = await client.put(
      Uri.parse('${Config.apiBaseUrl}/commerce/products/$id'),
      headers: _headers(),
      body: json.encode(payload),
    );
    return Map<String, dynamic>.from(_decode(res, 'Haryt täzelemek'));
  }

  static Future<void> deleteProduct(int id) async {
    final res = await client.delete(
      Uri.parse('${Config.apiBaseUrl}/commerce/products/$id'),
      headers: _headers(),
    );
    _decode(res, 'Haryt pozmak');
  }

  // --- Categories CRUD ---
  static Future<List<dynamic>> listCategories() async {
    final res = await client.get(
      Uri.parse('${Config.apiBaseUrl}/commerce/categories'),
      headers: _headers(),
    );
    final data = _decode(res, 'Kategoriýalary ýüklemek');
    if (data is List) return data;
    return [];
  }

  static Future<Map<String, dynamic>> createCategory(Map<String, dynamic> payload) async {
    final res = await client.post(
      Uri.parse('${Config.apiBaseUrl}/commerce/categories'),
      headers: _headers(),
      body: json.encode(payload),
    );
    return Map<String, dynamic>.from(_decode(res, 'Kategoriýa döretmek'));
  }

  static Future<Map<String, dynamic>> updateCategory(int id, Map<String, dynamic> payload) async {
    final res = await client.put(
      Uri.parse('${Config.apiBaseUrl}/commerce/categories/$id'),
      headers: _headers(),
      body: json.encode(payload),
    );
    return Map<String, dynamic>.from(_decode(res, 'Kategoriýa täzelemek'));
  }

  static Future<void> deleteCategory(int id) async {
    final res = await client.delete(
      Uri.parse('${Config.apiBaseUrl}/commerce/categories/$id'),
      headers: _headers(),
    );
    _decode(res, 'Kategoriýa pozmak');
  }

  // --- Brands CRUD ---
  static Future<List<dynamic>> listBrands() async {
    final res = await client.get(
      Uri.parse('${Config.apiBaseUrl}/commerce/brands'),
      headers: _headers(),
    );
    final data = _decode(res, 'Brendleri ýüklemek');
    if (data is List) return data;
    return [];
  }

  static Future<Map<String, dynamic>> createBrand(Map<String, dynamic> payload) async {
    final res = await client.post(
      Uri.parse('${Config.apiBaseUrl}/commerce/brands'),
      headers: _headers(),
      body: json.encode(payload),
    );
    return Map<String, dynamic>.from(_decode(res, 'Brend döretmek'));
  }

  static Future<Map<String, dynamic>> updateBrand(int id, Map<String, dynamic> payload) async {
    final res = await client.put(
      Uri.parse('${Config.apiBaseUrl}/commerce/brands/$id'),
      headers: _headers(),
      body: json.encode(payload),
    );
    return Map<String, dynamic>.from(_decode(res, 'Brend täzelemek'));
  }

  static Future<void> deleteBrand(int id) async {
    final res = await client.delete(
      Uri.parse('${Config.apiBaseUrl}/commerce/brands/$id'),
      headers: _headers(),
    );
    _decode(res, 'Brend pozmak');
  }

  // --- Commerce Orders CRUD ---
  static Future<List<dynamic>> listCommerceOrders() async {
    final res = await client.get(
      Uri.parse('${Config.apiBaseUrl}/commerce/orders'),
      headers: _headers(),
    );
    final data = _decode(res, 'Sargytlary ýüklemek');
    if (data is List) return data;
    return [];
  }

  static Future<Map<String, dynamic>> getCommerceOrderDetail(int id) async {
    final res = await client.get(
      Uri.parse('${Config.apiBaseUrl}/commerce/orders/$id'),
      headers: _headers(),
    );
    return Map<String, dynamic>.from(_decode(res, 'Sargyt jikme-jikligi'));
  }

  static Future<Map<String, dynamic>> updateCommerceOrderStatus(int id, String status) async {
    final res = await client.patch(
      Uri.parse('${Config.apiBaseUrl}/commerce/orders/$id'),
      headers: _headers(),
      body: json.encode({'status': status}),
    );
    return Map<String, dynamic>.from(_decode(res, 'Sargyt statusyny täzelemek'));
  }

  static Future<void> deleteCommerceOrder(int id) async {
    final res = await client.delete(
      Uri.parse('${Config.apiBaseUrl}/commerce/orders/$id'),
      headers: _headers(),
    );
    _decode(res, 'Sargyt pozmak');
  }

  // --- Studio Orders (Bookings) CRUD ---
  static Future<List<dynamic>> listStudioOrders() async {
    final res = await client.get(
      Uri.parse('${Config.apiBaseUrl}/management/orders'),
      headers: _headers(),
    );
    final data = _decode(res, 'Studiýa sargytlaryny ýüklemek');
    if (data is List) return data;
    if (data is Map && data['results'] is List) return data['results'];
    return [];
  }

  static Future<Map<String, dynamic>> updateStudioOrder(int id, Map<String, dynamic> payload) async {
    final res = await client.put(
      Uri.parse('${Config.apiBaseUrl}/management/orders/$id'),
      headers: _headers(),
      body: json.encode(payload),
    );
    return Map<String, dynamic>.from(_decode(res, 'Studiýa sargydyny täzelemek'));
  }

  static Future<Map<String, dynamic>> setStudioOrderStatus(int id, String status) async {
    final res = await client.post(
      Uri.parse('${Config.apiBaseUrl}/management/orders/$id/status'),
      headers: _headers(),
      body: json.encode({'status': status}),
    );
    return Map<String, dynamic>.from(_decode(res, 'Studiýa sargyt statusy'));
  }

  static Future<void> deleteStudioOrder(int id) async {
    final res = await client.delete(
      Uri.parse('${Config.apiBaseUrl}/management/orders/$id'),
      headers: _headers(),
    );
    _decode(res, 'Studiýa sargydyny pozmak');
  }

  // --- Studio Catalogs CRUD ---
  static Future<List<dynamic>> listStudioEquipments() async {
    final res = await client.get(
      Uri.parse('${Config.apiBaseUrl}/management/equipments'),
      headers: _headers(),
    );
    final data = _decode(res, 'Enjamlary ýüklemek');
    if (data is List) return data;
    return [];
  }

  static Future<Map<String, dynamic>> createStudioEquipment(Map<String, dynamic> payload) async {
    final res = await client.post(
      Uri.parse('${Config.apiBaseUrl}/management/equipments'),
      headers: _headers(),
      body: json.encode(payload),
    );
    return Map<String, dynamic>.from(_decode(res, 'Enjam döretmek'));
  }

  static Future<Map<String, dynamic>> updateStudioEquipment(int id, Map<String, dynamic> payload) async {
    final res = await client.put(
      Uri.parse('${Config.apiBaseUrl}/management/equipments/$id'),
      headers: _headers(),
      body: json.encode(payload),
    );
    return Map<String, dynamic>.from(_decode(res, 'Enjam täzelemek'));
  }

  static Future<void> deleteStudioEquipment(int id) async {
    final res = await client.delete(
      Uri.parse('${Config.apiBaseUrl}/management/equipments/$id'),
      headers: _headers(),
    );
    _decode(res, 'Enjam pozmak');
  }

  static Future<List<dynamic>> listStudioServices() async {
    final res = await client.get(
      Uri.parse('${Config.apiBaseUrl}/management/services'),
      headers: _headers(),
    );
    final data = _decode(res, 'Hyzmatlary ýüklemek');
    if (data is List) return data;
    return [];
  }

  static Future<Map<String, dynamic>> createStudioService(Map<String, dynamic> payload) async {
    final res = await client.post(
      Uri.parse('${Config.apiBaseUrl}/management/services'),
      headers: _headers(),
      body: json.encode(payload),
    );
    return Map<String, dynamic>.from(_decode(res, 'Hyzmat döretmek'));
  }

  static Future<Map<String, dynamic>> updateStudioService(int id, Map<String, dynamic> payload) async {
    final res = await client.put(
      Uri.parse('${Config.apiBaseUrl}/management/services/$id'),
      headers: _headers(),
      body: json.encode(payload),
    );
    return Map<String, dynamic>.from(_decode(res, 'Hyzmat täzelemek'));
  }

  static Future<void> deleteStudioService(int id) async {
    final res = await client.delete(
      Uri.parse('${Config.apiBaseUrl}/management/services/$id'),
      headers: _headers(),
    );
    _decode(res, 'Hyzmat pozmak');
  }

  static Future<List<dynamic>> listStudioOrderTypes() async {
    final res = await client.get(
      Uri.parse('${Config.apiBaseUrl}/management/order-types'),
      headers: _headers(),
    );
    final data = _decode(res, 'Sargyt görnüşlerini ýüklemek');
    if (data is List) return data;
    return [];
  }

  static Future<Map<String, dynamic>> createStudioOrderType(Map<String, dynamic> payload) async {
    final res = await client.post(
      Uri.parse('${Config.apiBaseUrl}/management/order-types'),
      headers: _headers(),
      body: json.encode(payload),
    );
    return Map<String, dynamic>.from(_decode(res, 'Sargyt görnüşini döretmek'));
  }

  static Future<Map<String, dynamic>> updateStudioOrderType(int id, Map<String, dynamic> payload) async {
    final res = await client.put(
      Uri.parse('${Config.apiBaseUrl}/management/order-types/$id'),
      headers: _headers(),
      body: json.encode(payload),
    );
    return Map<String, dynamic>.from(_decode(res, 'Sargyt görnüşini täzelemek'));
  }

  static Future<void> deleteStudioOrderType(int id) async {
    final res = await client.delete(
      Uri.parse('${Config.apiBaseUrl}/management/order-types/$id'),
      headers: _headers(),
    );
    _decode(res, 'Sargyt görnüşini pozmak');
  }

  // --- PhotoStudio Gallery collections CRUD ---
  static Future<List<dynamic>> listCollections() async {
    final res = await client.get(
      Uri.parse('${Config.apiBaseUrl}/photostudio/collections/'),
      headers: _headers(),
    );
    final data = _decode(res, 'Kolleksiýalary ýüklemek');
    if (data is List) return data;
    if (data is Map && data['results'] is List) return data['results'];
    return [];
  }

  static Future<Map<String, dynamic>> createCollection(Map<String, dynamic> payload) async {
    final res = await client.post(
      Uri.parse('${Config.apiBaseUrl}/photostudio/collections/'),
      headers: _headers(),
      body: json.encode(payload),
    );
    return Map<String, dynamic>.from(_decode(res, 'Kolleksiýa döretmek'));
  }

  static Future<Map<String, dynamic>> updateCollection(int id, Map<String, dynamic> payload) async {
    final res = await client.put(
      Uri.parse('${Config.apiBaseUrl}/photostudio/collections/$id/'),
      headers: _headers(),
      body: json.encode(payload),
    );
    return Map<String, dynamic>.from(_decode(res, 'Kolleksiýa täzelemek'));
  }

  static Future<void> deleteCollection(int id) async {
    final res = await client.delete(
      Uri.parse('${Config.apiBaseUrl}/photostudio/collections/$id/'),
      headers: _headers(),
    );
    _decode(res, 'Kolleksiýa pozmak');
  }

  static Future<List<dynamic>> listCollectionItems(int collectionId) async {
    final res = await client.get(
      Uri.parse('${Config.apiBaseUrl}/photostudio/collections/$collectionId/items/'),
      headers: _headers(),
    );
    final data = _decode(res, 'Galereýa suratlaryny ýüklemek');
    if (data is List) return data;
    if (data is Map && data['results'] is List) return data['results'];
    return [];
  }

  static Future<Map<String, dynamic>> createCollectionItem(int collectionId, Map<String, dynamic> payload) async {
    final res = await client.post(
      Uri.parse('${Config.apiBaseUrl}/photostudio/collections/$collectionId/items/'),
      headers: _headers(),
      body: json.encode(payload),
    );
    return Map<String, dynamic>.from(_decode(res, 'Galereýa suratyny döretmek'));
  }

  static Future<void> deleteCollectionItem(int collectionId, int itemId) async {
    final res = await client.delete(
      Uri.parse('${Config.apiBaseUrl}/photostudio/collections/$collectionId/items/$itemId/'),
      headers: _headers(),
    );
    _decode(res, 'Galereýa suratyny pozmak');
  }

  // --- Banners CRUD ---
  static Future<List<dynamic>> listBanners() async {
    final res = await client.get(
      Uri.parse('${Config.apiBaseUrl}/banners'),
      headers: _headers(),
    );
    final data = _decode(res, 'Bannerleri ýüklemek');
    if (data is List) return data;
    return [];
  }

  static Future<Map<String, dynamic>> createBanner(Map<String, dynamic> payload) async {
    final res = await client.post(
      Uri.parse('${Config.apiBaseUrl}/banners'),
      headers: _headers(),
      body: json.encode(payload),
    );
    return Map<String, dynamic>.from(_decode(res, 'Banner döretmek'));
  }

  static Future<Map<String, dynamic>> updateBanner(Map<String, dynamic> payload) async {
    // The web banner uses PUT banners directly with a body containing id
    final res = await client.put(
      Uri.parse('${Config.apiBaseUrl}/banners'),
      headers: _headers(),
      body: json.encode(payload),
    );
    return Map<String, dynamic>.from(_decode(res, 'Banner täzelemek'));
  }

  static Future<void> deleteBanner(int id) async {
    final res = await client.delete(
      Uri.parse('${Config.apiBaseUrl}/banners'),
      headers: _headers(),
      body: json.encode({'id': id}),
    );
    _decode(res, 'Banner pozmak');
  }

  // --- Giveaway Campaigns CRUD ---
  static Future<List<dynamic>> listCampaigns() async {
    final res = await client.get(
      Uri.parse('${Config.apiBaseUrl}/gifts/campaigns/'),
      headers: _headers(),
    );
    final data = _decode(res, 'Aksiýalary ýüklemek');
    if (data is List) return data;
    if (data is Map && data['results'] is List) return data['results'];
    return [];
  }

  static Future<Map<String, dynamic>> createCampaign(Map<String, dynamic> payload) async {
    final res = await client.post(
      Uri.parse('${Config.apiBaseUrl}/gifts/campaigns/'),
      headers: _headers(),
      body: json.encode(payload),
    );
    return Map<String, dynamic>.from(_decode(res, 'Aksiýa döretmek'));
  }

  static Future<Map<String, dynamic>> updateCampaign(int id, Map<String, dynamic> payload) async {
    final res = await client.put(
      Uri.parse('${Config.apiBaseUrl}/gifts/campaigns/$id/'),
      headers: _headers(),
      body: json.encode(payload),
    );
    return Map<String, dynamic>.from(_decode(res, 'Aksiýa täzelemek'));
  }

  static Future<void> deleteCampaign(int id) async {
    final res = await client.delete(
      Uri.parse('${Config.apiBaseUrl}/gifts/campaigns/$id/'),
      headers: _headers(),
    );
    _decode(res, 'Aksiýa pozmak');
  }

  static Future<List<dynamic>> listCampaignParticipants(int campaignId) async {
    final res = await client.get(
      Uri.parse('${Config.apiBaseUrl}/gifts/campaigns/$campaignId/join/'),
      headers: _headers(),
    );
    final data = _decode(res, 'Gatnaşyjylary ýüklemek');
    if (data is List) return data;
    return [];
  }

  static Future<Map<String, dynamic>> updateParticipantStatus(int participationId, String status) async {
    final res = await client.patch(
      Uri.parse('${Config.apiBaseUrl}/gifts/participations/$participationId/'),
      headers: _headers(),
      body: json.encode({'status': status}),
    );
    return Map<String, dynamic>.from(_decode(res, 'Gatnaşyjy statusyny üýtgetmek'));
  }

  // --- Blogs CRUD ---
  static Future<List<dynamic>> listBlogs() async {
    final res = await client.get(
      Uri.parse('${Config.apiBaseUrl}/blogs'),
      headers: _headers(),
    );
    final data = _decode(res, 'Bloglary ýüklemek');
    if (data is List) return data;
    if (data is Map && data['results'] is List) return data['results'];
    return [];
  }

  static Future<Map<String, dynamic>> createBlog(Map<String, dynamic> payload) async {
    final res = await client.post(
      Uri.parse('${Config.apiBaseUrl}/blogs'),
      headers: _headers(),
      body: json.encode(payload),
    );
    return Map<String, dynamic>.from(_decode(res, 'Blog döretmek'));
  }

  static Future<Map<String, dynamic>> updateBlog(String slug, Map<String, dynamic> payload) async {
    final res = await client.put(
      Uri.parse('${Config.apiBaseUrl}/blogs/$slug'),
      headers: _headers(),
      body: json.encode(payload),
    );
    return Map<String, dynamic>.from(_decode(res, 'Blog täzelemek'));
  }

  static Future<void> deleteBlog(String slug) async {
    final res = await client.delete(
      Uri.parse('${Config.apiBaseUrl}/blogs/$slug'),
      headers: _headers(),
    );
    _decode(res, 'Blog pozmak');
  }

  // --- Customer Messages (Support) ---
  static Future<List<dynamic>> listMessages() async {
    final res = await client.get(
      Uri.parse('${Config.apiBaseUrl}/commerce/messages'),
      headers: _headers(),
    );
    final data = _decode(res, 'Hatlary ýüklemek');
    if (data is List) return data;
    return [];
  }

  static Future<Map<String, dynamic>> replyToMessage(int id, String reply) async {
    final res = await client.put(
      Uri.parse('${Config.apiBaseUrl}/commerce/messages/$id'),
      headers: _headers(),
      body: json.encode({'reply': reply}),
    );
    return Map<String, dynamic>.from(_decode(res, 'Hata jogap bermek'));
  }

  static Future<void> deleteMessage(int id) async {
    final res = await client.delete(
      Uri.parse('${Config.apiBaseUrl}/commerce/messages/$id'),
      headers: _headers(),
    );
    _decode(res, 'Haty pozmak');
  }

  // --- Users CRUD ---
  static Future<List<dynamic>> listUsers({String search = '', String role = ''}) async {
    final queryParams = <String, String>{};
    if (search.isNotEmpty) queryParams['search'] = search;
    if (role.isNotEmpty) queryParams['role'] = role;
    
    final uri = Uri.parse('${Config.apiBaseUrl}/users/').replace(queryParameters: queryParams);
    final res = await client.get(
      uri,
      headers: _headers(),
    );
    final data = _decode(res, 'Ulanyjylary ýüklemek');
    if (data is List) return data;
    if (data is Map && data['results'] is List) return data['results'];
    return [];
  }

  static Future<Map<String, dynamic>> createUser(Map<String, dynamic> payload) async {
    final res = await client.post(
      Uri.parse('${Config.apiBaseUrl}/users/'),
      headers: _headers(),
      body: json.encode(payload),
    );
    return Map<String, dynamic>.from(_decode(res, 'Ulanyjy döretmek'));
  }

  static Future<Map<String, dynamic>> updateUser(int id, Map<String, dynamic> payload) async {
    final res = await client.put(
      Uri.parse('${Config.apiBaseUrl}/users/$id/'),
      headers: _headers(),
      body: json.encode(payload),
    );
    return Map<String, dynamic>.from(_decode(res, 'Ulanyjy täzelemek'));
  }

  static Future<void> deleteUser(int id) async {
    final res = await client.delete(
      Uri.parse('${Config.apiBaseUrl}/users/$id/'),
      headers: _headers(),
    );
    _decode(res, 'Ulanyjy pozmak');
  }

  // --- Product Reviews CRUD ---
  static Future<List<dynamic>> listReviews() async {
    final res = await client.get(
      Uri.parse('${Config.apiBaseUrl}/commerce/reviews'),
      headers: _headers(),
    );
    final data = _decode(res, 'Teswirleri ýüklemek');
    if (data is List) return data;
    if (data is Map && data['results'] is List) return data['results'];
    return [];
  }

  static Future<Map<String, dynamic>> updateReviewReadStatus(int id, bool isRead) async {
    final res = await client.put(
      Uri.parse('${Config.apiBaseUrl}/commerce/reviews/$id'),
      headers: _headers(),
      body: json.encode({'is_read': isRead}),
    );
    return Map<String, dynamic>.from(_decode(res, 'Teswir statusyny täzelemek'));
  }

  static Future<void> deleteReview(int id) async {
    final res = await client.delete(
      Uri.parse('${Config.apiBaseUrl}/commerce/reviews/$id'),
      headers: _headers(),
    );
    _decode(res, 'Teswiri pozmak');
  }

  // --- Currencies CRUD ---
  static Future<List<dynamic>> listCurrencies() async {
    final res = await client.get(
      Uri.parse('${Config.apiBaseUrl}/currencies'),
      headers: _headers(),
    );
    final data = _decode(res, 'Pul birlikleri ýüklemek');
    if (data is List) return data;
    return [];
  }

  static Future<Map<String, dynamic>> createCurrency(Map<String, dynamic> payload) async {
    final res = await client.post(
      Uri.parse('${Config.apiBaseUrl}/currencies'),
      headers: _headers(),
      body: json.encode(payload),
    );
    return Map<String, dynamic>.from(_decode(res, 'Walýuta döretmek'));
  }

  static Future<Map<String, dynamic>> updateCurrency(int id, Map<String, dynamic> payload) async {
    final res = await client.put(
      Uri.parse('${Config.apiBaseUrl}/currencies/$id'),
      headers: _headers(),
      body: json.encode(payload),
    );
    return Map<String, dynamic>.from(_decode(res, 'Walýuta täzelemek'));
  }

  static Future<void> deleteCurrency(int id) async {
    final res = await client.delete(
      Uri.parse('${Config.apiBaseUrl}/currencies/$id'),
      headers: _headers(),
    );
    _decode(res, 'Walýuta pozmak');
  }

  static Future<void> activateCurrency(int id) async {
    final res = await client.post(
      Uri.parse('${Config.apiBaseUrl}/currencies/$id/activate'),
      headers: _headers(),
    );
    _decode(res, 'Walýuta işjeňleşdirmek');
  }

  // --- Mobile App Versions CRUD ---
  static Future<List<dynamic>> listAppVersions() async {
    final res = await client.get(
      Uri.parse('${Config.apiBaseUrl}/mobile-apps/versions'),
      headers: _headers(),
    );
    final data = _decode(res, 'Programma wersiýalaryny ýüklemek');
    if (data is List) return data;
    return [];
  }

  static Future<Map<String, dynamic>> createAppVersion({
    required Map<String, dynamic> payload,
    String? filePath,
    Uint8List? fileBytes,
    String? fileName,
  }) async {
    final uri = Uri.parse('${Config.apiBaseUrl}/mobile-apps/versions');
    final request = http.MultipartRequest('POST', uri);
    
    _headers().forEach((key, val) {
      request.headers[key] = val;
    });
    
    request.fields['version_name'] = payload['version_name'].toString();
    request.fields['version_code'] = payload['version_code'].toString();
    request.fields['description'] = payload['description'].toString();
    request.fields['is_active'] = payload['is_active'].toString();
    
    if (filePath != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'file',
        filePath,
        filename: fileName ?? 'app-release.apk',
      ));
    } else if (fileBytes != null) {
      request.files.add(http.MultipartFile.fromBytes(
        'file',
        fileBytes,
        filename: fileName ?? 'app-release.apk',
      ));
    } else {
      final mockBytes = utf8.encode('dummy apk content');
      request.files.add(http.MultipartFile.fromBytes(
        'file',
        mockBytes,
        filename: 'app-release.apk',
      ));
    }
    
    final streamedResponse = await request.send();
    final res = await http.Response.fromStream(streamedResponse);
    return Map<String, dynamic>.from(_decode(res, 'Wersiýa goşmak'));
  }

  static Future<Map<String, dynamic>> updateAppVersion({
    required int id,
    required Map<String, dynamic> payload,
    String? filePath,
    Uint8List? fileBytes,
    String? fileName,
  }) async {
    final uri = Uri.parse('${Config.apiBaseUrl}/mobile-apps/versions/$id');
    final request = http.MultipartRequest('PUT', uri);
    
    _headers().forEach((key, val) {
      request.headers[key] = val;
    });
    
    request.fields['version_name'] = payload['version_name'].toString();
    request.fields['version_code'] = payload['version_code'].toString();
    request.fields['description'] = payload['description'].toString();
    request.fields['is_active'] = payload['is_active'].toString();
    
    if (filePath != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'file',
        filePath,
        filename: fileName ?? 'app-release-updated.apk',
      ));
    } else if (fileBytes != null) {
      request.files.add(http.MultipartFile.fromBytes(
        'file',
        fileBytes,
        filename: fileName ?? 'app-release-updated.apk',
      ));
    } else if (payload['has_new_file'] == true) {
      final mockBytes = utf8.encode('dummy apk content updated');
      request.files.add(http.MultipartFile.fromBytes(
        'file',
        mockBytes,
        filename: 'app-release-updated.apk',
      ));
    }
    
    final streamedResponse = await request.send();
    final res = await http.Response.fromStream(streamedResponse);
    return Map<String, dynamic>.from(_decode(res, 'Wersiýa täzelemek'));
  }

  static Future<void> activateAppVersion(int id) async {
    final res = await client.post(
      Uri.parse('${Config.apiBaseUrl}/mobile-apps/versions/$id/activate'),
      headers: _headers(),
    );
    _decode(res, 'Wersiýa işjeňleşdirmek');
  }

  static Future<void> deleteAppVersion(int id) async {
    final res = await client.delete(
      Uri.parse('${Config.apiBaseUrl}/mobile-apps/versions/$id'),
      headers: _headers(),
    );
    _decode(res, 'Wersiýa pozmak');
  }

  // --- System Logs ---
  static Future<List<dynamic>> listLogs() async {
    final res = await client.get(
      Uri.parse('${Config.apiBaseUrl}/admin/logs'),
      headers: _headers(),
    );
    final data = _decode(res, 'Sistem loglary ýüklemek');
    if (data is List) return data;
    return [];
  }

  static Future<void> deleteLogs(Map<String, dynamic> payload) async {
    final res = await client.delete(
      Uri.parse('${Config.apiBaseUrl}/admin/logs'),
      headers: _headers(),
      body: json.encode(payload),
    );
    _decode(res, 'Sistem loglary pozmak');
  }

  static Future<String> exportLogsCSV() async {
    final res = await client.get(
      Uri.parse('${Config.apiBaseUrl}/admin/logs?export=csv'),
      headers: _headers(),
    );
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('CSV eksport etmek şowsuz boldy (Status: ${res.statusCode})');
    }
    return utf8.decode(res.bodyBytes);
  }
  static Future<String> uploadImage({
    String? filePath,
    Uint8List? fileBytes,
    required String fileName,
  }) async {
    final uri = Uri.parse('${Config.apiBaseUrl}/commerce/upload');
    final request = http.MultipartRequest('POST', uri);
    _headers().forEach((key, val) {
      if (key != 'Content-Type') request.headers[key] = val;
    });
    if (filePath != null) {
      request.files.add(await http.MultipartFile.fromPath('file', filePath, filename: fileName));
    } else if (fileBytes != null) {
      request.files.add(http.MultipartFile.fromBytes('file', fileBytes, filename: fileName));
    } else {
      throw Exception('Surat faýly ýok');
    }
    final streamedResponse = await request.send();
    final res = await http.Response.fromStream(streamedResponse);
    final data = _decode(res, 'Surat ýüklemek');
    return data['url'] as String;
  }

  // --- PhotoStudio Videos direct CRUD ---
  static Future<Map<String, dynamic>> listStudioVideos({int page = 1, int pageSize = 10}) async {
    final res = await client.get(
      Uri.parse('${Config.apiBaseUrl}/photostudio/videos/?page=$page&page_size=$pageSize'),
      headers: _headers(),
    );
    final data = _decode(res, 'Wideolary ýüklemek');
    if (data is Map) return Map<String, dynamic>.from(data);
    return {'count': 0, 'results': []};
  }

  static Future<Map<String, dynamic>> createStudioVideo({
    required String title,
    required String description,
    String? videoPath,
    Uint8List? videoBytes,
    String? videoName,
    String? thumbnailPath,
    Uint8List? thumbnailBytes,
    String? thumbnailName,
  }) async {
    final uri = Uri.parse('${Config.apiBaseUrl}/photostudio/videos/');
    final request = http.MultipartRequest('POST', uri);
    _headers().forEach((key, val) {
      if (key != 'Content-Type') request.headers[key] = val;
    });

    request.fields['title'] = title;
    request.fields['description'] = description;

    if (videoPath != null) {
      request.files.add(await http.MultipartFile.fromPath('video', videoPath, filename: videoName));
    } else if (videoBytes != null) {
      request.files.add(http.MultipartFile.fromBytes('video', videoBytes, filename: videoName));
    }

    if (thumbnailPath != null) {
      request.files.add(await http.MultipartFile.fromPath('thumbnail_image', thumbnailPath, filename: thumbnailName));
    } else if (thumbnailBytes != null) {
      request.files.add(http.MultipartFile.fromBytes('thumbnail_image', thumbnailBytes, filename: thumbnailName));
    }

    final streamedResponse = await request.send();
    final res = await http.Response.fromStream(streamedResponse);
    return Map<String, dynamic>.from(_decode(res, 'Wideo goşmak'));
  }

  static Future<Map<String, dynamic>> updateStudioVideo({
    required int id,
    required String title,
    required String description,
    String? videoPath,
    Uint8List? videoBytes,
    String? videoName,
    String? thumbnailPath,
    Uint8List? thumbnailBytes,
    String? thumbnailName,
  }) async {
    final uri = Uri.parse('${Config.apiBaseUrl}/photostudio/videos/$id/');
    final request = http.MultipartRequest('PATCH', uri);
    _headers().forEach((key, val) {
      if (key != 'Content-Type') request.headers[key] = val;
    });

    request.fields['title'] = title;
    request.fields['description'] = description;

    if (videoPath != null) {
      request.files.add(await http.MultipartFile.fromPath('video', videoPath, filename: videoName));
    } else if (videoBytes != null) {
      request.files.add(http.MultipartFile.fromBytes('video', videoBytes, filename: videoName));
    }

    if (thumbnailPath != null) {
      request.files.add(await http.MultipartFile.fromPath('thumbnail_image', thumbnailPath, filename: thumbnailName));
    } else if (thumbnailBytes != null) {
      request.files.add(http.MultipartFile.fromBytes('thumbnail_image', thumbnailBytes, filename: thumbnailName));
    }

    final streamedResponse = await request.send();
    final res = await http.Response.fromStream(streamedResponse);
    return Map<String, dynamic>.from(_decode(res, 'Wideo üýtgetmek'));
  }

  static Future<void> deleteStudioVideo(int id) async {
    final res = await client.delete(
      Uri.parse('${Config.apiBaseUrl}/photostudio/videos/$id/'),
      headers: _headers(),
    );
    _decode(res, 'Wideo pozmak');
  }

  // --- PhotoStudio Images direct CRUD ---
  static Future<Map<String, dynamic>> listStudioImages({int page = 1, int pageSize = 10}) async {
    final res = await client.get(
      Uri.parse('${Config.apiBaseUrl}/photostudio/images/?page=$page&page_size=$pageSize'),
      headers: _headers(),
    );
    final data = _decode(res, 'Suratlary ýüklemek');
    if (data is Map) return Map<String, dynamic>.from(data);
    return {'count': 0, 'results': []};
  }

  static Future<Map<String, dynamic>> createStudioImage({
    required String title,
    required String description,
    String? imagePath,
    Uint8List? imageBytes,
    String? imageName,
    String? thumbnailPath,
    Uint8List? thumbnailBytes,
    String? thumbnailName,
  }) async {
    final uri = Uri.parse('${Config.apiBaseUrl}/photostudio/images/');
    final request = http.MultipartRequest('POST', uri);
    _headers().forEach((key, val) {
      if (key != 'Content-Type') request.headers[key] = val;
    });

    request.fields['title'] = title;
    request.fields['description'] = description;

    if (imagePath != null) {
      request.files.add(await http.MultipartFile.fromPath('image', imagePath, filename: imageName));
    } else if (imageBytes != null) {
      request.files.add(http.MultipartFile.fromBytes('image', imageBytes, filename: imageName));
    }

    if (thumbnailPath != null) {
      request.files.add(await http.MultipartFile.fromPath('thumbnail_image', thumbnailPath, filename: thumbnailName));
    } else if (thumbnailBytes != null) {
      request.files.add(http.MultipartFile.fromBytes('thumbnail_image', thumbnailBytes, filename: thumbnailName));
    }

    final streamedResponse = await request.send();
    final res = await http.Response.fromStream(streamedResponse);
    return Map<String, dynamic>.from(_decode(res, 'Surat goşmak'));
  }

  static Future<Map<String, dynamic>> updateStudioImage({
    required int id,
    required String title,
    required String description,
    String? imagePath,
    Uint8List? imageBytes,
    String? imageName,
    String? thumbnailPath,
    Uint8List? thumbnailBytes,
    String? thumbnailName,
  }) async {
    final uri = Uri.parse('${Config.apiBaseUrl}/photostudio/images/$id/');
    final request = http.MultipartRequest('PATCH', uri);
    _headers().forEach((key, val) {
      if (key != 'Content-Type') request.headers[key] = val;
    });

    request.fields['title'] = title;
    request.fields['description'] = description;

    if (imagePath != null) {
      request.files.add(await http.MultipartFile.fromPath('image', imagePath, filename: imageName));
    } else if (imageBytes != null) {
      request.files.add(http.MultipartFile.fromBytes('image', imageBytes, filename: imageName));
    }

    if (thumbnailPath != null) {
      request.files.add(await http.MultipartFile.fromPath('thumbnail_image', thumbnailPath, filename: thumbnailName));
    } else if (thumbnailBytes != null) {
      request.files.add(http.MultipartFile.fromBytes('thumbnail_image', thumbnailBytes, filename: thumbnailName));
    }

    final streamedResponse = await request.send();
    final res = await http.Response.fromStream(streamedResponse);
    return Map<String, dynamic>.from(_decode(res, 'Surat üýtgetmek'));
  }

  static Future<void> deleteStudioImage(int id) async {
    final res = await client.delete(
      Uri.parse('${Config.apiBaseUrl}/photostudio/images/$id/'),
      headers: _headers(),
    );
    _decode(res, 'Surat pozmak');
  }
}

