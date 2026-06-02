import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lms_mobile_app/src/core/config/constants/app_routes.dart';
import 'package:lms_mobile_app/src/core/di/injector.dart';
import 'package:lms_mobile_app/src/features/authentication/presentation/bloc/auth/auth_bloc.dart';
import 'package:lms_mobile_app/src/features/authentication/presentation/bloc/auth/auth_state.dart';

// Screen imports
import 'package:lms_mobile_app/src/features/authentication/presentation/screens/intro_screen.dart';
import 'package:lms_mobile_app/src/features/authentication/presentation/screens/login_screen.dart';
import 'package:lms_mobile_app/src/features/authentication/presentation/screens/register_screen.dart';
import 'package:lms_mobile_app/src/features/main/presentation/screens/main_screen.dart';
import 'package:lms_mobile_app/src/features/courses/presentation/screens/course_detail_screen.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/bloc/essay/essay_bloc.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/bloc/quiz/quiz_bloc.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/bloc/quiz_result/quiz_result_bloc.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/bloc/video/video_bloc.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/screens/video_lesson_detail_screen.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/screens/text_lesson_detail_screen.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/screens/document_lesson_detail_screen.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/screens/quiz_lesson_detail_screen.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/screens/essay_lesson_detail_screen.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/screens/image_lesson_detail_screen.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/screens/results_list_screen.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/screens/quiz_result_detail_screen.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/screens/essay_result_detail_screen.dart';
import 'package:lms_mobile_app/src/features/certificates/presentation/screens/certificate_detail_screen.dart';
import 'package:lms_mobile_app/src/features/certificates/presentation/screens/certificate_list_screen.dart';

// Entity imports
import 'package:lms_mobile_app/src/features/courses/domain/entities/course_entity.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/entities/lesson_entity.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/entities/lesson_attempt_entity.dart';

/// Global router configuration menggunakan GoRouter
/// Centralized navigation untuk seluruh app
class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();

  static final _sl = ServiceLocator().locator;
  static AuthBloc get _authBloc => _sl<AuthBloc>();

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.intro,
    refreshListenable: _GoRouterRefreshStream(_authBloc.stream),
    redirect: (context, state) {
      final authState = _authBloc.state;
      final isOnAuthRoute =
          state.matchedLocation == AppRoutes.intro ||
          state.matchedLocation == AppRoutes.login ||
          state.matchedLocation == AppRoutes.register;

      final isAuthenticated = authState is AuthSuccess;

      if (!isAuthenticated && !isOnAuthRoute) {
        return AppRoutes.intro;
      }

      if (isAuthenticated && isOnAuthRoute) {
        return AppRoutes.main;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.intro,
        builder: (context, state) => const IntroScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterScreen(),
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
        path: AppRoutes.courseResults,
        builder: (context, state) {
          final course = state.extra as CourseEntity;
          return ResultsListScreen(course: course);
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
              create: (context) => _sl<VideoBloc>(),
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
        path: AppRoutes.textLessonDetail,
        pageBuilder: (context, state) {
          final args = state.extra as Map<String, dynamic>;
          final lesson = args['lesson'] as LessonEntity;
          final course = args['course'] as CourseEntity;
          final lessonIndex = args['lessonIndex'] as int;
          return CustomTransitionPage(
            key: state.pageKey,
            child: TextLessonDetailScreen(
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
              create: (context) => _sl<QuizBloc>(),
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
              create: (context) => _sl<EssayBloc>(),
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
        path: AppRoutes.imageLessonDetail,
        pageBuilder: (context, state) {
          final args = state.extra as Map<String, dynamic>;
          final lesson = args['lesson'] as LessonEntity;
          final course = args['course'] as CourseEntity;
          final lessonIndex = args['lessonIndex'] as int;
          return CustomTransitionPage(
            key: state.pageKey,
            child: ImageLessonDetailScreen(
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
        path: AppRoutes.quizResultDetail,
        pageBuilder: (context, state) {
          final attempt = state.extra as LessonAttempt;
          return CustomTransitionPage(
            key: state.pageKey,
            child: BlocProvider<QuizResultBloc>(
              create: (context) => _sl<QuizResultBloc>(),
              child: QuizResultDetailScreen(attempt: attempt),
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
        path: AppRoutes.essayResultDetail,
        pageBuilder: (context, state) {
          final attempt = state.extra as LessonAttempt;
          return CustomTransitionPage(
            key: state.pageKey,
            child: EssayResultDetailScreen(attempt: attempt),
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

class _GoRouterRefreshStream extends ChangeNotifier {
  _GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.listen((_) {
      notifyListeners();
    });
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
