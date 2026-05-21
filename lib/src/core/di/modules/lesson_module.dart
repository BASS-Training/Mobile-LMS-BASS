// Lesson module - dependency injection untuk lesson feature
// Berisi: LessonRepository, UseCases, BLoC
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:lms_mobile_app/src/features/lessons/data/datasources/essay_local_data_source.dart';
import 'package:lms_mobile_app/src/features/lessons/data/datasources/essay_remote_datasource_impl.dart';
import 'package:lms_mobile_app/src/features/lessons/data/datasources/quiz_local_datasource_impl.dart';
import 'package:lms_mobile_app/src/features/lessons/data/datasources/quiz_remote_datasource_impl.dart';
import 'package:lms_mobile_app/src/features/lessons/data/datasources/video_repository_impl.dart';
import 'package:lms_mobile_app/src/features/lessons/data/repositories/essay_repository_impl.dart';
import 'package:lms_mobile_app/src/features/lessons/data/repositories/lesson_result_repository_impl.dart';
import 'package:lms_mobile_app/src/features/lessons/data/repositories/lesson_repository_impl.dart';
import 'package:lms_mobile_app/src/features/lessons/data/repositories/quiz_repository_impl.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/repositories/lesson_repository.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/repositories/lesson_result_repository.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/usecases/get_quiz_usecase.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/usecases/submit_quiz_usecase.dart';
import 'package:lms_mobile_app/src/features/authentication/domain/usecases/auth_usecase.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/usecases/is_lesson_completed_usecase.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/usecases/mark_lesson_complete_usecase.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/usecases/mark_lesson_incomplete_usecase.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/usecases/refresh_lesson_completion_usecase.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/usecases/submit_essay_usecase.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/usecases/toggle_lesson_completion_usecase.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/bloc/essay/essay_bloc.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/bloc/lesson/lesson_bloc.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/bloc/quiz/quiz_bloc.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/bloc/video/video_bloc.dart';

class LessonModule {
  /// Register semua lesson dependencies
  static void register(GetIt getIt) {
    if (getIt.isRegistered<LessonBloc>()) {
      return;
    }

    // Repository
    final LessonRepository lessonRepository = LessonRepositoryImpl();
    getIt.registerLazySingleton<LessonResultRepository>(
      () => const LessonResultRepositoryImpl(),
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

    getIt.registerFactory<QuizBloc>(() {
      final quizDataSource = QuizLocalDataSourceImpl();
      final quizRemote = QuizRemoteDataSourceImpl(dio: getIt<Dio>());
      final quizRepository = QuizRepositoryImpl(
        localDataSource: quizDataSource,
        remoteDataSource: quizRemote,
      );

      final submitUseCase = SubmitQuizUseCase(
        repository: quizRepository,
        resultRepository: lessonResultRepository,
      );

      return QuizBloc(
        getQuizUseCase: GetQuizUseCase(repository: quizRepository),
        submitQuizUseCase: submitUseCase,
      );
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

    getIt.registerFactory<VideoBloc>(() => VideoBloc(VideoRepositoryImpl()));
  }
}
