import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Warm, light palette: cream paper with violet / teal / coral accents.
class AppColors {
  static const bg = Color(0xFFEFEAFF);
  static const bgTint = Color(0xFFFFEFF5);
  static const lessonBackground = Color(0xFFF8F3E9);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceSoft = Color(0xFFE9F6FF);

  static const learn = Color(0xFF2E9BF0);
  static const learnDeep = Color(0xFF0F5FBF);

  static const practice = Color(0xFFF4569F);
  static const practiceDeep = Color(0xFFC21E70);

  static const play = Color(0xFF3FCF6E);
  static const playDeep = Color(0xFF14884A);

  static const sunshine = Color(0xFFFFC24B);
  static const grape = Color(0xFFB185FF);
  static const bubblegum = Color(0xFFFF7BAC);
  static const sky = Color(0xFF3FC5F0);

  static const ink = Color(0xFF2E2A4A);
  static const inkSoft = Color(0xFF837FA6);
  static const line = Color(0xFFEFE7E0);
}

/// Soft coloured glow so cards feel lifted rather than flat.
List<BoxShadow> glow(Color color, {double opacity = 0.32, double blur = 24}) => [
      BoxShadow(
        color: color.withValues(alpha: opacity),
        blurRadius: blur,
        offset: const Offset(0, 10),
      ),
    ];

ThemeData buildAppTheme() {
  final base = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.learn,
      primary: AppColors.learn,
    ),
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.bg,
  );

  return base.copyWith(
    textTheme: GoogleFonts.fredokaTextTheme(base.textTheme).apply(
      bodyColor: AppColors.ink,
      displayColor: AppColors.ink,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
    ),
  );
}
