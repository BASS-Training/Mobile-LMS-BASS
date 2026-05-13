import 'package:dartz/dartz.dart';
import 'package:lms_mobile_app/src/core/error/failures.dart';
import '../../domain/repositories/home_repository.dart';
import '../datasources/home_remote_data_source.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource remoteDataSource;

  HomeRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, void>> joinClass(String token) async {
    try {
      await remoteDataSource.submitJoinClassToken(token);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
