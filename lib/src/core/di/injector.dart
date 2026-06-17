// Injector - orchestrate semua DI modules dengan GetIt
// Ini adalah entry point untuk dependency injection
import 'package:get_it/get_it.dart';
import 'package:lms_mobile_app/src/core/di/modules/home_module.dart';
import 'package:lms_mobile_app/src/features/authentication/presentation/bloc/auth/auth_bloc.dart';

import 'modules/core_module.dart';
import 'modules/network_module.dart';
import 'modules/auth_module.dart';
import 'modules/course_module.dart';
import 'modules/lesson_module.dart';
import 'modules/certificate_module.dart';
import 'modules/game_module.dart';
import 'modules/instructor_module.dart';
import 'modules/notification_module.dart';
import 'modules/discussion_module.dart';

class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();
  static final GetIt _getIt = GetIt.instance;

  factory ServiceLocator() {
    return _instance;
  }

  ServiceLocator._internal();

  /// Initialize semua DI modules
  /// Harus dipanggil di main() sebelum runApp()
  Future<void> setupServiceLocator() async {
    if (_getIt.isRegistered<AuthBloc>()) {
      return;
    }

    // Core initialization (harus pertama)
    await CoreModule.register();

    // Network initialization
    await NetworkModule.register(_getIt);

    // Feature modules
    AuthModule.register(_getIt);
    HomeModule.register(_getIt);
    CourseModule.register(_getIt);
    LessonModule.register(_getIt);
    CertificateModule.register(_getIt);
    GameModule.register(_getIt);
    InstructorModule.register(_getIt);
    NotificationModule.register(_getIt);
    DiscussionModule.register(_getIt);
  }

  GetIt get locator => _getIt;
}
