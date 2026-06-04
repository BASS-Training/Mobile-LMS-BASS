import '../models/discussion_model.dart';

abstract class DiscussionRemoteDataSource {
  Future<List<DiscussionModel>> getByLesson(String lessonId);

  Future<DiscussionModel> create(
    String lessonId, {
    required String title,
    required String body,
  });

  Future<DiscussionReplyModel> reply(
    String discussionId, {
    required String body,
  });
}
