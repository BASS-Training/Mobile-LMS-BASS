import 'package:equatable/equatable.dart';

import '../../../domain/entities/discussion_entity.dart';

enum DiscussionStatus { initial, loading, loaded, error }

class DiscussionState extends Equatable {
  final DiscussionStatus status;
  final List<DiscussionEntity> discussions;

  /// True while a new topic is being posted.
  final bool submitting;

  /// IDs of discussions currently posting a reply.
  final Set<String> replyingIds;

  final String? error;

  const DiscussionState({
    this.status = DiscussionStatus.initial,
    this.discussions = const [],
    this.submitting = false,
    this.replyingIds = const {},
    this.error,
  });

  int get count => discussions.length;

  DiscussionState copyWith({
    DiscussionStatus? status,
    List<DiscussionEntity>? discussions,
    bool? submitting,
    Set<String>? replyingIds,
    String? error,
  }) {
    return DiscussionState(
      status: status ?? this.status,
      discussions: discussions ?? this.discussions,
      submitting: submitting ?? this.submitting,
      replyingIds: replyingIds ?? this.replyingIds,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
    status,
    discussions,
    submitting,
    replyingIds,
    error,
  ];
}
