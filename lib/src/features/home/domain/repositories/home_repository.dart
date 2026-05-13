import 'package:dartz/dartz.dart'; // Asumsi Anda menggunakan dartz untuk error handling
import 'package:lms_mobile_app/src/core/error/failures.dart';

abstract class HomeRepository {
  Future<Either<Failure, void>> joinClass(String token);
}