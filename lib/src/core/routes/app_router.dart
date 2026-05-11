import 'package:alice/alice.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:lms_mobile_app/src/core/di/injector.dart';
import 'package:lms_mobile_app/src/features/authentication/presentation/screens/login_screen.dart';
import 'package:lms_mobile_app/src/features/certificates/presentation/screens/certificate_list_screen.dart';
import 'package:lms_mobile_app/src/features/courses/domain/entities/course_entity.dart';
import 'package:lms_mobile_app/src/features/courses/presentation/screens/course_detail_screen.dart';
import 'package:lms_mobile_app/src/features/courses/presentation/screens/course_list_screen.dart';
import 'package:lms_mobile_app/src/features/courses/presentation/screens/home_screen.dart';
import 'package:lms_mobile_app/src/features/courses/presentation/screens/main_screen.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/entities/lesson_entity.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/screens/document_lesson_detail_screen.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/screens/lesson_detail_screen.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/screens/video_lesson_detail_screen.dart';
import 'package:lms_mobile_app/src/features/splash/presentation/screens/splash.dart';

final GoRouter appRouter = GoRouter(
  navigatorKey: getIt.isRegistered<Alice>()
      ? getIt<Alice>().getNavigatorKey()
      : null,
  initialLocation: '/splash',
  routes: <RouteBase>[
    GoRoute(
      name: 'splash',
      path: '/splash',
      builder: (BuildContext xontext, GoRouterState state) {
        return const SplashScreen();
      },
    ),
    GoRoute(
      name: 'login',
      path: '/login',
      builder: (BuildContext xontext, GoRouterState state) {
        return const LoginScreen();
      },
    ),
    GoRoute(
      name: 'main',
      path: '/main',
      builder: (BuildContext xontext, GoRouterState state) {
        return const MainScreen();
      },
    ),
    GoRoute(
      name: 'home',
      path: '/home',
      builder: (BuildContext xontext, GoRouterState state) {
        return const HomeScreen();
      },
    ),
    GoRoute(
      name: 'course-list',
      path: '/course-list',
      builder: (BuildContext xontext, GoRouterState state) {
        return const CourseListScreen();
      },
    ),
    GoRoute(
      name: 'saved-courses',
      path: '/saved-courses',
      builder: (BuildContext xontext, GoRouterState state) {
        return const CourseListScreen();
      },
    ),
    GoRoute(
      name: 'certificate-list',
      path: '/certificates-list',
      builder: (BuildContext xontext, GoRouterState state) {
        return const CertificateListScreen();
      },
    ),
    GoRoute(
      name: 'profile',
      path: '/profile',
      builder: (BuildContext xontext, GoRouterState state) {
        return const ProfileScreen();
      },
    ),
    GoRoute(
      name: 'course-detail',
      path: '/course-detail',
      builder: (BuildContext xontext, GoRouterState state) {
        final course = state.extra as CourseEntity;
        return CourseDetailScreen(course: course);
      },
    ),
    GoRoute(
      name: 'lesson-detail',
      path: '/lesson-detail',
      builder: (BuildContext xontext, GoRouterState state) {
        final args = state.extra as Map<String, dynamic>;
        final lesson = args['lesson'] as LessonEntity;
        final course = args['course'] as CourseEntity;
        final lessonIndex = args['lessonIndex'] as int;
        return LessonDetailScreen(
          lesson: lesson,
          course: course,
          lessonIndex: lessonIndex,
        );
      },
    ),
    GoRoute(
      name: 'lesson-video-detail',
      path: '/lesson-video-detail',
      builder: (BuildContext xontext, GoRouterState state) {
        final args = state.extra as Map<String, dynamic>;
        final lesson = args['lesson'] as LessonEntity;
        final course = args['course'] as CourseEntity;
        final lessonIndex = args['lessonIndex'] as int;
        return LessonVideoDetailScreen(
          lesson: lesson,
          course: course,
          lessonIndex: lessonIndex,
        );
      },
    ),
    GoRoute(
      name: 'lesson-document-detail',
      path: '/lesson-document-detail',
      builder: (BuildContext xontext, GoRouterState state) {
        final args = state.extra as Map<String, dynamic>;
        final lesson = args['lesson'] as LessonEntity;
        final course = args['course'] as CourseEntity;
        final lessonIndex = args['lessonIndex'] as int;
        return LessonDocumentDetailScreen(
          lesson: lesson,
          course: course,
          lessonIndex: lessonIndex,
        );
      },
    ),
  ],

  errorBuilder: (context, state) =>
      Scaffold(body: Center(child: Text('Page not found: ${state.error}.'))),
);
