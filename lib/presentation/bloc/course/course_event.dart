import 'package:equatable/equatable.dart';

abstract class CourseEvent extends Equatable {
  const CourseEvent();
}

class GetCoursesEvent extends CourseEvent {
  const GetCoursesEvent();

  @override
  List<Object?> get props => [];
}

class SearchCoursesEvent extends CourseEvent {
  final String query;

  const SearchCoursesEvent({required this.query});

  @override
  List<Object?> get props => [query];
}

class ToggleSaveCourseEvent extends CourseEvent {
  final String courseId;

  const ToggleSaveCourseEvent({required this.courseId});

  @override
  List<Object?> get props => [courseId];
}

class GetSavedCoursesEvent extends CourseEvent {
  const GetSavedCoursesEvent();

  @override
  List<Object?> get props => [];
}

class RefreshCoursesEvent extends CourseEvent {
  const RefreshCoursesEvent();

  @override
  List<Object?> get props => [];
}
