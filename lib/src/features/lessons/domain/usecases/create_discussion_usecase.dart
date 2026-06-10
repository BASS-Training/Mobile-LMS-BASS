import 'package:lms_mobile_app/src/features/lessons/domain/entities/discussion_entity.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/repositories/discussion_repository.dart';

class CreateDiscussionUseCase {
  final DiscussionRepository repository;

  const CreateDiscussionUseCase(this.repository);

  Future<DiscussionEntity> call(
    String lessonId, {
    required String title,
    required String body,
  }) => repository.createDiscussion(lessonId, title: title, body: body);
}
