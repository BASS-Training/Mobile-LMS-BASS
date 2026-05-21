// Course module - dependency injection untuk course feature
// Berisi: CourseRepository, DataSources, UseCases, BLoC
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
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
  /// Register semua course dependencies
  static void register(GetIt getIt) {
    if (getIt.isRegistered<CourseBloc>()) {
      return;
    }

    // Data Sources
    final CourseLocalDataSource courseLocalDataSource =
        CourseLocalDataSourceImpl();
    final CourseRemoteDataSource courseRemoteDataSource =
        CourseRemoteDataSourceImpl(dio: getIt<Dio>());

    // Repository
    final CourseRepository courseRepository = CourseRepositoryImpl(
      localDataSource: courseLocalDataSource,
      remoteDataSource: courseRemoteDataSource,
    );

    // Use Cases
    final getCoursesUseCase = GetCoursesUseCase(courseRepository);
    final searchCoursesUseCase = SearchCoursesUseCase(courseRepository);
    final toggleSaveCourseUseCase = ToggleSaveCourseUseCase(courseRepository);
    final getSavedCoursesUseCase = GetSavedCoursesUseCase(courseRepository);
    final refreshCoursesUseCase = RefreshCoursesUseCase(courseRepository);
    final watchCoursesUseCase = WatchCoursesUseCase(courseRepository);
    final addCourseUseCase = AddCourseUseCase(courseRepository);

    // BLoC
    getIt.registerFactory<CourseBloc>(
      () => CourseBloc(
        getCoursesUseCase: getCoursesUseCase,
        searchCoursesUseCase: searchCoursesUseCase,
        toggleSaveCourseUseCase: toggleSaveCourseUseCase,
        getSavedCoursesUseCase: getSavedCoursesUseCase,
        refreshCoursesUseCase: refreshCoursesUseCase,
        watchCoursesUseCase: watchCoursesUseCase,
        addCourseUseCase: addCourseUseCase,
      ),
    );
  }
}
