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

  @override
  List<Object?> get props => [lessonId, isCompleted];
}

class VideoProgressUpdated extends VideoEvent {
  final int currentPositionSeconds;
  final int totalDurationSeconds;
  const VideoProgressUpdated(
    this.currentPositionSeconds,
    this.totalDurationSeconds,
  );

  @override
  List<Object?> get props => [currentPositionSeconds, totalDurationSeconds];
}
