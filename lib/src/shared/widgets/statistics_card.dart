import 'package:flutter/material.dart';
import 'package:lms_mobile_app/src/shared/styles/app_colors.dart';

class StatisticsCard extends StatelessWidget {
  final String title;
  final String number;
  final String description;
  final Color borderColor;
  final Color backgroundColor;
  final String icon;

  const StatisticsCard({
    super.key,
    required this.title,
    required this.number,
    required this.description,
    required this.borderColor,
    required this.backgroundColor,
    this.icon = '',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor.withValues(alpha: 0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: borderColor.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Left accent bar
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Container(
              width: 6,
              decoration: BoxDecoration(
                color: borderColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
            ),
          ),
          // Content
          Padding(
            padding: EdgeInsets.fromLTRB(20, 16, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Title
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w600,
                    color: AppColors.slate,
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: 4),
                // Icon and Number Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (icon.isNotEmpty)
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: borderColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(icon, style: TextStyle(fontSize: 24)),
                        ),
                      ),
                    if (icon.isNotEmpty) SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        number,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: AppColors.charcoal,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                // Description
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.slate,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
