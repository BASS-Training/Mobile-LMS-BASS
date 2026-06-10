import 'package:flutter/material.dart';

/// A small pill-shaped status chip: a tinted background with a matching
/// colored label (and an optional leading icon). Consolidates the
/// `color.withValues(alpha: 0.12)` + rounded-999 + bold colored text pattern
/// that was hand-rolled across the result/score screens.
class AppChip extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;

  const AppChip({
    super.key,
    required this.label,
    required this.color,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
