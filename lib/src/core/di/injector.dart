/// Service Locator - Orchestrate semua DI modules
/// Ini adalah entry point untuk dependency injection
import 'package:lms_mobile_app/src/features/authentication/presentation/bloc/auth/auth_bloc.dart';
import 'package:lms_mobile_app/src/features/courses/presentation/bloc/course/course_bloc.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/bloc/lesson/lesson_bloc.dart';

import 'modules/core_module.dart';
import 'modules/network_module.dart';
import 'modules/auth_module.dart';
import 'modules/course_module.dart';
import 'modules/lesson_module.dart';
import 'modules/certificate_module.dart';

class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();

  factory ServiceLocator() {
    return _instance;
  }

  ServiceLocator._internal();

  /// Initialize semua DI modules
  /// Harus dipanggil di main() sebelum runApp()
  Future<void> setupServiceLocator() async {
    // Core initialization (harus pertama)
    await CoreModule.register();

    // Network initialization
    await NetworkModule.register();

    // Feature modules
    AuthModule.register();
    CourseModule.register();
    LessonModule.register();
    CertificateModule.register();
  }

  /// Get BLoCs
  AuthBloc get authBloc => AuthModule.authBloc;
  CourseBloc get courseBloc => CourseModule.courseBloc;
  LessonBloc get lessonBloc => LessonModule.lessonBloc;
}
