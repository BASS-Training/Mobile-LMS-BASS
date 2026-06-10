import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms_mobile_app/src/features/certificates/presentation/widgets/certificate_list_tile.dart';
import 'package:lms_mobile_app/src/features/courses/presentation/bloc/course/course_bloc.dart';
import 'package:lms_mobile_app/src/features/courses/presentation/bloc/course/course_state.dart';
import 'package:lms_mobile_app/src/shared/styles/app_colors.dart';
import 'package:lms_mobile_app/src/shared/widgets/app_empty_state.dart';
import 'package:lms_mobile_app/src/shared/widgets/brand_app_bar.dart';
import 'package:lms_mobile_app/src/shared/widgets/fade_slide_in.dart';

class CertificateListScreen extends StatelessWidget {
  const CertificateListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const BrandAppBar(title: 'Sertifikat Saya'),
      body: BlocBuilder<CourseBloc, CourseState>(
        builder: (context, state) {
          if (state is CourseLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.brandPrimary),
            );
          }

          if (state is CourseLoaded) {
            final completedCourses = state.courses
                .where((c) => c.progressPercentage == 100)
                .toList();

            if (completedCourses.isEmpty) {
              return const AppEmptyState(
                icon: Icons.workspace_premium_rounded,
                iconColor: AppColors.warning,
                title: 'Belum ada sertifikat',
                message:
                    'Selesaikan sebuah kursus hingga 100% untuk membuka sertifikat resmimu di sini.',
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
              itemCount: completedCourses.length + 1,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _CountHeader(count: completedCourses.length);
                }
                final course = completedCourses[index - 1];
                return FadeSlideIn(
                  delayMs: index * 40,
                  child: CertificateListTile(course: course),
                );
              },
            );
          }

          if (state is CourseFailure) {
            return Center(child: Text(state.message));
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _CountHeader extends StatelessWidget {
  final int count;

  const _CountHeader({required this.count});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          const Icon(
            Icons.emoji_events_rounded,
            color: AppColors.warning,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            '$count sertifikat diraih',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

