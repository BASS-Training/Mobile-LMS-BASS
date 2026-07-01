// Implementation QuizRepository - Data Layer
// Menghubungkan domain dan data layer

import 'package:flutter/foundation.dart';
import 'package:lms_mobile_app/src/core/utils/offline_test_mode.dart';
import 'package:lms_mobile_app/src/features/lessons/data/datasources/quiz_local_datasource.dart';
import 'package:lms_mobile_app/src/features/lessons/data/datasources/quiz_remote_datasource.dart';
import 'package:lms_mobile_app/src/core/config/flavor_config.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/entities/quiz_entity.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/repositories/quiz_repository.dart';

class QuizRepositoryImpl implements QuizRepository {
  static final Map<String, Quiz> _quizCache = <String, Quiz>{};

  final QuizLocalDataSource localDataSource;
  final QuizRemoteDataSource? remoteDataSource;

  const QuizRepositoryImpl({
    required this.localDataSource,
    this.remoteDataSource,
  });

  /// Debug-only diagnostic logging. Compiled out of release builds.
  void _log(String message) {
    if (kDebugMode) debugPrint(message);
  }

  @override
  Quiz? getCachedQuizByLessonId(String lessonId) {
    return _quizCache[lessonId];
  }

  @override
  void invalidateCachedQuiz(String lessonId) {
    _quizCache.remove(lessonId);
  }

  @override
  void clearQuizCache() {
    _quizCache.clear();
  }

  /// Versi statis dari [clearQuizCache]. Cache quiz bersifat statis (dibagi semua
  /// instance), jadi perlu dibersihkan saat logout agar status lulus/jawaban satu
  /// akun tidak bocor ke akun lain di perangkat yang sama.
  static void clearStaticCache() {
    _quizCache.clear();
  }

  @override
  Future<Quiz> getQuizByLessonId(String lessonId) async {
    try {
      final cachedQuiz = _quizCache[lessonId];
      if (cachedQuiz != null) {
        _log('[QUIZ][FETCH] cache hit for lessonId=$lessonId');
        return cachedQuiz;
      }

      _log(
        '[QUIZ][FETCH] lessonId=$lessonId tester=${OfflineTestMode.describeContext()} remoteAvailable=${remoteDataSource != null} mock=${FlavorConfig.instance.enableMockData}',
      );

      // Decide source: local dummy or remote API
      Map<String, dynamic> quizData;
      if (_isOfflineTestSession() ||
          FlavorConfig.instance.enableMockData ||
          remoteDataSource == null) {
        _log('[QUIZ][FETCH] using local dummy for lessonId=$lessonId');
        quizData = await localDataSource.getQuizByLessonId(lessonId);
      } else {
        _log('[QUIZ][FETCH] using remote API for lessonId=$lessonId');
        quizData = await remoteDataSource!.getQuizByLessonId(lessonId);
      }

      // Defensive: ensure questions is a List — if remote returned null, try local fallback
      List<dynamic> questionItems = <dynamic>[];
      if (quizData['questions'] is List) {
        questionItems.addAll(
          List<dynamic>.from(quizData['questions'] as List<dynamic>),
        );
      } else {
        _log(
          '[QUIZ][FETCH] questions missing/null from selected source, trying local fallback for lessonId=$lessonId',
        );
        try {
          final localQuiz = await localDataSource.getQuizByLessonId(lessonId);
          if (localQuiz['questions'] is List) {
            questionItems.addAll(
              List<dynamic>.from(localQuiz['questions'] as List<dynamic>),
            );
            // merge missing fields from local if necessary
            quizData = {
              'id': quizData['id'] ?? localQuiz['id'],
              'title': quizData['title'] ?? localQuiz['title'] ?? '',
              'timeLimit': quizData['timeLimit'] ?? localQuiz['timeLimit'] ?? 0,
              'passingScore':
                  quizData['passingScore'] ?? localQuiz['passingScore'] ?? 0,
              'questions': questionItems,
            };
          }
        } catch (_) {}
      }

      if (questionItems.isEmpty) {
        _log('[QUIZ][FETCH] local fallback still empty for lessonId=$lessonId');
        final localQuiz = await localDataSource.getQuizByLessonId(lessonId);
        if (localQuiz['questions'] is List) {
          questionItems.addAll(
            List<dynamic>.from(localQuiz['questions'] as List<dynamic>),
          );
          quizData = {
            'id': quizData['id'] ?? localQuiz['id'],
            'title': quizData['title'] ?? localQuiz['title'] ?? '',
            'timeLimit': quizData['timeLimit'] ?? localQuiz['timeLimit'] ?? 0,
            'passingScore':
                quizData['passingScore'] ?? localQuiz['passingScore'] ?? 0,
            'questions': questionItems,
          };
        }
      }

      final baseQuestions = questionItems.map((q) {
        final options = <String>[];
        try {
          options.addAll(List<String>.from(q['options'] as List<dynamic>));
        } catch (_) {}

        int? correct;
        if (q.containsKey('correctIndex')) {
          try {
            correct = q['correctIndex'] as int;
          } catch (_) {
            correct = null;
          }
        }

        return Question(
          id: q.containsKey('id') ? q['id'].toString() : null,
          text: q['text'] as String,
          options: options,
          optionIds: q['optionIds'] is List
              ? List<String>.from(q['optionIds'] as List<dynamic>)
              : null,
          correctIndex: correct,
        );
      }).toList();

      // Use questions exactly as returned from backend / database
      final questions = baseQuestions;

      // Convert to Quiz model
      final quiz = Quiz(
        id: quizData.containsKey('id') ? quizData['id'].toString() : null,
        title: quizData['title'] as String,
        totalQuestions: questions.length,
        timeLimit: quizData['timeLimit'] as int,
        passingScore: quizData['passingScore'] as int,
        enableLeaderboard: quizData['enableLeaderboard'] == true,
        questions: questions,
        userAttempt: quizData['userAttempt'] is Map<String, dynamic>
            ? Map<String, dynamic>.from(quizData['userAttempt'] as Map)
            : null,
        completed: quizData['completed'] == true,
      );

      _quizCache[lessonId] = quiz;
      return quiz;
    } catch (e) {
      throw Exception('Failed to get quiz: $e');
    }
  }

  @override
  Future<QuizResult> submitQuiz(Quiz quiz, Map<int, int> answers) async {
    // Helper to format answers payload
    List<Map<String, dynamic>> formatAnswers() {
      final payload = <Map<String, dynamic>>[];
      for (int i = 0; i < quiz.questions.length; i++) {
        if (!answers.containsKey(i)) continue;
        final selectedIndex = answers[i]!;
        final q = quiz.questions[i];
        final qId = q.id ?? i.toString();
        String? optionId;
        if (q.optionIds != null && selectedIndex < q.optionIds!.length) {
          optionId = q.optionIds![selectedIndex];
        }
        final map = <String, dynamic>{'question_id': qId};
        if (optionId != null) map['option_id'] = optionId;
        payload.add(map);
      }
      return payload;
    }

    // If remote datasource available and quiz has id, prefer server grading/persistence
    final payload = formatAnswers();
    if (!_isOfflineTestSession() &&
        quiz.id != null &&
        remoteDataSource != null) {
      _log(
        '[QUIZ][SUBMIT] using remote submit quizId=${quiz.id} tester=${OfflineTestMode.describeContext()}',
      );
      try {
        final attemptId = await remoteDataSource!.startQuizAttempt(quiz.id!);
        final data = await remoteDataSource!.submitQuizAttempt(
          quiz.id!,
          attemptId,
          payload,
        );
        final score = (data['score'] as num?)?.toInt() ?? 0;
        final total = (data['total'] as num?)?.toInt() ?? quiz.totalQuestions;
        return QuizResult(
          score: score,
          total: total,
          passingScore: quiz.passingScore,
        );
      } catch (_) {
        // fallthrough to client-side grading
      }
    }

    _log(
      '[QUIZ][SUBMIT] using local/client grading quizId=${quiz.id} tester=${OfflineTestMode.describeContext()}',
    );
    // Client-side grading fallback
    int correctCount = 0;
    for (int i = 0; i < quiz.totalQuestions; i++) {
      if (answers.containsKey(i) &&
          answers[i] == quiz.questions[i].correctIndex) {
        correctCount++;
      }
    }

    return QuizResult(
      score: correctCount,
      total: quiz.totalQuestions,
      passingScore: quiz.passingScore,
    );
  }

  @override
  Future<QuizLeaderboard> getLeaderboard(String quizId) async {
    if (remoteDataSource == null || _isOfflineTestSession()) {
      return QuizLeaderboard(
        quizTitle: '',
        totalParticipants: 0,
        currentUserRank: null,
        entries: const [],
      );
    }

    final data = await remoteDataSource!.fetchLeaderboard(quizId);
    final rawEntries = data['entries'];
    final entries = (rawEntries is List ? rawEntries : const [])
        .whereType<Map<String, dynamic>>()
        .map(
          (e) => QuizLeaderboardEntry(
            rank: (e['rank'] as num?)?.toInt() ?? 0,
            name: (e['name'] ?? '') as String,
            score: (e['score'] as num?)?.toInt() ?? 0,
            totalMarks: (e['totalMarks'] as num?)?.toInt() ?? 0,
            percentage: (e['percentage'] as num?)?.toDouble() ?? 0,
            passed: e['passed'] == true,
            isCurrentUser: e['isCurrentUser'] == true,
          ),
        )
        .toList();

    return QuizLeaderboard(
      quizTitle: (data['quizTitle'] ?? '') as String,
      totalParticipants:
          (data['totalParticipants'] as num?)?.toInt() ?? entries.length,
      currentUserRank: (data['currentUserRank'] as num?)?.toInt(),
      entries: entries,
    );
  }

  bool _isOfflineTestSession() {
    return OfflineTestMode.isActive();
  }
}
