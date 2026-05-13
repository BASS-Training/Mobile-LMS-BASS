import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lms_mobile_app/src/core/config/constants/app_routes.dart';
import 'package:lms_mobile_app/src/features/courses/domain/entities/course_entity.dart';
import 'package:lms_mobile_app/src/features/home/domain/entities/home_stats.entity.dart';
import 'package:lms_mobile_app/src/features/home/presentation/bloc/home_bloc.dart';
import 'package:lms_mobile_app/src/features/home/presentation/bloc/home_event.dart';
import 'package:lms_mobile_app/src/features/home/presentation/bloc/home_state.dart';
import 'package:lms_mobile_app/src/shared/styles/app_colors.dart';
import 'package:lms_mobile_app/src/shared/styles/app_measures.dart';

class HomeExtraSections extends StatelessWidget {
  final TextEditingController tokenController;
  final HomeStatsEntity? stats;
  final List<CourseEntity> completedCourses;

  const HomeExtraSections({
    super.key,
    required this.tokenController,
    required this.stats,
    required this.completedCourses,
  });

  @override
  Widget build(BuildContext context) {
    if (stats == null) return const SizedBox.shrink();

    final lessonText = '${stats!.completedLessons}/${stats!.totalLessons}';
    final quizText = stats!.totalQuizzes > 0
        ? '${stats!.completedQuizzes}/${stats!.totalQuizzes}'
        : '0/0';

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppMeasures.paddingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildModernCard(
            title: 'Statistik belajar',
            icon: Icons.insights_rounded,
            gradient: const LinearGradient(
              colors: [Color(0xFFEAF4FF), Color(0xFFDDF0FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            child: Column(
              children: [
                _buildMetricRowModern('Pelajaran Selesai', lessonText),
                const SizedBox(height: 8),
                _buildMetricRowModern('Kuis Selesai', quizText),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _buildModernCard(
            title: 'Gabung Kelas',
            icon: Icons.groups_2_rounded,
            gradient: const LinearGradient(
              colors: [Color(0xFFEFFFEF), Color(0xFFE1F8E1)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.emerald.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'Status Verifikasi AVPN: APPROVED',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.emerald,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Token Pendaftaran',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.charcoal,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: tokenController,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    hintText: 'Contoh: KLS-2026-AB12',
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    suffixIcon: const Icon(
                      Icons.vpn_key_rounded,
                      color: AppColors.violet,
                      size: 18,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                BlocBuilder<HomeBloc, HomeState>(
                  builder: (context, homeState) {
                    final isSubmitting = homeState is HomeJoinClassLoading;

                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: isSubmitting
                            ? null
                            : () {
                                final token = tokenController.text.trim();
                                context.read<HomeBloc>().add(
                                  SubmitJoinClassTokenEvent(token),
                                );
                              },
                        icon: isSubmitting
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.send_rounded, size: 16),
                        label: Text(
                          isSubmitting ? 'Mengirim...' : 'Kirim Token',
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          backgroundColor: AppColors.violet,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _buildModernCard(
            title: 'Sertifikat saya',
            icon: Icons.workspace_premium_rounded,
            trailing: GestureDetector(
              onTap: () {
                context.push(AppRoutes.certificateList);
              },
              child: Text(
                'Lihat daftar sertifikat',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.indigo,
                  fontWeight: FontWeight.w700,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            gradient: const LinearGradient(
              colors: [Color(0xFFFFF6E7), Color(0xFFFFEED3)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            child: completedCourses.isEmpty
                ? Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white),
                    ),
                    child: Text(
                      'Belum ada sertifikat. Selesaikan course sampai 100% untuk mendapatkan sertifikat.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.slate,
                        height: 1.4,
                      ),
                    ),
                  )
                : Column(
                    children: completedCourses.map((course) {
                      return GestureDetector(
                        onTap: () {
                          context.push(
                            AppRoutes.certificateDetail,
                            extra: course,
                          );
                        },
                        child: Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.72),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                course.title,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.charcoal,
                                  height: 1.3,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    Icons.verified_rounded,
                                    size: 14,
                                    color: AppColors.emerald,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Sertifikat tersedia',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.slate,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernCard({
    required String title,
    required IconData icon,
    required LinearGradient gradient,
    required Widget child,
    Widget? trailing,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.charcoal),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.charcoal,
                    ),
                  ),
                ),
                if (trailing != null) trailing,
              ],
            ),
            const SizedBox(height: 14),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildMetricRowModern(String label, String value) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.slate,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: AppColors.charcoal,
          ),
        ),
      ],
    );
  }
}
