import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms_mobile_app/src/features/authentication/presentation/screens/profile_screen.dart';
import 'package:lms_mobile_app/src/features/authentication/presentation/bloc/auth/auth_bloc.dart';
import 'package:lms_mobile_app/src/features/authentication/presentation/bloc/auth/auth_state.dart';
import 'package:lms_mobile_app/src/features/catalog/presentation/screens/catalog_screen.dart';
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
  final Set<int> _visitedTabs = {};

  static const int _tabCount = 5;

  int _normalizedTab(int index) => index >= 0 && index < _tabCount ? index : 0;

  @override
  void initState() {
    super.initState();
    _selectedIndex = _normalizedTab(widget.initialTab);
    _visitedTabs.add(_selectedIndex);
  }

  @override
  void didUpdateWidget(covariant MainScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialTab == widget.initialTab) return;
    final nextIndex = _normalizedTab(widget.initialTab);
    _selectedIndex = nextIndex;
    _visitedTabs.add(nextIndex);
  }

  void _selectTab(int index) {
    final nextIndex = _normalizedTab(index);
    if (nextIndex == _selectedIndex) return;
    setState(() {
      _selectedIndex = nextIndex;
      _visitedTabs.add(nextIndex);
    });
  }

  List<Widget> _buildScreens(String role, {required bool canManage}) {
    return [
      // Semua role memakai Home belajar yang sama. Instruktur/admin hanya
      // mendapat AKSES tambahan (pintasan penilaian, panel instruktur, buka
      // semua lesson) — bukan tampilan home yang berbeda.
      HomeScreen(
        accountRole: role,
        canManage: canManage,
        onShowCourses: () => _selectTab(2),
      ),
      const CatalogScreen(),
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
          body: IndexedStack(
            index: _selectedIndex,
            children: List.generate(
              screens.length,
              (index) => _visitedTabs.contains(index)
                  ? KeyedSubtree(key: ValueKey(index), child: screens[index])
                  : const SizedBox.shrink(),
            ),
          ),
          bottomNavigationBar: CustomBottomNavBar(
            currentIndex: _selectedIndex,
            onItemSelected: _selectTab,
          ),
        );
      },
    );
  }
}
