import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms_mobile_app/config/theme.dart';
import 'package:lms_mobile_app/presentation/bloc/auth/auth_bloc.dart';
import 'package:lms_mobile_app/presentation/bloc/auth/auth_state.dart';
import 'package:lms_mobile_app/presentation/bloc/course/course_bloc.dart';
import 'package:lms_mobile_app/presentation/bloc/course/course_event.dart';
import 'package:lms_mobile_app/presentation/bloc/course/course_state.dart';
import 'package:lms_mobile_app/presentation/widgets/course_card.dart';
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
                                  userName =
                                      state.user.name.split(' ')[0];
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
              // Subject Section
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppConstants.paddingLarge,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppConstants.subject,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.text,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacementNamed(context, '/courses');
                      },
                      child: Text(
                        AppConstants.viewAll,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12),
              // Subject Courses - Horizontal Scroll
              BlocBuilder<CourseBloc, CourseState>(
                builder: (context, state) {
                  if (state is CourseLoading) {
                    return SizedBox(
                      height: 280,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  } else if (state is CourseLoaded) {
                    final subjectCourses =
                        state.courses.take(3).toList();
                    return SizedBox(
                      height: 280,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.symmetric(
                          horizontal: AppConstants.paddingLarge,
                        ),
                        itemCount: subjectCourses.length,
                        itemBuilder: (context, index) {
                          final courseEntity = subjectCourses[index];
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
                                          courseId: courseEntity.id),
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
              // Recommended Section
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppConstants.paddingLarge,
                ),
                child: Text(
                  AppConstants.recommendedForYou,
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
                    final recommendedCourses =
                        state.courses.skip(3).take(3).toList();
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
                          final course =
                              CourseMapper.fromDomain(courseEntity);
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
                                          courseId: courseEntity.id),
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
}
