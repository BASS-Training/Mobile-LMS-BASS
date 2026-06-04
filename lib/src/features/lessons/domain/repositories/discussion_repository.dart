import '../entities/discussion_entity.dart';

/// Contract for the lesson discussion feature (topic + replies), backed by the
/// shared backend tables so posts stay in sync with the web.
abstract class DiscussionRepository {
  /// All discussion topics (with replies) for a lesson/content.
  Future<List<DiscussionEntity>> getDiscussions(String lessonId);

  /// Start a new discussion topic. Returns the created topic.
  Future<DiscussionEntity> createDiscussion(
    String lessonId, {
    required String title,
    required String body,
  });

  /// Reply to an existing discussion. Returns the created reply.
  Future<DiscussionReplyEntity> createReply(
    String discussionId, {
    required String body,
  });
}
