/// Lesson module - dependency injection untuk lesson feature
/// Berisi: LessonRepository, UseCases, BLoC
import 'package:lms_mobile_app/src/features/lessons/data/datasources/essay_local_data_source.dart';
import 'package:lms_mobile_app/src/features/lessons/data/datasources/quiz_local_datasource_impl.dart';
import 'package:lms_mobile_app/src/features/lessons/data/datasources/video_lesson_remote_data_source.dart';
import 'package:lms_mobile_app/src/features/lessons/data/repositories/essay_repository_impl.dart';
import 'package:lms_mobile_app/src/features/lessons/data/repositories/lesson_repository_impl.dart';
import 'package:lms_mobile_app/src/features/lessons/data/repositories/quiz_repository_impl.dart';
import 'package:lms_mobile_app/src/features/lessons/data/repositories/video_repository_impl.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/repositories/lesson_repository.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/usecases/get_quiz_usecase.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/usecases/lesson_usecase.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/usecases/submit_essay_usecase.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/usecases/video_lesson_usecase.dart.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/bloc/essay/essay_bloc.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/bloc/lesson/lesson_bloc.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/bloc/quiz/quiz_bloc.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/bloc/video/video_bloc.dart';

class LessonModule {
  static late LessonBloc _lessonBloc;

  /// Register semua lesson dependencies
  static void register() {
    // Repository
    LessonRepository lessonRepository = LessonRepositoryImpl();

    // Use Cases
    IsLessonCompletedUseCase isLessonCompletedUseCase =
        IsLessonCompletedUseCase(lessonRepository);
    ToggleLessonCompletionUseCase toggleLessonCompletionUseCase =
        ToggleLessonCompletionUseCase(lessonRepository);
    MarkLessonCompleteUseCase markLessonCompleteUseCase =
        MarkLessonCompleteUseCase(lessonRepository);
    MarkLessonIncompleteUseCase markLessonIncompleteUseCase =
        MarkLessonIncompleteUseCase(lessonRepository);
    RefreshLessonCompletionUseCase refreshLessonCompletionUseCase =
        RefreshLessonCompletionUseCase(lessonRepository);

    // BLoC
    _lessonBloc = LessonBloc(
      isLessonCompletedUseCase: isLessonCompletedUseCase,
      toggleLessonCompletionUseCase: toggleLessonCompletionUseCase,
      markLessonCompleteUseCase: markLessonCompleteUseCase,
      markLessonIncompleteUseCase: markLessonIncompleteUseCase,
      refreshLessonCompletionUseCase: refreshLessonCompletionUseCase,
    );
  }

  /// Get LessonBloc instance
  static LessonBloc get lessonBloc => _lessonBloc;
  static QuizBloc get quizBloc {
    final quizDataSource = QuizLocalDataSourceImpl();
    final quizRepository = QuizRepositoryImpl(localDataSource: quizDataSource);
    return QuizBloc(
      getQuizUseCase: GetQuizUseCase(
        // Pastikan repository kuis juga sudah diinisialisasi di module ini
        repository: quizRepository,
      ),
    );
  }

  // Tambahkan getter untuk EssayBloc
  static EssayBloc get essayBloc {
    // 1. Inisialisasi Data Source
    final localDataSource = EssayLocalDataSourceImpl();

    // 2. Inisialisasi Repository
    final repository = EssayRepositoryImpl(localDataSource);

    // 3. Inisialisasi UseCase
    final submitUseCase = SubmitEssayUseCase(repository);

    // 4. Return BLoC-nya
    return EssayBloc(repository: repository, submitUseCase: submitUseCase);
  }

  // Di dalam class Service Locator / Dependency Injection kamu:

static VideoBloc get videoBloc {
  // 1. Data Source
  final remoteDataSource = VideoLessonRemoteDataSourceImpl();
  
  // 2. Repository
  final repository = VideoLessonRepositoryImpl(remoteDataSource);
  
  // 3. Use Cases
  final getComments = GetVideoCommentsUseCase(repository);
  final submitComment = SubmitVideoCommentUseCase(repository);
  final markComplete = MarkVideoCompleteUseCase(repository);
  final checkProgress = CheckVideoProgressUseCase();

  // 4. BLoC
  return VideoBloc(
    getCommentsUseCase: getComments,
    submitCommentUseCase: submitComment,
    markCompleteUseCase: markComplete,
    checkProgressUseCase: checkProgress,
  );
}
}
