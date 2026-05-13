/// Lesson module - dependency injection untuk lesson feature
/// Berisi: LessonRepository, UseCases, BLoC
import 'package:lms_mobile_app/src/features/lessons/data/datasources/essay_local_data_source.dart';
import 'package:lms_mobile_app/src/features/lessons/data/datasources/quiz_local_datasource_impl.dart';
import 'package:lms_mobile_app/src/features/lessons/data/datasources/video_repository_impl.dart';
import 'package:lms_mobile_app/src/features/lessons/data/repositories/essay_repository_impl.dart';
import 'package:lms_mobile_app/src/features/lessons/data/repositories/lesson_result_repository_impl.dart';
import 'package:lms_mobile_app/src/features/lessons/data/repositories/lesson_repository_impl.dart';
import 'package:lms_mobile_app/src/features/lessons/data/repositories/quiz_repository_impl.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/repositories/lesson_repository.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/repositories/lesson_result_repository.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/usecases/get_quiz_usecase.dart';
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
  static late LessonBloc _lessonBloc;
  static final LessonResultRepository _lessonResultRepository =
      const LessonResultRepositoryImpl();

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
      resultRepository: _lessonResultRepository,
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
    return EssayBloc(
      repository: repository,
      submitUseCase: submitUseCase,
      resultRepository: _lessonResultRepository,
    );
  }

  static LessonResultRepository get lessonResultRepository =>
      _lessonResultRepository;

  // Di dalam class LessonModule:
  static VideoBloc get videoBloc {
    final repository = VideoRepositoryImpl();
    return VideoBloc(repository);
  }
}
