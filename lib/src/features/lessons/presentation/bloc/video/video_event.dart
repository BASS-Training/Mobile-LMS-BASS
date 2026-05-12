import 'package:equatable/equatable.dart';

abstract class VideoEvent extends Equatable {
  const VideoEvent();

  @override
  List<Object?> get props => [];
}

class LoadVideoContent extends VideoEvent {
  final String lessonId;
  final bool isCompleted;

  const LoadVideoContent({required this.lessonId, required this.isCompleted});

  @override
  List<Object?> get props => [lessonId, isCompleted];
}

class UpdateVideoProgress extends VideoEvent {
  final String lessonId;
  final Duration position;
  final Duration totalDuration;

  const UpdateVideoProgress({
    required this.lessonId,
    required this.position,
    required this.totalDuration,
  });

  @override
  List<Object?> get props => [lessonId, position, totalDuration];
}

class SubmitComment extends VideoEvent {
  final String lessonId;
  final String message;

  const SubmitComment({required this.lessonId, required this.message});

  @override
  List<Object?> get props => [lessonId, message];
}

class ResetSuccessMark extends VideoEvent {}