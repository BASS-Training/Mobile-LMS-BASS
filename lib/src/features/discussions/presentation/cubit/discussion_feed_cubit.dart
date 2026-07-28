import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms_mobile_app/src/features/discussions/data/discussion_feed_repository.dart';
import 'package:lms_mobile_app/src/features/discussions/domain/entities/discussion_feed_item.dart';

enum DiscussionFeedStatus { initial, loading, loaded, error }

String _msg(Object e) {
  final t = e.toString().replaceFirst('Exception: ', '');
  return t.isEmpty ? 'Terjadi kesalahan. Coba lagi.' : t;
}

class DiscussionFeedState extends Equatable {
  final DiscussionFeedStatus status;
  final List<DiscussionFeedItem> items;
  final String? error;

  const DiscussionFeedState({
    this.status = DiscussionFeedStatus.initial,
    this.items = const [],
    this.error,
  });

  DiscussionFeedState copyWith({
    DiscussionFeedStatus? status,
    List<DiscussionFeedItem>? items,
    String? error,
  }) => DiscussionFeedState(
    status: status ?? this.status,
    items: items ?? this.items,
    error: error,
  );

  @override
  List<Object?> get props => [status, items, error];
}

class DiscussionFeedCubit extends Cubit<DiscussionFeedState> {
  final DiscussionFeedRepository repository;

  DiscussionFeedCubit({required this.repository})
    : super(const DiscussionFeedState());

  Future<void> load({String? courseId}) async {
    emit(state.copyWith(status: DiscussionFeedStatus.loading, error: null));
    try {
      final items = await repository.getFeed(courseId: courseId);
      emit(state.copyWith(status: DiscussionFeedStatus.loaded, items: items));
    } catch (e) {
      emit(state.copyWith(status: DiscussionFeedStatus.error, error: _msg(e)));
    }
  }
}
