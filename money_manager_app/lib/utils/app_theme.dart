import 'package:flutter/material.dart';

class AppTheme {
  static const Color creamyYellow = Color(0xFFFFF4D2); // Increased saturation from 0xFFFFF8DC
  static const Color creamyYellowLight = Color(0xFFFFF9C4); // Increased saturation from 0xFFFFFACD
  static const Color accentGold = Color(0xFFFFD700);
  static const Color incomeBlue = Color(0xFF4A90D9);
  static const Color outgoingRed = Color(0xFFE74C3C);
  static const Color darkBg = Color(0xFF1a1a1a);
  static const Color darkSurface = Color(0xFF2d2d2d);
  static const Color darkCard = Color(0xFF333333);

  static const _pageTransitions = PageTransitionsTheme(
    builders: {
      TargetPlatform.android: CupertinoPageTransitionsBuilder(),
      TargetPlatform.linux: CupertinoPageTransitionsBuilder(),
    },
  );

  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: creamyYellow,
        colorScheme: ColorScheme.light(
          primary: accentGold,
          secondary: accentGold,
          surface: Colors.white,
          onSurface: Colors.black87,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: creamyYellowLight,
          foregroundColor: Colors.black87,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: const TextStyle(
            fontFamily: 'Outfit',
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        textTheme: const TextTheme(
          titleLarge: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w700),
          titleMedium: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w600),
          titleSmall: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w600),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: accentGold,
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          elevation: 8,
        ),
        fontFamily: 'Poppins',
        dividerTheme: DividerThemeData(
          color: Colors.grey.shade200,
          thickness: 1,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: accentGold, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        pageTransitionsTheme: _pageTransitions,
      );

  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: darkBg,
        colorScheme: ColorScheme.dark(
          primary: accentGold,
          secondary: accentGold,
          surface: darkSurface,
          onSurface: Colors.white,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: darkSurface,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: const TextStyle(
            fontFamily: 'Outfit',
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        textTheme: const TextTheme(
          titleLarge: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w700, color: Colors.white),
          titleMedium: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w600, color: Colors.white),
          titleSmall: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w600, color: Colors.white),
        ),
        cardTheme: CardThemeData(
          color: darkCard,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: darkSurface,
          selectedItemColor: accentGold,
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          elevation: 8,
        ),
        fontFamily: 'Poppins',
        dividerTheme: DividerThemeData(
          color: Colors.grey.shade700,
          thickness: 1,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: darkCard,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade600),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade600),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: accentGold, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        pageTransitionsTheme: _pageTransitions,
      );
}
