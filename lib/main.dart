import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms_mobile_app/src/core/config/constants/app_strings.dart';

// Core - Theme & DI
import 'package:lms_mobile_app/src/shared/styles/app_theme.dart';
import 'package:lms_mobile_app/src/core/di/injector.dart';
import 'package:lms_mobile_app/src/core/routes/app_router.dart';
import 'package:lms_mobile_app/src/core/services/firebase_initializer.dart';

// Domain Entities
// BLoCs
import 'package:lms_mobile_app/src/features/authentication/presentation/bloc/auth/auth_bloc.dart';
import 'package:lms_mobile_app/src/features/courses/presentation/bloc/course/course_bloc.dart';
import 'package:lms_mobile_app/src/features/home/presentation/bloc/home_bloc.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/bloc/lesson/lesson_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await FirebaseInitializer.ensureInitialized();

  // Initialize Service Locator (which includes CoreModule init)
  final serviceLocator = ServiceLocator();
  await serviceLocator.setupServiceLocator();

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final serviceLocator = ServiceLocator();

    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(create: (context) => serviceLocator.authBloc),
        BlocProvider<CourseBloc>(
          create: (context) => serviceLocator.courseBloc,
        ),
        BlocProvider<HomeBloc>(create: (context) => serviceLocator.homeBloc),
        BlocProvider<LessonBloc>(
          create: (context) => serviceLocator.lessonBloc,
        ),
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
