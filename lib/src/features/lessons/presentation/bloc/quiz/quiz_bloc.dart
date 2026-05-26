/// QuizBloc - State Management
/// Menghandle semua event dan state untuk quiz feature

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import 'package:lms_mobile_app/src/features/lessons/data/models/quiz_model.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/usecases/submit_quiz_usecase.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/usecases/get_quiz_usecase.dart';

part 'quiz_event.dart';
part 'quiz_state.dart';

class QuizBloc extends Bloc<QuizEvent, QuizState> {
  final GetQuizUseCase getQuizUseCase;
  final SubmitQuizUseCase submitQuizUseCase;
  String _lessonId = '';
  String _courseId = '';
  String _courseTitle = '';
  String _lessonTitle = '';
  Timer? _timer;

  QuizBloc({required this.getQuizUseCase, required this.submitQuizUseCase})
    : super(const QuizInitial()) {
    on<FetchQuizEvent>(_onFetchQuiz);
    on<StartQuizEvent>(_onStartQuiz);
    on<SelectAnswerEvent>(_onSelectAnswer);
    on<NextQuestionEvent>(_onNextQuestion);
    on<PreviousQuestionEvent>(_onPreviousQuestion);
    on<GoToQuestionEvent>(_onGoToQuestion);
    on<SubmitQuizEvent>(_onSubmitQuiz);
    on<ResetQuizEvent>(_onResetQuiz);
    on<TimerTickEvent>(_onTimerTick);
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
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

    try {
      final cachedQuiz = getQuizUseCase.peekCached(event.lessonId);
      if (cachedQuiz != null) {
        emit(QuizLoaded(quiz: cachedQuiz));
        return;
      }

      emit(const QuizLoading());
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
      // timeLimit dari server (menit), konversi ke detik; default 30 menit jika 0
      final minutes = currentState.quiz.timeLimit > 0
          ? currentState.quiz.timeLimit
          : 30;
      final totalSeconds = minutes * 60;

      // Cancel previous timer jika ada
      _timer?.cancel();

      // Emit state dengan timer dimulai
      emit(
        currentState.copyWith(isStarted: true, remainingSeconds: totalSeconds),
      );

      // Start countdown timer
      int remaining = totalSeconds;
      _timer = Timer.periodic(Duration(seconds: 1), (timer) {
        if (remaining > 0) {
          remaining--;
          add(TimerTickEvent(remainingSeconds: remaining));
        } else {
          timer.cancel();
          // Auto submit ketika timer habis
          add(const SubmitQuizEvent());
        }
      });
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
      // Cancel timer untuk mencegah memory leak dan auto-submit ganda
      _timer?.cancel();

      final currentState = state as QuizLoaded;
      emit(const QuizLoading());
      try {
        final result = await submitQuizUseCase.call(
          _courseId,
          _courseTitle,
          _lessonId,
          _lessonTitle,
          currentState.quiz,
          currentState.answers,
        );

        emit(
          QuizSubmitted(
            quiz: currentState.quiz,
            result: result,
            answers: currentState.answers,
            attempt: null,
          ),
        );
      } catch (e) {
        emit(QuizError(message: 'Failed to submit quiz: $e'));
      }
    }
  }

  /// Handle ResetQuizEvent - Reset ke state awal
  Future<void> _onResetQuiz(
    ResetQuizEvent event,
    Emitter<QuizState> emit,
  ) async {
    _timer?.cancel();
    emit(const QuizInitial());
  }

  /// Handle TimerTickEvent - Update remaining seconds
  Future<void> _onTimerTick(
    TimerTickEvent event,
    Emitter<QuizState> emit,
  ) async {
    if (state is QuizLoaded) {
      final currentState = state as QuizLoaded;
      emit(currentState.copyWith(remainingSeconds: event.remainingSeconds));
    }
  }
}
