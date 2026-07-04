import 'package:flutter/material.dart';
import 'splash_screen.dart';
import 'services/notification_service.dart';
import 'services/sync_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'config.dart';

import 'services/settings_service.dart';
import 'services/auth_service.dart';
import 'admin/admin_login_page.dart';
import 'admin/admin_main_layout_page.dart';

Future<void> fetchActiveCurrency() async {
  try {
    final res = await http.get(Uri.parse('${Config.apiBaseUrl}/currencies/active'));
    if (res.statusCode == 200) {
      final data = json.decode(utf8.decode(res.bodyBytes));
      if (data != null && data['symbol'] != null) {
        Config.activeCurrencySymbol = data['symbol'].toString();
      }
    }
  } catch (e) {
    debugPrint('Failed to load active currency: $e');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.init();
  final settings = SettingsService();
  await settings.init();
  SyncService.checkForUpdates();
  await fetchActiveCurrency();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: SettingsService(),
      builder: (context, _) {
        final settings = SettingsService();
        return MaterialApp(
          title: 'Doğanlar Foto',
          debugShowCheckedModeBanner: false,
          themeMode: settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          theme: ThemeData(
            brightness: Brightness.light,
            scaffoldBackgroundColor: Colors.white,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFFDC2626),
              primary: const Color(0xFFDC2626),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
              brightness: Brightness.light,
            ),
            textTheme: const TextTheme(
              bodyLarge: TextStyle(color: Colors.black),
              bodyMedium: TextStyle(color: Colors.black),
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              elevation: 0,
            ),
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF111827),
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFFDC2626),
              primary: const Color(0xFFDC2626),
              onPrimary: Colors.white,
              surface: const Color(0xFF1F2937),
              onSurface: Colors.white,
              brightness: Brightness.dark,
            ),
            textTheme: const TextTheme(
              bodyLarge: TextStyle(color: Colors.white),
              bodyMedium: TextStyle(color: Colors.white70),
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF111827),
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            useMaterial3: true,
          ),
          home: const SplashScreen(),
        );
      },
    );
  }
}

class AdminAuthWrapper extends StatelessWidget {
  const AdminAuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AuthService(),
      builder: (context, _) {
        final auth = AuthService();
        final user = auth.user;
        final bool isAdmin = auth.isAuthenticated &&
            user != null &&
            (user['role_name'] == 'Admin' || user['is_superuser'] == true);

        if (!isAdmin) {
          return const AdminLoginPage();
        }
        return const AdminMainLayoutPage();
      },
    );
  }
}
