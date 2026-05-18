import 'dart:ui';

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
    return ClipRRect(
      borderRadius: BorderRadius.vertical(
        bottom: Radius.circular(AppMeasures.radiusXLarge),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: EdgeInsets.fromLTRB(
            AppMeasures.paddingLarge,
            AppMeasures.paddingLarge,
            AppMeasures.paddingLarge,
            AppMeasures.paddingXXLarge,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.red.withValues(alpha: 1),
                AppColors.red.withValues(alpha: 1),
                AppColors.tomato.withValues(alpha: 1),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: -34,
                right: -18,
                child: Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.kids.withValues(alpha: 0.18),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildGreetingSection(),
                  const SizedBox(height: 20),
                  // _buildSearchBar(context),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGreetingSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.18),
                  ),
                ),
                child: const Text(
                  'Bass Training LMS',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                AppStrings.helloWelcome,
                style: const TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  height: 1.05,
                ),
              ),
              const SizedBox(height: 6),
              _buildUserNameDisplay(),
              const SizedBox(height: 8),
              Text(
                AppStrings.readyForLesson,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white.withValues(alpha: 0.84),
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
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
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white.withValues(alpha: 0.92),
          ),
        );
      },
    );
  }

  Widget _buildProfileAvatar() {
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.32),
          width: 1.6,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: const Center(
        child: Icon(Icons.person_rounded, color: Colors.white, size: 28),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: searchController,
      builder: (context, value, _) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: TextField(
            controller: searchController,
            onChanged: (value) {
              context.read<CourseBloc>().add(SearchCoursesEvent(query: value));
            },
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
            cursorColor: Colors.white,
            decoration: InputDecoration(
              hintText: AppStrings.searchCourses,
              hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.75)),
              prefixIcon: Icon(
                Icons.search_rounded,
                color: Colors.white.withValues(alpha: 0.92),
              ),
              suffixIcon: value.text.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        searchController.clear();
                        context.read<CourseBloc>().add(
                          const SearchCoursesEvent(query: ''),
                        );
                      },
                      icon: Icon(
                        Icons.close_rounded,
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
        );
      },
    );
  }
}
