import '../entities/comment_entity.dart';

abstract class VideoLessonRepository {
  Future<List<CommentEntity>> getComments(String lessonId);
  Future<void> submitComment(String lessonId, String message);
  Future<void> markLessonAsComplete(String lessonId);
}