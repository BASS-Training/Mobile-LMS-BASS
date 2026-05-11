import 'package:get_it/get_it.dart';
import 'package:lms_mobile_app/src/features/lessons/data/datasources/lesson_local_data_source.dart';
import 'package:lms_mobile_app/src/features/lessons/data/repositories/lesson_repository_impl.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/repositories/lesson_repository.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/usecases/is_lesson_completed_usecase.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/usecases/toggle_lesson_completion_usecase.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/usecases/mark_lesson_complete_usecase.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/usecases/mark_lesson_incomplete_usecase.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/usecases/refresh_lesson_completion_usecase.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/bloc/lesson_bloc.dart';

final getIt = GetIt.instance;

/// Register lessons feature dependencies
///
/// Call dari injector.dart configureDependencies()
void registerLessonsModule() {
  // ============ DATA SOURCES ============

  getIt.registerSingleton<LessonLocalDataSource>(LessonLocalDataSourceImpl());

  // ============ REPOSITORIES ============

  getIt.registerSingleton<LessonRepository>(
    LessonRepositoryImpl(localDataSource: getIt<LessonLocalDataSource>()),
  );

  // ============ USE CASES ============

  getIt.registerSingleton(IsLessonCompletedUseCase(getIt<LessonRepository>()));

  getIt.registerSingleton(
    ToggleLessonCompletionUseCase(getIt<LessonRepository>()),
  );

  getIt.registerSingleton(MarkLessonCompleteUseCase(getIt<LessonRepository>()));

  getIt.registerSingleton(
    MarkLessonIncompleteUseCase(getIt<LessonRepository>()),
  );

  getIt.registerSingleton(
    RefreshLessonCompletionUseCase(getIt<LessonRepository>()),
  );

  // ============ BLoCs ============

  getIt.registerSingleton(
    LessonBloc(
      isLessonCompletedUseCase: getIt(),
      toggleLessonCompletionUseCase: getIt(),
      markLessonCompleteUseCase: getIt(),
      markLessonIncompleteUseCase: getIt(),
      refreshLessonCompletionUseCase: getIt(),
    ),
  );
}
