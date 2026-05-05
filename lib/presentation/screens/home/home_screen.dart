import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms_mobile_app/config/theme.dart';
import 'package:lms_mobile_app/presentation/bloc/auth/auth_bloc.dart';
import 'package:lms_mobile_app/presentation/bloc/auth/auth_state.dart';
import 'package:lms_mobile_app/presentation/bloc/course/course_bloc.dart';
import 'package:lms_mobile_app/presentation/bloc/course/course_event.dart';
import 'package:lms_mobile_app/presentation/bloc/course/course_state.dart';
import 'package:lms_mobile_app/presentation/widgets/course_card.dart';
import 'package:lms_mobile_app/presentation/widgets/statistics_card.dart';
import 'package:lms_mobile_app/utils/constants.dart';
import 'package:lms_mobile_app/data/mappers/course_mapper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: EdgeInsets.all(AppConstants.paddingLarge),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.secondary],
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
                              AppConstants.helloWelcome,
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
                              AppConstants.readyForLesson,
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
                          hintText: AppConstants.searchCourses,
                          hintStyle: TextStyle(color: AppColors.textLighter),
                          prefixIcon: Icon(
                            Icons.search,
                            color: AppColors.primary,
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
              SizedBox(height: AppConstants.paddingLarge),
              // Statistics Cards - Grid Layout (2x2)
              BlocBuilder<CourseBloc, CourseState>(
                builder: (context, state) {
                  if (state is CourseLoading) {
                    return Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppConstants.paddingLarge,
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

                    return Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppConstants.paddingLarge,
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
                          _buildStatCard(
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
                        horizontal: AppConstants.paddingLarge,
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
                        horizontal: AppConstants.paddingLarge,
                      ),
                      child: SizedBox(
                        height: 200,
                        child: Center(
                          child: Text(
                            state.message,
                            style: TextStyle(
                              color: AppColors.error,
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
              SizedBox(height: AppConstants.paddingLarge),
              // Recommended Section
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppConstants.paddingLarge,
                ),
                child: Text(
                  AppConstants.kursusSaya,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.text,
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
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.symmetric(
                          horizontal: AppConstants.paddingLarge,
                        ),
                        itemCount: recommendedCourses.length,
                        itemBuilder: (context, index) {
                          final courseEntity = recommendedCourses[index];
                          final course = CourseMapper.fromDomain(courseEntity);
                          return Container(
                            width: 200,
                            margin: EdgeInsets.only(right: 12),
                            child: CourseCard(
                              course: course,
                              isSaved: courseEntity.isSaved,
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  '/course-detail',
                                  arguments: course,
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
                    );
                  }
                  return SizedBox.shrink();
                },
              ),
              SizedBox(height: AppConstants.paddingLarge),
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
                color: AppColors.text,
              ),
            ),
            SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textLight,
              ),
            ),
            SizedBox(height: 8),
            Expanded(
              child: Text(
                description,
                style: TextStyle(fontSize: 11, color: AppColors.textLighter),
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
                color: AppColors.text,
              ),
            ),
            SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textLight,
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
              style: TextStyle(fontSize: 11, color: AppColors.textLighter),
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
                color: AppColors.text,
              ),
            ),
            SizedBox(height: 8),
            Expanded(
              child: Text(
                'Panduan lengkap penggunaan aplikasi LMS',
                style: TextStyle(fontSize: 11, color: AppColors.textLighter),
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
}
