import 'package:equatable/equatable.dart';
import '../../../domain/entities/course_entity.dart';

abstract class CourseState extends Equatable {
  const CourseState();
}

class CourseInitial extends CourseState {
  const CourseInitial();

  @override
  List<Object?> get props => [];
}

class CourseLoading extends CourseState {
  const CourseLoading();

  @override
  List<Object?> get props => [];
}

class CourseLoaded extends CourseState {
  final List<CourseEntity> courses;
  final String searchQuery;

  const CourseLoaded({
    required this.courses,
    this.searchQuery = '',
  });

  @override
  List<Object?> get props => [courses, searchQuery];
}

class CourseFailure extends CourseState {
  final String message;

  const CourseFailure({required this.message});

  @override
  List<Object?> get props => [message];
}

class SavedCoursesLoaded extends CourseState {
  final List<CourseEntity> courses;

  const SavedCoursesLoaded({required this.courses});

  @override
  List<Object?> get props => [courses];
}
