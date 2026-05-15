import 'package:equatable/equatable.dart';
import 'package:lms_mobile_app/src/features/courses/domain/entities/course_entity.dart';

abstract class LessonEvent extends Equatable {
  const LessonEvent();
}

class CheckLessonCompletionEvent extends LessonEvent {
  final String lessonId;

  const CheckLessonCompletionEvent({required this.lessonId});

  @override
  List<Object?> get props => [lessonId];
}

class ToggleLessonCompletionEvent extends LessonEvent {
  final String lessonId;

  const ToggleLessonCompletionEvent({required this.lessonId});

  @override
  List<Object?> get props => [lessonId];
}

class MarkLessonCompleteEvent extends LessonEvent {
  final String lessonId;

  const MarkLessonCompleteEvent({required this.lessonId});

  @override
  List<Object?> get props => [lessonId];
}

class MarkLessonIncompleteEvent extends LessonEvent {
  final String lessonId;

  const MarkLessonIncompleteEvent({required this.lessonId});

  @override
  List<Object?> get props => [lessonId];
}

class RefreshLessonCompletionEvent extends LessonEvent {
  const RefreshLessonCompletionEvent();

  @override
  List<Object?> get props => [];
}

class RequestNavigateNextEvent extends LessonEvent {
  final CourseEntity course;
  final int currentIndex;

  const RequestNavigateNextEvent({
    required this.course,
    required this.currentIndex,
  });

  @override
  List<Object?> get props => [course, currentIndex];
}

class RequestNavigatePreviousEvent extends LessonEvent {
  final CourseEntity course;
  final int currentIndex;

  const RequestNavigatePreviousEvent({
    required this.course,
    required this.currentIndex,
  });

  @override
  List<Object?> get props => [course, currentIndex];
}
