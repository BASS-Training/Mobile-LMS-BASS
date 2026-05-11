/// Quiz Models - Data Layer
///
/// Mendefinisikan struktur data untuk quiz feature termasuk:
/// - Question: Model untuk pertanyaan kuis
/// - QuizResult: Model untuk hasil kuis
/// - Quiz: Metadata kuis

/// Model untuk pertanyaan
class Question {
  final String text;
  final List<String> options;
  final int correctIndex;

  Question({
    required this.text,
    required this.options,
    required this.correctIndex,
  });
}

/// Model untuk hasil kuis
class QuizResult {
  final int score;
  final int total;

  double get percentage => (score / total) * 100;
  bool get passed => percentage >= passingScore;

  static const int passingScore = 70;

  QuizResult({required this.score, required this.total});
}

/// Model untuk metadata kuis
class Quiz {
  final String title;
  final int totalQuestions;
  final int timeLimit; // dalam menit
  final int passingScore;
  final List<Question> questions;

  Quiz({
    required this.title,
    required this.totalQuestions,
    required this.timeLimit,
    required this.passingScore,
    required this.questions,
  });

  /// Dummy data untuk pengembangan
  static Quiz getDummyQuiz() {
    return Quiz(
      title: 'AI Fundamentals',
      totalQuestions: 2,
      timeLimit: 30,
      passingScore: 70,
      questions: [
        Question(
          text: 'Apa definisi dari Kecerdasan Artifisial (AI)?',
          options: [
            'Sistem komputer yang bekerja tanpa campur tangan manusia.',
            'Cabang ilmu komputer yang bertujuan menciptakan sistem yang dapat berpikir dan belajar seperti manusia.',
            'Teknologi yang hanya digunakan dalam perangkat keras.',
            'Algoritma sederhana untuk menyelesaikan perhitungan matematis.',
          ],
          correctIndex: 1,
        ),
        Question(
          text: 'Apa itu machine learning?',
          options: [
            'Proses memasang perangkat keras pada mesin.',
            'Teknik untuk membuat mesin belajar dari data tanpa diprogram secara eksplisit.',
            'Sebuah bahasa pemrograman.',
            'Sebuah framework UI.',
          ],
          correctIndex: 1,
        ),
      ],
    );
  }
}
