import '../models/comment_model.dart';

abstract class VideoLessonRemoteDataSource {
  Future<List<CommentModel>> fetchComments(String lessonId);
  Future<void> sendComment(String lessonId, String message);
  Future<void> setLessonComplete(String lessonId);
}

class VideoLessonRemoteDataSourceImpl implements VideoLessonRemoteDataSource {
  // Simulasi database di memory
  final Map<String, List<CommentModel>> _mockDatabase = {};

  @override
  Future<List<CommentModel>> fetchComments(String lessonId) async {
    await Future.delayed(const Duration(seconds: 1)); // Simulasi loading jaringan
    return _mockDatabase[lessonId] ?? [];
  }

  @override
  Future<void> sendComment(String lessonId, String message) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final newComment = CommentModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userName: "Hikam Rizqillah", // Mock nama user
      message: message,
      createdAt: DateTime.now(),
    );
    
    if (_mockDatabase.containsKey(lessonId)) {
      _mockDatabase[lessonId]!.insert(0, newComment);
    } else {
      _mockDatabase[lessonId] = [newComment];
    }
  }

  @override
  Future<void> setLessonComplete(String lessonId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Logika API untuk menyimpan status 'completed' ke database sesungguhnya
  }
}