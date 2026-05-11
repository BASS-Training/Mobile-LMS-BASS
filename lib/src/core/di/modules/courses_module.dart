import 'package:get_it/get_it.dart';
import 'package:lms_mobile_app/src/features/courses/data/datasources/course_remote_data_source.dart';
import 'package:lms_mobile_app/src/features/courses/data/datasources/course_local_data_source.dart';
import 'package:lms_mobile_app/src/features/courses/data/repositories/course_repository_impl.dart';
import 'package:lms_mobile_app/src/features/courses/domain/repositories/course_repository.dart';
import 'package:lms_mobile_app/src/features/courses/domain/usecases/get_courses_usecase.dart';
import 'package:lms_mobile_app/src/features/courses/domain/usecases/search_courses_usecase.dart';
import 'package:lms_mobile_app/src/features/courses/domain/usecases/toggle_save_course_usecase.dart';
import 'package:lms_mobile_app/src/features/courses/domain/usecases/get_saved_courses_usecase.dart';
import 'package:lms_mobile_app/src/features/courses/domain/usecases/refresh_courses_usecase.dart';
import 'package:lms_mobile_app/src/features/courses/presentation/bloc/course_bloc.dart';

final getIt = GetIt.instance;

/// Register courses feature dependencies
///
/// Call dari injector.dart configureDependencies()
void registerCoursesModule() {
  // ============ DATA SOURCES ============

  // Remote data source
  getIt.registerSingleton<CourseRemoteDataSource>(CourseRemoteDataSourceImpl());

  // Local data source
  getIt.registerSingleton<CourseLocalDataSource>(CourseLocalDataSourceImpl());

  // ============ REPOSITORIES ============

  getIt.registerSingleton<CourseRepository>(
    CourseRepositoryImpl(
      localDataSource: getIt<CourseLocalDataSource>(),
      remoteDataSource: getIt<CourseRemoteDataSource>(),
    ),
  );

  // ============ USE CASES ============

  getIt.registerSingleton(GetCoursesUseCase(getIt<CourseRepository>()));

  getIt.registerSingleton(SearchCoursesUseCase(getIt<CourseRepository>()));

  getIt.registerSingleton(ToggleSaveCourseUseCase(getIt<CourseRepository>()));

  getIt.registerSingleton(GetSavedCoursesUseCase(getIt<CourseRepository>()));

  getIt.registerSingleton(RefreshCoursesUseCase(getIt<CourseRepository>()));

  // ============ BLoCs ============

  getIt.registerSingleton(
    CourseBloc(
      getCoursesUseCase: getIt(),
      searchCoursesUseCase: getIt(),
      toggleSaveCourseUseCase: getIt(),
      getSavedCoursesUseCase: getIt(),
      refreshCoursesUseCase: getIt(),
    ),
  );
}
