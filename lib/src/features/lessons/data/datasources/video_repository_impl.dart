import '../../domain/entities/comment_entity.dart';
import '../../domain/repositories/video_repository.dart';

class VideoRepositoryImpl implements VideoRepository {
  final Map<String, List<CommentEntity>> _dummyDatabase = {};

  @override
  Future<List<CommentEntity>> getComments(String lessonId) async {
    // Memberikan data awal persis seperti kodemu sebelumnya
    if (!_dummyDatabase.containsKey(lessonId)) {
      _dummyDatabase[lessonId] = [
        const CommentEntity(
          userName: 'Andi',
          message: 'Materinya jelas dan mudah dipahami.',
          timeLabel: '2 menit lalu',
        ),
      ];
    }
    return _dummyDatabase[lessonId]!;
  }

  @override
  Future<void> addComment(String lessonId, CommentEntity comment) async {
    if (!_dummyDatabase.containsKey(lessonId)) {
      _dummyDatabase[lessonId] = [];
    }
    // Insert di urutan pertama agar muncul di atas
    _dummyDatabase[lessonId]!.insert(0, comment);
  }
}