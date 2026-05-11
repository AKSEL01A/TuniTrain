import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tuni_train/controller/home_controlle.dart';
import 'package:tuni_train/models/nav_item.dart';
import 'package:tuni_train/screen/page/accueil_screen.dart';

class HomePageClient extends StatelessWidget {
  const HomePageClient({super.key});

  static const _blue = Color(0xFF1B4F8A);
  static const _mid = Color(0xFF2E6DB4);
  static const _light = Color(0xFF7AB8D9);
  static const _sand = Color(0xFFC8A96E);

  static const List<NavItem> _navItems = [
    NavItem(Icons.home_rounded, 'Accueil'),
    NavItem(Icons.local_offer_sharp, 'Services'),
    NavItem(Icons.confirmation_num_rounded, 'Achats'),
    NavItem(Icons.train_rounded, 'Statut'),
    NavItem(Icons.notifications_rounded, 'Alertes'),
  ];

  // الأفضل: getter بدل static final
  List<Widget> get _pages => const [AccueilPageScreen()];

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.find<HomeController>();
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FA),

      // فقط index يتراقب
      body: Obx(() {
        return _pages[controller.currentIndex.value];
      }),

      bottomNavigationBar: Obx(() {
        return Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          height: 70,
          decoration: BoxDecoration(
            color: _blue,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: _blue.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),

          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_navItems.length, (index) {
              final item = _navItems[index];
              final isSelected = controller.currentIndex.value == index;

              return _buildNavItem(
                item: item,
                isSelected: isSelected,
                hasNotif: index == 4,
                onTap: () => controller.changePage(index),
              );
            }),
          ),
        );
      }),
    );
  }

  Widget _buildNavItem({
    required NavItem item,
    required bool isSelected,
    required VoidCallback onTap,
    bool hasNotif = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 14 : 10,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isSelected ? _mid : Colors.transparent,
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
                    color: isSelected ? Colors.white : _light,
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
                        color: _sand,
                        shape: BoxShape.circle,
                        border: Border.all(color: _blue, width: 1.5),
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
                color: isSelected ? Colors.white : _light,
              ),
              child: Text(item.label),
            ),
          ],
        ),
      ),
    );
  }
}
