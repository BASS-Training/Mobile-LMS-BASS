import 'package:flutter/material.dart';
import 'package:lms_mobile_app/src/shared/styles/app_colors.dart';
import 'package:lms_mobile_app/src/shared/styles/app_measures.dart';
import 'package:lms_mobile_app/src/shared/styles/app_shadows.dart';

/// Shown in place of the progress-summary card for brand-new learners who do
/// not own any course yet — an all-zero summary felt empty, so a warm welcome
/// sets a friendlier tone while the "Gabung Kelas" prompt below drives action.
class HomeWelcomeBanner extends StatelessWidget {
  const HomeWelcomeBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppMeasures.paddingLarge),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          // Soft brand-tinted wash (not saturated red) so it feels welcoming
          // and stays easy on the eyes.
          gradient: const LinearGradient(
            colors: [AppColors.brandSurface, AppColors.surface],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.borderSubtle),
          boxShadow: AppShadows.xs,
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.brandPrimary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Center(
                child: Text('👋', style: TextStyle(fontSize: 24)),
              ),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selamat datang di BASS!',
                    style: TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Mulai perjalanan belajarmu — gabung kelas pertamamu dengan token dari instruktur.',
                    style: TextStyle(
                      fontSize: 12.5,
                      height: 1.4,
                      color: AppColors.textSecondary,
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
