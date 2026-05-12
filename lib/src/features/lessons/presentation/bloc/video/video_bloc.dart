import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/usecases/video_lesson_usecase.dart.dart';
import 'video_event.dart';
import 'video_state.dart';

class VideoBloc extends Bloc<VideoEvent, VideoState> {
  final GetVideoCommentsUseCase getCommentsUseCase;
  final SubmitVideoCommentUseCase submitCommentUseCase;
  final MarkVideoCompleteUseCase markCompleteUseCase;
  final CheckVideoProgressUseCase checkProgressUseCase;

  VideoBloc({
    required this.getCommentsUseCase,
    required this.submitCommentUseCase,
    required this.markCompleteUseCase,
    required this.checkProgressUseCase,
  }) : super(const VideoState()) {
    
    on<LoadVideoContent>((event, emit) async {
      emit(state.copyWith(isLoading: true, canProceed: event.isCompleted));
      try {
        final comments = await getCommentsUseCase.execute(event.lessonId);
        emit(state.copyWith(isLoading: false, comments: comments));
      } catch (e) {
        emit(state.copyWith(isLoading: false));
        // Bisa tambahkan error state jika diperlukan
      }
    });

    on<UpdateVideoProgress>((event, emit) async {
      // Jika sudah bisa lanjut, abaikan pengecekan progress
      if (state.canProceed) return;

      final isFinished = checkProgressUseCase.execute(event.position, event.totalDuration);
      
      if (isFinished) {
        emit(state.copyWith(canProceed: true));
        try {
          await markCompleteUseCase.execute(event.lessonId);
          emit(state.copyWith(isSuccessMarkComplete: true));
        } catch (e) {
          // Tangani error API jika mark complete gagal
        }
      }
    });

    on<SubmitComment>((event, emit) async {
      try {
        await submitCommentUseCase.execute(event.lessonId, event.message);
        // Refresh komentar setelah submit
        final updatedComments = await getCommentsUseCase.execute(event.lessonId);
        emit(state.copyWith(comments: updatedComments));
      } catch (e) {
        // Tangani error
      }
    });

    on<ResetSuccessMark>((event, emit) {
      emit(state.copyWith(isSuccessMarkComplete: false));
    });
  }
}