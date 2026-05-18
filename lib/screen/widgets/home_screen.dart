import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tuni_train/controller/home_controlle.dart';
import 'package:tuni_train/models/nav_item.dart';
import 'package:tuni_train/screen/page/accueil/accueil_page.dart';
import 'package:tuni_train/screen/page/purchase/achats_page.dart';
import 'package:tuni_train/screen/page/mon_journee/mon_jourene_page.dart';
import 'package:tuni_train/screen/page/map/stations_map_page.dart';
import 'package:tuni_train/screen/page/trains/train_status_page.dart';

class HomePageClient extends StatelessWidget {
  const HomePageClient({super.key});

  static const _blue = Color(0xFF1B4F8A);
  static const _mid = Color(0xFF2E6DB4);
  static const _light = Color(0xFF7AB8D9);

  static const List<NavItem> _navItems = [
    NavItem(Icons.home_rounded, 'Accueil'),
    NavItem(Icons.confirmation_number_rounded, 'Mes Billets'),
    NavItem(Icons.search_rounded, 'Achats'),
    NavItem(Icons.train_rounded, 'Statut'),
    NavItem(Icons.map_rounded, 'Stations'),
  ];

  // الأفضل: getter بدل static final
  List<Widget> get _pages => [
    const AccueilPageScreen(),
    MyJourneyPage(),
    const AchatsPage(), // Achats
    const TrainStatusPage(), // Statut
    const StationsMapPage(), // Stations
  ];
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
