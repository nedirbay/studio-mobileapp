import 'package:flutter/material.dart';
import 'all_products/all_products_page.dart';
import 'widgets/haryt_home_tab.dart';
import 'widgets/cart_tab.dart';
import '../identity/profile_page.dart';
import '../widgets/top_bar.dart';
import '../widgets/app_header.dart';
import '../config.dart';

class HarytlarMainPage extends StatefulWidget {
  final int initialTab;

  const HarytlarMainPage({super.key, this.initialTab = 0});

  @override
  State<HarytlarMainPage> createState() => _HarytlarMainPageState();
}

class _HarytlarMainPageState extends State<HarytlarMainPage> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTab;
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> children = [
      HarytHomeTab(onNavigateToCategories: () => setState(() => _currentIndex = 1)),
      AllProductsPage(apiBaseUrl: Config.apiBaseUrl, isEmbedded: true),
      CartTab(onContinueShopping: () => setState(() => _currentIndex = 0)),
      const ProfilePage(),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
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
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFFDC2626), // brand color
          unselectedItemColor: const Color(0xFF9CA3AF),
          showSelectedLabels: true,
          showUnselectedLabels: true,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home_rounded), label: 'Baş sahypa'),
            BottomNavigationBarItem(icon: Icon(Icons.grid_view_outlined), activeIcon: Icon(Icons.grid_view_rounded), label: 'Kategoriýalar'),
            BottomNavigationBarItem(icon: Icon(Icons.shopping_cart_outlined), activeIcon: Icon(Icons.shopping_cart_rounded), label: 'Sebet'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person_rounded), label: 'Profil'),
          ],
        ),
      ),
    );
  }
}
