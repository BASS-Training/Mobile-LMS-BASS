import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Screen imports
import 'package:lms_mobile_app/src/features/splash/presentation/screens/splash_screen.dart';
import 'package:lms_mobile_app/src/features/authentication/presentation/screens/login_screen.dart';
import 'package:lms_mobile_app/src/features/courses/presentation/screens/course_list_screen.dart';
import 'package:lms_mobile_app/src/features/courses/presentation/screens/main_screen.dart';
import 'package:lms_mobile_app/src/features/courses/presentation/screens/course_detail_screen.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/screens/lesson_detail_screen.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/screens/video_lesson_detail_screen.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/screens/document_lesson_detail_screen.dart';
import 'package:lms_mobile_app/src/features/certificates/presentation/screens/certificate_detail_screen.dart';
import 'package:lms_mobile_app/src/features/certificates/presentation/screens/certificate_list_screen.dart';

// Entity imports
import 'package:lms_mobile_app/src/features/courses/domain/entities/course_entity.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/entities/lesson_entity.dart';

/// Route paths sebagai constants (untuk consistency)
const String _routeSplash = '/splash';
const String _routeLogin = '/login';
const String _routeMain = '/main';
const String _routeHome = '/home';
const String _routeCourses = '/courses';
const String _routeSavedCourses = '/saved-courses';
const String _routeProfile = '/profile';
const String _routeCourseDetail = '/course-detail';
const String _routeLessonDetail = '/lesson-detail';
const String _routeVideoLessonDetail = '/lesson-video-detail';
const String _routeDocumentLessonDetail = '/lesson-document-detail';
const String _routeCertificateDetail = '/certificate-detail';
const String _routeCertificateList = '/certificate-list';

/// Global router configuration menggunakan GoRouter
/// Centralized navigation untuk seluruh app
class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();

  static const splashName = 'splash';
  static const loginName = 'login';
  static const mainName = 'main';
  static const homeName = 'home';
  static const coursesName = 'courses';
  static const savedCoursesName = 'saved-courses';
  static const profileName = 'profile';
  static const courseDetailName = 'course-detail';
  static const lessonDetailName = 'lesson-detail';
  static const videoLessonDetailName = 'video-lesson-detail';
  static const documentLessonDetailName = 'document-lesson-detail';
  static const certificateDetailName = 'certificate-detail';
  static const certificateListName = 'certificate-list';

  static GoRouter get router => GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: _routeSplash,
    redirect: (context, state) {
      // TODO: Implement auth guard logic
      // - Jika user tidak authenticated, redirect ke login
      // - Jika user authenticated, allow navigation
      return null;
    },
    routes: [
      GoRoute(
        path: _routeSplash,
        name: splashName,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: _routeLogin,
        name: loginName,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: _routeMain,
        name: mainName,
        builder: (context, state) => const MainScreen(initialTab: 0),
      ),
      GoRoute(
        path: _routeHome,
        name: homeName,
        builder: (context, state) => const MainScreen(initialTab: 0),
      ),
      GoRoute(
        path: _routeCourses,
        name: coursesName,
        builder: (context, state) => const CourseListScreen(),
      ),
      GoRoute(
        path: _routeSavedCourses,
        name: savedCoursesName,
        builder: (context, state) => const MainScreen(initialTab: 2),
      ),
      GoRoute(
        path: _routeProfile,
        name: profileName,
        builder: (context, state) => const MainScreen(initialTab: 3),
      ),
      GoRoute(
        path: _routeCourseDetail,
        name: courseDetailName,
        builder: (context, state) {
          final course = state.extra as CourseEntity;
          return CourseDetailScreen(course: course);
        },
      ),
      GoRoute(
        path: _routeLessonDetail,
        name: lessonDetailName,
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
        path: _routeVideoLessonDetail,
        name: videoLessonDetailName,
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
        path: _routeDocumentLessonDetail,
        name: documentLessonDetailName,
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
        path: _routeCertificateDetail,
        name: certificateDetailName,
        builder: (context, state) {
          final course = state.extra as CourseEntity;
          return CertificateDetailScreen(course: course);
        },
      ),
      GoRoute(
        path: _routeCertificateList,
        name: certificateListName,
        builder: (context, state) => const CertificateListScreen(),
      ),
    ],
  );

  static void goToLogin(BuildContext context) {
    context.goNamed(loginName);
  }

  static Future<T?> goToCourses<T extends Object?>(BuildContext context) {
    return context.pushNamed<T>(coursesName);
  }

  static Future<T?> goToCourseDetail<T extends Object?>(
    BuildContext context,
    CourseEntity course,
  ) {
    return context.pushNamed<T>(courseDetailName, extra: course);
  }

  static Future<T?> goToCertificateList<T extends Object?>(
    BuildContext context,
  ) {
    return context.pushNamed<T>(certificateListName);
  }

  static Future<T?> goToCertificateDetail<T extends Object?>(
    BuildContext context,
    CourseEntity course,
  ) {
    return context.pushNamed<T>(certificateDetailName, extra: course);
  }

  static Future<T?> openLesson<T extends Object?>(
    BuildContext context, {
    required LessonEntity lesson,
    required CourseEntity course,
    required int lessonIndex,
  }) {
    final routeName = lesson.type.toLowerCase() == 'video'
        ? videoLessonDetailName
        : documentLessonDetailName;

    return context.pushNamed<T>(
      routeName,
      extra: {'lesson': lesson, 'course': course, 'lessonIndex': lessonIndex},
    );
  }
}
