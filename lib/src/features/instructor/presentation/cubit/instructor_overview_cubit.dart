import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms_mobile_app/src/features/instructor/data/instructor_repository.dart';
import 'package:lms_mobile_app/src/features/instructor/domain/entities/instructor_entities.dart';

enum InstructorStatus { initial, loading, loaded, error }

String _msg(Object e) {
  final t = e.toString().replaceFirst('Exception: ', '');
  return t.isEmpty ? 'Terjadi kesalahan. Coba lagi.' : t;
}

/// Daftar peserta + progres untuk sebuah course.
class ParticipantsState extends Equatable {
  final InstructorStatus status;
  final List<ParticipantProgress> items;
  final String? error;

  const ParticipantsState({
    this.status = InstructorStatus.initial,
    this.items = const [],
    this.error,
  });

  ParticipantsState copyWith({
    InstructorStatus? status,
    List<ParticipantProgress>? items,
    String? error,
  }) => ParticipantsState(
    status: status ?? this.status,
    items: items ?? this.items,
    error: error,
  );

  @override
  List<Object?> get props => [status, items, error];
}

class ParticipantsCubit extends Cubit<ParticipantsState> {
  final InstructorRepository repository;
  final String courseId;

  ParticipantsCubit({required this.repository, required this.courseId})
    : super(const ParticipantsState());

  Future<void> load() async {
    emit(state.copyWith(status: InstructorStatus.loading, error: null));
    try {
      final items = await repository.getParticipants(courseId);
      emit(state.copyWith(status: InstructorStatus.loaded, items: items));
    } catch (e) {
      emit(state.copyWith(status: InstructorStatus.error, error: _msg(e)));
    }
  }
}

/// Antrian penilaian (essay + studi kasus) untuk sebuah course.
class GradingQueueState extends Equatable {
  final InstructorStatus status;
  final List<GradingQueueItem> items;
  final String? error;

  const GradingQueueState({
    this.status = InstructorStatus.initial,
    this.items = const [],
    this.error,
  });

  GradingQueueState copyWith({
    InstructorStatus? status,
    List<GradingQueueItem>? items,
    String? error,
  }) => GradingQueueState(
    status: status ?? this.status,
    items: items ?? this.items,
    error: error,
  );

  int get pendingCount => items.where((i) => i.isPending).length;

  @override
  List<Object?> get props => [status, items, error];
}

class GradingQueueCubit extends Cubit<GradingQueueState> {
  final InstructorRepository repository;
  final String courseId;

  GradingQueueCubit({required this.repository, required this.courseId})
    : super(const GradingQueueState());

  Future<void> load() async {
    emit(state.copyWith(status: InstructorStatus.loading, error: null));
    try {
      final items = await repository.getGradingQueue(courseId);
      emit(state.copyWith(status: InstructorStatus.loaded, items: items));
    } catch (e) {
      emit(state.copyWith(status: InstructorStatus.error, error: _msg(e)));
    }
  }
}
