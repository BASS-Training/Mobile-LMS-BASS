import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Typography constants untuk consistent text styling
class AppTypography {
  // Display styles (Heading besar)
  static const TextStyle displayLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.text,
    height: 1.2,
  );

  static const TextStyle displayMedium = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.text,
    height: 1.2,
  );

  static const TextStyle displaySmall = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.text,
    height: 1.2,
  );

  // Heading styles
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.text,
    height: 1.4,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.text,
    height: 1.4,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.text,
    height: 1.4,
  );

  // Title styles
  static const TextStyle titleLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.text,
    height: 1.5,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.text,
    height: 1.5,
  );

  static const TextStyle titleSmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.text,
    height: 1.5,
  );

  // Body styles (untuk konten utama)
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.text,
    height: 1.6,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textLight,
    height: 1.6,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textLighter,
    height: 1.6,
  );

  // Label styles
  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.text,
    height: 1.5,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.text,
    height: 1.5,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppColors.textLight,
    height: 1.5,
  );

  // Button text styles
  static const TextStyle buttonText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    height: 1.5,
  );

  static const TextStyle buttonTextSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.5,
  );
}
