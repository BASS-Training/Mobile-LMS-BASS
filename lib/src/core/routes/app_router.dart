import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lms_mobile_app/src/core/config/constants/app_routes.dart';
import 'package:lms_mobile_app/src/core/di/injector.dart';
import 'package:lms_mobile_app/src/features/authentication/presentation/bloc/auth/auth_bloc.dart';
import 'package:lms_mobile_app/src/features/authentication/presentation/bloc/auth/auth_state.dart';

// Screen imports
import 'package:lms_mobile_app/src/features/authentication/presentation/screens/splash_screen.dart';
import 'package:lms_mobile_app/src/features/authentication/presentation/screens/intro_screen.dart';
import 'package:lms_mobile_app/src/features/authentication/presentation/screens/login_screen.dart';
import 'package:lms_mobile_app/src/features/authentication/presentation/screens/register_screen.dart';
import 'package:lms_mobile_app/src/features/authentication/presentation/auth_actions/auth_action_cubit.dart';
import 'package:lms_mobile_app/src/features/authentication/presentation/screens/verify_email_screen.dart';
import 'package:lms_mobile_app/src/features/authentication/presentation/screens/forgot_password_screen.dart';
import 'package:lms_mobile_app/src/features/authentication/presentation/screens/change_password_screen.dart';
import 'package:lms_mobile_app/src/features/authentication/presentation/screens/change_email_screen.dart';
import 'package:lms_mobile_app/src/features/authentication/presentation/edit_profile/edit_profile_cubit.dart';
import 'package:lms_mobile_app/src/features/authentication/presentation/screens/edit_profile_screen.dart';
import 'package:lms_mobile_app/src/features/authentication/domain/entities/user_entity.dart';
import 'package:lms_mobile_app/src/features/main/presentation/screens/main_screen.dart';
import 'package:lms_mobile_app/src/features/courses/presentation/screens/course_detail_screen.dart';
import 'package:lms_mobile_app/src/features/courses/presentation/screens/saved_courses_screen.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/bloc/essay/essay_bloc.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/bloc/quiz/quiz_bloc.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/bloc/quiz_result/quiz_result_bloc.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/bloc/video/video_bloc.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/bloc/case_study/case_study_bloc.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/screens/case_study_lesson_detail_screen.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/bloc/feedback/feedback_bloc.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/screens/feedback_lesson_detail_screen.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/screens/case_study_result_detail_screen.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/screens/video_lesson_detail_screen.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/screens/text_lesson_detail_screen.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/screens/document_lesson_detail_screen.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/screens/quiz_lesson_detail_screen.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/screens/essay_lesson_detail_screen.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/screens/image_lesson_detail_screen.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/screens/zoom_lesson_detail_screen.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/screens/results_list_screen.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/screens/quiz_result_detail_screen.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/screens/essay_result_detail_screen.dart';
import 'package:lms_mobile_app/src/features/certificates/presentation/screens/certificate_detail_screen.dart';
import 'package:lms_mobile_app/src/features/certificates/presentation/screens/certificate_list_screen.dart';
import 'package:lms_mobile_app/src/features/home/presentation/screens/join_class_screen.dart';
import 'package:lms_mobile_app/src/features/notifications/presentation/cubit/notifications_cubit.dart';
import 'package:lms_mobile_app/src/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:lms_mobile_app/src/features/discussions/presentation/screens/discussion_hub_screen.dart';
import 'package:lms_mobile_app/src/features/discussions/presentation/screens/discussion_thread_screen.dart';
import 'package:lms_mobile_app/src/features/achievements/presentation/screens/achievements_screen.dart';
import 'package:lms_mobile_app/src/features/agenda/presentation/screens/agenda_screen.dart';
import 'package:lms_mobile_app/src/features/assignments/presentation/screens/assignments_screen.dart';
import 'package:lms_mobile_app/src/features/instructor/presentation/screens/instructor_dashboard_screen.dart';
import 'package:lms_mobile_app/src/features/home/domain/entities/home_stats.entity.dart';
import 'package:lms_mobile_app/src/features/instructor/presentation/screens/instructor_participants_screen.dart';
import 'package:lms_mobile_app/src/features/instructor/presentation/screens/instructor_grading_queue_screen.dart';
import 'package:lms_mobile_app/src/features/instructor/presentation/screens/instructor_participant_detail_screen.dart';
import 'package:lms_mobile_app/src/features/instructor/presentation/screens/instructor_essay_grading_screen.dart';
import 'package:lms_mobile_app/src/features/instructor/presentation/screens/instructor_case_study_grading_screen.dart';
import 'package:lms_mobile_app/src/features/instructor/presentation/screens/instructor_document_grading_screen.dart';
import 'package:lms_mobile_app/src/features/games/presentation/hub/bloc/games_hub_bloc.dart';
import 'package:lms_mobile_app/src/features/games/presentation/hub/screens/games_hub_screen.dart';
import 'package:lms_mobile_app/src/features/games/presentation/games/game_2048/screens/game_2048_screen.dart';
import 'package:lms_mobile_app/src/features/games/presentation/games/schulte_table/screens/schulte_table_screen.dart';
import 'package:lms_mobile_app/src/features/games/presentation/games/stack_tower/screens/stack_tower_screen.dart';
import 'package:lms_mobile_app/src/features/games/presentation/games/flappy/screens/flappy_screen.dart';

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
    initialLocation: AppRoutes.splash,
    refreshListenable: _GoRouterRefreshStream(_authBloc.stream),
    redirect: (context, state) {
      // The splash gates the app while the session restores; never redirect it.
      if (state.matchedLocation == AppRoutes.splash) {
        return null;
      }

      final authState = _authBloc.state;
      final isAuthenticated = authState is AuthSuccess;
      final user = isAuthenticated ? authState.user : null;
      final mustVerify = user?.mustVerifyEmail ?? false;

      final loc = state.matchedLocation;
      final isOnAuthRoute =
          loc == AppRoutes.intro ||
          loc == AppRoutes.login ||
          loc == AppRoutes.register ||
          loc == AppRoutes.forgotPassword;
      final isOnVerify = loc == AppRoutes.verifyEmail;

      // Belum login: hanya boleh di layar auth/lupa-password.
      if (!isAuthenticated) {
        return isOnAuthRoute ? null : AppRoutes.intro;
      }

      // Login tapi WAJIB verifikasi email (akun baru): paksa ke layar OTP.
      // Kecuali layar "Ubah Email" — jalan keluar yang sah bila email salah
      // ketik saat daftar (ganti ke email valid sekaligus memverifikasinya).
      if (mustVerify) {
        final allowedWhileVerifying =
            isOnVerify || loc == AppRoutes.changeEmail;
        return allowedWhileVerifying ? null : AppRoutes.verifyEmail;
      }

      // Login: jauhkan dari layar auth.
      if (isOnAuthRoute) {
        return AppRoutes.main;
      }

      // Sudah verified tidak perlu layar verifikasi; tapi akun lama yang belum
      // verified BOLEH membukanya sukarela dari Profil.
      if (isOnVerify && (user?.emailVerified ?? true)) {
        return AppRoutes.main;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
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
        path: AppRoutes.verifyEmail,
        builder: (context, state) => BlocProvider<AuthActionCubit>(
          create: (_) => _sl<AuthActionCubit>(),
          child: const VerifyEmailScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (context, state) => BlocProvider<AuthActionCubit>(
          create: (_) => _sl<AuthActionCubit>(),
          child: const ForgotPasswordScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.changePassword,
        builder: (context, state) => BlocProvider<AuthActionCubit>(
          create: (_) => _sl<AuthActionCubit>(),
          child: const ChangePasswordScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.changeEmail,
        builder: (context, state) => BlocProvider<AuthActionCubit>(
          create: (_) => _sl<AuthActionCubit>(),
          child: const ChangeEmailScreen(),
        ),
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
        path: AppRoutes.joinClass,
        builder: (context, state) => const JoinClassScreen(),
      ),
      GoRoute(
        path: AppRoutes.notifications,
        builder: (context, state) => BlocProvider<NotificationsCubit>.value(
          value: _sl<NotificationsCubit>(),
          child: const NotificationsScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.discussionHub,
        builder: (context, state) => const DiscussionHubScreen(),
      ),
      GoRoute(
        path: AppRoutes.editProfile,
        builder: (context, state) {
          // `extra` is not part of the URL, so a router refresh (e.g. when the
          // AuthBloc emits after a successful save) drops it. Fall back to the
          // current authenticated user so the rebuild never casts a null.
          final authState = _authBloc.state;
          final user =
              (state.extra as UserEntity?) ??
              (authState is AuthSuccess ? authState.user : null);
          if (user == null) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          return BlocProvider<EditProfileCubit>(
            create: (_) => _sl<EditProfileCubit>(),
            child: EditProfileScreen(user: user),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.achievements,
        builder: (context, state) =>
            AchievementsScreen(stats: state.extra as HomeStatsEntity),
      ),
      GoRoute(
        path: AppRoutes.agenda,
        builder: (context, state) => const AgendaScreen(),
      ),
      GoRoute(
        path: AppRoutes.assignments,
        builder: (context, state) => const AssignmentsScreen(),
      ),
      GoRoute(
        path: AppRoutes.instructorHub,
        builder: (context, state) => const InstructorDashboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.discussionThread,
        builder: (context, state) {
          final args = state.extra as Map<String, dynamic>;
          return DiscussionThreadScreen(
            contentId: args['contentId'] as String,
            lessonTitle: (args['lessonTitle'] as String?) ?? '',
            courseTitle: args['courseTitle'] as String?,
            highlightDiscussionId: args['highlightDiscussionId'] as String?,
          );
        },
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
        path: AppRoutes.caseStudyLessonDetail,
        pageBuilder: (context, state) {
          final args = state.extra as Map<String, dynamic>;
          return CustomTransitionPage(
            key: state.pageKey,
            child: BlocProvider<CaseStudyBloc>(
              create: (context) => _sl<CaseStudyBloc>(),
              child: CaseStudyLessonDetailScreen(
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
        path: AppRoutes.feedbackLessonDetail,
        pageBuilder: (context, state) {
          final args = state.extra as Map<String, dynamic>;
          return CustomTransitionPage(
            key: state.pageKey,
            child: BlocProvider<FeedbackBloc>(
              create: (context) => _sl<FeedbackBloc>(),
              child: FeedbackLessonDetailScreen(
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
        path: AppRoutes.zoomLessonDetail,
        pageBuilder: (context, state) {
          final args = state.extra as Map<String, dynamic>;
          final lesson = args['lesson'] as LessonEntity;
          final course = args['course'] as CourseEntity;
          final lessonIndex = args['lessonIndex'] as int;
          return CustomTransitionPage(
            key: state.pageKey,
            child: ZoomLessonDetailScreen(
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
        path: AppRoutes.caseStudyResultDetail,
        pageBuilder: (context, state) {
          final attempt = state.extra as LessonAttempt;
          return CustomTransitionPage(
            key: state.pageKey,
            child: BlocProvider<CaseStudyBloc>(
              create: (context) => _sl<CaseStudyBloc>(),
              child: CaseStudyResultDetailScreen(attempt: attempt),
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
      // ── Instructor / admin ───────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.instructorParticipants,
        builder: (context, state) {
          final args = state.extra as Map<String, dynamic>;
          return InstructorParticipantsScreen(
            courseId: args['courseId'] as String,
            courseTitle: (args['courseTitle'] as String?) ?? '',
          );
        },
      ),
      GoRoute(
        path: AppRoutes.instructorGradingQueue,
        builder: (context, state) {
          final args = state.extra as Map<String, dynamic>;
          return InstructorGradingQueueScreen(
            courseId: args['courseId'] as String,
            courseTitle: args['courseTitle'] as String? ?? '',
          );
        },
      ),
      GoRoute(
        path: AppRoutes.instructorParticipantDetail,
        builder: (context, state) {
          final args = state.extra as Map<String, dynamic>;
          return InstructorParticipantDetailScreen(
            courseId: args['courseId'] as String,
            userId: args['userId'] as String,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.instructorEssayGrading,
        builder: (context, state) {
          final submissionId = state.extra as String;
          return InstructorEssayGradingScreen(submissionId: submissionId);
        },
      ),
      GoRoute(
        path: AppRoutes.instructorCaseStudyGrading,
        builder: (context, state) {
          final submissionId = state.extra as String;
          return InstructorCaseStudyGradingScreen(submissionId: submissionId);
        },
      ),
      GoRoute(
        path: AppRoutes.instructorDocumentGrading,
        builder: (context, state) {
          final args = state.extra as Map<String, dynamic>;
          return InstructorDocumentGradingScreen(
            submissionId: args['submissionId'] as String,
            contentId: args['contentId'] as String,
            contentTitle: (args['contentTitle'] as String?) ?? 'Pengumpulan Dokumen',
            participantName: (args['participantName'] as String?) ?? 'Peserta',
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
      GoRoute(
        path: AppRoutes.savedCourses,
        builder: (context, state) => const SavedCoursesScreen(),
      ),
      GoRoute(
        path: AppRoutes.gamesHub,
        builder: (context, state) => BlocProvider<GamesHubBloc>(
          create: (context) => _sl<GamesHubBloc>(),
          child: const GamesHubScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.game2048,
        builder: (context, state) => const Game2048Screen(),
      ),
      GoRoute(
        path: AppRoutes.gameSchulte,
        builder: (context, state) => const SchulteTableScreen(),
      ),
      GoRoute(
        path: AppRoutes.gameStackTower,
        builder: (context, state) => const StackTowerScreen(),
      ),
      GoRoute(
        path: AppRoutes.gameFlappy,
        builder: (context, state) => const FlappyScreen(),
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
