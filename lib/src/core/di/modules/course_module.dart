/// Course module - dependency injection untuk course feature
/// Berisi: CourseRepository, DataSources, UseCases, BLoC
import 'package:lms_mobile_app/src/features/courses/data/repositories/course_repository_impl.dart';
import 'package:lms_mobile_app/src/features/courses/data/datasources/course_local_data_source.dart';
import 'package:lms_mobile_app/src/features/courses/data/datasources/course_local_data_source_impl.dart';
import 'package:lms_mobile_app/src/features/courses/data/datasources/course_remote_data_source.dart';
import 'package:lms_mobile_app/src/features/courses/data/datasources/course_remote_data_source_impl.dart';
import 'package:lms_mobile_app/src/features/courses/domain/repositories/course_repository.dart';
import 'package:lms_mobile_app/src/features/courses/domain/usecases/add_course_usecase.dart';
import 'package:lms_mobile_app/src/features/courses/domain/usecases/get_courses_usecase.dart';
import 'package:lms_mobile_app/src/features/courses/domain/usecases/get_saved_courses_usecase.dart';
import 'package:lms_mobile_app/src/features/courses/domain/usecases/refresh_courses_usecase.dart';
import 'package:lms_mobile_app/src/features/courses/domain/usecases/search_courses_usecase.dart';
import 'package:lms_mobile_app/src/features/courses/domain/usecases/toggle_save_course_usecase.dart';
import 'package:lms_mobile_app/src/features/courses/domain/usecases/watch_courses_usecase.dart';
import 'package:lms_mobile_app/src/features/courses/presentation/bloc/course/course_bloc.dart';

class CourseModule {
  static late CourseBloc _courseBloc;

  /// Register semua course dependencies
  static void register() {
    // Data Sources
    CourseLocalDataSource courseLocalDataSource = CourseLocalDataSourceImpl();
    CourseRemoteDataSource courseRemoteDataSource =
        CourseRemoteDataSourceImpl();

    // Repository
    CourseRepository courseRepository = CourseRepositoryImpl(
      localDataSource: courseLocalDataSource,
      remoteDataSource: courseRemoteDataSource,
    );

    // Use Cases
    GetCoursesUseCase getCoursesUseCase = GetCoursesUseCase(courseRepository);
    SearchCoursesUseCase searchCoursesUseCase = SearchCoursesUseCase(
      courseRepository,
    );
    ToggleSaveCourseUseCase toggleSaveCourseUseCase = ToggleSaveCourseUseCase(
      courseRepository,
    );
    GetSavedCoursesUseCase getSavedCoursesUseCase = GetSavedCoursesUseCase(
      courseRepository,
    );
    RefreshCoursesUseCase refreshCoursesUseCase = RefreshCoursesUseCase(
      courseRepository,
    );
    WatchCoursesUseCase watchCoursesUseCase = WatchCoursesUseCase(
      courseRepository,
    );
    AddCourseUseCase addCourseUseCase = AddCourseUseCase(courseRepository);

    // BLoC
    _courseBloc = CourseBloc(
      getCoursesUseCase: getCoursesUseCase,
      searchCoursesUseCase: searchCoursesUseCase,
      toggleSaveCourseUseCase: toggleSaveCourseUseCase,
      getSavedCoursesUseCase: getSavedCoursesUseCase,
      refreshCoursesUseCase: refreshCoursesUseCase,
      watchCoursesUseCase: watchCoursesUseCase,
      addCourseUseCase: addCourseUseCase,
    );
  }

  /// Get CourseBloc instance
  static CourseBloc get courseBloc => _courseBloc;
}
