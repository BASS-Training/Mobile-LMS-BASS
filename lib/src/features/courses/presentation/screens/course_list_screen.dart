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
import 'package:lms_mobile_app/src/shared/styles/app_shadows.dart';

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
            title: const Text(
              'Semua Kursus',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 20,
              ),
            ),
            centerTitle: true,
            iconTheme: const IconThemeData(color: Colors.white),
            elevation: 0,
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: AppColors.brandGradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(24),
                ),
              ),
            ),
          ),
          floatingActionButton: isInstructor
              ? FloatingActionButton.extended(
                  onPressed: () => _showAddCourseDialog(context),
                  backgroundColor: AppColors.brandPrimary,
                  foregroundColor: Colors.white,
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
                        color: AppColors.brandSurface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.brandPrimary.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        children: const [
                          Icon(
                            Icons.info_rounded,
                            color: AppColors.brandPrimary,
                            size: 20,
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Mode pengelola aktif. Kursus baru akan tersinkron ke peserta secara otomatis.',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  Padding(
                    padding: EdgeInsets.all(AppMeasures.paddingLarge),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.borderSubtle),
                        boxShadow: AppShadows.sm,
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
                                color: AppColors.textTertiary,
                              ),
                              prefixIcon: const Icon(
                                Icons.search_rounded,
                                color: AppColors.brandPrimary,
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
                                        color: AppColors.textTertiary,
                                      ),
                                    )
                                  : null,
                              filled: false,
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 15,
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
                            child: CircularProgressIndicator(
                              color: AppColors.brandPrimary,
                            ),
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
                                      color: AppColors.brandPrimary.withValues(
                                        alpha: 0.1,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.search_off_rounded,
                                      size: 44,
                                      color: AppColors.brandPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'Kursus tidak ditemukan',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  const Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 32,
                                    ),
                                    child: Text(
                                      'Coba kata kunci lain atau kosongkan pencarian.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                        height: 1.4,
                                      ),
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
                                  childAspectRatio: 0.72,
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
                                    color: AppColors.brandPrimary.withValues(
                                      alpha: 0.1,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.error_outline_rounded,
                                    size: 44,
                                    color: AppColors.brandPrimary,
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
                                      color: AppColors.textPrimary,
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
    return const IgnorePointer(
      child: ColoredBox(color: AppColors.background),
    );
  }
}
