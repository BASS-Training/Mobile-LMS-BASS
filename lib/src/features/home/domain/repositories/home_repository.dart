import 'package:dartz/dartz.dart'; // Asumsi Anda menggunakan dartz untuk error handling
import 'package:lms_mobile_app/src/core/error/failures.dart';

/// Kontrak (Domain) untuk aksi di Home — saat ini bergabung kelas via token.
/// Mengembalikan `Either<Failure, _>` (dartz) agar error ditangani eksplisit.
/// Implementasi di lapisan Data. Lihat ARCHITECTURE.md §3.
abstract class HomeRepository {
  Future<Either<Failure, void>> joinClass(String token);
}