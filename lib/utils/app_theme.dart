import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'underwater_theme.dart';

/// FishQuest App Theme
/// 60:30:10 Color Rule Applied
/// Primary (60%) - Deep Ocean Blue
/// Secondary (30%) - Teal Accent
/// Accent (10%) - Amber/Gold
/// Rounded Modern Design System

class AppTheme {
  // Color Palette (60:30:10 Rule)
  static const Color colorPrimary = Color(0xFF0A2540);
  static const Color colorPrimaryLight = Color(0xFF134563);
  static const Color colorPrimaryDark = Color(0xFF051829);
  
  static const Color colorSecondary = Color(0xFF1A7F8E);
  static const Color colorSecondaryLight = Color(0xFF2B98A8);
  static const Color colorSecondaryDark = Color(0xFF0F5A66);
  
  static const Color colorAccent = Color(0xFFD4A574);
  static const Color colorAccentLight = Color(0xFFE3B985);
  static const Color colorAccentDark = Color(0xFFB88F60);
  
  // Neutral Colors
  static const Color colorTextPrimary = Color(0xFFFFFFFF);
  static const Color colorTextSecondary = Color(0xFFB8C5D6);
  static const Color colorTextMuted = Color(0xFF7A8A9E);
  static const Color colorTextDark = Color(0xFF0A2540);
  static const Color colorBackground = Color(0xFFF5F7FA);
  static const Color colorSurface = Color(0xFFFFFFFF);
  static const Color colorBorder = Color(0xFFE1E8ED);
  static const Color colorError = Color(0xFFC23934);
  static const Color colorSuccess = Color(0xFF2E7D32);
  
  // Border Radius System
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 20.0;
  
  // Shape System
  static const RoundedRectangleBorder roundedShapeSmall = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(radiusSmall)),
  );
  
  static const RoundedRectangleBorder roundedShapeMedium = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(radiusMedium)),
  );
  
  static const RoundedRectangleBorder roundedShapeLarge = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(radiusLarge)),
  );
  
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'System',
      
      // Color Scheme
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: colorPrimary,
        onPrimary: colorTextPrimary,
        secondary: colorSecondary,
        onSecondary: colorTextPrimary,
        tertiary: colorAccent,
        onTertiary: colorTextDark,
        error: colorError,
        onError: colorTextPrimary,
        surface: colorSurface,
        onSurface: colorTextDark,
      ),
      
      scaffoldBackgroundColor: colorBackground,
      
      // App Bar Theme - Rounded bottom
      appBarTheme: const AppBarTheme(
        backgroundColor: colorPrimary,
        foregroundColor: colorTextPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: colorTextPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      
      // Card Theme - Rounded
      cardTheme: const CardThemeData(
        color: colorSurface,
        elevation: 4,
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(radiusMedium)),
          side: BorderSide(color: colorBorder, width: 2),
        ),
        margin: EdgeInsets.zero,
      ),
      
      // Elevated Button Theme - Rounded
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorSecondary,
          foregroundColor: colorTextPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(radiusMedium)),
          ),
        ),
      ),
      
      // Outlined Button Theme - Rounded
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorSecondary,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
          ),
          side: const BorderSide(color: colorSecondary, width: 2),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(radiusMedium)),
          ),
        ),
      ),
      
      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorSecondary,
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      
      // Input Decoration Theme - Rounded with Underwater Colors
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: UnderwaterTheme.deepNavy1.withOpacity(0.5),
        border: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(radiusMedium)),
          borderSide: BorderSide(color: UnderwaterTheme.surfaceCyan1.withOpacity(0.5), width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(radiusMedium)),
          borderSide: BorderSide(color: UnderwaterTheme.surfaceCyan1.withOpacity(0.3), width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(radiusMedium)),
          borderSide: BorderSide(color: UnderwaterTheme.surfaceCyan1, width: 2),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(radiusMedium)),
          borderSide: BorderSide(color: colorError, width: 2),
        ),
        contentPadding: const EdgeInsets.all(16),
        labelStyle: const TextStyle(
          color: UnderwaterTheme.textCyan,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        hintStyle: const TextStyle(
          color: UnderwaterTheme.textCyan,
          fontSize: 14,
        ),
        prefixIconColor: UnderwaterTheme.surfaceCyan1,
        suffixIconColor: UnderwaterTheme.surfaceCyan1,
      ),
      
      // Text Selection Theme
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: UnderwaterTheme.surfaceCyan1,
        selectionColor: UnderwaterTheme.surfaceCyan1.withOpacity(0.3),
        selectionHandleColor: UnderwaterTheme.surfaceCyan1,
      ),
      
      // Floating Action Button Theme - Rounded
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: colorAccent,
        foregroundColor: colorTextDark,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(radiusLarge)),
        ),
      ),
      
      // Bottom Navigation Bar Theme - Glass effect
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: colorPrimaryDark,
        selectedItemColor: colorAccent,
        unselectedItemColor: colorTextSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
      
      // Dialog Theme - Rounded
      dialogTheme: const DialogThemeData(
        backgroundColor: colorPrimaryDark,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(radiusLarge)),
        ),
        titleTextStyle: TextStyle(
          color: UnderwaterTheme.textLight,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          shadows: UnderwaterTheme.textShadowLight,
        ),
      ),
      
      // Dropdown Menu Theme
      dropdownMenuTheme: DropdownMenuThemeData(
        textStyle: const TextStyle(
          color: UnderwaterTheme.textLight,
          fontSize: 16,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: UnderwaterTheme.deepNavy1.withOpacity(0.5),
          border: OutlineInputBorder(
            borderRadius: const BorderRadius.all(Radius.circular(radiusMedium)),
            borderSide: BorderSide(color: UnderwaterTheme.surfaceCyan1.withOpacity(0.5), width: 2),
          ),
        ),
      ),
      
      // Chip Theme - Rounded
      chipTheme: const ChipThemeData(
        backgroundColor: colorBackground,
        selectedColor: colorSecondary,
        labelStyle: TextStyle(
          color: colorTextDark,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(radiusSmall)),
          side: BorderSide(color: colorBorder, width: 2),
        ),
      ),
      
      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: colorBorder,
        thickness: 2,
        space: 2,
      ),
      
      // Text Theme - Underwater Colors
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: UnderwaterTheme.textLight,
          letterSpacing: 0.5,
          shadows: UnderwaterTheme.textShadowLight,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: UnderwaterTheme.textLight,
          letterSpacing: 0.5,
          shadows: UnderwaterTheme.textShadowLight,
        ),
        displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: UnderwaterTheme.textLight,
          letterSpacing: 0.5,
          shadows: UnderwaterTheme.textShadowLight,
        ),
        headlineLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: UnderwaterTheme.textLight,
          letterSpacing: 0.5,
        ),
        headlineMedium: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: UnderwaterTheme.textLight,
          letterSpacing: 0.5,
        ),
        headlineSmall: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: UnderwaterTheme.textLight,
          letterSpacing: 0.5,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: UnderwaterTheme.textLight,
          height: 1.6,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: UnderwaterTheme.textCyan,
          height: 1.6,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: UnderwaterTheme.textCyan,
          height: 1.6,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: UnderwaterTheme.textLight,
          letterSpacing: 0.5,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: UnderwaterTheme.textCyan,
          letterSpacing: 0.5,
        ),
        labelSmall: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: UnderwaterTheme.textCyan,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
