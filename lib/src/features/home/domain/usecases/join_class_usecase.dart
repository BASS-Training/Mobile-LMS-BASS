import 'package:dartz/dartz.dart';
import 'package:lms_mobile_app/src/core/error/failures.dart';
import '../repositories/home_repository.dart';

class JoinClassUseCase {
  final HomeRepository repository;

  JoinClassUseCase(this.repository);

  Future<Either<Failure, void>> call(String token) async {
    // Validasi token dilakukan di Domain, bukan di UI!
    if (token.isEmpty) {
      return Left(
        ServerFailure('Token pendaftaran wajib diisi'),
      ); // Gunakan class Failure Anda
    }
    if (token.length < 6) {
      return Left(ServerFailure('Token minimal 6 karakter'));
    }

    return await repository.joinClass(token);
  }
}
