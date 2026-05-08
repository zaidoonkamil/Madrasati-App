import 'package:flutter/material.dart';

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

class ThemeService {
  final lightTheme = ThemeData(
    scaffoldBackgroundColor: appBackgroundColor,
    primaryColor: primaryColor,
    fontFamily: 'tajawal',
    brightness: Brightness.light,
    appBarTheme: const AppBarTheme(
      backgroundColor: appHeaderColor,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
    ),
    cardTheme: const CardTheme(
      color: appSurfaceColor,
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
    tabBarTheme: const TabBarTheme(
      labelColor: Colors.black87,
      dividerColor: primaryColor,
    ),
    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      secondary: accentColor,
      surface: appSurfaceColor,
      error: appDangerColor,
    ),
  );
}
