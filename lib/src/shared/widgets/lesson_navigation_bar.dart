import 'package:flutter/material.dart';
import 'package:lms_mobile_app/src/shared/styles/app_colors.dart';
import 'package:lms_mobile_app/src/shared/styles/app_shadows.dart';
import 'package:lms_mobile_app/src/shared/widgets/press_scale.dart';

/// Standard bottom navigation bar used by all lesson screens that have
/// a simple Previous / (Next | Selesai) flow.
///
/// Screens with custom flow (quiz questions, essay answers) can still
/// use this as a base or compose their own controls on top.
class LessonNavigationBar extends StatelessWidget {
  final bool canGoPrevious;
  final bool canGoNext;
  final VoidCallback? onPrevious;
  final VoidCallback onForward;
  final Color primaryColor;

  /// Bila true, tombol maju terkunci (mis. menunggu ACC kehadiran instruktur).
  /// Menekannya menampilkan [blockedReason] alih-alih memanggil [onForward].
  final bool forwardBlocked;
  final String? blockedReason;

  /// Label tombol saat terkunci. Default "Menunggu Dinilai" (kasus pengumpulan
  /// tugas). Layar lain bisa memberi label lebih tepat, mis. "Menunggu
  /// Kehadiran" atau "Selesaikan Kuis".
  final String? blockedLabel;

  const LessonNavigationBar({
    super.key,
    required this.canGoPrevious,
    required this.canGoNext,
    this.onPrevious,
    required this.onForward,
    this.primaryColor = AppColors.brandPrimary,
    this.forwardBlocked = false,
    this.blockedReason,
    this.blockedLabel,
  });

  /// Gaya tombol "Sebelumnya" yang seragam untuk SEMUA layar lesson:
  /// outline + teks merah (brandText, agar terbaca di dark mode). Dipakai juga
  /// oleh bar kustom (quiz/essay/feedback) supaya tampilannya konsisten.
  static ButtonStyle previousButtonStyle() => OutlinedButton.styleFrom(
    side: BorderSide(color: AppColors.brandText, width: 1.5),
    foregroundColor: AppColors.brandText,
    backgroundColor: AppColors.surface,
    padding: const EdgeInsets.symmetric(vertical: 14),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
  );

  /// Gaya tombol maju "Lanjut/Selesai" yang seragam: solid merah, teks putih.
  static ButtonStyle forwardButtonStyle([
    Color color = AppColors.brandPrimary,
  ]) => ElevatedButton.styleFrom(
    backgroundColor: color,
    foregroundColor: Colors.white,
    shadowColor: color.withValues(alpha: 0.45),
    elevation: 8,
    padding: const EdgeInsets.symmetric(vertical: 14),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
  );

  void _showBlocked(BuildContext context) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            blockedReason ??
                'Menunggu konfirmasi kehadiran dari instruktur sebelum Anda bisa melanjutkan.',
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.borderSubtle),
        boxShadow: AppShadows.sm,
      ),
      child: Row(
        children: [
          if (canGoPrevious) ...[
            Expanded(
              child: PressScale(
                child: OutlinedButton.icon(
                  onPressed: onPrevious,
                  icon: const Icon(Icons.arrow_back_rounded),
                  label: const Text('Sebelumnya'),
                  style: previousButtonStyle(),
                ),
              ),
            ),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: PressScale(
              child: ElevatedButton.icon(
                onPressed: forwardBlocked
                    ? () => _showBlocked(context)
                    : onForward,
                style: forwardButtonStyle(
                  forwardBlocked ? AppColors.slate : primaryColor,
                ),
                icon: Icon(
                  forwardBlocked
                      ? Icons.lock_outline_rounded
                      : (canGoNext
                            ? Icons.arrow_forward_rounded
                            : Icons.check_rounded),
                ),
                label: Text(
                  forwardBlocked
                      ? (blockedLabel ?? 'Menunggu Dinilai')
                      : (canGoNext ? 'Lanjut' : 'Selesai'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
