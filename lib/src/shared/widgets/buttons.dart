import 'package:flutter/material.dart';
import '../styles/app_colors.dart';
import '../styles/app_measures.dart';
import '../styles/app_typography.dart';

/// Primary button widget - untuk aksi utama
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isEnabled;
  final double? width;
  final IconData? icon;

  const PrimaryButton({
    Key? key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
    this.width,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: ElevatedButton.icon(
        onPressed: isEnabled && !isLoading ? onPressed : null,
        icon: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isEnabled ? Colors.white : AppColors.silver,
                  ),
                ),
              )
            : (icon != null ? Icon(icon) : SizedBox.shrink()),
        label: Text(label),
      ),
    );
  }
}

/// Secondary button widget
class SecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isEnabled;
  final double? width;
  final IconData? icon;

  const SecondaryButton({
    Key? key,
    required this.label,
    required this.onPressed,
    this.isEnabled = true,
    this.width,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: OutlinedButton.icon(
        onPressed: isEnabled ? onPressed : null,
        icon: icon != null ? Icon(icon) : SizedBox.shrink(),
        label: Text(label),
      ),
    );
  }
}

/// Text button widget - untuk aksi sekunder
class TextActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final Color color;

  const TextActionButton({
    Key? key,
    required this.label,
    required this.onPressed,
    this.color = AppColors.violet,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: Text(
        label,
        style: AppTypography.titleMedium.copyWith(color: color),
      ),
    );
  }
}

