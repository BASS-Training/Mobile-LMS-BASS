import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms_mobile_app/src/features/courses/presentation/bloc/course/course_bloc.dart';
import 'package:lms_mobile_app/src/features/courses/presentation/bloc/course/course_event.dart';

/// Leaves the current lesson screen and asks the course list to refresh, so the
/// completion/progress shown there stays in sync. Centralizes the
/// "pop + RefreshCoursesEvent" pattern that every lesson detail screen repeats.
void popToCourse(BuildContext context) {
  Navigator.pop(context);
  context.read<CourseBloc>().add(const RefreshCoursesEvent());
}
