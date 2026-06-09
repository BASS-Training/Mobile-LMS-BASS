import 'package:flutter/material.dart';
import 'package:lms_mobile_app/src/shared/styles/app_colors.dart';

/// Three-stop progress indicator for the registration wizard. Driven purely by
/// [currentStep] (1-based) and the [labels] for each step.
class RegisterStepProgress extends StatelessWidget {
  final int currentStep;
  final List<String> labels;

  const RegisterStepProgress({
    super.key,
    required this.currentStep,
    required this.labels,
  });

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    for (var i = 0; i < labels.length; i++) {
      final stepNumber = i + 1;
      children.add(_chip(stepNumber, labels[i]));
      if (i < labels.length - 1) {
        children.add(_connector(active: currentStep > stepNumber));
      }
    }
    return Row(children: children);
  }

  Widget _chip(int index, String label) {
    final isActive = currentStep >= index;
    final isCompleted = currentStep > index;

    return Expanded(
      child: Column(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color:
                  isActive ? Colors.white : Colors.white.withValues(alpha: 0.2),
              border: Border.all(
                color: isActive ? Colors.white : Colors.white54,
                width: 2,
              ),
            ),
            child: Center(
              child: isCompleted
                  ? const Icon(Icons.check, size: 22, color: AppColors.brandPrimary)
                  : Text(
                      '$index',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: isActive ? AppColors.brandPrimary : Colors.white,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: isActive ? Colors.white : Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _connector({required bool active}) {
    return Expanded(
      flex: 2,
      child: Container(
        margin: const EdgeInsets.only(bottom: 24),
        height: 2,
        decoration: BoxDecoration(
          color: active ? Colors.white : Colors.white38,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
