import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lms_mobile_app/src/core/config/constants/app_routes.dart';
import 'package:lms_mobile_app/src/core/utils/local_storage.dart';
import 'package:lms_mobile_app/src/features/courses/presentation/widgets/course_detail_header.dart';
import 'package:lms_mobile_app/src/features/courses/presentation/widgets/course_info_cards.dart';
import 'package:lms_mobile_app/src/features/courses/presentation/widgets/course_section_accordion.dart';
import 'package:lms_mobile_app/src/shared/styles/app_colors.dart';
import 'package:lms_mobile_app/src/shared/styles/app_measures.dart';
import 'package:lms_mobile_app/src/shared/widgets/progress_indicator.dart';
import '../../domain/entities/course_entity.dart';
import '../bloc/course/course_bloc.dart';
import '../bloc/course/course_state.dart';

class CourseDetailScreen extends StatefulWidget {
  final CourseEntity course;

  const CourseDetailScreen({super.key, required this.course});

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  @override
  void initState() {
    super.initState();
    LocalStorage.recordRecentCourse(widget.course.id);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CourseBloc, CourseState>(
      builder: (context, state) {
        CourseEntity currentCourseEntity = widget.course;
        if (state is CourseLoaded) {
          currentCourseEntity = state.courses.firstWhere(
            (c) => c.id == widget.course.id,
            orElse: () => widget.course,
          );
        }

        return Scaffold(
          backgroundColor: AppColors.mist,
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Header (Gambar & Tombol atas)
                CourseDetailHeader(course: currentCourseEntity),

                Padding(
                  padding: const EdgeInsets.all(AppMeasures.paddingLarge),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 2. Info Cards (Instruktur & Durasi)
                      CourseInfoCards(course: currentCourseEntity),
                      const SizedBox(height: 24),

                      // 3. Deskripsi
                      const Text(
                        'About Course',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.charcoal,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        currentCourseEntity.description,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.slate,
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // 4. Progress Keseluruhan
                      CourseProgressIndicator(
                        progress: currentCourseEntity.progressPercentage,
                        label: 'Your Progress',
                        showPercentage: true,
                      ),
                      const SizedBox(height: 24),

                      // 5. Tombol Nilai
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: () => context.push(
                            AppRoutes.courseResults,
                            extra: currentCourseEntity,
                          ),
                          icon: const Icon(Icons.assessment_outlined),
                          label: const Text('Nilai & Hasil'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.violet,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // 6. Daftar Section dan Materi
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Sections',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.charcoal,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.violet.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${currentCourseEntity.completedLessons}/${currentCourseEntity.totalLessons}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.violet,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Loop Accordion
                      ...currentCourseEntity.sections.map((section) {
                        return CourseSectionAccordion(
                          section: section,
                          course: currentCourseEntity,
                        );
                      }),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
