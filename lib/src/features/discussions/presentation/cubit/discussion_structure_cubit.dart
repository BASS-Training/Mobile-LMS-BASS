import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms_mobile_app/src/features/discussions/data/discussion_feed_repository.dart';
import 'package:lms_mobile_app/src/features/discussions/domain/entities/discussion_structure.dart';

enum DiscussionStructureStatus { initial, loading, loaded, error }

String _msg(Object e) {
  final t = e.toString().replaceFirst('Exception: ', '');
  return t.isEmpty ? 'Terjadi kesalahan. Coba lagi.' : t;
}

class DiscussionStructureState extends Equatable {
  final DiscussionStructureStatus status;
  final List<DiscussionCourseGroup> groups;
  final String? error;

  const DiscussionStructureState({
    this.status = DiscussionStructureStatus.initial,
    this.groups = const [],
    this.error,
  });

  DiscussionStructureState copyWith({
    DiscussionStructureStatus? status,
    List<DiscussionCourseGroup>? groups,
    String? error,
  }) => DiscussionStructureState(
    status: status ?? this.status,
    groups: groups ?? this.groups,
    error: error,
  );

  @override
  List<Object?> get props => [status, groups, error];
}

class DiscussionStructureCubit extends Cubit<DiscussionStructureState> {
  final DiscussionFeedRepository repository;

  DiscussionStructureCubit({required this.repository})
    : super(const DiscussionStructureState());

  Future<void> load() async {
    emit(state.copyWith(status: DiscussionStructureStatus.loading, error: null));
    try {
      final groups = await repository.getStructure();
      emit(
        state.copyWith(status: DiscussionStructureStatus.loaded, groups: groups),
      );
    } catch (e) {
      emit(
        state.copyWith(status: DiscussionStructureStatus.error, error: _msg(e)),
      );
    }
  }
}
