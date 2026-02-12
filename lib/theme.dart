import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFFFF7A00);
  static const Color secondary = Color(0xFF0A192F);
  static const Color backgroundDark = Color(0xFF050B14);
  static const Color backgroundLight = Color(0xFFF2F2F7);
}

class AppTheme {
  static ThemeData darkTheme(
    Color primaryColor, {
    required bool highContrast,
    required bool reduceMotion,
    required bool largeTouchTargets,
  }) => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: AppColors.backgroundDark,
    materialTapTargetSize: largeTouchTargets
        ? MaterialTapTargetSize.padded
        : MaterialTapTargetSize.shrinkWrap,
    visualDensity: largeTouchTargets
        ? VisualDensity.comfortable
        : VisualDensity.standard,
    pageTransitionsTheme: _pageTransitions(reduceMotion),
    dividerColor: Colors.white.withValues(alpha: highContrast ? 0.18 : 0.08),
    appBarTheme: AppBarTheme(
      centerTitle: true,
      backgroundColor: AppColors.secondary.withValues(alpha: 0.95),
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      iconTheme: IconThemeData(color: Colors.white.withValues(alpha: 0.75)),
      actionsIconTheme: IconThemeData(
        color: Colors.white.withValues(alpha: 0.75),
      ),
      titleTextStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: Colors.white,
        fontFamily: 'inter',
      ),
      shape: Border(
        bottom: BorderSide(
          color: Colors.white.withValues(alpha: highContrast ? 0.16 : 0.06),
        ),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
    ),
    textTheme: ThemeData.dark().textTheme.apply(fontFamily: 'inter'),
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.dark,
      surface: AppColors.secondary,
    ),
  );

  static ThemeData lightTheme(
    Color primaryColor, {
    required bool highContrast,
    required bool reduceMotion,
    required bool largeTouchTargets,
  }) => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: AppColors.backgroundLight,
    materialTapTargetSize: largeTouchTargets
        ? MaterialTapTargetSize.padded
        : MaterialTapTargetSize.shrinkWrap,
    visualDensity: largeTouchTargets
        ? VisualDensity.comfortable
        : VisualDensity.standard,
    pageTransitionsTheme: _pageTransitions(reduceMotion),
    dividerColor: Colors.black.withValues(alpha: highContrast ? 0.18 : 0.08),
    appBarTheme: AppBarTheme(
      centerTitle: true,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      iconTheme: IconThemeData(color: Colors.black.withValues(alpha: 0.65)),
      actionsIconTheme: IconThemeData(
        color: Colors.black.withValues(alpha: 0.65),
      ),
      titleTextStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: Colors.black87,
        fontFamily: 'inter',
      ),
      shape: Border(
        bottom: BorderSide(
          color: Colors.black.withValues(alpha: highContrast ? 0.16 : 0.06),
        ),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
    ),
    textTheme: ThemeData.light().textTheme.apply(fontFamily: 'inter'),
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.light,
      surface: Colors.white,
    ),
  );

  static PageTransitionsTheme _pageTransitions(bool reduceMotion) {
    if (!reduceMotion) {
      return const PageTransitionsTheme();
    }
    return const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: _NoAnimationTransitionsBuilder(),
        TargetPlatform.iOS: _NoAnimationTransitionsBuilder(),
        TargetPlatform.linux: _NoAnimationTransitionsBuilder(),
        TargetPlatform.macOS: _NoAnimationTransitionsBuilder(),
        TargetPlatform.windows: _NoAnimationTransitionsBuilder(),
      },
    );
  }
}

class _NoAnimationTransitionsBuilder extends PageTransitionsBuilder {
  const _NoAnimationTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return child;
  }
}
