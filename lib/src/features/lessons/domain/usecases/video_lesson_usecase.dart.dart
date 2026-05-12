import '../entities/comment_entity.dart';
import '../repositories/video_lesson_repository.dart';

class GetVideoCommentsUseCase {
  final VideoLessonRepository repository;
  GetVideoCommentsUseCase(this.repository);

  Future<List<CommentEntity>> execute(String lessonId) {
    return repository.getComments(lessonId);
  }
}

class SubmitVideoCommentUseCase {
  final VideoLessonRepository repository;
  SubmitVideoCommentUseCase(this.repository);

  Future<void> execute(String lessonId, String message) {
    if (message.trim().isEmpty) throw Exception("Komentar tidak boleh kosong");
    return repository.submitComment(lessonId, message);
  }
}

class MarkVideoCompleteUseCase {
  final VideoLessonRepository repository;
  MarkVideoCompleteUseCase(this.repository);

  Future<void> execute(String lessonId) {
    return repository.markLessonAsComplete(lessonId);
  }
}

class CheckVideoProgressUseCase {
  // Aturan bisnis: Video dianggap selesai jika sisa waktu <= 10 detik
  bool execute(Duration currentPosition, Duration totalDuration) {
    final remainingSeconds = totalDuration.inSeconds - currentPosition.inSeconds;
    return remainingSeconds <= 10 && remainingSeconds >= 0;
  }
}