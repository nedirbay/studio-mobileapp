import 'package:flutter/material.dart';
import '../harytlar_main_page.dart';
import '../../services/settings_service.dart';
import '../../services/cart_service.dart';

class CommerceBottomNav extends StatelessWidget {
  final int currentIndex;

  const CommerceBottomNav({super.key, this.currentIndex = 0});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([SettingsService(), CartService()]),
      builder: (context, _) {
        final settings = SettingsService();
        final cart = CartService();
        final isDark = settings.isDarkMode;
        final navBgColor = isDark ? const Color(0xFF1F2937) : Colors.white;
        final cartCount = cart.count;

        return Container(
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
            currentIndex: currentIndex,
            onTap: (index) {
              if (index == currentIndex) return;

              // Pop to selection page (first route) and push HarytlarMainPage with targeted index
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => HarytlarMainPage(initialTab: index),
                ),
                (route) => route.isFirst,
              );
            },
            type: BottomNavigationBarType.fixed,
            backgroundColor: navBgColor,
            selectedItemColor: const Color(0xFFDC2626), // brand color
            unselectedItemColor: isDark ? Colors.grey[400] : const Color(0xFF9CA3AF),
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
        );
      },
    );
  }
}
