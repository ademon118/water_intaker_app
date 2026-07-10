import 'package:flutter/material.dart';

import 'app_tokens.dart';

abstract final class AppTheme {
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      fontFamily: AppFonts.inter,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: Colors.white,
        primaryContainer: AppColors.primaryLight,
        onPrimaryContainer: AppColors.black,
        secondary: AppColors.secondary,
        onSecondary: Colors.white,
        secondaryContainer: AppColors.secondaryLight,
        onSecondaryContainer: AppColors.black,
        tertiary: AppColors.accent,
        onTertiary: AppColors.black,
        tertiaryContainer: AppColors.accentAlt,
        onTertiaryContainer: AppColors.black,
        surface: AppColors.background,
        onSurface: AppColors.black,
        onSurfaceVariant: AppColors.black70,
        outline: AppColors.black70,
        error: AppColors.error,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: AppColors.secondaryLight,
      cardColor: AppColors.background,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.black),
        titleTextStyle: AppTextStyles.inter20SemiBold.copyWith(
          color: AppColors.black,
        ),
      ),
      textTheme: TextTheme(
        bodySmall: AppTextStyles.inter12Regular.copyWith(color: AppColors.black60),
        bodyMedium: AppTextStyles.inter14Regular.copyWith(color: AppColors.black),
        bodyLarge: AppTextStyles.inter16Regular.copyWith(color: AppColors.black),
        titleMedium: AppTextStyles.inter16SemiBold.copyWith(color: AppColors.black2),
        titleLarge: AppTextStyles.inter20SemiBold.copyWith(color: AppColors.black2),
        headlineSmall: AppTextStyles.inter24Bold.copyWith(color: AppColors.black2),
        labelSmall: AppTextStyles.inter10Medium.copyWith(color: AppColors.black70),
        labelMedium: AppTextStyles.inter12Medium.copyWith(color: AppColors.black70),
        labelLarge: AppTextStyles.inter14Medium.copyWith(color: AppColors.black70),
      ),
      iconTheme: const IconThemeData(color: AppColors.black),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.background,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.black70,
        selectedLabelStyle: AppTextStyles.inter12SemiBold.copyWith(
          color: AppColors.primary,
        ),
        unselectedLabelStyle: AppTextStyles.inter12Medium.copyWith(
          color: AppColors.black70,
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size(0, 45),
          textStyle: AppTextStyles.inter16SemiBold,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size(0, 45),
          textStyle: AppTextStyles.inter16SemiBold,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          textStyle: AppTextStyles.inter14Medium,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.primary;
          return AppColors.black70;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary.withValues(alpha: 0.4);
          }
          return AppColors.black70.withValues(alpha: 0.3);
        }),
      ),
    );
  }
}
