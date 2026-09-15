import 'package:flutter/material.dart';

class VibeTokens {
  // Brand Purple (Section 17.2)
  static const Color brandPurple900 = Color(0xFF3B0764);
  static const Color brandPurple800 = Color(0xFF4C1D95); // Primary brand
  static const Color brandPurple700 = Color(0xFF5B21B6); // Hover / pressed
  static const Color brandPurple600 = Color(0xFF6D28D9); // Secondary CTA
  static const Color brandPurple500 = Color(0xFF7C3AED); // Active chips
  static const Color brandPurple400 = Color(0xFF8B5CF6);
  static const Color brandPurple300 = Color(0xFFA78BFA);
  static const Color brandPurple200 = Color(0xFFC4B5FD);
  static const Color brandPurple100 = Color(0xFFDDD6FE); // Hero light surface
  static const Color brandPurple050 = Color(0xFFEDE9FE);

  // Neutrals
  static const Color neutral000 = Color(0xFFFFFFFF);
  static const Color neutral050 = Color(0xFFFAFAFB);
  static const Color neutral100 = Color(0xFFF3F4F6);
  static const Color neutral200 = Color(0xFFE5E7EB);
  static const Color neutral300 = Color(0xFFD1D5DB);
  static const Color neutral400 = Color(0xFF9CA3AF);
  static const Color neutral500 = Color(0xFF6B7280);
  static const Color neutral600 = Color(0xFF4B5563);
  static const Color neutral700 = Color(0xFF374151);
  static const Color neutral800 = Color(0xFF1F2937);
  static const Color neutral900 = Color(0xFF111827);

  // Semantic
  static const Color semanticSuccess = Color(0xFF15803D);
  static const Color semanticWarning = Color(0xFFB45309);
  static const Color semanticDanger = Color(0xFFB91C1C);
  static const Color semanticInfo = Color(0xFF1D4ED8);

  // Dark Theme
  static const Color darkBgApp = Color(0xFF0B0B12);
  static const Color darkBgSurface = Color(0xFF15151F);
  static const Color darkBgSurfaceAlt = Color(0xFF1C1C28);
  static const Color darkTextPrimary = Color(0xFFF5F5F7);
  static const Color darkTextSecondary = Color(0xFFC7C7D1);
  static const Color darkBorder = Color(0xFF2A2A36);

  // Spacing (Section 17.4)
  static const double space0 = 0.0;
  static const double space1 = 4.0;
  static const double space2 = 8.0;
  static const double space3 = 12.0;
  static const double space4 = 16.0;
  static const double space5 = 20.0;
  static const double space6 = 24.0;
  static const double space8 = 32.0;
  static const double space10 = 40.0;
  static const double space12 = 48.0;
  static const double space16 = 64.0;
  static const double space24 = 96.0;

  // Radius (Section 17.5)
  static const double radiusXs = 4.0;
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 24.0;
  static const double radiusFull = 9999.0;

  // Motion (Section 17.7)
  static const Duration motionFast = Duration(milliseconds: 120);
  static const Duration motionBase = Duration(milliseconds: 220);
  static const Duration motionSlow = Duration(milliseconds: 320);

  // Typography Styles (Section 17.3)
  static const TextStyle displayLg = TextStyle(
    fontFamily: 'Inter',
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 40 / 32,
    letterSpacing: -0.5,
  );

  static const TextStyle displaySm = TextStyle(
    fontFamily: 'Inter',
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 32 / 24,
    letterSpacing: -0.4,
  );

  static const TextStyle titleLg = TextStyle(
    fontFamily: 'Inter',
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 28 / 20,
    letterSpacing: -0.2,
  );

  static const TextStyle titleMd = TextStyle(
    fontFamily: 'Inter',
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 26 / 18,
  );

  static const TextStyle bodyLg = TextStyle(
    fontFamily: 'Inter',
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 24 / 16,
  );

  static const TextStyle bodyMd = TextStyle(
    fontFamily: 'Inter',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 22 / 14,
  );

  static const TextStyle bodySm = TextStyle(
    fontFamily: 'Inter',
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 20 / 13,
  );

  static const TextStyle labelLg = TextStyle(
    fontFamily: 'Inter',
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 20 / 14,
    letterSpacing: 0.1,
  );

  static const TextStyle labelSm = TextStyle(
    fontFamily: 'Inter',
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 16 / 12,
    letterSpacing: 0.2,
  );
}
