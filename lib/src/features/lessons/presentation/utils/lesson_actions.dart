import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms_mobile_app/src/features/courses/presentation/bloc/course/course_bloc.dart';
import 'package:lms_mobile_app/src/features/courses/presentation/bloc/course/course_event.dart';

/// Leaves the current lesson screen and asks the course list to refresh, so the
/// completion/progress shown there stays in sync. Centralizes the
/// "pop + RefreshCoursesEvent" pattern that every lesson detail screen repeats.
///
/// Hanya pop bila masih ada halaman di bawahnya. Ini mencegah crash/black screen
/// ("popped the last page off of the stack") bila — karena alur navigasi tertentu
/// — layar lesson menjadi satu-satunya halaman di stack.
void popToCourse(BuildContext context) {
  final navigator = Navigator.of(context);
  if (navigator.canPop()) {
    navigator.pop();
  }
  context.read<CourseBloc>().add(const RefreshCoursesEvent());
}
