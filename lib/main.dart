import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms_mobile_app/config/theme.dart';
import 'package:lms_mobile_app/config/service_locator.dart';
import 'package:lms_mobile_app/data/sources/local_storage.dart';
import 'package:lms_mobile_app/domain/entities/course_entity.dart';
import 'package:lms_mobile_app/domain/entities/lesson_entity.dart';
import 'package:lms_mobile_app/presentation/bloc/auth/auth_bloc.dart';
import 'package:lms_mobile_app/presentation/bloc/course/course_bloc.dart';
import 'package:lms_mobile_app/presentation/bloc/lesson/lesson_bloc.dart';
import 'package:lms_mobile_app/presentation/screens/auth/login_screen.dart';
import 'package:lms_mobile_app/presentation/screens/certificate/certificate_detail_screen.dart';
import 'package:lms_mobile_app/presentation/screens/certificate/certificate_list_screen.dart';
import 'package:lms_mobile_app/presentation/screens/courses/course_detail_screen.dart';
import 'package:lms_mobile_app/presentation/screens/lessons/lesson_detail_screen.dart';
import 'package:lms_mobile_app/presentation/screens/lessons/document_lesson_detail_screen.dart';
import 'package:lms_mobile_app/presentation/screens/lessons/video_lesson_detail_screen.dart';
import 'package:lms_mobile_app/presentation/screens/main_screen.dart';
import 'package:lms_mobile_app/utils/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalStorage.init();

  // Setup service locator for dependency injection
  ServiceLocator().setupServiceLocator();

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
          '/certificates': (context) => const CertificateListScreen(),
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
