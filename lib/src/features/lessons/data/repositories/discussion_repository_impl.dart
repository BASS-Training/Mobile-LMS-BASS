import '../../domain/entities/discussion_entity.dart';
import '../../domain/repositories/discussion_repository.dart';
import '../datasources/discussion_remote_datasource.dart';

class DiscussionRepositoryImpl implements DiscussionRepository {
  final DiscussionRemoteDataSource remoteDataSource;

  const DiscussionRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<DiscussionEntity>> getDiscussions(String lessonId) async {
    final models = await remoteDataSource.getByLesson(lessonId);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<DiscussionEntity> createDiscussion(
    String lessonId, {
    required String title,
    required String body,
  }) async {
    final model =
        await remoteDataSource.create(lessonId, title: title, body: body);
    return model.toEntity();
  }

  @override
  Future<DiscussionReplyEntity> createReply(
    String discussionId, {
    required String body,
  }) async {
    final model = await remoteDataSource.reply(discussionId, body: body);
    return model.toEntity();
  }
}
