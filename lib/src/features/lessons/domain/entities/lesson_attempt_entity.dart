import 'package:equatable/equatable.dart';

class LessonAttemptQuestionSnapshot extends Equatable {
  final int questionIndex;
  final String questionText;
  final List<String> options;
  final int? correctOptionIndex;
  final int? selectedOptionIndex;
  final String? selectedOptionText;
  final String? correctOptionText;
  final String? writtenAnswer;

  const LessonAttemptQuestionSnapshot({
    required this.questionIndex,
    required this.questionText,
    required this.options,
    this.correctOptionIndex,
    this.selectedOptionIndex,
    this.selectedOptionText,
    this.correctOptionText,
    this.writtenAnswer,
  });

  bool get isQuiz => options.isNotEmpty;

  Map<String, dynamic> toJson() {
    return {
      'questionIndex': questionIndex,
      'questionText': questionText,
      'options': options,
      'correctOptionIndex': correctOptionIndex,
      'selectedOptionIndex': selectedOptionIndex,
      'selectedOptionText': selectedOptionText,
      'correctOptionText': correctOptionText,
      'writtenAnswer': writtenAnswer,
    };
  }

  factory LessonAttemptQuestionSnapshot.fromJson(Map<String, dynamic> json) {
    return LessonAttemptQuestionSnapshot(
      questionIndex: (json['questionIndex'] as num?)?.toInt() ?? 0,
      questionText: json['questionText']?.toString() ?? '',
      options: List<String>.from(json['options'] as List? ?? const []),
      correctOptionIndex: (json['correctOptionIndex'] as num?)?.toInt(),
      selectedOptionIndex: (json['selectedOptionIndex'] as num?)?.toInt(),
      selectedOptionText: json['selectedOptionText']?.toString(),
      correctOptionText: json['correctOptionText']?.toString(),
      writtenAnswer: json['writtenAnswer']?.toString(),
    );
  }

  @override
  List<Object?> get props => [
    questionIndex,
    questionText,
    options,
    correctOptionIndex,
    selectedOptionIndex,
    selectedOptionText,
    correctOptionText,
    writtenAnswer,
  ];
}

class LessonAttempt extends Equatable {
  final String id;
  final String courseId;
  final String courseTitle;
  final String lessonId;
  final String lessonTitle;
  final String lessonType;
  final int attemptNumber;
  final DateTime submittedAt;
  final bool graded;
  final double? score;
  final double? maxScore;
  final bool? passed;
  final int? passingGrade;
  final int? correctAnswers;
  final int? totalQuestions;
  final int? wrongAnswers;
  final String? completedAtLabel;
  final String? durationLabel;
  final String? statusLabel;
  final String? statusMessage;
  final List<LessonAttemptQuestionSnapshot> questions;

  const LessonAttempt({
    required this.id,
    required this.courseId,
    required this.courseTitle,
    required this.lessonId,
    required this.lessonTitle,
    required this.lessonType,
    required this.attemptNumber,
    required this.submittedAt,
    required this.graded,
    required this.questions,
    this.score,
    this.maxScore,
    this.passed,
    this.passingGrade,
    this.correctAnswers,
    this.totalQuestions,
    this.wrongAnswers,
    this.completedAtLabel,
    this.durationLabel,
    this.statusLabel,
    this.statusMessage,
  });

  double get percentage {
    if (score == null || maxScore == null || maxScore == 0) return 0;
    return (score! / maxScore!) * 100;
  }

  bool get isPassedQuiz => passed == true;

  String get resolvedStatusLabel =>
      statusLabel ?? (isPassedQuiz ? 'Lulus' : 'Belum Lulus');

  String get resolvedStatusMessage =>
      statusMessage ??
      (isPassedQuiz
          ? 'Selamat! Anda berhasil menyelesaikan kuis ini dengan baik.'
          : 'Jangan menyerah! Terus belajar dan coba lagi.');

  int get resolvedCorrectAnswers => correctAnswers ?? 0;

  int get resolvedTotalQuestions => totalQuestions ?? questions.length;

  int get resolvedWrongAnswers =>
      wrongAnswers ?? (resolvedTotalQuestions - resolvedCorrectAnswers);

  int get resolvedPassingGrade => passingGrade ?? 0;

  String get attemptLabel {
    final prefix = lessonType == 'quiz' ? 'Tes' : 'Pengumpulan';
    return '$prefix ke-$attemptNumber';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'courseId': courseId,
      'courseTitle': courseTitle,
      'lessonId': lessonId,
      'lessonTitle': lessonTitle,
      'lessonType': lessonType,
      'attemptNumber': attemptNumber,
      'submittedAt': submittedAt.toIso8601String(),
      'graded': graded,
      'score': score,
      'maxScore': maxScore,
      'passed': passed,
      'passingGrade': passingGrade,
      'correctAnswers': correctAnswers,
      'totalQuestions': totalQuestions,
      'wrongAnswers': wrongAnswers,
      'completedAtLabel': completedAtLabel,
      'durationLabel': durationLabel,
      'statusLabel': statusLabel,
      'statusMessage': statusMessage,
      'questions': questions.map((question) => question.toJson()).toList(),
    };
  }

  factory LessonAttempt.fromJson(Map<String, dynamic> json) {
    return LessonAttempt(
      id: json['id']?.toString() ?? '',
      courseId: json['courseId']?.toString() ?? '',
      courseTitle: json['courseTitle']?.toString() ?? '',
      lessonId: json['lessonId']?.toString() ?? '',
      lessonTitle: json['lessonTitle']?.toString() ?? '',
      lessonType: json['lessonType']?.toString() ?? 'quiz',
      attemptNumber: (json['attemptNumber'] as num?)?.toInt() ?? 1,
      submittedAt:
          DateTime.tryParse(json['submittedAt']?.toString() ?? '') ??
          DateTime.now(),
      graded: json['graded'] as bool? ?? false,
      score: (json['score'] as num?)?.toDouble(),
      maxScore: (json['maxScore'] as num?)?.toDouble(),
      passed: json['passed'] as bool?,
      passingGrade: (json['passingGrade'] as num?)?.toInt(),
      correctAnswers: (json['correctAnswers'] as num?)?.toInt(),
      totalQuestions: (json['totalQuestions'] as num?)?.toInt(),
      wrongAnswers: (json['wrongAnswers'] as num?)?.toInt(),
      completedAtLabel: json['completedAtLabel']?.toString(),
      durationLabel: json['durationLabel']?.toString(),
      statusLabel: json['statusLabel']?.toString(),
      statusMessage: json['statusMessage']?.toString(),
      questions: (json['questions'] as List? ?? const [])
          .whereType<Map>()
          .map(
            (entry) => LessonAttemptQuestionSnapshot.fromJson(
              entry.map((key, value) => MapEntry(key.toString(), value)),
            ),
          )
          .toList(),
    );
  }

  @override
  List<Object?> get props => [
    id,
    courseId,
    courseTitle,
    lessonId,
    lessonTitle,
    lessonType,
    attemptNumber,
    submittedAt,
    graded,
    score,
    maxScore,
    passed,
    passingGrade,
    correctAnswers,
    totalQuestions,
    wrongAnswers,
    completedAtLabel,
    durationLabel,
    statusLabel,
    statusMessage,
    questions,
  ];
}
