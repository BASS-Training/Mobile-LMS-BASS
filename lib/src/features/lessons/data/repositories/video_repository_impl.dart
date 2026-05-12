import '../../domain/entities/comment_entity.dart';
import '../../domain/repositories/video_lesson_repository.dart';
import '../datasources/video_lesson_remote_data_source.dart';

class VideoLessonRepositoryImpl implements VideoLessonRepository {
  final VideoLessonRemoteDataSource remoteDataSource;

  VideoLessonRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<CommentEntity>> getComments(String lessonId) async {
    return await remoteDataSource.fetchComments(lessonId);
  }

  @override
  Future<void> submitComment(String lessonId, String message) async {
    await remoteDataSource.sendComment(lessonId, message);
  }

  @override
  Future<void> markLessonAsComplete(String lessonId) async {
    await remoteDataSource.setLessonComplete(lessonId);
  }
}