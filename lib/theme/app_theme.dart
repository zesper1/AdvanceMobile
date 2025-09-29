import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Defines the color palette and text styles for the application.
class AppTheme {
  // --- Colors ---
  static const Color primaryColor = Color(0xFF0D47A1); // A deep, rich blue
  static const Color accentColor = Color(0xFFFFD700); // A vibrant gold
  static const Color backgroundColor = Color(0xFFFFFFFF); // Clean white
  static const Color textColor = Color(0xFF333333); // Dark grey for text
  static const Color subtleTextColor =
      Color(0xFF757575); // Lighter grey for hints
  static const Color cardColor =
      Color(0xFFF5F5F5); // A very light grey for cards/inputs

  // --- ThemeData ---
  // This is the main theme configuration for the app.
  static final ThemeData lightTheme = ThemeData(
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,

    // Defines the visual properties of an AppBar.
    appBarTheme: AppBarTheme(
      backgroundColor: primaryColor,
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.white),
      titleTextStyle: GoogleFonts.poppins(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),

    // Defines the default text styling for the entire app using Google's Poppins font.
    textTheme: GoogleFonts.poppinsTextTheme().apply(
      bodyColor: textColor,
      displayColor: textColor,
    ),

    // Defines the visual properties of elevated buttons.
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: primaryColor,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    // Defines the default decoration for text input fields.
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: cardColor,
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      hintStyle: const TextStyle(color: subtleTextColor),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      prefixIconColor: subtleTextColor,
    ),

    // Defines the visual properties of dropdown menus.
    dropdownMenuTheme: DropdownMenuThemeData(
      textStyle: GoogleFonts.poppins(color: textColor),
    ),

    // Defines the visual properties of text buttons.
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryColor,
        textStyle: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    // Sets the color scheme for other components like floating action buttons.
    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      secondary: accentColor,
      background: backgroundColor,
    ).copyWith(background: backgroundColor),
  );
}
