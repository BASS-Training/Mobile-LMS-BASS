import '../entities/discussion_entity.dart';
import '../repositories/discussion_repository.dart';

class GetDiscussionsUseCase {
  final DiscussionRepository repository;

  const GetDiscussionsUseCase(this.repository);

  Future<List<DiscussionEntity>> call(String lessonId) =>
      repository.getDiscussions(lessonId);
}

class CreateDiscussionUseCase {
  final DiscussionRepository repository;

  const CreateDiscussionUseCase(this.repository);

  Future<DiscussionEntity> call(
    String lessonId, {
    required String title,
    required String body,
  }) =>
      repository.createDiscussion(lessonId, title: title, body: body);
}

class CreateReplyUseCase {
  final DiscussionRepository repository;

  const CreateReplyUseCase(this.repository);

  Future<DiscussionReplyEntity> call(
    String discussionId, {
    required String body,
  }) =>
      repository.createReply(discussionId, body: body);
}
