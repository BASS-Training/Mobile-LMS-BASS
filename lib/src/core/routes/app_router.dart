import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lms_mobile_app/src/core/config/constants/app_routes.dart';
import 'package:lms_mobile_app/src/core/di/modules/lesson_module.dart';

// Screen imports
import 'package:lms_mobile_app/src/features/authentication/presentation/screens/login_screen.dart';
import 'package:lms_mobile_app/src/features/courses/presentation/screens/main_screen.dart';
import 'package:lms_mobile_app/src/features/courses/presentation/screens/course_detail_screen.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/bloc/essay/essay_bloc.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/bloc/quiz/quiz_bloc.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/bloc/video/video_bloc.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/screens/video_lesson_detail_screen.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/screens/document_lesson_detail_screen.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/screens/quiz_lesson_detail_screen.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/screens/essay_lesson_detail_screen.dart';
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
        path: AppRoutes.videoLessonDetail,
        pageBuilder: (context, state) {
          final args = state.extra as Map<String, dynamic>;
          final lesson = args['lesson'] as LessonEntity;
          final course = args['course'] as CourseEntity;
          final lessonIndex = args['lessonIndex'] as int;
          return CustomTransitionPage(
            key: state.pageKey,
            child: BlocProvider<VideoBloc>(
              create: (context) => LessonModule.videoBloc,
              child: VideoLessonDetailScreen(
                lesson: lesson,
                course: course,
                lessonIndex: lessonIndex,
              ),
            ),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  final fade = CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  );
                  final slide = Tween<Offset>(
                    begin: const Offset(0.04, 0),
                    end: Offset.zero,
                  ).animate(fade);
                  return FadeTransition(
                    opacity: fade,
                    child: SlideTransition(position: slide, child: child),
                  );
                },
          );
        },
      ),
      GoRoute(
        path: AppRoutes.documentLessonDetail,
        pageBuilder: (context, state) {
          final args = state.extra as Map<String, dynamic>;
          final lesson = args['lesson'] as LessonEntity;
          final course = args['course'] as CourseEntity;
          final lessonIndex = args['lessonIndex'] as int;
          return CustomTransitionPage(
            key: state.pageKey,
            child: DocumentLessonDetailScreen(
              lesson: lesson,
              course: course,
              lessonIndex: lessonIndex,
            ),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  final fade = CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  );
                  final slide = Tween<Offset>(
                    begin: const Offset(0.04, 0),
                    end: Offset.zero,
                  ).animate(fade);
                  return FadeTransition(
                    opacity: fade,
                    child: SlideTransition(position: slide, child: child),
                  );
                },
          );
        },
      ),
      GoRoute(
        path: AppRoutes.quizLessonDetail,
        pageBuilder: (context, state) {
          final args = state.extra as Map<String, dynamic>;
          return CustomTransitionPage(
            key: state.pageKey,
            child: BlocProvider<QuizBloc>(
              create: (context) => LessonModule.quizBloc,
              child: QuizLessonDetailScreen(
                lesson: args['lesson'],
                course: args['course'],
                lessonIndex: args['lessonIndex'],
              ),
            ),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  final fade = CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  );
                  final slide = Tween<Offset>(
                    begin: const Offset(0.04, 0),
                    end: Offset.zero,
                  ).animate(fade);
                  return FadeTransition(
                    opacity: fade,
                    child: SlideTransition(position: slide, child: child),
                  );
                },
          );
        },
      ),
      GoRoute(
        path: AppRoutes.essayLessonDetail,
        pageBuilder: (context, state) {
          final args = state.extra as Map<String, dynamic>;
          return CustomTransitionPage(
            key: state.pageKey,
            child: BlocProvider<EssayBloc>(
              create: (context) => LessonModule.essayBloc,
              child: EssayLessonDetailScreen(
                lesson: args['lesson'],
                course: args['course'],
                lessonIndex: args['lessonIndex'],
              ),
            ),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  final fade = CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  );
                  final slide = Tween<Offset>(
                    begin: const Offset(0.04, 0),
                    end: Offset.zero,
                  ).animate(fade);
                  return FadeTransition(
                    opacity: fade,
                    child: SlideTransition(position: slide, child: child),
                  );
                },
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
