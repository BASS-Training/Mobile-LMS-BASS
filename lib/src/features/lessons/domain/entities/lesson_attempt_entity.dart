import 'package:equatable/equatable.dart';

class LessonAttemptQuestionSnapshot extends Equatable {
  final int questionIndex;
  final String questionText;
  final List<String> options;
  final int? correctOptionIndex;
  final int? selectedOptionIndex;
  final String? writtenAnswer;

  const LessonAttemptQuestionSnapshot({
    required this.questionIndex,
    required this.questionText,
    required this.options,
    this.correctOptionIndex,
    this.selectedOptionIndex,
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
  });

  double get percentage {
    if (score == null || maxScore == null || maxScore == 0) return 0;
    return (score! / maxScore!) * 100;
  }

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
    questions,
  ];
}
