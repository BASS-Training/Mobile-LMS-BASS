import '../entities/comment_entity.dart';

abstract class VideoRepository {
  Future<List<CommentEntity>> getComments(String lessonId);
  Future<void> addComment(String lessonId, CommentEntity comment);
}