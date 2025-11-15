import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  static const Size designSize = Size(393, 852);
  
  // Colors
  // Primary/secondary colors updated to match the blue + teal gradient
  // used in the original app screenshots.
  static const Color primary = Color(0xFF2980B9); // blue
  static const Color secondary = Color(0xFF16A085); // teal
  // App-wide gradient (used in header bars, cards, and primary accents)
  static const Gradient appGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  // A darker gradient variant for dark mode headers/cards
  static const Gradient darkGradient = LinearGradient(
    colors: [Color(0xFF0B1220), Color(0xFF172338)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  // Dark-mode friendly backgrounds (deep navy / slate) for improved contrast
  // slightly brighter dark background/surface for better contrast
  static const Color background = Color(0xFF071827);
  static const Color surface = Color(0xFF0B1A2A);
  static const Color error = Color(0xFFE74C3C);
  // Additional semantic colors
  static const Color warning = Color(0xFFE67E22);
  static const Color purple = Color(0xFF9B59B6);
  static const Color slate = Color(0xFF34495E);
  static const Color textPrimary = Color(0xFF1E1E1E);
  static const Color textSecondary = Colors.black54;
  
  // Font Sizes
  static const double _baseFontSize = 16.0;
  static const double _scaleFactor = 0.875;
  
  // Text Styles
  static TextStyle heading1(BuildContext context) => TextStyle(
    fontSize: scaledFontSize(context, 24),
    fontWeight: FontWeight.bold,
    color: textPrimary,
  );

  static TextStyle heading2(BuildContext context) => TextStyle(
    fontSize: scaledFontSize(context, 20),
    fontWeight: FontWeight.bold,
    color: textPrimary,
  );

  static TextStyle bodyText(BuildContext context) => TextStyle(
    fontSize: scaledFontSize(context, _baseFontSize),
    color: textPrimary,
  );

  static TextStyle caption(BuildContext context) => TextStyle(
    fontSize: scaledFontSize(context, 14),
    color: textSecondary,
  );

  // Utility Methods
  static double scaledFontSize(BuildContext context, double size) {
    final screenWidth = MediaQuery.of(context).size.width;
    final scale = screenWidth / designSize.width;
    return size * scale * _scaleFactor;
  }

  static EdgeInsets scaledPadding(
    BuildContext context, {
    double horizontal = 0,
    double vertical = 0,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final scale = screenWidth / designSize.width;
    return EdgeInsets.symmetric(
      horizontal: horizontal * scale,
      vertical: vertical * scale,
    );
  }

  static Size scaledSize(BuildContext context, double width, double height) {
    final screenWidth = MediaQuery.of(context).size.width;
    final scale = screenWidth / designSize.width;
    return Size(width * scale, height * scale);
  }

  static Color withOpacityFixed(Color color, double opacity) {
    // Prefer withAlpha over withOpacity to avoid deprecation warnings
    // in newer Flutter SDKs while preserving behavior.
    return color.withAlpha((opacity.clamp(0.0, 1.0) * 255).round());
  }

  /// Creates a ThemeData instance for the specified brightness
  static ThemeData _createTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final theme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: brightness,
      ),
    );
    // Provide an accessible text theme depending on brightness
    final baseTextTheme = isDark ? ThemeData.dark().textTheme : ThemeData.light().textTheme;
    final textTheme = baseTextTheme.apply(
      bodyColor: isDark ? Colors.white : const Color(0xFF1E1E1E),
      displayColor: isDark ? Colors.white : const Color(0xFF1E1E1E),
    );
    
    return theme.copyWith(
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      // Original app used a light, slightly cool gray background in light mode
  scaffoldBackgroundColor: isDark ? background : const Color(0xFFF5F7FA),
      appBarTheme: AppBarTheme(
        // Light mode app bar was white with dark text; dark kept as before
        backgroundColor: isDark ? background : Colors.white,
        foregroundColor: isDark ? Colors.white : const Color(0xFF1F2937),
        centerTitle: true,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? surface : Colors.grey[100],
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: isDark ? background : Colors.white,
        selectedItemColor: primary,
        unselectedItemColor: isDark ? Colors.white70 : Colors.black54,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
      ),
      drawerTheme: DrawerThemeData(
        backgroundColor: isDark ? background : Colors.white,
      ),
      cardTheme: CardThemeData(
        color: isDark ? surface : Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  /// Configures system UI settings
  static void setSystemUI() {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  /// Returns theme data for requested brightness
  static ThemeData getTheme(Brightness brightness) => _createTheme(brightness);
}