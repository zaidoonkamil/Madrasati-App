import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';

import '../../features/user/view/Home.dart';
import '../../features/user/view/all_categories.dart';
import '../../features/user/view/orders.dart';
import '../../features/user/view/profile.dart';
import '../styles/themes.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _selectedIndex = 3;

  final List<Widget> _widgetOptions = const [
    Profile(),
    Orders(),
    AllCategoriesPage(useHomeAppBar: true),
    Home(),
  ];

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: bottomNavigationSafeColor,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: bottomNavigationSafeColor,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        body: Stack(
          children: [
            Positioned.fill(child: _widgetOptions[_selectedIndex]),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: MediaQuery.paddingOf(context).top,
              child: const ColoredBox(color: bottomNavigationSafeColor),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                color: bottomNavigationSafeColor,
                child: SafeArea(
                  top: false,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: const Color(
                            0xFF111228,
                          ).withValues(alpha: 0.24),
                          blurRadius: 26,
                          spreadRadius: -4,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Container(
                      height: 74,
                      color: bottomNavigationSafeColor,
                      child: Row(
                        children: [
                          _NavItem(
                            label: 'حسابي',
                            icon: Iconsax.user,
                            selected: _selectedIndex == 0,
                            onTap: () => setState(() => _selectedIndex = 0),
                          ),
                          _NavItem(
                            label: 'طلباتي',
                            icon: Iconsax.box,
                            selected: _selectedIndex == 1,
                            onTap: () => setState(() => _selectedIndex = 1),
                          ),
                          _NavItem(
                            label: 'الأقسام',
                            icon: Iconsax.category,
                            selected: _selectedIndex == 2,
                            onTap: () => setState(() => _selectedIndex = 2),
                          ),
                          _NavItem(
                            label: 'الرئيسية',
                            icon: Iconsax.home_1,
                            selected: _selectedIndex == 3,
                            onTap: () => setState(() => _selectedIndex = 3),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color =
        selected ? secondPrimaryColor : Colors.white.withValues(alpha: 0.46);

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
          height: 66,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedScale(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                scale: selected ? 1.08 : 1,
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(height: 5),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                style: TextStyle(
                  color: color,
                  fontSize: 10.5,
                  fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
                ),
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 5),
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                width: selected ? 4 : 0,
                height: selected ? 4 : 0,
                decoration: const BoxDecoration(
                  color: secondPrimaryColor,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
