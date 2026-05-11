import 'package:equatable/equatable.dart';

abstract class LessonState extends Equatable {
  const LessonState();
}

class LessonInitial extends LessonState {
  const LessonInitial();

  @override
  List<Object?> get props => [];
}

class LessonLoading extends LessonState {
  const LessonLoading();

  @override
  List<Object?> get props => [];
}

class LessonCompletionChecked extends LessonState {
  final bool isCompleted;

  const LessonCompletionChecked({required this.isCompleted});

  @override
  List<Object?> get props => [isCompleted];
}

class LessonCompletionToggled extends LessonState {
  final String lessonId;

  const LessonCompletionToggled({required this.lessonId});

  @override
  List<Object?> get props => [lessonId];
}

class LessonMarkedComplete extends LessonState {
  final String lessonId;

  const LessonMarkedComplete({required this.lessonId});

  @override
  List<Object?> get props => [lessonId];
}

class LessonMarkedIncomplete extends LessonState {
  final String lessonId;

  const LessonMarkedIncomplete({required this.lessonId});

  @override
  List<Object?> get props => [lessonId];
}

class LessonFailure extends LessonState {
  final String message;

  const LessonFailure({required this.message});

  @override
  List<Object?> get props => [message];
}
