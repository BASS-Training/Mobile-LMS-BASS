import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/repositories/feedback_repository.dart';

import 'feedback_event.dart';
import 'feedback_state.dart';

class FeedbackBloc extends Bloc<FeedbackEvent, FeedbackState> {
  final FeedbackRepository repository;

  FeedbackBloc({required this.repository}) : super(const FeedbackState()) {
    on<LoadFeedback>(_onLoad);
    on<SubmitFeedback>(_onSubmit);
    on<ClearFeedbackMessage>(_onClearMessage);
  }

  Future<void> _onLoad(LoadFeedback event, Emitter<FeedbackState> emit) async {
    emit(state.copyWith(status: FeedbackStatus.loading, clearMessages: true));
    try {
      final data = await repository.getByLesson(event.lessonId);
      emit(state.copyWith(status: FeedbackStatus.loaded, data: data));
    } catch (e) {
      emit(
        state.copyWith(
          status: FeedbackStatus.error,
          errorMessage: e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  Future<void> _onSubmit(
    SubmitFeedback event,
    Emitter<FeedbackState> emit,
  ) async {
    emit(state.copyWith(submitting: true, clearMessages: true));
    try {
      final submission = await repository.submit(event.lessonId, event.answers);
      emit(
        state.copyWith(
          submitting: false,
          data: state.data?.copyWith(submission: submission),
          justSubmitted: true,
          infoMessage: 'Terima kasih! Tanggapan Anda terkirim.',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          submitting: false,
          errorMessage: e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  void _onClearMessage(
    ClearFeedbackMessage event,
    Emitter<FeedbackState> emit,
  ) {
    emit(state.copyWith(clearMessages: true));
  }
}
