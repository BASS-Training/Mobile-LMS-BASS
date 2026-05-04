import 'package:flutter/material.dart';
import 'package:lms_mobile_app/config/theme.dart';

class StatisticsCard extends StatelessWidget {
  final String title;
  final String number;
  final String description;
  final Color borderColor;
  final Color backgroundColor;
  final String icon;

  const StatisticsCard({
    Key? key,
    required this.title,
    required this.number,
    required this.description,
    required this.borderColor,
    required this.backgroundColor,
    this.icon = '',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: borderColor,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: borderColor.withOpacity(0.1),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Icon and Title
            Row(
              children: [
                if (icon.isNotEmpty)
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: borderColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        icon,
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                if (icon.isNotEmpty) SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: borderColor,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            // Number
            Text(
              number,
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: AppColors.text,
              ),
            ),
            SizedBox(height: 8),
            // Description
            Text(
              description,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textLight,
                height: 1.5,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
