import 'package:flutter/material.dart';

import '../../core/ navigation/navigation.dart';
import '../../core/navigation_bar/navigation_bar.dart';
import '../../core/navigation_bar/navigation_bar_Admin.dart';
import '../../core/network/local/cache_helper.dart';
import '../../core/styles/themes.dart';
import '../../core/widgets/constant.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    Future.delayed(const Duration(seconds: 1), () {
      Widget? widget;
      if (CacheHelper.getData(key: 'token') == null) {
        token = '';
        widget = BottomNavBar();
      } else {
        if (CacheHelper.getData(key: 'role') == null) {
          widget = BottomNavBar();
          adminOrUser = 'user';
        } else {
          adminOrUser = CacheHelper.getData(key: 'role');
          if (adminOrUser == 'admin') {
            widget = BottomNavBarAdmin();
          } else {
            widget = BottomNavBar();
          }
        }
        token = CacheHelper.getData(key: 'token');
        id = CacheHelper.getData(key: 'id') ?? '';
      }

      navigateAndFinish(context, widget);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: appPageColor(context),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: SizedBox(
                width: double.maxFinite,
                height: double.maxFinite,
                child: Center(
                  child: Image.asset('assets/images/$logo', width: 150),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
