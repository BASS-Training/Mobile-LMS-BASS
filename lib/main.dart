import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Core - Theme & DI
import 'package:lms_mobile_app/src/shared/styles/app_theme.dart';
import 'package:lms_mobile_app/src/core/di/injector.dart';
import 'package:lms_mobile_app/src/core/routes/app_router.dart';

// Domain Entities
import 'package:lms_mobile_app/src/features/courses/domain/entities/course_entity.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/entities/lesson_entity.dart';

// BLoCs
import 'package:lms_mobile_app/src/features/authentication/presentation/bloc/auth/auth_bloc.dart';
import 'package:lms_mobile_app/src/features/courses/presentation/bloc/course/course_bloc.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/bloc/lesson/lesson_bloc.dart';

// Screens
import 'package:lms_mobile_app/src/features/authentication/presentation/screens/login_screen.dart';
import 'package:lms_mobile_app/src/features/certificates/presentation/screens/certificate_detail_screen.dart';
import 'package:lms_mobile_app/src/features/certificates/presentation/screens/certificate_list_screen.dart';
import 'package:lms_mobile_app/src/features/courses/presentation/screens/course_detail_screen.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/screens/lesson_detail_screen.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/screens/document_lesson_detail_screen.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/screens/video_lesson_detail_screen.dart';
import 'package:lms_mobile_app/src/features/courses/presentation/screens/main_screen.dart';
import 'package:lms_mobile_app/src/core/config/constants/app_strings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
        BlocProvider<LessonBloc>(
          create: (context) => serviceLocator.lessonBloc,
        ),
      ],
      child: MaterialApp(
        title: 'LMS Mobile App',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        initialRoute: '/login',
        routes: {
          '/login': (context) => const LoginScreen(),
          '/home': (context) => const MainScreen(initialTab: 0),
          '/courses': (context) => const MainScreen(initialTab: 1),
          '/certificate-list': (context) => const CertificateListScreen(),
        },
        onGenerateRoute: (RouteSettings settings) {
          if (settings.name == '/course-detail') {
            final course = settings.arguments as CourseEntity;
            return MaterialPageRoute(
              builder: (context) => CourseDetailScreen(course: course),
              settings: settings,
            );
          } else if (settings.name == '/lesson-detail') {
            final args = settings.arguments as Map<String, dynamic>;
            final lesson = args['lesson'] as LessonEntity;
            final course = args['course'] as CourseEntity;
            final lessonIndex = args['lessonIndex'] as int;
            return MaterialPageRoute(
              builder: (context) => LessonDetailScreen(
                lesson: lesson,
                course: course,
                lessonIndex: lessonIndex,
              ),
              settings: settings,
            );
          } else if (settings.name == '/certificate-detail') {
            final course = settings.arguments as CourseEntity;
            return MaterialPageRoute(
              builder: (context) => CertificateDetailScreen(course: course),
              settings: settings,
            );
          } else if (settings.name == '/lesson-video-detail') {
            final args = settings.arguments as Map<String, dynamic>;
            final lesson = args['lesson'] as LessonEntity;
            final course = args['course'] as CourseEntity;
            final lessonIndex = args['lessonIndex'] as int;

            return MaterialPageRoute(
              builder: (context) => VideoLessonDetailScreen(
                lesson: lesson,
                course: course,
                lessonIndex: lessonIndex,
              ),
              settings: settings,
            );
          } else if (settings.name == '/lesson-document-detail') {
            final args = settings.arguments as Map<String, dynamic>;
            final lesson = args['lesson'] as LessonEntity;
            final course = args['course'] as CourseEntity;
            final lessonIndex = args['lessonIndex'] as int;

            return MaterialPageRoute(
              builder: (context) => DocumentLessonDetailScreen(
                lesson: lesson,
                course: course,
                lessonIndex: lessonIndex,
              ),
              settings: settings,
            );
          }
          return null;
        },
        home: const LoginScreen(),
      ),
    );
  }
}
