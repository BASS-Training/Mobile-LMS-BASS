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

  /// Empty [courseId] means the global inbox across all managed courses.
  bool get isGlobal => courseId.isEmpty;

  Future<void> load() async {
    emit(state.copyWith(status: InstructorStatus.loading, error: null));
    try {
      final items = isGlobal
          ? await repository.getGlobalGradingQueue()
          : await repository.getGradingQueue(courseId);
      emit(state.copyWith(status: InstructorStatus.loaded, items: items));
    } catch (e) {
      emit(state.copyWith(status: InstructorStatus.error, error: _msg(e)));
    }
  }
}

/// Full progress detail for one participant in a course.
class ParticipantDetailState extends Equatable {
  final InstructorStatus status;
  final ParticipantProgressDetail? data;
  final String? error;

  const ParticipantDetailState({
    this.status = InstructorStatus.initial,
    this.data,
    this.error,
  });

  ParticipantDetailState copyWith({
    InstructorStatus? status,
    ParticipantProgressDetail? data,
    String? error,
  }) => ParticipantDetailState(
    status: status ?? this.status,
    data: data ?? this.data,
    error: error,
  );

  @override
  List<Object?> get props => [status, data, error];
}

class ParticipantDetailCubit extends Cubit<ParticipantDetailState> {
  final InstructorRepository repository;
  final String courseId;
  final String userId;

  ParticipantDetailCubit({
    required this.repository,
    required this.courseId,
    required this.userId,
  }) : super(const ParticipantDetailState());

  Future<void> load() async {
    emit(state.copyWith(status: InstructorStatus.loading, error: null));
    try {
      final data = await repository.getParticipantProgress(courseId, userId);
      emit(state.copyWith(status: InstructorStatus.loaded, data: data));
    } catch (e) {
      emit(state.copyWith(status: InstructorStatus.error, error: _msg(e)));
    }
  }
}

/// Aggregate dashboard for the instructor/admin home.
class InstructorDashboardState extends Equatable {
  final InstructorStatus status;
  final InstructorDashboard? data;
  final String? error;

  const InstructorDashboardState({
    this.status = InstructorStatus.initial,
    this.data,
    this.error,
  });

  InstructorDashboardState copyWith({
    InstructorStatus? status,
    InstructorDashboard? data,
    String? error,
  }) => InstructorDashboardState(
    status: status ?? this.status,
    data: data ?? this.data,
    error: error,
  );

  @override
  List<Object?> get props => [status, data, error];
}

class InstructorDashboardCubit extends Cubit<InstructorDashboardState> {
  final InstructorRepository repository;

  InstructorDashboardCubit({required this.repository})
    : super(const InstructorDashboardState());

  Future<void> load() async {
    emit(state.copyWith(status: InstructorStatus.loading, error: null));
    try {
      final data = await repository.getDashboard();
      emit(state.copyWith(status: InstructorStatus.loaded, data: data));
    } catch (e) {
      emit(state.copyWith(status: InstructorStatus.error, error: _msg(e)));
    }
  }
}
