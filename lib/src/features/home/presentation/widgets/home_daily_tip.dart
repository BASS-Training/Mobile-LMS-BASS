import 'package:flutter/material.dart';
import 'package:lms_mobile_app/src/shared/styles/app_colors.dart';
import 'package:lms_mobile_app/src/shared/styles/app_measures.dart';

/// "Tip of the day" micro-content card. Rotates through a curated list of bass
/// practice tips based on the calendar day, giving learners a small, fresh
/// reason to open the app daily — a common engagement pattern in LMS apps.
class HomeDailyTip extends StatelessWidget {
  const HomeDailyTip({super.key});

  static const List<String> _tips = [
    'Mulai latihan dengan metronome pelan, lalu naikkan tempo bertahap setelah bersih.',
    'Fokus pada tangan kanan: konsistensi petikan menentukan groove yang solid.',
    'Latih tangga nada mayor di satu posisi sebelum berpindah fret.',
    'Redam senar yang tidak dimainkan untuk suara bass yang bersih.',
    'Rekam permainanmu — telinga sering menangkap yang jari lewatkan.',
    'Pelajari pola root–fifth dulu sebelum walking bass yang kompleks.',
    'Istirahatkan jari tiap 20 menit agar tidak cedera dan tetap rileks.',
  ];

  String get _todaysTip {
    final now = DateTime.now();
    final dayOfYear = now.difference(DateTime(now.year)).inDays;
    return _tips[dayOfYear % _tips.length];
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppMeasures.paddingLarge),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.textPrimary,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(13),
              ),
              child: const Icon(
                Icons.lightbulb_rounded,
                color: AppColors.warning,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Tips Bass Hari Ini',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text('🎸', style: const TextStyle(fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _todaysTip,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.5,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
