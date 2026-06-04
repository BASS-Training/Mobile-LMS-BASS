import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/usecases/discussion_usecases.dart';
import 'discussion_state.dart';

/// Manages the discussion thread for a single lesson (backend content).
///
/// One instance per lesson screen — created with the lesson id so the widgets
/// only trigger intents (load / post topic / post reply).
class DiscussionCubit extends Cubit<DiscussionState> {
  final GetDiscussionsUseCase getDiscussions;
  final CreateDiscussionUseCase createDiscussion;
  final CreateReplyUseCase createReply;
  final String lessonId;

  DiscussionCubit({
    required this.getDiscussions,
    required this.createDiscussion,
    required this.createReply,
    required this.lessonId,
  }) : super(const DiscussionState());

  Future<void> load() async {
    emit(state.copyWith(status: DiscussionStatus.loading, error: null));
    try {
      final list = await getDiscussions(lessonId);
      emit(state.copyWith(status: DiscussionStatus.loaded, discussions: list));
    } catch (e) {
      emit(state.copyWith(
        status: DiscussionStatus.error,
        error: _message(e),
      ));
    }
  }

  /// Post a new topic. Returns true on success.
  Future<bool> postTopic({required String title, required String body}) async {
    if (state.submitting) return false;
    emit(state.copyWith(submitting: true, error: null));
    try {
      final created =
          await createDiscussion(lessonId, title: title, body: body);
      emit(state.copyWith(
        status: DiscussionStatus.loaded,
        discussions: [created, ...state.discussions],
        submitting: false,
      ));
      return true;
    } catch (e) {
      emit(state.copyWith(submitting: false, error: _message(e)));
      return false;
    }
  }

  /// Post a reply to [discussionId]. Returns true on success.
  Future<bool> postReply(String discussionId, String body) async {
    if (state.replyingIds.contains(discussionId)) return false;
    emit(state.copyWith(replyingIds: {...state.replyingIds, discussionId}));
    try {
      final reply = await createReply(discussionId, body: body);
      final updated = state.discussions.map((d) {
        if (d.id != discussionId) return d;
        return d.copyWith(replies: [...d.replies, reply]);
      }).toList();
      emit(state.copyWith(
        discussions: updated,
        replyingIds: {...state.replyingIds}..remove(discussionId),
      ));
      return true;
    } catch (e) {
      emit(state.copyWith(
        replyingIds: {...state.replyingIds}..remove(discussionId),
        error: _message(e),
      ));
      return false;
    }
  }

  String _message(Object e) {
    final text = e.toString().replaceFirst('Exception: ', '');
    return text.isEmpty ? 'Terjadi kesalahan. Coba lagi.' : text;
  }
}
