import 'package:flutter/material.dart';

/// Design tokens port from minimalist/components/tokens/design-tokens.js
abstract final class DesignTokens {
  /// Color Palette Tokens (25 tokens)
  static const Color onyx = Color(0xFF212121);
  static const Color accentYellow = Color(0xFFFFFF1E);
  static const Color neutralLightSurface = Color(0xFFF5F7FA);
  static const Color pureWhite = Color(0xFFFFFFFF);

  static const Color darkSurfaceOne = Color(0xFF2A2A2A);
  static const Color darkSurfaceTwo = Color(0xFF2D2D2D);
  static const Color darkSurfaceThree = Color(0xFF333333);
  static const Color darkSurfaceFour = Color(0xFF383838);
  static const Color darkSurfaceFive = Color(0xFF3A3A3A);
  static const Color darkSurfaceSix = Color(0xFF3D3D3D);

  static const Color neutralGrayFifty = Color(0xFFFAFBFC);
  static const Color neutralGrayOneHundred = Color(0xFFEFF2F5);
  static const Color neutralGrayTwoHundred = Color(0xFFE2E6EA);
  static const Color neutralGrayThreeHundred = Color(0xFFD0D5DD);
  static const Color neutralGrayFourHundred = Color(0xFF98A2B3);
  static const Color neutralGrayFiveHundred = Color(0xFF667085);
  static const Color neutralGraySixHundred = Color(0xFF475467);
  static const Color neutralGraySevenHundred = Color(0xFF344054);
  static const Color neutralGrayEightHundred = Color(0xFF1D2939);
  static const Color neutralGrayNineHundred = Color(0xFF101828);

  static const Color statusOnlineGreen = Color(0xFF22C55E);
  static const Color statusErrorRed = Color(0xFFEF4444);

  static const Color inkCyan = Color(0xFF00B4FF);
  static const Color inkMagenta = Color(0xFFFF2E93);
  static const Color inkYellow = Color(0xFFFFFF1E);
  static const Color inkBlack = Color(0xFF212121);

  /// Corner Radius Tokens (Calibrated for native frameless window & sleek cards)
  static const double radiusPill = 100.0;
  static const double radiusCircle = 999.0;
  static const double radiusViewportDesktop = 16.0;
  static const double radiusViewportMobile = 24.0;
  static const double radiusCardOuter = 22.0;
  static const double radiusCardMedium = 18.0;
  static const double radiusCardInner = 14.0;
  static const double radiusModuleContainer = 14.0;
  static const double radiusControlSmall = 10.0;

  /// Dimensions & Spacing
  static const double desktopWidth = 1080.0;
  static const double desktopHeight = 780.0;
  static const double platenCapsuleWidthDesktop = 340.0;

  /// Shadows
  static const List<BoxShadow> shadowCard = [
    BoxShadow(
      color: Color(0x0F000000),
      offset: Offset(0, 12),
      blurRadius: 32,
    ),
  ];

  static const List<BoxShadow> shadowWorkstation = [
    BoxShadow(
      color: Color(0x24000000),
      offset: Offset(0, 24),
      blurRadius: 48,
    ),
  ];

  static const List<BoxShadow> shadowYellowButton = [
    BoxShadow(
      color: Color(0x40FFFF1E),
      offset: Offset(0, 6),
      blurRadius: 20,
    ),
  ];

  static const List<BoxShadow> shadowFloatingPill = [
    BoxShadow(
      color: Color(0x1A000000),
      offset: Offset(0, 6),
      blurRadius: 20,
    ),
  ];
}
