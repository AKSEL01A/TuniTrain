import 'package:flutter/material.dart';
import 'package:get/get.dart';
//import 'package:google_fonts/google_fonts.dart';
import 'package:tuni_train/screen/page/accueil_screen.dart';

// ─── Home Controller ──────────────────────────────────────────────
class HomeController extends GetxController {
  final currentIndex = 0.obs;
  void changePage(int index) => currentIndex.value = index;
}

// ─── Nav Item Model ───────────────────────────────────────────────
class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem(this.icon, this.label);
}

// ─── Home Page Client ─────────────────────────────────────────────
class HomePageClient extends StatelessWidget {
  const HomePageClient({super.key});

  static const _sidiBouSaidBlue = Color(0xFF1B4F8A);
  static const _sidiBouSaidMid = Color(0xFF2E6DB4);
  static const _sidiBouSaidLight = Color(0xFF7AB8D9);
  static const _sidiBouSaidSand = Color(0xFFC8A96E);

  static const List<_NavItem> _navItems = [
    _NavItem(Icons.home_rounded, 'Accueil'),
    _NavItem(Icons.local_offer_sharp, 'Services'),
    _NavItem(Icons.confirmation_num_rounded, 'Achats'),
    _NavItem(Icons.train_rounded, 'Statut'),
    _NavItem(Icons.notifications_rounded, 'Alertes'),
  ];

  // ← AccueilPage() replaces the old HomePage() placeholder
  static final List<Widget> _pages = [
    const AccueilPageScreen(), // ← changed
    //const MonJourneePage(),
    //const PurchasePage(),
    //const TrainStatusPage(),
    //const NotificationPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.put(HomeController());

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FA),
      body: Obx(() => _pages[controller.currentIndex.value]),
      bottomNavigationBar: Obx(
        () => Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          height: 70,
          decoration: BoxDecoration(
            color: _sidiBouSaidBlue,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: _sidiBouSaidBlue.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              _navItems.length,
              (index) => _buildNavItem(
                index: index,
                item: _navItems[index],
                isSelected: controller.currentIndex.value == index,
                hasNotif: index == 4,
                onTap: () => controller.changePage(index),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required _NavItem item,
    required bool isSelected,
    required VoidCallback onTap,
    bool hasNotif = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 14 : 10,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isSelected ? _sidiBouSaidMid : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                AnimatedScale(
                  scale: isSelected ? 1.15 : 1.0,
                  duration: const Duration(milliseconds: 250),
                  child: Icon(
                    item.icon,
                    size: 22,
                    color: isSelected ? Colors.white : _sidiBouSaidLight,
                  ),
                ),
                if (hasNotif)
                  Positioned(
                    top: -3,
                    right: -3,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _sidiBouSaidSand,
                        shape: BoxShape.circle,
                        border: Border.all(color: _sidiBouSaidBlue, width: 1.5),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 3),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 250),
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? Colors.white : _sidiBouSaidLight,
              ),
              child: Text(item.label),
            ),
          ],
        ),
      ),
    );
  }
}
