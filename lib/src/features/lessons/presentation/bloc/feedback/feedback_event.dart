import 'package:equatable/equatable.dart';

abstract class FeedbackEvent extends Equatable {
  const FeedbackEvent();

  @override
  List<Object?> get props => [];
}

class LoadFeedback extends FeedbackEvent {
  final String lessonId;
  const LoadFeedback(this.lessonId);

  @override
  List<Object?> get props => [lessonId];
}

class SubmitFeedback extends FeedbackEvent {
  final String lessonId;
  final Map<String, dynamic> answers;
  const SubmitFeedback({required this.lessonId, required this.answers});

  @override
  List<Object?> get props => [lessonId, answers];
}

class ClearFeedbackMessage extends FeedbackEvent {
  const ClearFeedbackMessage();
}
