import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lms_mobile_app/src/core/config/constants/app_routes.dart';
import 'package:lms_mobile_app/src/core/config/constants/app_strings.dart';
import 'package:lms_mobile_app/src/features/authentication/presentation/bloc/auth/auth_bloc.dart';
import 'package:lms_mobile_app/src/features/authentication/presentation/bloc/auth/auth_state.dart';
import 'package:lms_mobile_app/src/features/courses/domain/entities/course_entity.dart';
import 'package:lms_mobile_app/src/features/courses/presentation/bloc/course/course_bloc.dart';
import 'package:lms_mobile_app/src/features/courses/presentation/bloc/course/course_event.dart';
import 'package:lms_mobile_app/src/features/courses/presentation/bloc/course/course_state.dart';
import 'package:lms_mobile_app/src/features/courses/presentation/widgets/course_card.dart';
import 'package:lms_mobile_app/src/shared/styles/app_colors.dart';
import 'package:lms_mobile_app/src/shared/styles/app_measures.dart';

class CourseListScreen extends StatefulWidget {
  const CourseListScreen({super.key});

  @override
  State<CourseListScreen> createState() => _CourseListScreenState();
}

class _CourseListScreenState extends State<CourseListScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<CourseBloc>().add(const GetCoursesEvent());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final isInstructor =
            authState is AuthSuccess &&
            (authState.user.hasRole('instructor') ||
                authState.user.hasRole('admin') ||
                authState.user.hasRole('super-admin'));

        return Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: const Text('All Courses'),
            elevation: 0,
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.tomato, AppColors.red],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          floatingActionButton: isInstructor
              ? FloatingActionButton.extended(
                  onPressed: () => _showAddCourseDialog(context),
                  backgroundColor: AppColors.charcoal,
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Tambah Kursus'),
                )
              : null,
          body: Stack(
            children: [
              const _CourseListBackdrop(),
              Column(
                children: [
                  if (isInstructor)
                    Container(
                      width: double.infinity,
                      margin: EdgeInsets.fromLTRB(
                        AppMeasures.paddingLarge,
                        AppMeasures.paddingLarge,
                        AppMeasures.paddingLarge,
                        0,
                      ),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.charcoal,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Text(
                        'Mode pengelola aktif. Tambah kursus baru akan langsung tersinkron ke peserta lewat Laravel.',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  Padding(
                    padding: EdgeInsets.all(AppMeasures.paddingLarge),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.86),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.pearl.withValues(alpha: 0.8),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ValueListenableBuilder<TextEditingValue>(
                        valueListenable: _searchController,
                        builder: (context, value, _) {
                          return TextField(
                            controller: _searchController,
                            onChanged: (value) {
                              context.read<CourseBloc>().add(
                                SearchCoursesEvent(query: value),
                              );
                            },
                            decoration: InputDecoration(
                              hintText: AppStrings.searchCourses,
                              hintStyle: const TextStyle(
                                color: AppColors.silver,
                              ),
                              prefixIcon: const Icon(
                                Icons.search_rounded,
                                color: AppColors.violet,
                              ),
                              suffixIcon: value.text.isNotEmpty
                                  ? IconButton(
                                      onPressed: () {
                                        _searchController.clear();
                                        context.read<CourseBloc>().add(
                                          const SearchCoursesEvent(query: ''),
                                        );
                                      },
                                      icon: const Icon(
                                        Icons.close_rounded,
                                        color: AppColors.silver,
                                      ),
                                    )
                                  : null,
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  Expanded(
                    child: BlocBuilder<CourseBloc, CourseState>(
                      builder: (context, state) {
                        if (state is CourseLoading) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (state is CourseLoaded) {
                          final courses = state.courses;
                          if (courses.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 92,
                                    height: 92,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.violet.withValues(
                                        alpha: 0.1,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.search_off_rounded,
                                      size: 48,
                                      color: AppColors.violet,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'No courses found',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.charcoal,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  const Text(
                                    'Coba kata kunci lain atau kosongkan pencarian.',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.slate,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          return GridView.builder(
                            padding: EdgeInsets.fromLTRB(
                              AppMeasures.paddingLarge,
                              4,
                              AppMeasures.paddingLarge,
                              AppMeasures.paddingLarge,
                            ),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: 0.82,
                                  crossAxisSpacing: 14,
                                  mainAxisSpacing: 14,
                                ),
                            itemCount: courses.length,
                            itemBuilder: (context, index) {
                              final courseEntity = courses[index];
                              return CourseCard(
                                course: courseEntity,
                                isSaved: courseEntity.isSaved,
                                onTap: () {
                                  context.push(
                                    AppRoutes.courseDetail,
                                    extra: courseEntity,
                                  );
                                },
                                onSavePressed: () {
                                  context.read<CourseBloc>().add(
                                    ToggleSaveCourseEvent(
                                      courseId: courseEntity.id,
                                    ),
                                  );
                                },
                              );
                            },
                          );
                        }

                        if (state is CourseFailure) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 92,
                                  height: 92,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.crimson.withValues(
                                      alpha: 0.1,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.error_outline_rounded,
                                    size: 48,
                                    color: AppColors.crimson,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                  ),
                                  child: Text(
                                    state.message,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.charcoal,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showAddCourseDialog(BuildContext context) async {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final instructorController = TextEditingController();
    final durationController = TextEditingController(text: '4 hours');
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Tambah Kursus Baru'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Judul'),
                ),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Deskripsi'),
                  maxLines: 2,
                ),
                TextField(
                  controller: instructorController,
                  decoration: const InputDecoration(labelText: 'Instruktur'),
                ),
                TextField(
                  controller: durationController,
                  decoration: const InputDecoration(labelText: 'Durasi'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                final title = titleController.text.trim();
                final description = descriptionController.text.trim();
                final instructor = instructorController.text.trim();

                if (title.isEmpty ||
                    description.isEmpty ||
                    instructor.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Judul, deskripsi, dan instruktur wajib diisi.',
                      ),
                    ),
                  );
                  return;
                }

                final course = CourseEntity(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  title: title,
                  description: description,
                  instructor: instructor,
                  color: '#6C5CE7',
                  icon: '📚',
                  chaptersCount: 0,
                  duration: durationController.text.trim().isEmpty
                      ? '4 hours'
                      : durationController.text.trim(),
                  sections: const [],
                  lessons: const [],
                );

                context.read<CourseBloc>().add(AddCourseEvent(course: course));
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );

    if (result == true) {
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text(
            'Kursus dikirim ke Laravel dan akan tersinkron ke peserta.',
          ),
          backgroundColor: AppColors.emerald,
        ),
      );
    }

    titleController.dispose();
    descriptionController.dispose();
    instructorController.dispose();
    durationController.dispose();
  }
}

class _CourseListBackdrop extends StatelessWidget {
  const _CourseListBackdrop();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFF6F8FF), Color(0xFFF0F4FF)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Positioned(
            top: -60,
            right: -50,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.cherry.withValues(alpha: 0.11),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
