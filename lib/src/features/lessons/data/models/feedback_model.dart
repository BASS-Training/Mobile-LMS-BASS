import 'package:lms_mobile_app/src/features/lessons/domain/entities/feedback_entity.dart';

/// Parsing JSON dari endpoint `feedback/by-lesson/{id}` menjadi entitas domain.
class FeedbackModel {
  static FeedbackEntity fromApi(Map<String, dynamic> data) {
    final questions = <FeedbackQuestionEntity>[];
    if (data['questions'] is List) {
      for (final q in (data['questions'] as List)) {
        if (q is Map) {
          questions.add(_questionFromJson(Map<String, dynamic>.from(q)));
        }
      }
    }

    FeedbackSubmissionEntity? submission;
    final sub = data['submission'];
    if (sub is Map) {
      submission = _submissionFromJson(Map<String, dynamic>.from(sub));
    }

    return FeedbackEntity(
      id: data['id']?.toString() ?? '',
      title: data['title']?.toString() ?? '',
      description: data['description']?.toString() ?? '',
      courseId: data['courseId']?.toString() ?? '',
      isAnonymous: data['isAnonymous'] == true,
      questions: questions,
      submission: submission,
    );
  }

  static FeedbackQuestionEntity _questionFromJson(Map<String, dynamic> json) {
    final rawConfig = json['config'];
    return FeedbackQuestionEntity(
      id: json['id']?.toString() ?? '',
      type: json['type']?.toString() ?? 'text',
      question: json['question']?.toString() ?? '',
      helpText: json['helpText']?.toString(),
      isRequired: json['isRequired'] == true,
      config: rawConfig is Map
          ? Map<String, dynamic>.from(rawConfig)
          : const {},
    );
  }

  static FeedbackSubmissionEntity _submissionFromJson(
    Map<String, dynamic> json,
  ) {
    final answers = <String, FeedbackAnswerEntity>{};
    final rawAnswers = json['answers'];
    if (rawAnswers is Map) {
      rawAnswers.forEach((k, v) {
        if (v is Map) {
          final choiceRaw = v['choice'];
          answers[k.toString()] = FeedbackAnswerEntity(
            rating: (v['rating'] as num?)?.toInt(),
            text: v['text']?.toString(),
            choice: choiceRaw is List
                ? choiceRaw.map((e) => e.toString()).toList()
                : const [],
          );
        }
      });
    }
    return FeedbackSubmissionEntity(
      submissionId: json['submissionId']?.toString() ?? '',
      status: json['status']?.toString() ?? 'submitted',
      submittedAt: json['submittedAt']?.toString(),
      answers: answers,
    );
  }
}
