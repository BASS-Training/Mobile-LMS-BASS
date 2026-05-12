import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/entities/comment_entity.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/repositories/video_repository.dart';

import 'video_event.dart';
import 'video_state.dart';

class VideoBloc extends Bloc<VideoEvent, VideoState> {
  final VideoRepository repository;

  VideoBloc(this.repository) : super(const VideoState()) {
    
    on<InitVideoLesson>((event, emit) async {
      // Inisialisasi status tombol "Next" dan ambil data komentar
      final comments = await repository.getComments(event.lessonId);
      emit(state.copyWith(
        canProceed: event.isCompleted,
        comments: comments,
      ));
    });

    on<VideoProgressUpdated>((event, emit) {
      if (state.canProceed) return; // Jika sudah bisa lanjut, hiraukan

      // Logika bisnis 10 detik pindah ke sini
      final remaining = event.totalDurationSeconds - event.currentPositionSeconds;
      final reachedThreshold = remaining <= 10 || event.currentPositionSeconds >= (event.totalDurationSeconds - 10);

      if (reachedThreshold) {
        emit(state.copyWith(canProceed: true));
      }
    });

    on<SubmitDiscussionComment>((event, emit) async {
      final newComment = CommentEntity(
        userName: 'Anda', 
        message: event.message, 
        timeLabel: 'Baru saja',
      );
      
      await repository.addComment(event.lessonId, newComment);
      final updatedComments = await repository.getComments(event.lessonId);
      
      emit(state.copyWith(comments: List.from(updatedComments)));
    });
  }
}