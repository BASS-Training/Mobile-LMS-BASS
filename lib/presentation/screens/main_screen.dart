import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms_mobile_app/config/theme.dart';
import 'package:lms_mobile_app/presentation/bloc/auth/auth_bloc.dart';
import 'package:lms_mobile_app/presentation/bloc/auth/auth_event.dart';
import 'package:lms_mobile_app/presentation/bloc/auth/auth_state.dart';
import 'package:lms_mobile_app/presentation/bloc/course/course_bloc.dart';
import 'package:lms_mobile_app/presentation/bloc/course/course_event.dart';
import 'package:lms_mobile_app/presentation/bloc/course/course_state.dart';
import 'package:lms_mobile_app/presentation/screens/courses/course_list_screen.dart';
import 'package:lms_mobile_app/presentation/screens/home/home_screen.dart';
import 'package:lms_mobile_app/presentation/widgets/bottom_nav_bar.dart';
import 'package:lms_mobile_app/data/mappers/course_mapper.dart';

class MainScreen extends StatefulWidget {
  final int initialTab;
  const MainScreen({super.key, this.initialTab = 0});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _selectedIndex;

  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialTab;
    _screens = [
      HomeScreen(),
      CourseListScreen(),
      SavedCoursesScreen(),
      ProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _selectedIndex,
        onItemSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}

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
      appBar: AppBar(title: Text('Saved Courses'), elevation: 0),
      body: BlocBuilder<CourseBloc, CourseState>(
        builder: (context, state) {
          if (state is CourseLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (state is SavedCoursesLoaded) {
            final savedCourses = state.courses;
            if (savedCourses.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.bookmark_outline,
                      size: 64,
                      color: AppColors.textLighter,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No saved courses yet',
                      style: TextStyle(fontSize: 16, color: AppColors.textLight),
                    ),
                  ],
                ),
              );
            }
            return ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: savedCourses.length,
              itemBuilder: (context, index) {
                final courseEntity = savedCourses[index];
                final course = CourseMapper.fromDomain(courseEntity);
                return Container(
                  margin: EdgeInsets.only(bottom: 12),
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color(
                                int.parse(
                                  course.color.replaceFirst('#', '0xFF'),
                                ),
                              ),
                              Color(
                                int.parse(
                                  course.color.replaceFirst('#', '0xFF'),
                                ),
                              ).withOpacity(0.7),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            course.icon,
                            style: TextStyle(fontSize: 32),
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              course.title,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.text,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              course.instructor,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textLight,
                              ),
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.book_outlined,
                                  size: 12,
                                  color: AppColors.textLighter,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  '${course.totalLessons} lessons',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textLighter,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/course-detail',
                            arguments: course,
                          );
                        },
                        child: Icon(
                          Icons.arrow_forward,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }
          return SizedBox.shrink();
        },
      ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthSuccess) {
          final user = state.user;
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(title: Text('Profile'), elevation: 0),
            body: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 24),
                  // Profile Avatar
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [AppColors.primary, AppColors.secondary],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text('👤', style: TextStyle(fontSize: 64)),
                    ),
                  ),
                  SizedBox(height: 20),
                  // User info
                  Text(
                    user.name,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.text,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    user.email,
                    style: TextStyle(fontSize: 14, color: AppColors.textLight),
                  ),
                  SizedBox(height: 32),
                  // Info cards
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: AppColors.primary,
                              ),
                              SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Account Status',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textLight,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Active',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.success,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 12),
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.star_outline,
                                color: AppColors.accentOrange,
                              ),
                              SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Member Since',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textLight,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Today',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.text,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 32),
                  // Logout button
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: ElevatedButton(
                      onPressed: () {
                        context.read<AuthBloc>().add(const AuthLogoutEvent());
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        minimumSize: Size(double.infinity, 50),
                      ),
                      child: Text('Logout'),
                    ),
                  ),
                  SizedBox(height: 24),
                ],
              ),
            ),
          );
        }
        return Scaffold(
          body: Center(child: Text('No user logged in')),
        );
      },
    );
  }
}
