import 'package:flutter/material.dart';
import 'all_products/all_products_page.dart';
import 'widgets/haryt_home_tab.dart';
import 'widgets/cart_tab.dart';
import '../identity/profile_page.dart';
import '../widgets/top_bar.dart';
import '../widgets/app_header.dart';
import '../config.dart';

import '../services/settings_service.dart';
import '../services/cart_service.dart';

class HarytlarMainPage extends StatefulWidget {
  final int initialTab;

  const HarytlarMainPage({super.key, this.initialTab = 0});

  @override
  State<HarytlarMainPage> createState() => _HarytlarMainPageState();
}

class _HarytlarMainPageState extends State<HarytlarMainPage> {
  late int _currentIndex;
  String? _selectedBrand;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTab;
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([SettingsService(), CartService()]),
      builder: (context, _) {
        final settings = SettingsService();
        final cart = CartService();
        final isDark = settings.isDarkMode;
        final bgColor = isDark ? const Color(0xFF111827) : const Color(0xFFF9FAFB);
        final navBgColor = isDark ? const Color(0xFF1F2937) : Colors.white;
        final cartCount = cart.count;

        final List<Widget> children = [
          HarytHomeTab(onNavigateToCategories: (brand) {
            setState(() {
              _selectedBrand = brand;
              _currentIndex = 1;
            });
          }),
          AllProductsPage(
            apiBaseUrl: Config.apiBaseUrl,
            isEmbedded: true,
            initialBrand: _selectedBrand,
          ),
          CartTab(onContinueShopping: () => setState(() {
            _selectedBrand = null;
            _currentIndex = 1;
          })),
          const ProfilePage(),
        ];

        return Scaffold(
          backgroundColor: bgColor,
          body: SafeArea(
            child: Column(
              children: [
                // Only show main headers for Home tab to keep embedded subpages clean
                if (_currentIndex == 0) ...[
                  const TopBar(),
                  AppHeader(),
                ],
                Expanded(
                  child: IndexedStack(
                    index: _currentIndex,
                    children: children,
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: navBgColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) => setState(() {
                _currentIndex = index;
                _selectedBrand = null;
              }),
              type: BottomNavigationBarType.fixed,
              backgroundColor: navBgColor,
              selectedItemColor: const Color(0xFFDC2626), // brand color
              unselectedItemColor: isDark ? Colors.grey[500] : const Color(0xFF9CA3AF),
              showSelectedLabels: true,
              showUnselectedLabels: true,
              selectedFontSize: 12,
              unselectedFontSize: 12,
              elevation: 0,
              items: [
                BottomNavigationBarItem(
                  icon: const Icon(Icons.home_outlined),
                  activeIcon: const Icon(Icons.home_rounded),
                  label: settings.translate('home_tab'),
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.grid_view_outlined),
                  activeIcon: const Icon(Icons.grid_view_rounded),
                  label: settings.translate('categories_tab'),
                ),
                BottomNavigationBarItem(
                  icon: Badge(
                    label: Text(
                      '$cartCount',
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                    isLabelVisible: cartCount > 0,
                    backgroundColor: const Color(0xFFDC2626),
                    child: const Icon(Icons.shopping_cart_outlined),
                  ),
                  activeIcon: Badge(
                    label: Text(
                      '$cartCount',
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                    isLabelVisible: cartCount > 0,
                    backgroundColor: const Color(0xFFDC2626),
                    child: const Icon(Icons.shopping_cart_rounded),
                  ),
                  label: settings.translate('cart_tab'),
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.person_outline),
                  activeIcon: const Icon(Icons.person_rounded),
                  label: settings.translate('profile_tab'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
