import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      primarySwatch: Colors.blue,
      brightness: Brightness.light,
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: AppBarTheme(
        elevation: 1,
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      iconTheme: IconThemeData(
        color: Colors.grey[700],
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      primarySwatch: Colors.blue,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: Color(0xFF121212),
      appBarTheme: AppBarTheme(
        elevation: 1,
        centerTitle: true,
        backgroundColor: Color(0xFF1E1E1E),
        foregroundColor: Colors.white,
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      iconTheme: IconThemeData(
        color: Colors.grey[300],
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}