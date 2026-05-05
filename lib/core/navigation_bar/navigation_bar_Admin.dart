import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';

import '../../features/admin/view/HomeAdmin.dart';
import '../../features/admin/view/OrdersAdmin.dart';
import '../../features/admin/view/details/details.dart';
import '../../features/user/view/profile.dart';
import '../styles/themes.dart';

class BottomNavBarAdmin extends StatefulWidget {
  const BottomNavBarAdmin({super.key});

  @override
  State<BottomNavBarAdmin> createState() => _BottomNavBarAdminState();
}

class _BottomNavBarAdminState extends State<BottomNavBarAdmin> {
  int _selectedIndex = 3;

  final List<Widget> _widgetOptions = const [
    Profile(),
    Details(),
    OrdersAdmin(),
    HomeAdmin(),
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
                  child: SizedBox(
                    height: 68,
                    child: Row(
                      children: [
                        _AdminNavItem(
                          label: 'حسابي',
                          icon: Iconsax.user_octagon,
                          selected: _selectedIndex == 0,
                          onTap: () => setState(() => _selectedIndex = 0),
                        ),
                        _AdminNavItem(
                          label: 'الإعدادات',
                          icon: Iconsax.setting,
                          selected: _selectedIndex == 1,
                          onTap: () => setState(() => _selectedIndex = 1),
                        ),
                        _AdminNavItem(
                          label: 'الطلبات',
                          icon: Iconsax.box,
                          selected: _selectedIndex == 2,
                          onTap: () => setState(() => _selectedIndex = 2),
                        ),
                        _AdminNavItem(
                          label: 'الرئيسية',
                          icon: Iconsax.home,
                          selected: _selectedIndex == 3,
                          onTap: () => setState(() => _selectedIndex = 3),
                        ),
                      ],
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

class _AdminNavItem extends StatelessWidget {
  const _AdminNavItem({
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
                    color: appAdminAccentColor,
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
                              ? appAdminAccentColor
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
