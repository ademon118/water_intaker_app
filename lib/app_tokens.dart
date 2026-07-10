import 'package:flutter/material.dart';

enum AppFontWeightToken { regular, medium, semibold, bold }

/// Design tokens for Water Intaker App.
abstract final class AppColors {
  static const Color primary = Color(0xFF3A86FF);
  static const Color primaryLight = Color(0xFFA2D2FF);
  static const Color primaryDisabled = Color(0xFFB8D4FF);
  static const Color secondary = Color(0xFF00B4D8);
  static const Color secondaryLight = Color(0xFFF1F5F9);
  static const Color accent = Color(0xFF80ED99);
  static const Color accentAlt = Color(0xFFFFAA4C);
  static const Color error = Color(0xFFDC3545);

  static const Color black = Color(0xFF2E2E2E);
  static const Color black1 = Color(0xFF000000);
  static const Color black2 = Color(0xFF111111);
  static const Color black90 = Color(0xFF3B3B3B);
  static const Color black80 = Color(0xFF515151);
  static const Color black70 = Color(0xFF6C757D);
  static const Color black60 = Color(0xFF7C7C7C);
  static const Color black50 = Color(0xFF929292);
  static const Color black40 = Color(0xFFA8A8A8);
  static const Color black30 = Color(0xFFBEBEBE);
  static const Color black20 = Color(0xFFD3D3D3);
  static const Color black10 = Color(0xFFE9E9E9);

  static const Color background = Color(0xFFFFFFFF);
  static const Color white90 = Color(0xFFF5F5F5);
  static const Color linkBlue = Color(0xFF4592F7);

  // Backward-compatible aliases
  static const Color textPrimary = black;
  static const Color textSecondary = black70;
}

abstract final class AppFonts {
  static const String inter = 'Inter';
  static const String interRegular = inter;
  static const String interMedium = inter;
  static const String interSemiBold = inter;
  static const String interBold = inter;
}

abstract final class AppTextStyles {
  static TextStyle inter(
    double size, {
    AppFontWeightToken weight = AppFontWeightToken.regular,
    Color color = AppColors.black,
  }) {
    switch (weight) {
      case AppFontWeightToken.regular:
        return interRegular(size, color: color);
      case AppFontWeightToken.medium:
        return interMedium(size, color: color);
      case AppFontWeightToken.semibold:
        return interSemiBold(size, color: color);
      case AppFontWeightToken.bold:
        return interBold(size, color: color);
    }
  }

  static TextStyle interRegular(double size, {Color color = AppColors.black}) {
    return TextStyle(
      fontFamily: AppFonts.interRegular,
      fontSize: size,
      color: color,
      fontWeight: FontWeight.w400,
    );
  }

  static TextStyle interMedium(double size, {Color color = AppColors.black}) {
    return TextStyle(
      fontFamily: AppFonts.interMedium,
      fontSize: size,
      color: color,
      fontWeight: FontWeight.w500,
    );
  }

  static TextStyle interSemiBold(double size, {Color color = AppColors.black}) {
    return TextStyle(
      fontFamily: AppFonts.interSemiBold,
      fontSize: size,
      color: color,
      fontWeight: FontWeight.w600,
    );
  }

  static TextStyle interBold(double size, {Color color = AppColors.black}) {
    return TextStyle(
      fontFamily: AppFonts.interBold,
      fontSize: size,
      color: color,
      fontWeight: FontWeight.w700,
    );
  }

  static TextStyle get inter10Regular => interRegular(10);
  static TextStyle get inter12Regular => interRegular(12);
  static TextStyle get inter14Regular => interRegular(14);
  static TextStyle get inter16Regular => interRegular(16);
  static TextStyle get inter18Regular => interRegular(18);
  static TextStyle get inter20Regular => interRegular(20);
  static TextStyle get inter22Regular => interRegular(22);
  static TextStyle get inter24Regular => interRegular(24);

  static TextStyle get inter10Medium => interMedium(10);
  static TextStyle get inter12Medium => interMedium(12);
  static TextStyle get inter14Medium => interMedium(14);
  static TextStyle get inter16Medium => interMedium(16);
  static TextStyle get inter18Medium => interMedium(18);
  static TextStyle get inter20Medium => interMedium(20);
  static TextStyle get inter22Medium => interMedium(22);
  static TextStyle get inter24Medium => interMedium(24);

  static TextStyle get inter10SemiBold => interSemiBold(10);
  static TextStyle get inter12SemiBold => interSemiBold(12);
  static TextStyle get inter14SemiBold => interSemiBold(14);
  static TextStyle get inter16SemiBold => interSemiBold(16);
  static TextStyle get inter18SemiBold => interSemiBold(18);
  static TextStyle get inter20SemiBold => interSemiBold(20);
  static TextStyle get inter22SemiBold => interSemiBold(22);
  static TextStyle get inter24SemiBold => interSemiBold(24);

  static TextStyle get inter10Bold => interBold(10);
  static TextStyle get inter12Bold => interBold(12);
  static TextStyle get inter14Bold => interBold(14);
  static TextStyle get inter16Bold => interBold(16);
  static TextStyle get inter18Bold => interBold(18);
  static TextStyle get inter20Bold => interBold(20);
  static TextStyle get inter22Bold => interBold(22);
  static TextStyle get inter24Bold => interBold(24);
}

extension AppTextColorTokens on TextStyle {
  TextStyle get textLinkBlue => copyWith(color: AppColors.linkBlue);
  TextStyle get textWhite => copyWith(color: AppColors.background);
  TextStyle get textPrimary => copyWith(color: AppColors.primary);
  TextStyle get textError => copyWith(color: AppColors.error);
  TextStyle get textBlack => copyWith(color: AppColors.black);
  TextStyle get textBlack70 => copyWith(color: AppColors.black70);
  TextStyle get textBlack60 => copyWith(color: AppColors.black60);
}
