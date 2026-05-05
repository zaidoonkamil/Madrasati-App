import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../features/user/view/basket.dart';
import '../../features/user/view/notifications.dart';
import '../ navigation/navigation.dart';
import '../network/remote/dio_helper.dart';
import '../styles/themes.dart';
import 'constant.dart';
import 'show_toast.dart';

class CustomAppBar extends StatelessWidget {
  const CustomAppBar({
    super.key,
    this.title = 'مدرستي',
    this.subtitle = 'كل ما تحتاجه في مكان واحد',
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        MediaQuery.paddingOf(context).top + 12,
        16,
        16,
      ),
      decoration: const BoxDecoration(color: homeTextColor),
      child: Row(
        children: [
          // Cart / Basket icon
          _BasketIconButton(
            onTap: () {
              if (token.isEmpty || id.isEmpty) {
                showToastInfo(text: 'سجل الدخول أولاً', context: context);
                return;
              }

              navigateTo(context, const Basket());
            },
          ),
          const SizedBox(width: 10),
          // Notification icon
          _AppBarIconButton(
            icon: Iconsax.notification,
            badgeCount: 0,
            onTap: () => navigateTo(context, const NotificationsUser()),
          ),

          // Spacer
          const Spacer(),

          // Brand name + tagline
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Cairo',
                    ),
                  ),
                  const SizedBox(width: 5),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: homeAccentColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 10,
                  fontFamily: 'Cairo',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class CustomAppBarBack extends StatelessWidget {
  const CustomAppBarBack({
    super.key,
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        MediaQuery.paddingOf(context).top + 12,
        16,
        14,
      ),
      decoration: const BoxDecoration(color: homeTextColor),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => navigateBack(context),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(13),
                border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
              ),
              child: Icon(
                Iconsax.arrow_left,
                color: Colors.white.withValues(alpha: 0.75),
                size: 20,
              ),
            ),
          ),

          const Spacer(),

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Cairo',
                    ),
                  ),
                  const SizedBox(width: 5),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: homeAccentColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.45),
                  fontSize: 10,
                  fontFamily: 'Cairo',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class CustomAppBarAdmin extends StatelessWidget {
  const CustomAppBarAdmin({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.maxFinite,
      padding: EdgeInsets.fromLTRB(
        16,
        MediaQuery.paddingOf(context).top + 12,
        16,
        16,
      ),
      decoration: const BoxDecoration(color: appAdminHeaderColor),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(13),
              border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
            ),
            child: const Icon(
              Iconsax.setting_2,
              color: appAdminAccentColor,
              size: 20,
            ),
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  const Text(
                    'لوحة التحكم',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Cairo',
                    ),
                  ),
                  const SizedBox(width: 5),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: appAdminAccentColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
              Text(
                'إدارة المنتجات والطلبات والمستخدمين',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.50),
                  fontSize: 10,
                  fontFamily: 'Cairo',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AppBarIconButton extends StatelessWidget {
  final IconData icon;
  final int badgeCount;
  final VoidCallback onTap;

  const _AppBarIconButton({
    required this.icon,
    required this.badgeCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(13),
              border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
            ),
            child: Icon(
              icon,
              color: Colors.white.withValues(alpha: 0.85),
              size: 20,
            ),
          ),
          if (badgeCount > 0)
            Positioned(
              top: -4,
              right: -4,
              child: Container(
                width: 18,
                height: 18,
                decoration: const BoxDecoration(
                  color: homeAccentColor,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$badgeCount',
                    style: const TextStyle(
                      color: homeTextColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _BasketIconButton extends StatefulWidget {
  const _BasketIconButton({required this.onTap});

  final VoidCallback onTap;

  @override
  State<_BasketIconButton> createState() => _BasketIconButtonState();
}

class _BasketIconButtonState extends State<_BasketIconButton> {
  late final Future<int> _basketCountFuture;

  @override
  void initState() {
    super.initState();
    _basketCountFuture = _getBasketCount();
  }

  Future<int> _getBasketCount() async {
    if (id.isEmpty) {
      return 0;
    }

    final response = await DioHelper.getData(url: '/basket/$id');
    final data = response.data;
    if (data is List) {
      return data.length;
    }

    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<int>(
      future: _basketCountFuture,
      builder: (context, snapshot) {
        return _AppBarIconButton(
          icon: Iconsax.shopping_bag,
          badgeCount: snapshot.data ?? 0,
          onTap: widget.onTap,
        );
      },
    );
  }
}
