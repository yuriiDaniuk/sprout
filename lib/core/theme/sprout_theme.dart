import 'package:flutter/material.dart';

abstract final class SproutColors {
  static const green = Color(0xFF2D6A4F);
  static const text = Color(0xFF1A2521);
  static const muted = Color(0xFF5A6E66);
  static const home = Color(0xFFF6FAF7);
  static const softGreen = Color(0xFFEAF2EC);
  static const input = Color(0xFFF9FBF9);
  static const border = Color(0xFFE2EBE5);
  static const profileMuted = Color(0xFF8A9C91);
  static const profileSurface = Color(0xFFF7FAF8);
  static const profileBorder = Color(0xFFE9F0EC);
}

TextStyle sproutText(
  double size, {
  FontWeight weight = FontWeight.w400,
  Color color = SproutColors.text,
}) => TextStyle(
  fontFamily: 'Manrope',
  fontSize: size,
  fontWeight: weight,
  fontVariations: [FontVariation('wght', weight.value.toDouble())],
  color: color,
  height: 1.4,
);

abstract final class SproutTheme {
  static final light = ThemeData(
    platform: TargetPlatform.iOS,
    brightness: Brightness.light,
    scaffoldBackgroundColor: Colors.white,
    fontFamily: 'Manrope',
    colorScheme: ColorScheme.fromSeed(
      seedColor: SproutColors.green,
      primary: SproutColors.green,
      surface: Colors.white,
    ),
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: SproutColors.green,
      selectionColor: Color(0x332D6A4F),
      selectionHandleColor: SproutColors.green,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: SproutColors.text,
      contentTextStyle: sproutText(14, color: Colors.white),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  );
}
