import 'package:equatable/equatable.dart';

abstract class VideoEvent extends Equatable {
  const VideoEvent();
  @override
  List<Object?> get props => [];
}

class InitVideoLesson extends VideoEvent {
  final String lessonId;
  final bool isCompleted;
  const InitVideoLesson(this.lessonId, this.isCompleted);
}

class VideoProgressUpdated extends VideoEvent {
  final int currentPositionSeconds;
  final int totalDurationSeconds;
  const VideoProgressUpdated(this.currentPositionSeconds, this.totalDurationSeconds);
}

class SubmitDiscussionComment extends VideoEvent {
  final String lessonId;
  final String message;
  const SubmitDiscussionComment(this.lessonId, this.message);
}