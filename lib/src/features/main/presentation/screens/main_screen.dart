import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms_mobile_app/src/features/authentication/presentation/screens/profile_screen.dart';
import 'package:lms_mobile_app/src/features/authentication/presentation/bloc/auth/auth_bloc.dart';
import 'package:lms_mobile_app/src/features/authentication/presentation/bloc/auth/auth_state.dart';
import 'package:lms_mobile_app/src/features/courses/presentation/screens/course_list_screen.dart';
import 'package:lms_mobile_app/src/features/courses/presentation/screens/saved_courses_screen.dart';
import 'package:lms_mobile_app/src/features/home/presentation/screens/home_screen.dart';
import 'package:lms_mobile_app/src/features/instructor/presentation/screens/instructor_dashboard_screen.dart';
import 'package:lms_mobile_app/src/shared/widgets/bottom_nav_bar.dart';

class MainScreen extends StatefulWidget {
  final int initialTab;

  const MainScreen({super.key, this.initialTab = 0});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialTab;
  }

  List<Widget> _buildScreens(String role, {required bool canManage}) {
    return [
      // Instructors/admins get an action-oriented dashboard; participants get
      // the learning home.
      canManage
          ? const InstructorDashboardScreen()
          : HomeScreen(
              accountRole: role,
              onShowCourses: () {
                setState(() {
                  _selectedIndex = 1;
                });
              },
            ),
      const CourseListScreen(),
      const SavedCoursesScreen(),
      const ProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final role = state is AuthSuccess ? state.user.role : 'participant';
        final canManage =
            state is AuthSuccess &&
            (state.user.hasRole('instructor') ||
                state.user.hasRole('admin') ||
                state.user.hasRole('super-admin'));
        final screens = _buildScreens(role, canManage: canManage);

        return Scaffold(
          body: screens[_selectedIndex],
          bottomNavigationBar: CustomBottomNavBar(
            currentIndex: _selectedIndex,
            onItemSelected: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
          ),
        );
      },
    );
  }
}
