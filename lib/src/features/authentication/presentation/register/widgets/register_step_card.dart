import 'package:flutter/material.dart';
import 'package:lms_mobile_app/src/shared/styles/app_colors.dart';

/// Shared frame for a registration step: a title, a subtitle, and the step's
/// fields. Centralises the heading layout so each step widget only declares its
/// own content.
class RegisterStepCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Widget> children;

  const RegisterStepCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textTertiary,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 20),
        ...children,
      ],
    );
  }
}

/// Small bold caption above a group of inputs/choices within a step.
class RegisterSectionLabel extends StatelessWidget {
  final String text;

  const RegisterSectionLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: AppColors.textSecondary,
      ),
    );
  }
}
