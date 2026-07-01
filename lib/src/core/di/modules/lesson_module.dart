// Lesson module - dependency injection untuk lesson feature
// Berisi: LessonRepository, UseCases, BLoC
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:lms_mobile_app/src/features/authentication/domain/usecases/get_current_user_usecase.dart';
import 'package:lms_mobile_app/src/features/lessons/data/datasources/essay_local_data_source.dart';
import 'package:lms_mobile_app/src/features/lessons/data/datasources/essay_remote_datasource_impl.dart';
import 'package:lms_mobile_app/src/features/lessons/data/datasources/quiz_local_datasource_impl.dart';
import 'package:lms_mobile_app/src/features/lessons/data/datasources/quiz_remote_datasource_impl.dart';
import 'package:lms_mobile_app/src/features/lessons/data/datasources/lesson_remote_datasource_impl.dart';
import 'package:lms_mobile_app/src/features/lessons/data/datasources/discussion_remote_datasource_impl.dart';
import 'package:lms_mobile_app/src/features/lessons/data/repositories/discussion_repository_impl.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/usecases/create_discussion_usecase.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/usecases/create_reply_usecase.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/usecases/get_discussion_usecase.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/bloc/discussion/discussion_cubit.dart';
import 'package:lms_mobile_app/src/features/lessons/data/repositories/essay_repository_impl.dart';
import 'package:lms_mobile_app/src/features/lessons/data/repositories/lesson_result_remote_impl.dart';
import 'package:lms_mobile_app/src/features/lessons/data/repositories/lesson_repository_impl.dart';
import 'package:lms_mobile_app/src/features/lessons/data/repositories/quiz_repository_impl.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/repositories/quiz_repository.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/repositories/lesson_repository.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/repositories/lesson_result_repository.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/usecases/get_quiz_usecase.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/usecases/get_quiz_leaderboard_usecase.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/usecases/submit_quiz_usecase.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/usecases/is_lesson_completed_usecase.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/usecases/mark_lesson_complete_usecase.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/usecases/mark_lesson_incomplete_usecase.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/usecases/refresh_lesson_completion_usecase.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/usecases/submit_essay_usecase.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/usecases/toggle_lesson_completion_usecase.dart';
import 'package:lms_mobile_app/src/features/lessons/data/datasources/case_study_remote_datasource_impl.dart';
import 'package:lms_mobile_app/src/features/lessons/data/repositories/case_study_repository_impl.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/bloc/case_study/case_study_bloc.dart';
import 'package:lms_mobile_app/src/features/lessons/data/datasources/feedback_remote_datasource_impl.dart';
import 'package:lms_mobile_app/src/features/lessons/data/repositories/feedback_repository_impl.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/bloc/feedback/feedback_bloc.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/bloc/essay/essay_bloc.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/bloc/lesson/lesson_bloc.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/bloc/quiz/quiz_bloc.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/bloc/quiz_result/quiz_result_bloc.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/bloc/video/video_bloc.dart';

class LessonModule {
  /// Register semua lesson dependencies
  static void register(GetIt getIt) {
    if (getIt.isRegistered<LessonBloc>()) {
      return;
    }

    // Repository
    final lessonRemoteDataSource = LessonRemoteDataSourceImpl(
      dio: getIt<Dio>(),
    );
    final LessonRepository lessonRepository = LessonRepositoryImpl(
      remoteDataSource: lessonRemoteDataSource,
    );
    getIt.registerLazySingleton<LessonResultRepository>(
      () => LessonResultRemoteImpl(dio: getIt<Dio>()),
    );
    final lessonResultRepository = getIt<LessonResultRepository>();

    // Use Cases
    final isLessonCompletedUseCase = IsLessonCompletedUseCase(lessonRepository);
    final toggleLessonCompletionUseCase = ToggleLessonCompletionUseCase(
      lessonRepository,
    );
    final markLessonCompleteUseCase = MarkLessonCompleteUseCase(
      lessonRepository,
    );
    final markLessonIncompleteUseCase = MarkLessonIncompleteUseCase(
      lessonRepository,
    );
    final refreshLessonCompletionUseCase = RefreshLessonCompletionUseCase(
      lessonRepository,
    );

    // BLoC
    getIt.registerLazySingleton<LessonBloc>(
      () => LessonBloc(
        isLessonCompletedUseCase: isLessonCompletedUseCase,
        toggleLessonCompletionUseCase: toggleLessonCompletionUseCase,
        markLessonCompleteUseCase: markLessonCompleteUseCase,
        markLessonIncompleteUseCase: markLessonIncompleteUseCase,
        refreshLessonCompletionUseCase: refreshLessonCompletionUseCase,
      ),
    );

    // QuizRepository sebagai singleton agar bisa dipakai ulang di luar QuizBloc
    // (mis. QuizLeaderboardSection di halaman "Nilai & Hasil"). Cache-nya statis
    // sehingga singleton/factory tak berpengaruh ke perilaku cache.
    getIt.registerLazySingleton<QuizRepository>(
      () => QuizRepositoryImpl(
        localDataSource: QuizLocalDataSourceImpl(),
        remoteDataSource: QuizRemoteDataSourceImpl(dio: getIt<Dio>()),
      ),
    );

    getIt.registerFactory<QuizBloc>(() {
      final quizRepository = getIt<QuizRepository>();

      final submitUseCase = SubmitQuizUseCase(
        repository: quizRepository,
        resultRepository: lessonResultRepository,
      );

      return QuizBloc(
        getQuizUseCase: GetQuizUseCase(repository: quizRepository),
        submitQuizUseCase: submitUseCase,
        getQuizLeaderboardUseCase: GetQuizLeaderboardUseCase(
          repository: quizRepository,
        ),
      );
    });

    getIt.registerFactory<QuizResultBloc>(() {
      return QuizResultBloc(resultRepository: lessonResultRepository);
    });

    getIt.registerFactory<EssayBloc>(() {
      final localDataSource = EssayLocalDataSourceImpl();
      final remoteDataSource = EssayRemoteDataSourceImpl(dio: getIt<Dio>());
      final repository = EssayRepositoryImpl(
        localDataSource,
        remoteDataSource: remoteDataSource,
      );
      return EssayBloc(
        repository: repository,
        submitUseCase: SubmitEssayUseCase(repository),
        getCurrentUserUseCase: getIt.isRegistered<GetCurrentUserUseCase>()
            ? getIt<GetCurrentUserUseCase>()
            : null,
        resultRepository: lessonResultRepository,
      );
    });

    getIt.registerFactory<CaseStudyBloc>(() {
      final remoteDataSource = CaseStudyRemoteDataSourceImpl(dio: getIt<Dio>());
      final repository = CaseStudyRepositoryImpl(
        remoteDataSource: remoteDataSource,
      );
      return CaseStudyBloc(repository: repository);
    });

    getIt.registerFactory<FeedbackBloc>(() {
      final remoteDataSource = FeedbackRemoteDataSourceImpl(dio: getIt<Dio>());
      final repository = FeedbackRepositoryImpl(
        remoteDataSource: remoteDataSource,
      );
      return FeedbackBloc(repository: repository);
    });

    getIt.registerFactory<VideoBloc>(() => VideoBloc());

    // Discussion cubit — one per lesson screen, created with the lesson id.
    getIt.registerFactoryParam<DiscussionCubit, String, void>((lessonId, _) {
      final remote = DiscussionRemoteDataSourceImpl(dio: getIt<Dio>());
      final repository = DiscussionRepositoryImpl(remoteDataSource: remote);
      return DiscussionCubit(
        getDiscussions: GetDiscussionUseCase(repository),
        createDiscussion: CreateDiscussionUseCase(repository),
        createReply: CreateReplyUseCase(repository),
        lessonId: lessonId,
      );
    });
  }
}
