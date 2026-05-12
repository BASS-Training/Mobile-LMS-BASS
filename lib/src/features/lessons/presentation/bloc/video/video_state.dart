import 'package:equatable/equatable.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/entities/comment_entity.dart';

class VideoState extends Equatable {
  final List<CommentEntity> comments;
  final bool canProceed;

  const VideoState({this.comments = const [], this.canProceed = false});

  VideoState copyWith({List<CommentEntity>? comments, bool? canProceed}) {
    return VideoState(
      comments: comments ?? this.comments,
      canProceed: canProceed ?? this.canProceed,
    );
  }

  @override
  List<Object?> get props => [comments, canProceed];
}
