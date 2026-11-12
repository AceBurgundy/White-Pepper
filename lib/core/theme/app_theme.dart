import 'package:flutter/material.dart';
import 'design_tokens.dart';

abstract final class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: DesignTokens.neutralLightSurface,
      fontFamily: 'Google Sans',
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: DesignTokens.onyx,
        onPrimary: DesignTokens.pureWhite,
        secondary: DesignTokens.accentYellow,
        onSecondary: DesignTokens.onyx,
        error: DesignTokens.statusErrorRed,
        onError: DesignTokens.pureWhite,
        surface: DesignTokens.pureWhite,
        onSurface: DesignTokens.onyx,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusCardOuter),
        ),
        color: DesignTokens.pureWhite,
      ),
    );
  }
}
