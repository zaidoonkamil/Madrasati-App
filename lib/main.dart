import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

import 'bloc_observer.dart';
import 'core/network/local/cache_helper.dart';
import 'core/network/remote/dio_helper.dart';
import 'core/styles/themes.dart';
import 'features/splash/splash.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: bottomNavigationSafeColor,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: bottomNavigationSafeColor,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  Bloc.observer = MyBlocObserver();
  await CacheHelper.init();
  AppThemeController.instance.init();
  DioHelper.init();
  OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
  OneSignal.Debug.setAlertLevel(OSLogLevel.none);
  OneSignal.initialize("e014afb9-90e5-4c29-9bf3-b0dfbfc118e7");
  OneSignal.Notifications.requestPermission(true);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeService = ThemeService();

    return AnimatedBuilder(
      animation: AppThemeController.instance,
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: themeService.lightTheme,
          darkTheme: themeService.darkTheme,
          themeMode: AppThemeController.instance.themeMode,
          locale: const Locale('ar'),
          builder: (context, child) {
            return AnnotatedRegion<SystemUiOverlayStyle>(
              value: const SystemUiOverlayStyle(
                statusBarColor: bottomNavigationSafeColor,
                statusBarIconBrightness: Brightness.light,
                statusBarBrightness: Brightness.dark,
                systemNavigationBarColor: bottomNavigationSafeColor,
                systemNavigationBarIconBrightness: Brightness.light,
              ),
              child: ColoredBox(
                color: bottomNavigationSafeColor,
                child: Directionality(
                  textDirection: TextDirection.ltr,
                  child: child ?? const SizedBox.shrink(),
                ),
              ),
            );
          },
          title: 'مدرستي',
          home: SplashScreen(),
        );
      },
    );
  }
}
