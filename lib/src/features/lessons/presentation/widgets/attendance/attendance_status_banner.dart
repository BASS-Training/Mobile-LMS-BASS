import 'package:flutter/material.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/entities/lesson_entity.dart';
import 'package:lms_mobile_app/src/shared/styles/app_colors.dart';

/// Info kehadiran (attendance) untuk sebuah lesson. Bila admin mengaktifkan
/// "Require Attendance" di web, peserta tidak bisa melanjutkan ke lesson
/// berikutnya sampai instruktur menandai kehadirannya (present/excused).
///
/// Helper terpusat agar teks status & alasan blokir konsisten di semua layar.
class AttendanceInfo {
  const AttendanceInfo._();

  /// Label status yang ramah untuk peserta.
  static String statusLabel(String? status) {
    switch (status) {
      case 'present':
        return 'Hadir';
      case 'excused':
        return 'Izin';
      case 'late':
        return 'Terlambat';
      case 'absent':
        return 'Tidak Hadir';
      default:
        return 'Menunggu konfirmasi';
    }
  }

  /// Alasan mengapa tombol "Lanjut" terkunci (untuk snackbar / banner).
  static String blockedReason(LessonEntity lesson) {
    switch (lesson.attendanceStatus) {
      case 'late':
        return 'Kehadiran Anda ditandai "Terlambat". Hubungi instruktur agar bisa melanjutkan.';
      case 'absent':
        return 'Kehadiran Anda ditandai "Tidak Hadir". Anda belum bisa melanjutkan ke materi berikutnya.';
      default:
        return 'Menunggu konfirmasi kehadiran dari instruktur sebelum Anda bisa melanjutkan.';
    }
  }
}

/// Banner yang menampilkan status kehadiran pada lesson yang mewajibkannya.
/// Hijau bila sudah hadir/izin; kuning bila masih menunggu / bermasalah.
class AttendanceStatusBanner extends StatelessWidget {
  final LessonEntity lesson;

  const AttendanceStatusBanner({super.key, required this.lesson});

  @override
  Widget build(BuildContext context) {
    if (!lesson.attendanceRequired) return const SizedBox.shrink();

    final ok = !lesson.attendancePending; // present / excused
    final Color surface = ok
        ? AppColors.successSurface
        : AppColors.warningSurface;
    final Color border = ok ? AppColors.successBorder : AppColors.warningBorder;
    final Color fg = ok ? AppColors.successText : AppColors.warningText;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                ok ? Icons.verified_rounded : Icons.how_to_reg_rounded,
                color: fg,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  ok
                      ? 'Kehadiran terkonfirmasi: ${AttendanceInfo.statusLabel(lesson.attendanceStatus)}'
                      : 'Kehadiran diperlukan • ${AttendanceInfo.statusLabel(lesson.attendanceStatus)}',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: fg,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            ok
                ? 'Anda sudah dapat melanjutkan ke materi berikutnya.'
                : AttendanceInfo.blockedReason(lesson),
            style: TextStyle(fontSize: 12.5, height: 1.4, color: fg),
          ),
          if (lesson.minAttendanceMinutes != null &&
              lesson.minAttendanceMinutes! > 0) ...[
            const SizedBox(height: 4),
            Text(
              'Minimal kehadiran: ${lesson.minAttendanceMinutes} menit.',
              style: TextStyle(
                fontSize: 12,
                color: fg.withValues(alpha: 0.85),
              ),
            ),
          ],
          if ((lesson.attendanceNotes ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.surface.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                lesson.attendanceNotes!.trim(),
                style: TextStyle(
                  fontSize: 12.5,
                  height: 1.4,
                  color: AppColors.charcoal,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
