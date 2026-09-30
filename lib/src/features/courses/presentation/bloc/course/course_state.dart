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
  /// Daftar yang sedang ditampilkan pada Course List (dapat terfilter).
  final List<CourseEntity> courses;

  /// Sumber data lengkap yang tidak boleh diganti oleh hasil pencarian.
  final List<CourseEntity> allCourses;
  final String searchQuery;

  const CourseLoaded({
    required this.courses,
    List<CourseEntity>? allCourses,
    this.searchQuery = '',
  }) : allCourses = allCourses ?? courses;

  @override
  List<Object?> get props => [courses, allCourses, searchQuery];
}

class CourseFailure extends CourseState {
  final String message;

  const CourseFailure({required this.message});

  @override
  List<Object?> get props => [message];
}
