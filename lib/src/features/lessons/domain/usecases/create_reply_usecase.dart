import 'package:lms_mobile_app/src/features/lessons/domain/entities/discussion_entity.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/repositories/discussion_repository.dart';

class CreateReplyUseCase {
  final DiscussionRepository repository;

  const CreateReplyUseCase(this.repository);

  Future<DiscussionReplyEntity> call(
    String discussionId, {
    required String body,
  }) => repository.createReply(discussionId, body: body);
}
