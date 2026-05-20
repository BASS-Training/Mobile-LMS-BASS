import 'package:flutter/material.dart';
import 'package:lms_mobile_app/src/shared/widgets/fade_slide_in.dart';
import 'package:lms_mobile_app/src/shared/styles/app_colors.dart';

/// Widget untuk menampilkan kartu instruksi kuis
class InstructionCardWidget extends StatelessWidget {
  const InstructionCardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return FadeSlideIn(
      delayMs: 40,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.red.withValues(alpha: 0.08),
              AppColors.tomato.withValues(alpha: 0.06),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.red.withValues(alpha: 0.16)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: AppColors.red.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.info_outline,
                    color: AppColors.red,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Instruksi Kuis',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.charcoal,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Baca pertanyaan dengan seksama dan pilih salah satu jawaban. Pastikan koneksi internet Anda stabil.',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.slate,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
