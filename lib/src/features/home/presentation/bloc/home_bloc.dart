import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/join_class_usecase.dart';
import 'home_event.dart';
import 'home_state.dart';

/// Bloc untuk aksi Home (mis. gabung kelas via token). Statistik dashboard
/// sendiri diturunkan dari CourseBloc → HomeStatsEntity, bukan dari sini.
/// Lihat ARCHITECTURE.md §10–11.
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final JoinClassUseCase joinClassUseCase;

  HomeBloc({required this.joinClassUseCase}) : super(const HomeInitial()) {
    on<SubmitJoinClassTokenEvent>(_onSubmitJoinClassToken);
  }

  Future<void> _onSubmitJoinClassToken(
    SubmitJoinClassTokenEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(HomeJoinClassLoading());
    final result = await joinClassUseCase(event.token);

    result.fold(
      (failure) => emit(HomeJoinClassFailure(failure.message)),
      (_) => emit(HomeJoinClassSuccess()),
    );
  }
}
