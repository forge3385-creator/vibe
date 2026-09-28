import 'package:flutter/material.dart';

class VibeTokens {
  // Brand Colors
  static const Color brandPurple900 = Color(0xFF2E1065);
  static const Color brandPurple800 = Color(0xFF4C1D95); // Primary brand
  static const Color brandPurple700 = Color(0xFF5B21B6);
  static const Color brandPurple600 = Color(0xFF6D28D9);
  static const Color brandPurple500 = Color(0xFF7C3AED); // Active accents
  static const Color brandPurple400 = Color(0xFF8B5CF6);
  static const Color brandPurple300 = Color(0xFFA78BFA);
  static const Color brandPurple200 = Color(0xFFC4B5FD);
  static const Color brandPurple100 = Color(0xFFDDD6FE);
  static const Color brandPurple050 = Color(0xFFF3E8FF);

  // Futuristic Cosmic Dark Palette
  static const Color darkBgCosmic = Color(0xFF07070D);
  static const Color darkBgSurface = Color(0xFF0E0E1A);
  static const Color darkBgSurfaceAlt = Color(0xFF161626);
  static const Color darkBgElevated = Color(0xFF1E1E34);

  // Glassmorphism System Colors
  static const Color glassFillUltraSubtle = Color(0x0AFFFFFF); // 4% white
  static const Color glassFillSubtle = Color(0x12FFFFFF);      // 7% white
  static const Color glassFillCard = Color(0x1AFFFFFF);        // 10% white
  static const Color glassFillElevated = Color(0x28FFFFFF);    // 16% white
  static const Color glassBorderLight = Color(0x33FFFFFF);     // 20% white
  static const Color glassBorderGlow = Color(0x66A78BFA);      // 40% brand purple
  static const Color specularHighlight = Color(0x80FFFFFF);    // 50% white highlight

  // Glow Accents
  static const Color glowPurple = Color(0xFF8B5CF6);
  static const Color glowIndigo = Color(0xFF6366F1);
  static const Color glowCyan = Color(0xFF06B6D4);
  static const Color glowPink = Color(0xFFEC4899);

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
  static const Color semanticSuccess = Color(0xFF10B981);
  static const Color semanticWarning = Color(0xFFF59E0B);
  static const Color semanticDanger = Color(0xFFEF4444);
  static const Color semanticInfo = Color(0xFF3B82F6);

  // Dark Theme Text & Border
  static const Color darkBrandPurple500 = Color(0xFFA78BFA);
  static const Color darkTextPrimary = Color(0xFFF9FAFB);
  static const Color darkTextSecondary = Color(0xFF9CA3AF);
  static const Color darkTextMuted = Color(0xFF6B7280);
  static const Color darkBorder = Color(0x26FFFFFF);

  // Gradients
  static const LinearGradient cosmicGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0D0B18), Color(0xFF06060A), Color(0xFF140D26)],
  );

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF8B5CF6), Color(0xFF6366F1), Color(0xFFD946EF)],
  );

  static const LinearGradient glassGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x24FFFFFF),
      Color(0x0CFFFFFF),
    ],
  );

  static const LinearGradient glassBorderGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x66FFFFFF),
      Color(0x1AFFFFFF),
      Color(0x33A78BFA),
    ],
  );

  // Spacing
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

  // Radius
  static const double radiusXs = 4.0;
  static const double radiusSm = 8.0;
  static const double radiusMd = 14.0;
  static const double radiusLg = 20.0;
  static const double radiusXl = 28.0;
  static const double radiusFull = 9999.0;

  // Blur Amounts
  static const double blurSubtle = 12.0;
  static const double blurStandard = 20.0;
  static const double blurHeavy = 32.0;

  // Motion
  static const Duration motionFast = Duration(milliseconds: 150);
  static const Duration motionBase = Duration(milliseconds: 260);
  static const Duration motionSlow = Duration(milliseconds: 400);

  // Typography
  static const TextStyle displayLg = TextStyle(
    fontFamily: 'Inter',
    fontSize: 32,
    fontWeight: FontWeight.w800,
    height: 1.2,
    letterSpacing: -0.8,
  );

  static const TextStyle displaySm = TextStyle(
    fontFamily: 'Inter',
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 1.25,
    letterSpacing: -0.5,
  );

  static const TextStyle titleLg = TextStyle(
    fontFamily: 'Inter',
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: -0.3,
  );

  static const TextStyle titleMd = TextStyle(
    fontFamily: 'Inter',
    fontSize: 17,
    fontWeight: FontWeight.w600,
    height: 1.35,
    letterSpacing: -0.2,
  );

  static const TextStyle bodyLg = TextStyle(
    fontFamily: 'Inter',
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static const TextStyle bodyMd = TextStyle(
    fontFamily: 'Inter',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static const TextStyle bodySm = TextStyle(
    fontFamily: 'Inter',
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );

  static const TextStyle labelLg = TextStyle(
    fontFamily: 'Inter',
    fontSize: 15,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  static const TextStyle labelSm = TextStyle(
    fontFamily: 'Inter',
    fontSize: 11,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: 0.5,
  );
}
