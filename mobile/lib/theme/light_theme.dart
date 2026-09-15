import 'package:flutter/material.dart';
import 'tokens.dart';

final ThemeData vibeLightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  primaryColor: VibeTokens.brandPurple800,
  scaffoldBackgroundColor: VibeTokens.neutral000,
  colorScheme: const ColorScheme.light(
    primary: VibeTokens.brandPurple800,
    secondary: VibeTokens.brandPurple600,
    surface: VibeTokens.neutral050,
    background: VibeTokens.neutral000,
    error: VibeTokens.semanticDanger,
  ),
  cardTheme: CardTheme(
    color: VibeTokens.neutral050,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(VibeTokens.radiusLg),
      side: const BorderSide(color: VibeTokens.neutral200, width: 1),
    ),
    elevation: 0,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: VibeTokens.neutral000,
    elevation: 0,
    scrolledUnderElevation: 0,
    iconTheme: IconThemeData(color: VibeTokens.neutral900),
    titleTextStyle: TextStyle(
      fontFamily: 'Inter',
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: VibeTokens.neutral900,
    ),
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: VibeTokens.neutral000,
    selectedItemColor: VibeTokens.brandPurple700,
    unselectedItemColor: VibeTokens.neutral500,
    type: BottomNavigationBarType.fixed,
    elevation: 0,
  ),
);

final ThemeData vibeDarkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  primaryColor: VibeTokens.darkBrandPurple500,
  scaffoldBackgroundColor: VibeTokens.darkBgApp,
  colorScheme: const ColorScheme.dark(
    primary: VibeTokens.darkBrandPurple500,
    secondary: VibeTokens.brandPurple300,
    surface: VibeTokens.darkBgSurface,
    background: VibeTokens.darkBgApp,
    error: VibeTokens.semanticDanger,
  ),
);

extension VibeThemeExtension on VibeTokens {
  static const Color darkBrandPurple500 = Color(0xFFA78BFA);
}
