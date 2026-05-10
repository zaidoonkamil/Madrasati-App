import 'package:flutter/material.dart';

import '../network/local/cache_helper.dart';

const Color primaryColor = Color(0xFF154C9A);
const Color secondPrimaryColor = Color(0xFFF9B51E);
const Color accentColor = secondPrimaryColor;
const Color primaryDarkColor = Color(0xFF0E3B78);

const Color pageBackgroundColor = Color(0xFFFDF8F2);
const Color cardSurfaceColor = Colors.white;
const Color mutedSurfaceColor = Color(0xFFF0EBE3);
const Color secondTextColor = Color(0xFF7B7080);
const Color borderColor = Color(0xFFF0EBE3);
const Color containerColor = Color(0xFFF3F5F7);
const Color successColor = Color(0xFF3DAA6E);
const Color dangerColor = Color(0xFFE05C6A);

const Color appBackgroundColor = pageBackgroundColor;
const Color appSurfaceColor = cardSurfaceColor;
const Color appMutedSurfaceColor = mutedSurfaceColor;
const Color appBorderColor = borderColor;
const Color appTextPrimaryColor = Color(0xFF1B1B32);
const Color appTextSecondaryColor = Color(0xFF2D2D44);
const Color appTextMutedColor = secondTextColor;
const Color appAccentColor = secondPrimaryColor;
const Color appAccentLightColor = Color(0xFFFFC84A);
const Color appSuccessColor = successColor;
const Color appDangerColor = dangerColor;
const Color appHeaderColor = appTextPrimaryColor;
const Color appHeaderMutedColor = appTextSecondaryColor;
const Color appOverlayMidColor = Color(0x441A1A2E);
const Color appOverlayEndColor = Color(0xDD1A1A2E);
const Color appSoftShadowColor = Color(0x0A1A1A2E);
const Color appWarmSurfaceColor = Color(0xFFF8E7E4);
const Color appRustColor = Color(0xFFBE3D2A);
const Color appOrangeColor = Color(0xFFD98F39);
const Color appDarkGradientStartColor = appTextPrimaryColor;
const Color appDarkGradientEndColor = appTextSecondaryColor;
const Color appAdminBackgroundColor = appBackgroundColor;
const Color appAdminSurfaceColor = appSurfaceColor;
const Color appAdminHeaderColor = appHeaderColor;
const Color appAdminAccentColor = appAccentColor;

const Color homeBackgroundColor = pageBackgroundColor;
const Color homeHeaderColor = primaryColor;
const Color homeHeaderTextColor = Colors.white;
const Color homeTextColor = appTextPrimaryColor;
const Color homeTextMutedColor = appTextSecondaryColor;
const Color homeAccentColor = secondPrimaryColor;
const Color homeAccentLightColor = appAccentLightColor;
const Color homeCardColor = cardSurfaceColor;
const Color homeBorderColor = mutedSurfaceColor;
const Color homeHeroOverlayMidColor = appOverlayMidColor;
const Color homeHeroOverlayEndColor = appOverlayEndColor;
const Color bottomNavigationSafeColor = Color(0xFF17172B);
const Color darkBackgroundColor = Color(0xFF10111F);
const Color darkSurfaceColor = Color(0xFF18192B);
const Color darkMutedSurfaceColor = Color(0xFF22243A);
const Color darkBorderColor = Color(0xFF2F3150);
const Color darkTextPrimaryColor = Color(0xFFF8F8FC);
const Color darkTextSecondaryColor = Color(0xFFD8D9E8);
const Color darkTextMutedColor = Color(0xFF9A9DB7);

const String themeModeCacheKey = 'theme_mode';

class AppThemeController extends ChangeNotifier {
  AppThemeController._();

  static final AppThemeController instance = AppThemeController._();

  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;
  bool get isDark => _themeMode == ThemeMode.dark;

  void init() {
    final mode = CacheHelper.getData(key: themeModeCacheKey);
    _themeMode = mode == 'dark' ? ThemeMode.dark : ThemeMode.light;
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    _themeMode = mode;
    notifyListeners();
    await CacheHelper.saveData(
      key: themeModeCacheKey,
      value: mode == ThemeMode.dark ? 'dark' : 'light',
    );
  }

  Future<void> toggleTheme() {
    return setThemeMode(isDark ? ThemeMode.light : ThemeMode.dark);
  }
}

class ThemeService {
  ThemeData get lightTheme => _theme(
    brightness: Brightness.light,
    background: appBackgroundColor,
    surface: appSurfaceColor,
    mutedSurface: appMutedSurfaceColor,
    border: appBorderColor,
    textPrimary: appTextPrimaryColor,
    textSecondary: appTextSecondaryColor,
    textMuted: appTextMutedColor,
  );

  ThemeData get darkTheme => _theme(
    brightness: Brightness.dark,
    background: darkBackgroundColor,
    surface: darkSurfaceColor,
    mutedSurface: darkMutedSurfaceColor,
    border: darkBorderColor,
    textPrimary: darkTextPrimaryColor,
    textSecondary: darkTextSecondaryColor,
    textMuted: darkTextMutedColor,
  );

  ThemeData _theme({
    required Brightness brightness,
    required Color background,
    required Color surface,
    required Color mutedSurface,
    required Color border,
    required Color textPrimary,
    required Color textSecondary,
    required Color textMuted,
  }) {
    final isDark = brightness == Brightness.dark;

    return ThemeData(
      scaffoldBackgroundColor: background,
      primaryColor: primaryColor,
      fontFamily: 'tajawal',
      brightness: brightness,
      appBarTheme: const AppBarTheme(
        backgroundColor: appHeaderColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardTheme(
        color: surface,
        surfaceTintColor: Colors.transparent,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        selectedItemColor: primaryColor,
        unselectedItemColor: appTextMutedColor,
        backgroundColor: bottomNavigationSafeColor,
        showUnselectedLabels: false,
      ),
      buttonTheme: const ButtonThemeData(
        colorScheme: ColorScheme.dark(),
        buttonColor: Colors.black87,
      ),
      tabBarTheme: TabBarTheme(
        labelColor: textPrimary,
        dividerColor: primaryColor,
      ),
      dividerColor: border,
      canvasColor: background,
      dialogTheme: DialogThemeData(backgroundColor: surface),
      textTheme: TextTheme(
        bodyLarge: TextStyle(color: textPrimary),
        bodyMedium: TextStyle(color: textSecondary),
        bodySmall: TextStyle(color: textMuted),
        titleLarge: TextStyle(color: textPrimary),
        titleMedium: TextStyle(color: textPrimary),
        titleSmall: TextStyle(color: textSecondary),
        labelLarge: TextStyle(color: textPrimary),
        labelMedium: TextStyle(color: textSecondary),
        labelSmall: TextStyle(color: textMuted),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: mutedSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: secondPrimaryColor, width: 1.4),
        ),
        labelStyle: TextStyle(color: textMuted),
        hintStyle: TextStyle(color: textMuted),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: secondPrimaryColor,
          foregroundColor: appTextPrimaryColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      colorScheme: (isDark
              ? const ColorScheme.dark(
                primary: primaryColor,
                secondary: accentColor,
                surface: darkSurfaceColor,
                error: appDangerColor,
              )
              : const ColorScheme.light(
                primary: primaryColor,
                secondary: accentColor,
                surface: appSurfaceColor,
                error: appDangerColor,
              ))
          .copyWith(
            brightness: brightness,
            surface: surface,
            onSurface: textPrimary,
          ),
    );
  }
}

Color appPageColor(BuildContext context) =>
    Theme.of(context).scaffoldBackgroundColor;
Color appSurface(BuildContext context) =>
    Theme.of(context).cardTheme.color ?? appSurfaceColor;
Color appMutedSurface(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
        ? darkMutedSurfaceColor
        : appMutedSurfaceColor;
Color appBorder(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
        ? darkBorderColor
        : appBorderColor;
Color appTextPrimary(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
        ? darkTextPrimaryColor
        : appTextPrimaryColor;
Color appTextSecondary(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
        ? darkTextSecondaryColor
        : appTextSecondaryColor;
Color appTextMuted(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
        ? darkTextMutedColor
        : appTextMutedColor;
Color appHeaderBackground(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
        ? bottomNavigationSafeColor
        : homeTextColor;
