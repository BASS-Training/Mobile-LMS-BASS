import 'package:equatable/equatable.dart';

/// A reply to a [DiscussionEntity].
class DiscussionReplyEntity extends Equatable {
  final String id;
  final String body;
  final String authorId;
  final String authorName;
  final String createdAtLabel;

  const DiscussionReplyEntity({
    required this.id,
    required this.body,
    required this.authorId,
    required this.authorName,
    required this.createdAtLabel,
  });

  @override
  List<Object?> get props => [id, body, authorId, authorName, createdAtLabel];
}

/// A discussion topic attached to a lesson (backend Content), mirroring the web
/// forum structure: a title + body started by a user, with a list of replies.
class DiscussionEntity extends Equatable {
  final String id;
  final String title;
  final String body;
  final String authorId;
  final String authorName;
  final String createdAtLabel;
  final List<DiscussionReplyEntity> replies;

  const DiscussionEntity({
    required this.id,
    required this.title,
    required this.body,
    required this.authorId,
    required this.authorName,
    required this.createdAtLabel,
    this.replies = const [],
  });

  int get repliesCount => replies.length;

  DiscussionEntity copyWith({List<DiscussionReplyEntity>? replies}) {
    return DiscussionEntity(
      id: id,
      title: title,
      body: body,
      authorId: authorId,
      authorName: authorName,
      createdAtLabel: createdAtLabel,
      replies: replies ?? this.replies,
    );
  }

  @override
  List<Object?> get props =>
      [id, title, body, authorId, authorName, createdAtLabel, replies];
}
