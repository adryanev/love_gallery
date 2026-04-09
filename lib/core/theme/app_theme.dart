import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppTheme {
  // Color Palette (more pastel for watercolor effect)
  static const Color blushPink = Color(0xFFFCE8E6);
  static const Color roseQuartz = Color(0xFFF6B6B6);
  static const Color dustyMauve = Color(0xFFA6828A);
  static const Color warmCharcoal = Color(0xFF4C3A3A);
  static const Color goldWash = Color(0xFFF3D8A8);
  static const Color petalPink = Color(0xFFFADADD);

  // Additional watercolor palette
  static const Color softLavender = Color(0xFFE6E6FA);
  static const Color paleGreen = Color(0xFFDCEDC8);
  static const Color skyBlue = Color(0xFFBBDEFB);

  // Typography with more artistic fonts
  static TextTheme textTheme = TextTheme(
    displayLarge: GoogleFonts.playfairDisplay(
      color: warmCharcoal,
      fontSize: 34.sp,
      fontWeight: FontWeight.bold,
      letterSpacing: 0.5,
    ),
    displayMedium: GoogleFonts.playfairDisplay(
      color: warmCharcoal,
      fontSize: 28.sp,
      fontWeight: FontWeight.bold,
    ),
    displaySmall: GoogleFonts.playfairDisplay(
      color: warmCharcoal,
      fontSize: 24.sp,
      fontWeight: FontWeight.w600,
    ),
    headlineMedium: GoogleFonts.cormorantGaramond(
      color: warmCharcoal,
      fontSize: 22.sp,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.3,
    ),
    headlineSmall: GoogleFonts.cormorantGaramond(
      color: warmCharcoal,
      fontSize: 20.sp,
      fontWeight: FontWeight.w600,
    ),
    titleLarge: GoogleFonts.cormorantGaramond(
      color: warmCharcoal,
      fontSize: 18.sp,
      fontWeight: FontWeight.w600,
    ),
    bodyLarge: GoogleFonts.notoSerif(
      color: warmCharcoal,
      fontSize: 16.sp,
      height: 1.5,
    ),
    bodyMedium: GoogleFonts.notoSerif(
      color: warmCharcoal,
      fontSize: 14.sp,
      height: 1.5,
    ),
    labelLarge: GoogleFonts.dancingScript(
      color: warmCharcoal,
      fontSize: 20.sp,
      fontWeight: FontWeight.w600,
    ),
  );

  static ThemeData getLightTheme() {
    return ThemeData(
      scaffoldBackgroundColor: blushPink,
      colorScheme: const ColorScheme.light(
        primary: dustyMauve,
        secondary: roseQuartz,
        surface: blushPink,
        error: Colors.redAccent,
        onPrimary: Colors.white,
        onSecondary: warmCharcoal,
        onSurface: warmCharcoal,
        onError: Colors.white,
      ),
      textTheme: textTheme,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: petalPink,
          foregroundColor: warmCharcoal,
          elevation: 2,
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          textStyle: GoogleFonts.cormorantGaramond(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: dustyMauve,
          side: BorderSide(color: dustyMauve, width: 1.5.w),
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          textStyle: GoogleFonts.cormorantGaramond(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      iconTheme: IconThemeData(color: dustyMauve, size: 24.r),
      appBarTheme: AppBarTheme(
        backgroundColor: petalPink.withValues(alpha: 0.8),
        foregroundColor: warmCharcoal,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.playfairDisplay(
          color: warmCharcoal,
          fontSize: 24.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white.withValues(alpha: 0.85),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.r),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.7),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.r),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.r),
          borderSide: BorderSide(color: dustyMauve, width: 1.5.w),
        ),
      ),
    );
  }
}
