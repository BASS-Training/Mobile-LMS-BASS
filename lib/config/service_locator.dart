import 'package:lms_mobile_app/data/repositories/auth_repository_impl.dart';
import 'package:lms_mobile_app/data/repositories/course_repository_impl.dart';
import 'package:lms_mobile_app/data/repositories/lesson_repository_impl.dart';
import 'package:lms_mobile_app/domain/repositories/auth_repository.dart';
import 'package:lms_mobile_app/domain/repositories/course_repository.dart';
import 'package:lms_mobile_app/domain/repositories/lesson_repository.dart';
import 'package:lms_mobile_app/domain/usecases/auth_usecase.dart';
import 'package:lms_mobile_app/domain/usecases/course_usecase.dart';
import 'package:lms_mobile_app/domain/usecases/lesson_usecase.dart';
import 'package:lms_mobile_app/presentation/bloc/auth/auth_bloc.dart';
import 'package:lms_mobile_app/presentation/bloc/course/course_bloc.dart';
import 'package:lms_mobile_app/presentation/bloc/lesson/lesson_bloc.dart';

class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();

  factory ServiceLocator() {
    return _instance;
  }

  ServiceLocator._internal();

  late AuthBloc _authBloc;
  late CourseBloc _courseBloc;
  late LessonBloc _lessonBloc;

  void setupServiceLocator() {
    // Repositories
    AuthRepository authRepository = AuthRepositoryImpl();
    CourseRepository courseRepository = CourseRepositoryImpl();
    LessonRepository lessonRepository = LessonRepositoryImpl();

    // Auth Use Cases
    LoginUseCase loginUseCase = LoginUseCase(authRepository);
    LogoutUseCase logoutUseCase = LogoutUseCase(authRepository);

    // Course Use Cases
    GetCoursesUseCase getCoursesUseCase = GetCoursesUseCase(courseRepository);
    SearchCoursesUseCase searchCoursesUseCase =
        SearchCoursesUseCase(courseRepository);
    ToggleSaveCourseUseCase toggleSaveCourseUseCase =
        ToggleSaveCourseUseCase(courseRepository);
    GetSavedCoursesUseCase getSavedCoursesUseCase =
        GetSavedCoursesUseCase(courseRepository);
    RefreshCoursesUseCase refreshCoursesUseCase =
        RefreshCoursesUseCase(courseRepository);

    // Lesson Use Cases
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

    // Blocs
    _authBloc = AuthBloc(
      loginUseCase: loginUseCase,
      logoutUseCase: logoutUseCase,
    );

    _courseBloc = CourseBloc(
      getCoursesUseCase: getCoursesUseCase,
      searchCoursesUseCase: searchCoursesUseCase,
      toggleSaveCourseUseCase: toggleSaveCourseUseCase,
      getSavedCoursesUseCase: getSavedCoursesUseCase,
      refreshCoursesUseCase: refreshCoursesUseCase,
    );

    _lessonBloc = LessonBloc(
      isLessonCompletedUseCase: isLessonCompletedUseCase,
      toggleLessonCompletionUseCase: toggleLessonCompletionUseCase,
      markLessonCompleteUseCase: markLessonCompleteUseCase,
      markLessonIncompleteUseCase: markLessonIncompleteUseCase,
      refreshLessonCompletionUseCase: refreshLessonCompletionUseCase,
    );
  }

  AuthBloc get authBloc => _authBloc;
  CourseBloc get courseBloc => _courseBloc;
  LessonBloc get lessonBloc => _lessonBloc;
}
