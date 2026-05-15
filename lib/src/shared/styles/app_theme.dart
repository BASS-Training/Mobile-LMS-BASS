import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';
import 'app_measures.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      visualDensity: VisualDensity.standard,
      colorScheme: ColorScheme.light(
        primary: AppColors.violet,
        secondary: AppColors.azure,
        surface: AppColors.white,
        error: AppColors.crimson,
      ),
      scaffoldBackgroundColor: const Color(0xFFFFF7F4),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppTypography.displaySmall,
        iconTheme: const IconThemeData(color: AppColors.charcoal),
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        color: AppColors.white,
        elevation: AppMeasures.elevationMedium,
        shadowColor: Colors.black.withValues(alpha: 0.08),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppMeasures.radiusLarge),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: AppColors.pearl.withValues(alpha: 0.7),
        thickness: 1,
        space: AppMeasures.paddingLarge,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.cloud,
        labelStyle: AppTypography.titleMedium.copyWith(
          color: AppColors.charcoal,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppMeasures.radiusCircle),
        ),
        side: BorderSide(color: AppColors.pearl.withValues(alpha: 0.8)),
      ),
      textTheme: TextTheme(
        displayLarge: AppTypography.displayLarge,
        displayMedium: AppTypography.displayMedium,
        displaySmall: AppTypography.displaySmall,
        headlineSmall: AppTypography.headlineSmall,
        titleLarge: AppTypography.titleLarge,
        titleMedium: AppTypography.titleMedium,
        bodyLarge: AppTypography.bodyLarge,
        bodyMedium: AppTypography.bodyMedium,
        bodySmall: AppTypography.bodySmall,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppMeasures.paddingLarge,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppMeasures.radiusMedium),
          borderSide: const BorderSide(color: AppColors.pearl),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppMeasures.radiusMedium),
          borderSide: const BorderSide(color: AppColors.pearl),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppMeasures.radiusMedium),
          borderSide: const BorderSide(color: AppColors.violet, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppMeasures.radiusMedium),
          borderSide: const BorderSide(color: AppColors.crimson),
        ),
        hintStyle: AppTypography.bodyMedium,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.violet,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(
            horizontal: AppMeasures.paddingXLarge,
            vertical: 14,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppMeasures.radiusMedium),
          ),
          elevation: AppMeasures.elevationMedium,
          textStyle: AppTypography.titleLarge.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.violet,
        foregroundColor: Colors.white,
        elevation: AppMeasures.elevationLarge,
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.violet,
          side: const BorderSide(color: AppColors.violet),
          padding: const EdgeInsets.symmetric(
            horizontal: AppMeasures.paddingXLarge,
            vertical: 14,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppMeasures.radiusMedium),
          ),
        ),
      ),
    );
  }
}
