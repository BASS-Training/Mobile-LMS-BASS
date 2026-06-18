import 'package:flutter/material.dart';
import 'package:lms_mobile_app/src/shared/styles/app_colors.dart';
import 'package:lms_mobile_app/src/shared/styles/app_measures.dart';

/// "Tip of the day" micro-content card. Rotates through a curated list of
/// short learning tips for the Bass academy and app, giving learners a small,
/// fresh reason to open the app daily — a common engagement pattern in LMS apps.
class HomeDailyTip extends StatelessWidget {
  const HomeDailyTip({super.key});

  static const List<String> _tips = [
    'Mulai sesi belajar dengan tujuan kecil dan spesifik untuk konsistensi.',
    'Gunakan timer untuk sesi fokus dan evaluasi progres rutin.',
    'Ulangi materi sebelumnya sebelum menambahkan topik baru.',
    'Praktikkan teknik secara bertahap hingga terasa nyaman.',
    'Rekam latihan atau catat progres untuk melihat perkembangan.',
    'Pecah materi besar menjadi bagian kecil agar tidak kewalahan.',
    'Istirahat singkat setiap 20 menit untuk menjaga konsentrasi.',
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
          color: AppColors.surface,
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
                      Text(
                        'Tips Hari Ini',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text('🎓', style: const TextStyle(fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _todaysTip,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.5,
                      color: AppColors.textPrimary.withValues(alpha: 0.85),
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
