import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lms_mobile_app/src/core/config/constants/app_routes.dart';
import 'package:lms_mobile_app/src/features/instructor/domain/entities/instructor_entities.dart';
import 'package:lms_mobile_app/src/features/instructor/presentation/cubit/instructor_overview_cubit.dart';
import 'package:lms_mobile_app/src/shared/styles/app_colors.dart';
import 'package:lms_mobile_app/src/shared/styles/app_measures.dart';
import 'package:lms_mobile_app/src/shared/styles/app_shadows.dart';
import 'package:lms_mobile_app/src/shared/widgets/press_scale.dart';

/// Hero "Lanjutkan Mengoreksi" untuk instruktur/admin — cermin visual dari
/// [HomeContinueLearning] milik peserta, tapi alih-alih melanjutkan belajar,
/// mengarahkan ke halaman Penugasan (antrian penilaian). Menyorot kelas dengan
/// tumpukan koreksi terbanyak.
class HomeContinueGrading extends StatelessWidget {
  final InstructorDashboard? dashboard;
  final InstructorStatus status;

  const HomeContinueGrading({
    super.key,
    required this.dashboard,
    required this.status,
  });

  void _openGrading(BuildContext context) {
    context.push(AppRoutes.instructorGradingQueue, extra: {'courseId': ''});
  }

  @override
  Widget build(BuildContext context) {
    final loading =
        status == InstructorStatus.loading ||
        status == InstructorStatus.initial;
    final pending = dashboard?.pendingGrading ?? 0;

    // Kelas dengan tumpukan koreksi terbanyak dijadikan sorotan.
    final courses = [
      ...(dashboard?.courses ?? const <InstructorCourseSummary>[]),
    ]..sort((a, b) => b.pendingCount.compareTo(a.pendingCount));
    final top = courses.isNotEmpty && courses.first.pendingCount > 0
        ? courses.first
        : null;
    final allDone = !loading && pending == 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppMeasures.paddingLarge),
      child: PressScale(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _openGrading(context),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: AppColors.brandGradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: AppShadows.brand(AppColors.brandPrimary, opacity: 0.18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _overline('LANJUTKAN MENGOREKSI'),
                    const Spacer(),
                    if (!loading && pending > 0) _pendingBadge(pending),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _iconBadge(),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            loading
                                ? 'Memuat tugas peserta…'
                                : allDone
                                ? 'Semua tugas sudah dinilai 🎉'
                                : '$pending tugas menunggu koreksi',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            loading
                                ? 'Menyiapkan antrian penilaian'
                                : top != null
                                ? 'Terbanyak di ${top.title}'
                                : 'Tinjau & beri nilai submission peserta',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12.5,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                _button(context, allDone),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _overline(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 10.5,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.2,
        color: Colors.white.withValues(alpha: 0.85),
      ),
    );
  }

  Widget _pendingBadge(int pending) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$pending perlu nilai',
        style: const TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _iconBadge() {
    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
      ),
      child: const Center(
        child: Icon(Icons.rate_review_rounded, color: Colors.white, size: 28),
      ),
    );
  }

  Widget _button(BuildContext context, bool allDone) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _openGrading(context),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              allDone ? Icons.history_rounded : Icons.rate_review_rounded,
              color: AppColors.brandText,
              size: 20,
            ),
            const SizedBox(width: 6),
            Text(
              allDone ? 'Lihat Penilaian' : 'Koreksi Sekarang',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: AppColors.brandText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
