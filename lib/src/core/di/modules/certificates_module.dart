import 'package:get_it/get_it.dart';
import 'package:lms_mobile_app/src/features/certificates/domain/repositories/certificate_repository.dart';
import 'package:lms_mobile_app/src/features/certificates/data/repositories/certificate_repository_impl.dart';

final getIt = GetIt.instance;

/// Register certificates feature dependencies
void registerCertificatesModule() {
  // ============ DATA SOURCES ============
  // TODO: Add certificate datasources

  // ============ REPOSITORIES ============

  getIt.registerSingleton<CertificateRepository>(CertificateRepositoryImpl());

  // ============ USE CASES ============
  // TODO: Add certificate usecases

  // ============ BLoCs ============
  // TODO: Add certificate blocs
}
