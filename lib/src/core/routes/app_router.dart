import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lms_mobile_app/src/core/config/constants/app_routes.dart';

// Screen imports
import 'package:lms_mobile_app/src/features/authentication/presentation/screens/login_screen.dart';
import 'package:lms_mobile_app/src/features/courses/presentation/screens/main_screen.dart';
import 'package:lms_mobile_app/src/features/courses/presentation/screens/course_detail_screen.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/screens/lesson_detail_screen.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/screens/video_lesson_detail_screen.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/screens/document_lesson_detail_screen.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/screens/quiz_lesson_detail_screen.dart';
import 'package:lms_mobile_app/src/features/certificates/presentation/screens/certificate_detail_screen.dart';
import 'package:lms_mobile_app/src/features/certificates/presentation/screens/certificate_list_screen.dart';

// Entity imports
import 'package:lms_mobile_app/src/features/courses/domain/entities/course_entity.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/entities/lesson_entity.dart';

/// Global router configuration menggunakan GoRouter
/// Centralized navigation untuk seluruh app
class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.login,
    redirect: (context, state) {
      // TODO: Tambahkan auth guard ketika state auth sudah siap.
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.main,
        builder: (context, state) => const MainScreen(initialTab: 0),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const MainScreen(initialTab: 0),
      ),
      GoRoute(
        path: AppRoutes.courses,
        builder: (context, state) => const MainScreen(initialTab: 1),
      ),
      GoRoute(
        path: AppRoutes.courseDetail,
        builder: (context, state) {
          final course = state.extra as CourseEntity;
          return CourseDetailScreen(course: course);
        },
      ),
      GoRoute(
        path: AppRoutes.lessonDetail,
        builder: (context, state) {
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
        path: AppRoutes.videoLessonDetail,
        builder: (context, state) {
          final args = state.extra as Map<String, dynamic>;
          final lesson = args['lesson'] as LessonEntity;
          final course = args['course'] as CourseEntity;
          final lessonIndex = args['lessonIndex'] as int;
          return VideoLessonDetailScreen(
            lesson: lesson,
            course: course,
            lessonIndex: lessonIndex,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.documentLessonDetail,
        builder: (context, state) {
          final args = state.extra as Map<String, dynamic>;
          final lesson = args['lesson'] as LessonEntity;
          final course = args['course'] as CourseEntity;
          final lessonIndex = args['lessonIndex'] as int;
          return DocumentLessonDetailScreen(
            lesson: lesson,
            course: course,
            lessonIndex: lessonIndex,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.quizLessonDetail,
        builder: (context, state) {
          final args = state.extra as Map<String, dynamic>;
          final lesson = args['lesson'] as LessonEntity;
          final course = args['course'] as CourseEntity;
          final lessonIndex = args['lessonIndex'] as int;
          return QuizLessonDetailScreen(
            lesson: lesson,
            course: course,
            lessonIndex: lessonIndex,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.certificateDetail,
        builder: (context, state) {
          final course = state.extra as CourseEntity;
          return CertificateDetailScreen(course: course);
        },
      ),
      GoRoute(
        path: AppRoutes.certificateList,
        builder: (context, state) => const CertificateListScreen(),
      ),
    ],
  );
}
