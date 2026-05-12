import 'package:equatable/equatable.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/entities/comment_entity.dart';

class VideoState extends Equatable {
  final bool isLoading;
  final List<CommentEntity> comments;
  final bool canProceed;
  final bool isSuccessMarkComplete;

  const VideoState({
    this.isLoading = false,
    this.comments = const [],
    this.canProceed = false,
    this.isSuccessMarkComplete = false,
  });

  VideoState copyWith({
    bool? isLoading,
    List<CommentEntity>? comments,
    bool? canProceed,
    bool? isSuccessMarkComplete,
  }) {
    return VideoState(
      isLoading: isLoading ?? this.isLoading,
      comments: comments ?? this.comments,
      canProceed: canProceed ?? this.canProceed,
      isSuccessMarkComplete: isSuccessMarkComplete ?? this.isSuccessMarkComplete,
    );
  }

  @override
  List<Object?> get props => [isLoading, comments, canProceed, isSuccessMarkComplete];
}