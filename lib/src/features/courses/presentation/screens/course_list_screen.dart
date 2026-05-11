import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms_mobile_app/src/core/config/constants/app_strings.dart';
import 'package:lms_mobile_app/src/features/courses/presentation/bloc/course/course_bloc.dart';
import 'package:lms_mobile_app/src/features/courses/presentation/bloc/course/course_event.dart';
import 'package:lms_mobile_app/src/features/courses/presentation/bloc/course/course_state.dart';
import 'package:lms_mobile_app/src/features/courses/presentation/widgets/course_card.dart';
import 'package:lms_mobile_app/src/shared/styles/app_colors.dart';
import 'package:lms_mobile_app/src/shared/styles/app_measures.dart';

class CourseListScreen extends StatefulWidget {
  const CourseListScreen({super.key});

  @override
  State<CourseListScreen> createState() => _CourseListScreenState();
}

class _CourseListScreenState extends State<CourseListScreen> {
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
      appBar: AppBar(title: Text('All Courses'), elevation: 0),
      body: Column(
        children: [
          // Search Bar
          Container(
            margin: EdgeInsets.all(AppMeasures.paddingLarge),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: Offset(0, 2),
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
                hintStyle: TextStyle(color: AppColors.textLighter),
                prefixIcon: Icon(Icons.search, color: AppColors.primary),
                suffixIcon: _searchController.text.isNotEmpty
                    ? GestureDetector(
                        onTap: () {
                          _searchController.clear();
                          context.read<CourseBloc>().add(
                            const SearchCoursesEvent(query: ''),
                          );
                        },
                        child: Icon(Icons.close, color: AppColors.textLighter),
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
          ),
          // Courses Grid
          Expanded(
            child: BlocBuilder<CourseBloc, CourseState>(
              builder: (context, state) {
                if (state is CourseLoading) {
                  return Center(child: CircularProgressIndicator());
                } else if (state is CourseLoaded) {
                  final courses = state.courses;
                  if (courses.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 64,
                            color: AppColors.textLighter,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No courses found',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.textLight,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return GridView.builder(
                    padding: EdgeInsets.all(AppMeasures.paddingLarge),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.85,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: courses.length,
                    itemBuilder: (context, index) {
                      final courseEntity = courses[index];
                      return CourseCard(
                        course: courseEntity,
                        isSaved: courseEntity.isSaved,
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/course-detail',
                            arguments: courseEntity,
                          );
                        },
                        onSavePressed: () {
                          context.read<CourseBloc>().add(
                            ToggleSaveCourseEvent(courseId: courseEntity.id),
                          );
                        },
                      );
                    },
                  );
                } else if (state is CourseFailure) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: AppColors.error,
                        ),
                        SizedBox(height: 16),
                        Text(
                          state.message,
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.error,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}
