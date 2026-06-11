import 'package:equatable/equatable.dart';

/// Satu opsi untuk pertanyaan pilihan (single/multi choice).
class FeedbackOptionEntity extends Equatable {
  final String id;
  final String label;

  const FeedbackOptionEntity({required this.id, required this.label});

  @override
  List<Object?> get props => [id, label];
}

/// Satu pertanyaan pada form feedback.
class FeedbackQuestionEntity extends Equatable {
  final String id;
  final String type; // rating | single_choice | multi_choice | text
  final String question;
  final String? helpText;
  final bool isRequired;
  final Map<String, dynamic> config;

  const FeedbackQuestionEntity({
    required this.id,
    required this.type,
    required this.question,
    this.helpText,
    this.isRequired = false,
    this.config = const {},
  });

  bool get isRating => type == 'rating';
  bool get isSingleChoice => type == 'single_choice';
  bool get isMultiChoice => type == 'multi_choice';
  bool get isText => type == 'text';

  int get ratingMax => (config['max'] as num?)?.toInt() ?? 5;
  String? get minLabel => (config['min_label']?.toString().isNotEmpty ?? false)
      ? config['min_label'].toString()
      : null;
  String? get maxLabel => (config['max_label']?.toString().isNotEmpty ?? false)
      ? config['max_label'].toString()
      : null;

  List<FeedbackOptionEntity> get options {
    final raw = config['options'];
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map(
          (o) => FeedbackOptionEntity(
            id: o['id']?.toString() ?? '',
            label: o['label']?.toString() ?? '',
          ),
        )
        .toList();
  }

  @override
  List<Object?> get props => [id, type, question, helpText, isRequired, config];
}

/// Jawaban satu pertanyaan yang sudah tersimpan.
class FeedbackAnswerEntity extends Equatable {
  final int? rating;
  final String? text;
  final List<String> choice;

  const FeedbackAnswerEntity({this.rating, this.text, this.choice = const []});

  @override
  List<Object?> get props => [rating, text, choice];
}

/// Pengiriman feedback milik user.
class FeedbackSubmissionEntity extends Equatable {
  final String submissionId;
  final String status; // submitted
  final String? submittedAt;
  final Map<String, FeedbackAnswerEntity> answers; // questionId -> answer

  const FeedbackSubmissionEntity({
    required this.submissionId,
    required this.status,
    this.submittedAt,
    this.answers = const {},
  });

  bool get isSubmitted => status == 'submitted';

  @override
  List<Object?> get props => [submissionId, status, submittedAt, answers];
}

/// Payload lengkap konten feedback (definisi form + submission user).
class FeedbackEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final String courseId;
  final bool isAnonymous;
  final List<FeedbackQuestionEntity> questions;
  final FeedbackSubmissionEntity? submission;

  const FeedbackEntity({
    required this.id,
    required this.title,
    this.description = '',
    this.courseId = '',
    this.isAnonymous = false,
    this.questions = const [],
    this.submission,
  });

  FeedbackEntity copyWith({FeedbackSubmissionEntity? submission}) {
    return FeedbackEntity(
      id: id,
      title: title,
      description: description,
      courseId: courseId,
      isAnonymous: isAnonymous,
      questions: questions,
      submission: submission ?? this.submission,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    courseId,
    isAnonymous,
    questions,
    submission,
  ];
}
