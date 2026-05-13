import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms_mobile_app/src/core/config/constants/app_strings.dart';
import 'package:lms_mobile_app/src/features/authentication/presentation/bloc/auth/auth_bloc.dart';
import 'package:lms_mobile_app/src/features/authentication/presentation/bloc/auth/auth_state.dart';
import 'package:lms_mobile_app/src/features/courses/presentation/bloc/course/course_bloc.dart';
import 'package:lms_mobile_app/src/features/courses/presentation/bloc/course/course_event.dart';
import 'package:lms_mobile_app/src/shared/styles/app_colors.dart';
import 'package:lms_mobile_app/src/shared/styles/app_measures.dart';

/// Home Screen Header with Greeting, User Name, and Search Bar
class HomeHeader extends StatelessWidget {
  final TextEditingController searchController;

  const HomeHeader({super.key, required this.searchController});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppMeasures.paddingLarge),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.violet, AppColors.azure],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildGreetingSection(),
          const SizedBox(height: 24),
          _buildSearchBar(context),
        ],
      ),
    );
  }

  Widget _buildGreetingSection() {
    return Row(
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
            const SizedBox(height: 4),
            _buildUserNameDisplay(),
            const SizedBox(height: 8),
            Text(
              AppStrings.readyForLesson,
              style: TextStyle(
                fontSize: 13,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ],
        ),
        _buildProfileAvatar(),
      ],
    );
  }

  Widget _buildUserNameDisplay() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        var userName = 'User';
        if (state is AuthSuccess) {
          userName = state.user.name.split(' ').first;
        }
        return Text(
          userName,
          style: TextStyle(fontSize: 22, color: Colors.white.withOpacity(0.9)),
        );
      },
    );
  }

  Widget _buildProfileAvatar() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.2),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
      ),
      child: const Center(child: Text('👤', style: TextStyle(fontSize: 32))),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: searchController,
        onChanged: (value) {
          context.read<CourseBloc>().add(SearchCoursesEvent(query: value));
        },
        decoration: InputDecoration(
          hintText: AppStrings.searchCourses,
          hintStyle: const TextStyle(color: AppColors.silver),
          prefixIcon: const Icon(Icons.search, color: AppColors.violet),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }
}
