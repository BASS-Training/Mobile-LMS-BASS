import 'package:flutter_bloc/flutter_bloc.dart';

import 'video_event.dart';
import 'video_state.dart';

/// Gates the "Next" button for video lessons: the learner may proceed once the
/// video is (near) finished, or if the lesson was already completed. Discussion
/// now lives in the shared `DiscussionCubit`, so this bloc no longer handles
/// comments.
class VideoBloc extends Bloc<VideoEvent, VideoState> {
  VideoBloc() : super(const VideoState()) {
    on<InitVideoLesson>((event, emit) {
      emit(state.copyWith(canProceed: event.isCompleted));
    });

    on<VideoProgressUpdated>((event, emit) {
      if (state.canProceed) return;

      final reachedThreshold =
          event.currentPositionSeconds >= (event.totalDurationSeconds - 10);
      if (reachedThreshold) {
        emit(state.copyWith(canProceed: true));
      }
    });
  }
}
