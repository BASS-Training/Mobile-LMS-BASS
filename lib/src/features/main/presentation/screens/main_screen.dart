import 'package:flutter/material.dart';
import 'package:lms_mobile_app/src/features/authentication/presentation/screens/profile_screen.dart';
import 'package:lms_mobile_app/src/features/courses/presentation/screens/course_list_screen.dart';
import 'package:lms_mobile_app/src/features/courses/presentation/screens/saved_courses_screen.dart';
import 'package:lms_mobile_app/src/features/home/presentation/screens/home_screen.dart';
import 'package:lms_mobile_app/src/shared/widgets/bottom_nav_bar.dart';

class MainScreen extends StatefulWidget {
  final int initialTab;

  const MainScreen({super.key, this.initialTab = 0});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _selectedIndex;
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialTab;
    _screens = [
      HomeScreen(
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
