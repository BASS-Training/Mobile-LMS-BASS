/// QuizBloc - State Management
/// Menghandle semua event dan state untuk quiz feature

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms_mobile_app/src/features/lessons/data/models/quiz_model.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:lms_mobile_app/src/core/config/flavor_config.dart';
import 'package:lms_mobile_app/src/core/config/constants/api_endpoints.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/entities/lesson_attempt_entity.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/repositories/lesson_result_repository.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/usecases/get_quiz_usecase.dart';

part 'quiz_event.dart';
part 'quiz_state.dart';

class QuizBloc extends Bloc<QuizEvent, QuizState> {
  final GetQuizUseCase getQuizUseCase;
  final LessonResultRepository? resultRepository;
  String _lessonId = '';
  String _courseId = '';
  String _courseTitle = '';
  String _lessonTitle = '';

  QuizBloc({required this.getQuizUseCase, this.resultRepository})
    : super(const QuizInitial()) {
    on<FetchQuizEvent>(_onFetchQuiz);
    on<StartQuizEvent>(_onStartQuiz);
    on<SelectAnswerEvent>(_onSelectAnswer);
    on<NextQuestionEvent>(_onNextQuestion);
    on<PreviousQuestionEvent>(_onPreviousQuestion);
    on<GoToQuestionEvent>(_onGoToQuestion);
    on<SubmitQuizEvent>(_onSubmitQuiz);
    on<ResetQuizEvent>(_onResetQuiz);
  }

  /// Handle FetchQuizEvent - Load quiz dari data source
  Future<void> _onFetchQuiz(
    FetchQuizEvent event,
    Emitter<QuizState> emit,
  ) async {
    _lessonId = event.lessonId;
    _courseId = event.courseId;
    _courseTitle = event.courseTitle;
    _lessonTitle = event.lessonTitle;

    emit(const QuizLoading());
    try {
      final quiz = await getQuizUseCase.call(event.lessonId);
      emit(QuizLoaded(quiz: quiz));
    } catch (e) {
      emit(QuizError(message: e.toString()));
    }
  }

  /// Handle StartQuizEvent - Mulai quiz
  Future<void> _onStartQuiz(
    StartQuizEvent event,
    Emitter<QuizState> emit,
  ) async {
    if (state is QuizLoaded) {
      final currentState = state as QuizLoaded;
      emit(currentState.copyWith(isStarted: true));
    }
  }

  /// Handle SelectAnswerEvent - Simpan jawaban user
  Future<void> _onSelectAnswer(
    SelectAnswerEvent event,
    Emitter<QuizState> emit,
  ) async {
    if (state is QuizLoaded) {
      final currentState = state as QuizLoaded;
      final updatedAnswers = Map<int, int>.from(currentState.answers);
      updatedAnswers[event.questionIndex] = event.selectedOptionIndex;

      emit(currentState.copyWith(answers: updatedAnswers));
    }
  }

  /// Handle NextQuestionEvent - Ke soal berikutnya
  Future<void> _onNextQuestion(
    NextQuestionEvent event,
    Emitter<QuizState> emit,
  ) async {
    if (state is QuizLoaded) {
      final currentState = state as QuizLoaded;
      final nextIndex = currentState.currentQuestionIndex + 1;

      if (nextIndex < currentState.quiz.totalQuestions) {
        emit(currentState.copyWith(currentQuestionIndex: nextIndex));
      }
    }
  }

  /// Handle PreviousQuestionEvent - Ke soal sebelumnya
  Future<void> _onPreviousQuestion(
    PreviousQuestionEvent event,
    Emitter<QuizState> emit,
  ) async {
    if (state is QuizLoaded) {
      final currentState = state as QuizLoaded;
      final prevIndex = currentState.currentQuestionIndex - 1;

      if (prevIndex >= 0) {
        emit(currentState.copyWith(currentQuestionIndex: prevIndex));
      }
    }
  }

  /// Handle GoToQuestionEvent - Jump ke soal tertentu
  Future<void> _onGoToQuestion(
    GoToQuestionEvent event,
    Emitter<QuizState> emit,
  ) async {
    if (state is QuizLoaded) {
      final currentState = state as QuizLoaded;
      if (event.questionIndex >= 0 &&
          event.questionIndex < currentState.quiz.totalQuestions) {
        emit(currentState.copyWith(currentQuestionIndex: event.questionIndex));
      }
    }
  }

  /// Handle SubmitQuizEvent - Hitung hasil dan emit QuizSubmitted state
  Future<void> _onSubmitQuiz(
    SubmitQuizEvent event,
    Emitter<QuizState> emit,
  ) async {
    if (state is QuizLoaded) {
      final currentState = state as QuizLoaded;
      final quiz = currentState.quiz;
      final answers = currentState.answers;

      // If server does not expose correctIndex (server-graded), call API to submit
      if (quiz.questions.any((q) => q.correctIndex == null) &&
          quiz.id != null) {
        try {
          final baseUrl = FlavorConfig.instance.apiBaseUrl;
          final startEndpoint = ApiEndpoints.startQuizAttempt.replaceFirst(
            '{quiz}',
            quiz.id!,
          );
          final startUrl = Uri.parse('$baseUrl$startEndpoint');

          final startResp = await http.post(
            startUrl,
            headers: {'Content-Type': 'application/json'},
          );
          if (!(startResp.statusCode == 200 || startResp.statusCode == 201))
            throw Exception('Start attempt failed ${startResp.statusCode}');
          final startJson = json.decode(startResp.body) as Map<String, dynamic>;
          final attemptId = startJson['data']?['attemptId']?.toString();

          // Build answers payload
          final payloadAnswers = <Map<String, dynamic>>[];
          for (int i = 0; i < quiz.questions.length; i++) {
            if (!answers.containsKey(i)) continue;
            final selectedIndex = answers[i]!;
            final q = quiz.questions[i];
            final qId = q.id ?? i.toString();
            String? optionId;
            if (q.optionIds != null && selectedIndex < q.optionIds!.length) {
              optionId = q.optionIds![selectedIndex];
            }
            payloadAnswers.add({
              'question_id': qId,
              if (optionId != null) 'option_id': optionId,
            });
          }

          final submitEndpoint = ApiEndpoints.submitQuizAttempt
              .replaceFirst('{quiz}', quiz.id!)
              .replaceFirst('{attempt}', attemptId ?? '');
          final submitUrl = Uri.parse('$baseUrl$submitEndpoint');
          final submitResp = await http.post(
            submitUrl,
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'answers': payloadAnswers}),
          );
          if (submitResp.statusCode != 200)
            throw Exception('Submit failed ${submitResp.statusCode}');
          final submitJson =
              json.decode(submitResp.body) as Map<String, dynamic>;
          final data = submitJson['data'] as Map<String, dynamic>?;

          final score = (data?['score'] as num?)?.toInt() ?? 0;
          final total =
              (data?['total'] as num?)?.toInt() ?? quiz.totalQuestions;
          final passed = data?['passed'] as bool? ?? false;

          final result = QuizResult(score: score, total: total);

          dynamic savedAttempt;
          if (resultRepository != null) {
            try {
              final questions = quiz.questions.asMap().entries.map((entry) {
                return LessonAttemptQuestionSnapshot(
                  questionIndex: entry.key,
                  questionText: entry.value.text,
                  options: List<String>.from(entry.value.options),
                  correctOptionIndex: entry.value.correctIndex,
                  selectedOptionIndex: answers[entry.key],
                );
              }).toList();

              savedAttempt = await resultRepository!.recordQuizAttempt(
                courseId: _courseId,
                courseTitle: _courseTitle,
                lessonId: _lessonId,
                lessonTitle: _lessonTitle,
                questions: questions,
                score: score,
                maxScore: total,
                passed: passed,
              );
            } catch (_) {}
          }

          emit(
            QuizSubmitted(
              quiz: quiz,
              result: result,
              answers: answers,
              attempt: savedAttempt,
            ),
          );
          return;
        } catch (e) {
          emit(QuizError(message: 'Failed to submit quiz: $e'));
          return;
        }
      }

      // Fallback: client-side grading (for dummy/local quizzes)
      int correctCount = 0;
      for (int i = 0; i < quiz.totalQuestions; i++) {
        if (answers.containsKey(i) &&
            answers[i] == quiz.questions[i].correctIndex) {
          correctCount++;
        }
      }

      // Buat result
      final result = QuizResult(
        score: correctCount,
        total: quiz.totalQuestions,
      );

      dynamic savedAttempt;
      if (resultRepository != null) {
        try {
          final questions = quiz.questions.asMap().entries.map((entry) {
            return LessonAttemptQuestionSnapshot(
              questionIndex: entry.key,
              questionText: entry.value.text,
              options: List<String>.from(entry.value.options),
              correctOptionIndex: entry.value.correctIndex,
              selectedOptionIndex: answers[entry.key],
            );
          }).toList();

          savedAttempt = await resultRepository!.recordQuizAttempt(
            courseId: _courseId,
            courseTitle: _courseTitle,
            lessonId: _lessonId,
            lessonTitle: _lessonTitle,
            questions: questions,
            score: correctCount,
            maxScore: quiz.totalQuestions,
            passed: result.passed,
          );
        } catch (_) {
          // Keep quiz submission flow intact even if local history save fails.
        }
      }

      // Also persist user's answers to server if quiz has an id
      if (quiz.id != null) {
        try {
          final baseUrl = FlavorConfig.instance.apiBaseUrl;
          final startEndpoint = ApiEndpoints.startQuizAttempt.replaceFirst(
            '{quiz}',
            quiz.id!,
          );
          final startUrl = Uri.parse('$baseUrl$startEndpoint');

          final startResp = await http.post(
            startUrl,
            headers: {'Content-Type': 'application/json'},
          );
          if (startResp.statusCode == 200 || startResp.statusCode == 201) {
            final startJson =
                json.decode(startResp.body) as Map<String, dynamic>;
            final attemptId = startJson['data']?['attemptId']?.toString();

            // Build answers payload
            final payloadAnswers = <Map<String, dynamic>>[];
            for (int i = 0; i < quiz.questions.length; i++) {
              if (!answers.containsKey(i)) continue;
              final selectedIndex = answers[i]!;
              final q = quiz.questions[i];
              final qId = q.id ?? i.toString();
              String? optionId;
              if (q.optionIds != null && selectedIndex < q.optionIds!.length) {
                optionId = q.optionIds![selectedIndex];
              }
              payloadAnswers.add({
                'question_id': qId,
                if (optionId != null) 'option_id': optionId,
              });
            }

            final submitEndpoint = ApiEndpoints.submitQuizAttempt
                .replaceFirst('{quiz}', quiz.id!)
                .replaceFirst('{attempt}', attemptId ?? '');
            final submitUrl = Uri.parse('$baseUrl$submitEndpoint');
            final submitResp = await http.post(
              submitUrl,
              headers: {'Content-Type': 'application/json'},
              body: json.encode({'answers': payloadAnswers}),
            );
            if (submitResp.statusCode == 200) {
              final submitJson =
                  json.decode(submitResp.body) as Map<String, dynamic>;
              final data = submitJson['data'] as Map<String, dynamic>?;

              final serverScore = (data?['score'] as num?)?.toInt();
              final serverTotal = (data?['total'] as num?)?.toInt();

              if (serverScore != null) {
                // Override result with server-computed values
                final serverResult = QuizResult(
                  score: serverScore,
                  total: serverTotal ?? result.total,
                );
                emit(
                  QuizSubmitted(
                    quiz: quiz,
                    result: serverResult,
                    answers: answers,
                    attempt: savedAttempt,
                  ),
                );
                return;
              }
            }
          }
        } catch (_) {
          // ignore server persistence errors; we'll still emit local result
        }
      }

      emit(
        QuizSubmitted(
          quiz: quiz,
          result: result,
          answers: answers,
          attempt: savedAttempt,
        ),
      );
    }
  }

  /// Handle ResetQuizEvent - Reset ke state awal
  Future<void> _onResetQuiz(
    ResetQuizEvent event,
    Emitter<QuizState> emit,
  ) async {
    emit(const QuizInitial());
  }
}
