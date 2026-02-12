import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFFFF7A00);
  static const Color secondary = Color(0xFF0A192F);
  static const Color backgroundDark = Color(0xFF050B14);
  static const Color backgroundLight = Color(0xFFF2F2F7);
}

class AppTheme {
  static ThemeData darkTheme(
    Color primaryColor,
    String fontFamily,
    int fontWeightValue,
  ) => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        primaryColor: primaryColor,
        scaffoldBackgroundColor: AppColors.backgroundDark,
        appBarTheme: AppBarTheme(
          centerTitle: true,
          backgroundColor: AppColors.secondary.withValues(alpha: 0.95),
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          iconTheme:
              IconThemeData(color: Colors.white.withValues(alpha: 0.75)),
          actionsIconTheme: IconThemeData(
            color: Colors.white.withValues(alpha: 0.75),
          ),
          titleTextStyle: TextStyle(
            fontSize: 18,
            fontWeight: _fontWeight(fontWeightValue),
            color: Colors.white,
            fontFamily: _fontAssetFamily(fontFamily),
          ),
          shape: Border(
            bottom: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
          ),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
        ),
        textTheme: _withBaseWeight(
          ThemeData.dark().textTheme.apply(
            fontFamily: _fontAssetFamily(fontFamily),
          ),
          _fontWeight(fontWeightValue),
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          brightness: Brightness.dark,
          surface: AppColors.secondary,
        ),
      );

  static ThemeData lightTheme(
    Color primaryColor,
    String fontFamily,
    int fontWeightValue,
  ) => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        primaryColor: primaryColor,
        scaffoldBackgroundColor: AppColors.backgroundLight,
        appBarTheme: AppBarTheme(
          centerTitle: true,
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          iconTheme:
              IconThemeData(color: Colors.black.withValues(alpha: 0.65)),
          actionsIconTheme: IconThemeData(
            color: Colors.black.withValues(alpha: 0.65),
          ),
          titleTextStyle: TextStyle(
            fontSize: 18,
            fontWeight: _fontWeight(fontWeightValue),
            color: Colors.black87,
            fontFamily: _fontAssetFamily(fontFamily),
          ),
          shape: Border(
            bottom: BorderSide(color: Colors.black.withValues(alpha: 0.06)),
          ),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
        ),
        textTheme: _withBaseWeight(
          ThemeData.light().textTheme.apply(
            fontFamily: _fontAssetFamily(fontFamily),
          ),
          _fontWeight(fontWeightValue),
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          brightness: Brightness.light,
          surface: Colors.white,
        ),
      );

  static String _fontAssetFamily(String fontFamily) {
    switch (fontFamily) {
      case 'inter':
      case 'nunito':
      case 'poppins':
      case 'playfair':
      case 'merriweather':
        return fontFamily;
      default:
        return 'inter';
    }
  }

  static FontWeight _fontWeight(int value) {
    switch (value) {
      case 300:
        return FontWeight.w300;
      case 500:
        return FontWeight.w500;
      case 600:
        return FontWeight.w600;
      case 700:
        return FontWeight.w700;
      case 400:
      default:
        return FontWeight.w400;
    }
  }

  static TextTheme _withBaseWeight(TextTheme base, FontWeight weight) {
    return base.copyWith(
      displayLarge: base.displayLarge?.copyWith(fontWeight: weight),
      displayMedium: base.displayMedium?.copyWith(fontWeight: weight),
      displaySmall: base.displaySmall?.copyWith(fontWeight: weight),
      headlineLarge: base.headlineLarge?.copyWith(fontWeight: weight),
      headlineMedium: base.headlineMedium?.copyWith(fontWeight: weight),
      headlineSmall: base.headlineSmall?.copyWith(fontWeight: weight),
      titleLarge: base.titleLarge?.copyWith(fontWeight: weight),
      titleMedium: base.titleMedium?.copyWith(fontWeight: weight),
      titleSmall: base.titleSmall?.copyWith(fontWeight: weight),
      bodyLarge: base.bodyLarge?.copyWith(fontWeight: weight),
      bodyMedium: base.bodyMedium?.copyWith(fontWeight: weight),
      bodySmall: base.bodySmall?.copyWith(fontWeight: weight),
      labelLarge: base.labelLarge?.copyWith(fontWeight: weight),
      labelMedium: base.labelMedium?.copyWith(fontWeight: weight),
      labelSmall: base.labelSmall?.copyWith(fontWeight: weight),
    );
  }
}
