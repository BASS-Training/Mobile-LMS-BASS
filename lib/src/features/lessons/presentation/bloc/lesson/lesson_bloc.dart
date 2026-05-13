import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/usecases/is_lesson_completed_usecase.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/usecases/mark_lesson_complete_usecase.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/usecases/mark_lesson_incomplete_usecase.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/usecases/refresh_lesson_completion_usecase.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/usecases/toggle_lesson_completion_usecase.dart';
import 'lesson_event.dart';
import 'lesson_state.dart';

class LessonBloc extends Bloc<LessonEvent, LessonState> {
  final IsLessonCompletedUseCase isLessonCompletedUseCase;
  final ToggleLessonCompletionUseCase toggleLessonCompletionUseCase;
  final MarkLessonCompleteUseCase markLessonCompleteUseCase;
  final MarkLessonIncompleteUseCase markLessonIncompleteUseCase;
  final RefreshLessonCompletionUseCase refreshLessonCompletionUseCase;

  LessonBloc({
    required this.isLessonCompletedUseCase,
    required this.toggleLessonCompletionUseCase,
    required this.markLessonCompleteUseCase,
    required this.markLessonIncompleteUseCase,
    required this.refreshLessonCompletionUseCase,
  }) : super(const LessonInitial()) {
    on<CheckLessonCompletionEvent>(_onCheckLessonCompletion);
    on<ToggleLessonCompletionEvent>(_onToggleLessonCompletion);
    on<MarkLessonCompleteEvent>(_onMarkLessonComplete);
    on<MarkLessonIncompleteEvent>(_onMarkLessonIncomplete);
    on<RefreshLessonCompletionEvent>(_onRefreshLessonCompletion);
  }

  Future<void> _onCheckLessonCompletion(
      CheckLessonCompletionEvent event, Emitter<LessonState> emit) async {
    emit(const LessonLoading());

    try {
      final isCompleted = await isLessonCompletedUseCase(event.lessonId);
      emit(LessonCompletionChecked(isCompleted: isCompleted));
    } catch (e) {
      emit(const LessonFailure(message: 'Failed to check completion status'));
    }
  }

  Future<void> _onToggleLessonCompletion(
      ToggleLessonCompletionEvent event, Emitter<LessonState> emit) async {
    try {
      await toggleLessonCompletionUseCase(event.lessonId);
      emit(LessonCompletionToggled(lessonId: event.lessonId));
    } catch (e) {
      emit(const LessonFailure(message: 'Failed to toggle completion'));
    }
  }

  Future<void> _onMarkLessonComplete(
      MarkLessonCompleteEvent event, Emitter<LessonState> emit) async {
    try {
      await markLessonCompleteUseCase(event.lessonId);
      emit(LessonMarkedComplete(lessonId: event.lessonId));
    } catch (e) {
      emit(const LessonFailure(message: 'Failed to mark lesson complete'));
    }
  }

  Future<void> _onMarkLessonIncomplete(
      MarkLessonIncompleteEvent event, Emitter<LessonState> emit) async {
    try {
      await markLessonIncompleteUseCase(event.lessonId);
      emit(LessonMarkedIncomplete(lessonId: event.lessonId));
    } catch (e) {
      emit(const LessonFailure(message: 'Failed to mark lesson incomplete'));
    }
  }

  Future<void> _onRefreshLessonCompletion(
      RefreshLessonCompletionEvent event, Emitter<LessonState> emit) async {
    try {
      await refreshLessonCompletionUseCase();
      emit(const LessonInitial());
    } catch (e) {
      emit(const LessonFailure(message: 'Failed to refresh completion status'));
    }
  }
}
