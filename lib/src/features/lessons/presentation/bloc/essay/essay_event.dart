import 'package:equatable/equatable.dart';

abstract class EssayEvent extends Equatable {
  const EssayEvent();

  @override
  List<Object?> get props => [];
}

class LoadEssay extends EssayEvent {
  final String lessonId;
  final String courseId;
  final String courseTitle;
  final String lessonTitle;
  final String content;
  const LoadEssay({
    required this.lessonId,
    required this.courseId,
    required this.courseTitle,
    required this.lessonTitle,
    required this.content,
  });

  @override
  List<Object?> get props => [
    lessonId,
    courseId,
    courseTitle,
    lessonTitle,
    content,
  ];
}

class AnswerChanged extends EssayEvent {
  final int questionIndex;
  final String answer;
  const AnswerChanged(this.questionIndex, this.answer);
  @override
  List<Object?> get props => [questionIndex, answer];
}

class ChangeQuestion extends EssayEvent {
  final int index;
  const ChangeQuestion(this.index);
  @override
  List<Object?> get props => [index];
}

class SaveDraftClicked extends EssayEvent {
  final int? nextQuestionIndex;

  const SaveDraftClicked({this.nextQuestionIndex});

  @override
  List<Object?> get props => [nextQuestionIndex];
}

class SubmitEssayClicked extends EssayEvent {}

class ClearSnackbarMessage extends EssayEvent {}
