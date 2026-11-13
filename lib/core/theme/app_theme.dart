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
      sliderTheme: const SliderThemeData(
        mouseCursor: WidgetStatePropertyAll<MouseCursor>(SystemMouseCursors.click),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          mouseCursor: WidgetStatePropertyAll<MouseCursor>(SystemMouseCursors.click),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          mouseCursor: WidgetStatePropertyAll<MouseCursor>(SystemMouseCursors.click),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          mouseCursor: WidgetStatePropertyAll<MouseCursor>(SystemMouseCursors.click),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: ButtonStyle(
          mouseCursor: WidgetStatePropertyAll<MouseCursor>(SystemMouseCursors.click),
        ),
      ),
      radioTheme: const RadioThemeData(
        mouseCursor: WidgetStatePropertyAll<MouseCursor>(SystemMouseCursors.click),
      ),
      checkboxTheme: const CheckboxThemeData(
        mouseCursor: WidgetStatePropertyAll<MouseCursor>(SystemMouseCursors.click),
      ),
      switchTheme: const SwitchThemeData(
        mouseCursor: WidgetStatePropertyAll<MouseCursor>(SystemMouseCursors.click),
      ),
    );
  }
}
