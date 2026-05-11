import 'package:flutter/material.dart';
import '../styles/styles.dart';

/// Generic reusable card widget dengan gradient header
/// Replaces: CourseCard dan similar card widgets
class AppGradientCard extends StatelessWidget {
  /// Card title
  final String title;

  /// Card description/subtitle
  final String? description;

  /// Gradient colors untuk header
  final List<Color> gradientColors;

  /// Icon/emoji untuk header
  final String? icon;

  /// Icon size
  final double iconSize;

  /// Header height
  final double headerHeight;

  /// Additional metadata (bisa untuk lessons count, duration, dll)
  final Map<String, String>? metadata;

  /// Callback saat card di-tap
  final VoidCallback onTap;

  /// Callback untuk action button (e.g., bookmark)
  final VoidCallback? onActionPressed;

  /// Action button icon (e.g., bookmark icon)
  final IconData? actionIcon;

  /// Is action button filled/active
  final bool isActionFilled;

  /// Custom content widget (di bawah header)
  final Widget? contentWidget;

  /// Background color body
  final Color bodyColor;

  const AppGradientCard({
    super.key,
    required this.title,
    this.description,
    required this.gradientColors,
    this.icon,
    this.iconSize = 44,
    this.headerHeight = 120,
    this.metadata,
    required this.onTap,
    this.onActionPressed,
    this.actionIcon,
    this.isActionFilled = false,
    this.contentWidget,
    this.bodyColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header dengan gradient
            Container(
              height: headerHeight,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: gradientColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Stack(
                children: [
                  // Icon di kanan
                  if (icon != null)
                    Positioned(
                      right: 16,
                      top: 16,
                      child: Text(icon!, style: TextStyle(fontSize: iconSize)),
                    ),

                  // Action button
                  if (onActionPressed != null && actionIcon != null)
                    Positioned(
                      right: 16,
                      bottom: 12,
                      child: GestureDetector(
                        onTap: onActionPressed,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: Icon(
                            actionIcon,
                            color: AppColors.primary,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Body
            Expanded(
              child: Container(
                color: bodyColor,
                padding: const EdgeInsets.all(12),
                child:
                    contentWidget ??
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Title
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.text,
                          ),
                        ),

                        // Description
                        if (description != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            description!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textLight,
                            ),
                          ),
                        ],

                        // Metadata
                        if (metadata != null && metadata!.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: metadata!.entries
                                .toList()
                                .asMap()
                                .entries
                                .map((entry) {
                                  final isLast =
                                      entry.key == metadata!.entries.length - 1;
                                  final value = entry.value;

                                  return Expanded(
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          value.value,
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: AppColors.textLight,
                                          ),
                                        ),
                                        if (!isLast) const SizedBox(width: 8),
                                      ],
                                    ),
                                  );
                                })
                                .toList(),
                          ),
                        ],
                      ],
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Helper untuk create gradient colors dari hex
LinearGradient createGradientFromHex(String hexColor) {
  final color = Color(int.parse(hexColor.replaceFirst('#', '0xFF')));
  return LinearGradient(
    colors: [color, color.withOpacity(0.7)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
