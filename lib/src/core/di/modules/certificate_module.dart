import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:lms_mobile_app/src/features/certificates/data/certificate_repository.dart';
import 'package:lms_mobile_app/src/features/certificates/presentation/cubit/certificate_cubit.dart';

/// Modul DI fitur Sertifikat. Sertifikat mobile kini nyata (record + PDF
/// backend) dengan aturan kelayakan yang sama persis dengan web.
/// Repository = lazySingleton; Cubit = factory (per-layar).
class CertificateModule {
  static void register(GetIt getIt) {
    if (getIt.isRegistered<CertificateRepository>()) {
      return;
    }

    getIt.registerLazySingleton<CertificateRepository>(
      () => CertificateRepository(dio: getIt<Dio>()),
    );

    getIt.registerFactory<CertificateCubit>(
      () => CertificateCubit(repository: getIt<CertificateRepository>()),
    );
  }
}
