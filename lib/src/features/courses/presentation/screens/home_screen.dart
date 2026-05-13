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
import 'package:lms_mobile_app/src/shared/widgets/statistics_card.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback? onShowCourses;

  const HomeScreen({super.key, this.onShowCourses});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  final _joinClassTokenController = TextEditingController();
  bool _isSubmittingJoinToken = false;
  bool _didNavigateFromEdgeSwipe = false;
  double _edgeOverscrollAcumulator = 0.0;
  static const double _edgeSwipeThreshold = 80.0;

  void _goToCourseList() {
    if (!mounted || _didNavigateFromEdgeSwipe) return;

    _didNavigateFromEdgeSwipe = true;
    _edgeOverscrollAcumulator = 0;

    if (widget.onShowCourses != null) {
      widget.onShowCourses!.call();
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) _didNavigateFromEdgeSwipe = false;
      });
      return;
    }
    context.push(AppRoutes.courses).then((_) {
      if (!mounted) return;
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          _didNavigateFromEdgeSwipe = false;
        }
      });
    });
  }

  // Simulate join class action with validation and loading state
  Future<void> _submitJoinClassToken() async {
    final token = _joinClassTokenController.text.trim();

    if (token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Token pendaftaran wajib diisi')),
      );
      return;
    }

    if (token.length < 6) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Token minimal 6 karakter')));
      return;
    }

    setState(() => _isSubmittingJoinToken = true);

    try {
      await Future.delayed(const Duration(milliseconds: 900));

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Berhasil gabung kelas')));

      _joinClassTokenController.clear();
    } finally {
      if (mounted) {
        setState(() => _isSubmittingJoinToken = false);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    context.read<CourseBloc>().add(const GetCoursesEvent());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _joinClassTokenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mist,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: EdgeInsets.all(AppMeasures.paddingLarge),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.violet, AppColors.azure],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppStrings.helloWelcome,
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 4),
                            BlocBuilder<AuthBloc, AuthState>(
                              builder: (context, state) {
                                String userName = 'User';
                                if (state is AuthSuccess) {
                                  userName = state.user.name.split(' ')[0];
                                }
                                return Text(
                                  userName,
                                  style: TextStyle(
                                    fontSize: 22,
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                                );
                              },
                            ),
                            SizedBox(height: 8),
                            Text(
                              AppStrings.readyForLesson,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.2),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: Text('👤', style: TextStyle(fontSize: 32)),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 24),
                    // Search Bar
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) {
                          context.read<CourseBloc>().add(
                            SearchCoursesEvent(query: value),
                          );
                        },
                        decoration: InputDecoration(
                          hintText: AppStrings.searchCourses,
                          hintStyle: TextStyle(color: AppColors.silver),
                          prefixIcon: Icon(
                            Icons.search,
                            color: AppColors.violet,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppMeasures.paddingLarge),
              // Statistics Cards - Grid Layout (2x2)
              BlocBuilder<CourseBloc, CourseState>(
                builder: (context, state) {
                  if (state is CourseLoading) {
                    return Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppMeasures.paddingLarge,
                      ),
                      child: SizedBox(
                        height: 400,
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    );
                  }

                  // Show cards for CourseLoaded state
                  if (state is CourseLoaded) {
                    // Calculate metrics
                    final totalCourses = state.courses.length;
                    final completedCourses = state.courses
                        .where((course) => course.progressPercentage == 100)
                        .length;
                    final incompleteCourses = totalCourses - completedCourses;

                    // Calculate total lessons
                    int totalLessons = 0;
                    int totalCompletedLessons = 0;
                    for (final course in state.courses) {
                      totalLessons += course.totalLessons;
                      totalCompletedLessons += course.completedLessons;
                    }

                    final overallProgress = totalLessons > 0
                        ? ((totalCompletedLessons / totalLessons) * 100).toInt()
                        : 0;

                    final allLessons = state.courses
                        .expand((c) => c.allLessons)
                        .toList();
                    final totalLessonsAll = allLessons.length;
                    final completedLessonsAll = allLessons
                        .where((l) => l.isCompleted)
                        .length;

                    final totalQuizzes = allLessons
                        .where((l) => l.type == 'quiz')
                        .length;
                    final completedQuizzes = allLessons
                        .where((l) => l.type == 'quiz' && l.isCompleted)
                        .length;

                    return Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppMeasures.paddingLarge,
                      ),
                      child: GridView.count(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        childAspectRatio: 1.0,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        children: [
                          // Card 1: Courses
                          StatisticsCard(
                            icon: '📚',
                            title: 'Kursus',
                            number: totalCourses.toString(),
                            description:
                                '$completedCourses selesai, $incompleteCourses belum selesai',
                            borderColor: Color(0xFF6366F1),
                            backgroundColor: Color(0xFFF0F3FF),
                          ),
                          // Card 2: Progress Keseluruhan
                          _buildProgressCard(
                            icon: '📈',
                            title: 'Progress Keseluruhan',
                            number: '$overallProgress%',
                            percentage: overallProgress / 100.0,
                            description: '% Lesson Selesai',
                            borderColor: Color(0xFF14B8A6),
                            backgroundColor: Color(0xFFF0FFFE),
                          ),
                          // Card 3: Konten Selesai
                          _buildStatCard(
                            icon: '✅',
                            title: 'Konten Selesai',
                            number: totalCompletedLessons.toString(),
                            description: 'dari $totalLessons total lesson',
                            borderColor: Color(0xFFA855F7),
                            backgroundColor: Color(0xFFFAF5FF),
                          ),
                          // Card 4: User Guide
                          _buildUserGuideCard(),
                        ],
                      ),
                    );
                  }

                  // Show cards for CourseInitial state
                  if (state is CourseInitial) {
                    return Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppMeasures.paddingLarge,
                      ),
                      child: GridView.count(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        childAspectRatio: 1.0,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        children: [
                          _buildStatCard(
                            icon: '📚',
                            title: 'Kursus',
                            number: '0',
                            description: '0 selesai, 0 belum selesai',
                            borderColor: Color(0xFF6366F1),
                            backgroundColor: Color(0xFFF0F3FF),
                          ),
                          _buildProgressCard(
                            icon: '📈',
                            title: 'Progress Keseluruhan',
                            number: '0%',
                            percentage: 0.0,
                            description: '% Lesson Selesai',
                            borderColor: Color(0xFF14B8A6),
                            backgroundColor: Color(0xFFF0FFFE),
                          ),
                          _buildStatCard(
                            icon: '✅',
                            title: 'Konten Selesai',
                            number: '0',
                            description: 'dari 0 total lesson',
                            borderColor: Color(0xFFA855F7),
                            backgroundColor: Color(0xFFFAF5FF),
                          ),
                          _buildUserGuideCard(),
                        ],
                      ),
                    );
                  }

                  // Show error message for CourseFailure
                  if (state is CourseFailure) {
                    return Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppMeasures.paddingLarge,
                      ),
                      child: SizedBox(
                        height: 200,
                        child: Center(
                          child: Text(
                            state.message,
                            style: TextStyle(
                              color: AppColors.crimson,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    );
                  }

                  return SizedBox.shrink();
                },
              ),
              SizedBox(height: AppMeasures.paddingLarge),
              // Recommended Section
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppMeasures.paddingLarge,
                ),
                child: Text(
                  AppStrings.myCourses,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.charcoal,
                  ),
                ),
              ),
              SizedBox(height: 12),
              // Recommended Courses - Horizontal Scroll
              BlocBuilder<CourseBloc, CourseState>(
                builder: (context, state) {
                  if (state is CourseLoaded) {
                    final recommendedCourses = state.courses
                        .skip(3)
                        .take(3)
                        .toList();
                    return SizedBox(
                      height: 280,
                      child: NotificationListener<ScrollNotification>(
                        onNotification: (notification) {
                          if (_didNavigateFromEdgeSwipe) return false;
                          if (notification.metrics.axis != Axis.horizontal)
                            return false;

                          if (notification is OverscrollNotification) {
                            final atRightEdge =
                                notification.metrics.pixels >=
                                notification.metrics.maxScrollExtent;
                            final pushingBeyondRight =
                                notification.overscroll > 0;

                            if (atRightEdge && pushingBeyondRight) {
                              _edgeOverscrollAcumulator +=
                                  notification.overscroll;

                              if (_edgeOverscrollAcumulator >=
                                  _edgeSwipeThreshold) {
                                _goToCourseList();
                                return true;
                              }
                            } else {
                              _edgeOverscrollAcumulator = 0;
                            }
                          }

                          if (notification is ScrollEndNotification) {
                            _edgeOverscrollAcumulator = 0;
                          }

                          return false;
                        },

                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(
                            parent: AlwaysScrollableScrollPhysics(),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: AppMeasures.paddingLarge,
                          ),
                          itemCount: recommendedCourses.length + 1,
                          itemBuilder: (context, index) {
                            if (index == recommendedCourses.length) {
                              return _buildViewAllCard();
                            }
                            final courseEntity = recommendedCourses[index];
                            return Container(
                              width: 200,
                              margin: EdgeInsets.only(right: 12),
                              child: CourseCard(
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
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  }
                  return SizedBox.shrink();
                },
              ),
              SizedBox(height: 16),
              BlocBuilder<CourseBloc, CourseState>(
                builder: (context, state) {
                  if (state is CourseLoaded) {
                    final allLessons = state.courses
                        .expand((c) => c.allLessons)
                        .toList();
                    final totalLessonsAll = allLessons.length;
                    final completedLessonsAll = allLessons
                        .where((l) => l.isCompleted)
                        .length;

                    final totalQuizzes = allLessons
                        .where((l) => l.type == 'quiz')
                        .length;
                    final completedQuizzes = allLessons
                        .where((l) => l.type == 'quiz' && l.isCompleted)
                        .length;
                    final completedCourses = state.courses
                        .where((c) => c.progressPercentage == 100)
                        .toList();

                    return _buildExtraHomeSections(
                      completedLessonCount: completedLessonsAll,
                      totalLessonCount: totalLessonsAll,
                      completedQuizCount: completedQuizzes,
                      totalQuizCount: totalQuizzes,
                      completedCourses: completedCourses,
                    );
                  }
                  return SizedBox.shrink();
                },
              ),
              SizedBox(height: AppMeasures.paddingLarge),
            ],
          ),
        ),
      ),
    );
  }

  /// Helper method to build a simple statistic card
  Widget _buildStatCard({
    required String icon,
    required String title,
    required String number,
    required String description,
    required Color borderColor,
    required Color backgroundColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: borderColor.withOpacity(0.08),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),

      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(icon, style: TextStyle(fontSize: 28)),
            SizedBox(height: 12),
            Text(
              number,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.charcoal,
              ),
            ),
            SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.slate,
              ),
            ),
            SizedBox(height: 8),
            Expanded(
              child: Text(
                description,
                style: TextStyle(fontSize: 11, color: AppColors.silver),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Helper method to build progress card with progress bar
  Widget _buildProgressCard({
    required String icon,
    required String title,
    required String number,
    required double percentage,
    required String description,
    required Color borderColor,
    required Color backgroundColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: borderColor.withOpacity(0.08),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(icon, style: TextStyle(fontSize: 28)),
            SizedBox(height: 12),
            Text(
              number,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.charcoal,
              ),
            ),
            SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.slate,
              ),
            ),
            SizedBox(height: 12),
            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: percentage,
                minHeight: 6,
                backgroundColor: borderColor.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(borderColor),
              ),
            ),
            SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(fontSize: 11, color: AppColors.silver),
            ),
          ],
        ),
      ),
    );
  }

  /// Helper method to build User Guide card
  Widget _buildUserGuideCard() {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFFF3F0FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Color(0xFF9333EA).withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF9333EA).withOpacity(0.08),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('📖', style: TextStyle(fontSize: 28)),
            SizedBox(height: 12),
            Text(
              'User Guide',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.charcoal,
              ),
            ),
            SizedBox(height: 8),
            Expanded(
              child: Text(
                'Panduan lengkap penggunaan aplikasi LMS',
                style: TextStyle(fontSize: 11, color: AppColors.silver),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Color(0xFF9333EA).withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'Buka',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF9333EA),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildViewAllCard() {
    return GestureDetector(
      onTap: _goToCourseList,
      child: Container(
        width: 200,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.pearl),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.menu_book_rounded, color: AppColors.violet, size: 28),
              const Spacer(),
              Text(
                'Tampilkan Semua',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.charcoal,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Text(
                    'Buka daftar Kursus',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.silver,
                    ),
                  ),
                  const Spacer(),
                  Icon(Icons.arrow_forward_rounded, color: AppColors.charcoal),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExtraHomeSections({
    required int completedLessonCount,
    required int totalLessonCount,
    required int completedQuizCount,
    required int totalQuizCount,
    required List<CourseEntity> completedCourses,
  }) {
    String lessonText = '$completedLessonCount/$totalLessonCount';
    String quizText = totalQuizCount > 0
        ? '$completedQuizCount/$totalQuizCount'
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
                Text(
                  'Token Pendaftaran',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.charcoal,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _joinClassTokenController,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _submitJoinClassToken(),
                  decoration: InputDecoration(
                    hintText: 'Contoh: KLS-2026-AB12',
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    suffixIcon: Icon(
                      Icons.vpn_key_rounded,
                      color: AppColors.violet,
                      size: 18,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isSubmittingJoinToken
                        ? null
                        : _submitJoinClassToken,
                    icon: _isSubmittingJoinToken
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
                      _isSubmittingJoinToken ? 'Mengirim...' : 'Kirim Token',
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

  Widget _buildSectionCard({
    required String title,
    required Widget child,
    Widget? trailing,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Color(0xFFF4F3CC),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.black26, width: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
              ),
              if (trailing != null) trailing,
            ],
          ),
          SizedBox(height: 8),
          child,
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 2),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontSize: 11, color: AppColors.charcoal),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.charcoal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricRowModern(
    String label,
    String value, {
    bool isLast = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 2 : 0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontSize: 11, color: AppColors.charcoal),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.charcoal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernCard({
    required String title,
    required IconData icon,
    required Widget child,
    required Gradient gradient,
    Widget? trailing,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppColors.indigo, size: 19),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.charcoal,
                  ),
                ),
              ),
              if (trailing != null) trailing,
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}


