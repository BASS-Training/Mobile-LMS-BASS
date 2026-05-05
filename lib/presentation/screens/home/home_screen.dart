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
              // Subject Courses - Grid Layout (2x2)
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
                  
                  // Show cards for both CourseInitial and CourseLoaded states
                  if (state is CourseLoaded || state is CourseInitial) {
                    final statsItems = [
                      {
                        'icon': '👥📚',
                        'title': 'KURSUS DIIKUTI',
                        'number': '5,109',
                        'description': '5091 Peserta • 15 Instruktur',
                        'borderColor': Color(0xFF6366F1), // Blue
                        'backgroundColor': Color(0xFFF0F3FF),
                      },
                      {
                        'icon': '📚',
                        'title': 'TOTAL KURSUS',
                        'number': '56',
                        'description': '53 Published • 3 Draft',
                        'borderColor': Color(0xFF14B8A6), // Teal
                        'backgroundColor': Color(0xFFF0FFFE),
                      },
                      {
                        'icon': '📋',
                        'title': 'TOTAL KUIS',
                        'number': '446',
                        'description': '23226/23321 percobaan selesai',
                        'borderColor': Color(0xFFA855F7), // Purple
                        'backgroundColor': Color(0xFFFAF5FF),
                      },
                      {
                        'icon': '📢',
                        'title': 'PENGUMUMAN',
                        'number': '0',
                        'description': '0 aktif dari 0 total',
                        'borderColor': Color(0xFFFB923C), // Orange
                        'backgroundColor': Color(0xFFFFF7ED),
                      },
                    ];
                    
                    return Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppConstants.paddingLarge,
                      ),
                      child: GridView.count(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        childAspectRatio: 0.9,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        children: List.generate(
                          statsItems.length,
                          (index) {
                            final item = statsItems[index];
                            return StatisticsCard(
                              icon: item['icon'] as String,
                              title: item['title'] as String,
                              number: item['number'] as String,
                              description: item['description'] as String,
                              borderColor: item['borderColor'] as Color,
                              backgroundColor: item['backgroundColor'] as Color,
                            );
                          },
                        ),
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
              // User Guide Card
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppConstants.paddingLarge,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Color(0xFFF3F0FF),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Color(0xFF9333EA).withOpacity(0.2),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFF9333EA).withOpacity(0.08),
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Left accent bar
                      Positioned(
                        left: 0,
                        top: 0,
                        bottom: 0,
                        child: Container(
                          width: 6,
                          decoration: BoxDecoration(
                            color: Color(0xFF9333EA),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(16),
                              bottomLeft: Radius.circular(16),
                            ),
                          ),
                        ),
                      ),
                      // Content
                      Padding(
                        padding: EdgeInsets.fromLTRB(20, 16, 16, 16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: Color(0xFF9333EA).withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(
                                    child: Text('📖', style: TextStyle(fontSize: 24)),
                                  ),
                                ),
                                SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'User Guide',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.text,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Panduan penggunaan aplikasi',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textLight,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              color: Color(0xFF9333EA),
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
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
