import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lms_mobile_app/src/core/error/failures.dart';
import 'package:lms_mobile_app/src/features/home/domain/repositories/home_repository.dart';
import 'package:lms_mobile_app/src/features/home/domain/usecases/join_class_usecase.dart';
import 'package:lms_mobile_app/src/features/home/presentation/bloc/home_bloc.dart';
import 'package:lms_mobile_app/src/features/home/presentation/bloc/home_event.dart';
import 'package:lms_mobile_app/src/features/home/presentation/bloc/home_state.dart';

void main() {
  test('join class sukses menghasilkan HomeJoinClassSuccess', () async {
    final bloc = _bloc(_FakeHomeRepository(result: Right(null)));
    addTearDown(bloc.close);

    bloc.add(const SubmitJoinClassTokenEvent('TOKEN123'));
    final state = await _nextState<HomeJoinClassSuccess>(bloc);

    expect(state, isA<HomeJoinClassSuccess>());
  });

  test('join class failure meneruskan pesan dari server', () async {
    final bloc = _bloc(
      _FakeHomeRepository(
        result: Left(const ServerFailure('Token tidak valid')),
      ),
    );
    addTearDown(bloc.close);

    bloc.add(const SubmitJoinClassTokenEvent('TOKEN123'));
    final state = await _nextState<HomeJoinClassFailure>(bloc);

    expect(state, isA<HomeJoinClassFailure>());
    expect((state as HomeJoinClassFailure).message, 'Token tidak valid');
  });

  test('exception usecase menjadi failure, bukan stuck di loading', () async {
    final bloc = _bloc(_FakeHomeRepository(error: Exception('boom')));
    addTearDown(bloc.close);

    bloc.add(const SubmitJoinClassTokenEvent('TOKEN123'));
    final state = await _nextState<HomeJoinClassFailure>(bloc);

    expect(state, isA<HomeJoinClassFailure>());
    expect(
      (state as HomeJoinClassFailure).message,
      'Gagal bergabung ke kelas. Coba lagi.',
    );
  });
}

Future<HomeState> _nextState<T extends HomeState>(HomeBloc bloc) {
  return bloc.stream
      .firstWhere((state) => state is T)
      .timeout(const Duration(seconds: 2));
}

HomeBloc _bloc(HomeRepository repository) {
  return HomeBloc(joinClassUseCase: JoinClassUseCase(repository));
}

class _FakeHomeRepository implements HomeRepository {
  final Either<Failure, void>? result;
  final Object? error;

  _FakeHomeRepository({this.result, this.error});

  @override
  Future<Either<Failure, void>> joinClass(String token) async {
    final error = this.error;
    if (error != null) throw error;
    final result = this.result;
    if (result != null) return result;
    return Right(null);
  }
}
