import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter/services.dart';

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
                    child: ClipRRect(
                      child: Container(
                        height: 68,
                        decoration: BoxDecoration(
                          color: bottomNavigationSafeColor,
                          // border: Border.all(
                          //   color: primaryColor.withValues(alpha: 0.2),
                          //   width: 1.2,
                          // ),
                        ),
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
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
          height: 58,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          child: Stack(
            alignment: Alignment.center,
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOutCubic,
                bottom: selected ? 5 : 0,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  width: selected ? 4 : 0,
                  height: selected ? 4 : 0,
                  decoration: const BoxDecoration(
                    color: secondPrimaryColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              AnimatedPositioned(
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOutCubic,
                top: selected ? 13 : 17,
                child: Tooltip(
                  message: label,
                  child: AnimatedScale(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutCubic,
                    scale: selected ? 1.08 : 1,
                    child: Icon(
                      icon,
                      color:
                          selected
                              ? secondPrimaryColor
                              : Colors.white.withValues(alpha: 0.36),
                      size: 22,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
