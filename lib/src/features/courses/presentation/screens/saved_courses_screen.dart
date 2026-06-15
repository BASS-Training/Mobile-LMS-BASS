import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lms_mobile_app/src/core/config/constants/app_routes.dart';
import 'package:lms_mobile_app/src/features/courses/domain/entities/course_entity.dart';
import 'package:lms_mobile_app/src/features/courses/presentation/bloc/course/course_bloc.dart';
import 'package:lms_mobile_app/src/features/courses/presentation/bloc/course/course_event.dart';
import 'package:lms_mobile_app/src/features/courses/presentation/bloc/course/course_state.dart';
import 'package:lms_mobile_app/src/features/courses/presentation/widgets/course_accent.dart';
import 'package:lms_mobile_app/src/shared/styles/app_colors.dart';
import 'package:lms_mobile_app/src/shared/styles/app_shadows.dart';
import 'package:lms_mobile_app/src/shared/widgets/app_empty_state.dart';
import 'package:lms_mobile_app/src/shared/widgets/brand_app_bar.dart';
import 'package:lms_mobile_app/src/shared/widgets/press_scale.dart';

class SavedCoursesScreen extends StatefulWidget {
  const SavedCoursesScreen({super.key});

  @override
  State<SavedCoursesScreen> createState() => _SavedCoursesScreenState();
}

class _SavedCoursesScreenState extends State<SavedCoursesScreen> {
  @override
  void initState() {
    super.initState();
    context.read<CourseBloc>().add(const GetSavedCoursesEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const BrandAppBar(title: 'Kursus Tersimpan'),
      body: BlocBuilder<CourseBloc, CourseState>(
        builder: (context, state) {
          if (state is CourseLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.brandPrimary),
            );
          }
          if (state is SavedCoursesLoaded) {
            final savedCourses = state.courses;
            if (savedCourses.isEmpty) {
              return AppEmptyState(
                illustration: 'assets/illustrations/empty_collection.svg',
                title: 'Koleksimu masih kosong',
                message:
                    'Simpan kursus favoritmu dengan menekan ikon bookmark agar mudah ditemukan kembali di sini.',
                actionLabel: 'Jelajahi Kursus',
                onAction: () => context.push(AppRoutes.courses),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: savedCourses.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return _SavedCourseTile(course: savedCourses[index]);
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _SavedCourseTile extends StatelessWidget {
  final CourseEntity course;

  const _SavedCourseTile({required this.course});

  @override
  Widget build(BuildContext context) {
    return PressScale(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => context.push(AppRoutes.courseDetail, extra: course),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.borderSubtle),
            boxShadow: AppShadows.sm,
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: CourseAccent.of(course.id).gradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    course.icon,
                    style: const TextStyle(fontSize: 30),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      course.instructor,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.menu_book_rounded,
                          size: 13,
                          color: AppColors.textTertiary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${course.totalLessons} lesson',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

