import 'package:lms_mobile_app/src/features/lessons/domain/entities/discussion_entity.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/repositories/discussion_repository.dart';

class GetDiscussionUseCase {
  final DiscussionRepository repository;

  const GetDiscussionUseCase(this.repository);

  Future<List<DiscussionEntity>> call(String lessonId) =>
      repository.getDiscussions(lessonId);
}
