// ignore_for_file: use_null_aware_elements

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
    return switch (stats) {
      null => const SizedBox.shrink(),
      final currentStats => Padding(
        padding: EdgeInsets.symmetric(horizontal: AppMeasures.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildModernCard(
              title: 'Statistik belajar',
              icon: Icons.insights_rounded,
              color: AppColors.bubblegum,
              child: Column(
                children: [
                  _buildMetricRowModern(
                    'Pelajaran Selesai',
                    '${currentStats.completedLessons}/${currentStats.totalLessons}',
                  ),
                  const SizedBox(height: 8),
                  _buildMetricRowModern(
                    'Kuis Selesai',
                    currentStats.totalQuizzes > 0
                        ? '${currentStats.completedQuizzes}/${currentStats.totalQuizzes}'
                        : '0/0',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            _buildModernCard(
              title: 'Gabung Course',
              icon: Icons.groups_2_rounded,
              color: const Color(0xFFFFF8E7),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.cherry.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      'Status Verifikasi AVPN: APPROVED',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.cherry,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Token Course',
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
                      hintText: 'Masukkan token course',
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      suffixIcon: const Icon(
                        Icons.vpn_key_rounded,
                        color: AppColors.cherry,
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
                            backgroundColor: AppColors.cherry,
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
                    color: AppColors.cherry,
                    fontWeight: FontWeight.w700,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              color: const Color(0xFFFFF7F4),
              child: completedCourses.isEmpty
                  ? Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.7),
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
                              color: Colors.white.withValues(alpha: 0.72),
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
                                      color: AppColors.cherry,
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
      ),
    };
  }

  Widget _buildModernCard({
    required String title,
    required IconData icon,
    required Color color,
    required Widget child,
    Widget? trailing,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 2,
            offset: const Offset(4, 4),
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
