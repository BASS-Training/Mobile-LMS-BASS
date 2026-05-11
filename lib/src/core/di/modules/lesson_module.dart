/// Lesson module - dependency injection untuk lesson feature
/// Berisi: LessonRepository, UseCases, BLoC
import 'package:lms_mobile_app/src/features/lessons/data/repositories/lesson_repository_impl.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/repositories/lesson_repository.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/usecases/lesson_usecase.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/bloc/lesson/lesson_bloc.dart';

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
}
