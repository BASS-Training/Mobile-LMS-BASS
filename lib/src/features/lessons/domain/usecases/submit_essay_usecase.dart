import 'package:lms_mobile_app/src/features/lessons/domain/repositories/essay_repository.dart';

class SubmitEssayUseCase {
  final EssayRepository repository;
  static const int minWordsPerQuestion = 10;

  SubmitEssayUseCase(this.repository);

  Future<bool> execute(String lessonId, Map<int, String> answers, int totalQuestions) async {
    // Logika menghitung kata yang tadinya ada di UI pindah ke sini
    int validCount = 0;
    for (var answer in answers.values) {
      if (_countWords(answer) >= minWordsPerQuestion) {
        validCount++;
      }
    }

    if (validCount < totalQuestions) {
      return false; // Gagal validasi
    }

    await repository.submitEssayAnswers(lessonId, answers);
    return true; // Berhasil
  }

  int _countWords(String text) {
    final normalized = text.trim();
    if (normalized.isEmpty) return 0;
    return normalized.split(RegExp(r'\s+')).where((e) => e.isNotEmpty).length;
  }
}