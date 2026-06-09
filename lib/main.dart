import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms_mobile_app/src/core/config/constants/app_strings.dart';
import 'package:lms_mobile_app/src/core/config/flavor_config.dart';

// Core - Theme & DI
import 'package:lms_mobile_app/src/shared/styles/app_theme.dart';
import 'package:lms_mobile_app/src/core/di/injector.dart';
import 'package:lms_mobile_app/src/core/routes/app_router.dart';

// Domain Entities
// BLoCs
import 'package:lms_mobile_app/src/features/authentication/presentation/bloc/auth/auth_bloc.dart';
import 'package:lms_mobile_app/src/features/courses/presentation/bloc/course/course_bloc.dart';
import 'package:lms_mobile_app/src/features/home/presentation/bloc/home_bloc.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/bloc/lesson/lesson_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock the whole app to portrait — no landscape, on any screen.
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  if (kReleaseMode) {
    // Jika aplikasi di-build untuk rilis (Production)
    FlavorConfig.init(
      flavor: ProductionFlavorConfig.config.flavor,
      apiBaseUrl: ProductionFlavorConfig.config.apiBaseUrl,
      enableLogging: ProductionFlavorConfig.config.enableLogging,
      enableMockData: ProductionFlavorConfig.config.enableMockData,
    );
  } else {
    // Jika aplikasi di-run dari VS Code (Development)
    FlavorConfig.init(
      flavor: DevelopmentFlavorConfig.config.flavor,
      apiBaseUrl: DevelopmentFlavorConfig.config.apiBaseUrl,
      enableLogging: DevelopmentFlavorConfig.config.enableLogging,
      enableMockData: DevelopmentFlavorConfig.config.enableMockData,
    );
  }

  // Initialize Service Locator (which includes CoreModule init)
  final serviceLocator = ServiceLocator();
  await serviceLocator.setupServiceLocator();

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final sl = ServiceLocator().locator;

    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(create: (context) => sl<AuthBloc>()),
        BlocProvider<CourseBloc>(create: (context) => sl<CourseBloc>()),
        BlocProvider<HomeBloc>(create: (context) => sl<HomeBloc>()),
        BlocProvider<LessonBloc>(create: (context) => sl<LessonBloc>()),
      ],
      child: MaterialApp.router(
        title: AppStrings.appName,
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        routerConfig: AppRouter.router,
      ),
    );
  }
}
