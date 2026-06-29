import 'package:flutter/material.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/entities/lesson_attempt_entity.dart';
import 'package:lms_mobile_app/src/shared/styles/app_colors.dart';

class QuizPerformanceOverview extends StatelessWidget {
  final LessonAttempt attempt;

  const QuizPerformanceOverview({super.key, required this.attempt});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.borderSubtle),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final tileWidth = (constraints.maxWidth - 12) / 2;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.analytics_rounded,
                      color: AppColors.red,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ringkasan Hasil',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.charcoal,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Data ditarik langsung dari backend',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.slate,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  // _buildMetricTile(
                  //   width: tileWidth,
                  //   label: 'Nilai',
                  //   value: '${attempt.percentage.toStringAsFixed(0)}%',
                  //   accentColor: AppColors.red,
                  //   icon: Icons.auto_graph_rounded,
                  // ),
                  _buildMetricTile(
                    width: tileWidth,
                    label: 'Benar',
                    value: '${attempt.resolvedCorrectAnswers}',
                    accentColor: Colors.green,
                    icon: Icons.check_circle_rounded,
                  ),
                  _buildMetricTile(
                    width: tileWidth,
                    label: 'Salah',
                    value: '${attempt.resolvedWrongAnswers}',
                    accentColor: Colors.orange,
                    icon: Icons.cancel_rounded,
                  ),
                  _buildMetricTile(
                    width: tileWidth,
                    label: 'Total Soal',
                    value: '${attempt.resolvedTotalQuestions}',
                    accentColor: Colors.blue,
                    icon: Icons.quiz_rounded,
                  ),
                  _buildMetricTile(
                    width: tileWidth,
                    label: 'Passing Grade',
                    value: '${attempt.resolvedPassingGrade}%',
                    accentColor: Colors.purple,
                    icon: Icons.flag_rounded,
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMetricTile({
    required double width,
    required String label,
    required String value,
    required IconData icon,
    required Color accentColor,
  }) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.pearl.withValues(alpha: 0.8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 18, color: accentColor),
          ),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(fontSize: 11, color: AppColors.slate)),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w900,
              color: AppColors.charcoal,
            ),
          ),
        ],
      ),
    );
  }
}
