import 'package:equatable/equatable.dart';

/// Tolerant numeric parsing — the backend (MySQL aggregates / decimal columns)
/// can return numbers as strings, so a plain `as num` cast would crash.
int? _asInt(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse(v.toString()) ?? double.tryParse(v.toString())?.toInt();
}

num? _asNum(dynamic v) {
  if (v == null) return null;
  if (v is num) return v;
  return num.tryParse(v.toString());
}

/// One enrolled participant with a concise progress snapshot for a course.
class ParticipantProgress extends Equatable {
  final String id;
  final String name;
  final String email;
  final double progressPercentage;
  final int completedContents;
  final int totalContents;
  final int completedLessons;

  /// How many of this participant's submissions still await grading.
  final int pendingGrading;

  const ParticipantProgress({
    required this.id,
    required this.name,
    required this.email,
    required this.progressPercentage,
    required this.completedContents,
    required this.totalContents,
    required this.completedLessons,
    required this.pendingGrading,
  });

  factory ParticipantProgress.fromJson(Map<String, dynamic> json) {
    return ParticipantProgress(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Peserta',
      email: json['email']?.toString() ?? '',
      progressPercentage: _asNum(json['progressPercentage'])?.toDouble() ?? 0,
      completedContents: _asInt(json['completedContents']) ?? 0,
      totalContents: _asInt(json['totalContents']) ?? 0,
      completedLessons: _asInt(json['completedLessons']) ?? 0,
      pendingGrading: _asInt(json['pendingGrading']) ?? 0,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    email,
    progressPercentage,
    completedContents,
    totalContents,
    completedLessons,
    pendingGrading,
  ];
}

/// An essay / case-study submission shown in the grading queue.
class GradingQueueItem extends Equatable {
  final String submissionId;
  final String type; // 'essay' | 'case_study'
  final String participantId;
  final String participantName;
  final String contentId;
  final String contentTitle;
  final String lessonTitle;
  final bool scoringEnabled;
  final String status; // 'pending' | 'graded'
  final String? submittedAt;

  const GradingQueueItem({
    required this.submissionId,
    required this.type,
    required this.participantId,
    required this.participantName,
    required this.contentId,
    required this.contentTitle,
    required this.lessonTitle,
    required this.scoringEnabled,
    required this.status,
    this.submittedAt,
  });

  bool get isEssay => type == 'essay';
  bool get isPending => status == 'pending';

  factory GradingQueueItem.fromJson(Map<String, dynamic> json) {
    return GradingQueueItem(
      submissionId: json['submissionId']?.toString() ?? '',
      type: json['type']?.toString() ?? 'essay',
      participantId: json['participantId']?.toString() ?? '',
      participantName: json['participantName']?.toString() ?? 'Peserta',
      contentId: json['contentId']?.toString() ?? '',
      contentTitle: json['contentTitle']?.toString() ?? '',
      lessonTitle: json['lessonTitle']?.toString() ?? '',
      scoringEnabled: json['scoringEnabled'] != false,
      status: json['status']?.toString() ?? 'pending',
      submittedAt: json['submittedAt']?.toString(),
    );
  }

  @override
  List<Object?> get props => [
    submissionId,
    type,
    participantId,
    participantName,
    contentId,
    contentTitle,
    lessonTitle,
    scoringEnabled,
    status,
    submittedAt,
  ];
}

/// One question+answer pair inside an essay submission being graded.
class EssayAnswerItem extends Equatable {
  final String answerId;
  final String questionId;
  final String question;
  final int maxScore;
  final String answer;
  final int? score;
  final String? feedback;

  const EssayAnswerItem({
    required this.answerId,
    required this.questionId,
    required this.question,
    required this.maxScore,
    required this.answer,
    this.score,
    this.feedback,
  });

  factory EssayAnswerItem.fromJson(Map<String, dynamic> json) {
    return EssayAnswerItem(
      answerId: json['answerId']?.toString() ?? '',
      questionId: json['questionId']?.toString() ?? '',
      question: json['question']?.toString() ?? '',
      maxScore: _asInt(json['maxScore']) ?? 0,
      answer: json['answer']?.toString() ?? '',
      score: _asInt(json['score']),
      feedback: json['feedback']?.toString(),
    );
  }

  @override
  List<Object?> get props =>
      [answerId, questionId, question, maxScore, answer, score, feedback];
}

/// Full essay submission detail for the grading screen.
class EssaySubmissionDetail extends Equatable {
  final String submissionId;
  final String participantName;
  final String contentTitle;
  final bool scoringEnabled;
  final String gradingMode; // 'individual' | 'overall'
  final bool requiresReview;
  final String status;
  final bool isFullyGraded;
  final num? totalScore;
  final num? maxTotalScore;
  final List<EssayAnswerItem> answers;

  const EssaySubmissionDetail({
    required this.submissionId,
    required this.participantName,
    required this.contentTitle,
    required this.scoringEnabled,
    required this.gradingMode,
    required this.requiresReview,
    required this.status,
    required this.isFullyGraded,
    required this.answers,
    this.totalScore,
    this.maxTotalScore,
  });

  bool get isOverall => gradingMode == 'overall';

  factory EssaySubmissionDetail.fromJson(Map<String, dynamic> json) {
    final rawAnswers = json['answers'];
    final answers = <EssayAnswerItem>[];
    if (rawAnswers is List) {
      for (final a in rawAnswers) {
        if (a is Map) {
          answers.add(EssayAnswerItem.fromJson(Map<String, dynamic>.from(a)));
        }
      }
    }
    return EssaySubmissionDetail(
      submissionId: json['submissionId']?.toString() ?? '',
      participantName: json['participantName']?.toString() ?? 'Peserta',
      contentTitle: json['contentTitle']?.toString() ?? '',
      scoringEnabled: json['scoringEnabled'] != false,
      gradingMode: json['gradingMode']?.toString() ?? 'individual',
      requiresReview: json['requiresReview'] != false,
      status: json['status']?.toString() ?? 'submitted',
      isFullyGraded: json['isFullyGraded'] == true,
      totalScore: _asNum(json['totalScore']),
      maxTotalScore: _asNum(json['maxTotalScore']),
      answers: answers,
    );
  }

  @override
  List<Object?> get props => [
    submissionId,
    participantName,
    contentTitle,
    scoringEnabled,
    gradingMode,
    requiresReview,
    status,
    isFullyGraded,
    totalScore,
    maxTotalScore,
    answers,
  ];
}
