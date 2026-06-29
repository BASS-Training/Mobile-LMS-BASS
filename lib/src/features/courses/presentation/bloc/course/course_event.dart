import 'package:equatable/equatable.dart';
import '../../../domain/entities/course_entity.dart';

abstract class CourseEvent extends Equatable {
  const CourseEvent();
}

class GetCoursesEvent extends CourseEvent {
  const GetCoursesEvent();

  @override
  List<Object?> get props => [];
}

class WatchCoursesEvent extends CourseEvent {
  const WatchCoursesEvent();

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

class AddCourseEvent extends CourseEvent {
  final CourseEntity course;

  const AddCourseEvent({required this.course});

  @override
  List<Object?> get props => [course];
}

/// Kosongkan state course (kembali ke [CourseInitial]). Dipakai saat logout agar
/// data akun sebelumnya tidak tersisa di memori dan terbawa ke akun berikutnya
/// pada perangkat yang sama (mencegah perayaan achievement & kebocoran data).
class ResetCoursesEvent extends CourseEvent {
  const ResetCoursesEvent();

  @override
  List<Object?> get props => [];
}
