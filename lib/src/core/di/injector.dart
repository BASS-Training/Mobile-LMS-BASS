import 'package:get_it/get_it.dart';
import 'modules/auth_module.dart';
import 'modules/courses_module.dart';
import 'modules/lessons_module.dart';
import 'modules/certificates_module.dart';
import 'modules/profile_module.dart';

/// Global GetIt instance untuk DI
final getIt = GetIt.instance;

/// Configure semua dependencies untuk aplikasi
///
/// Call ini di main.dart sebelum runApp()
/// Contoh: configureDependencies(); runApp(const MyApp());
void configureDependencies() {
  // Register core module dependencies
  // (jika ada config, network, storage, dll)

  // Register feature modules (order tidak penting karena independent)
  registerAuthModule();
  registerCoursesModule();
  registerLessonsModule();
  registerCertificatesModule();
  registerProfileModule();
}
