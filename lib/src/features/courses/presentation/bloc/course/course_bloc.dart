import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms_mobile_app/src/features/courses/domain/entities/course_entity.dart';
import 'package:lms_mobile_app/src/features/courses/domain/usecases/add_course_usecase.dart';
import 'package:lms_mobile_app/src/features/courses/domain/usecases/get_courses_usecase.dart';
import 'package:lms_mobile_app/src/features/courses/domain/usecases/get_saved_courses_usecase.dart';
import 'package:lms_mobile_app/src/features/courses/domain/usecases/refresh_courses_usecase.dart';
import 'package:lms_mobile_app/src/features/courses/domain/usecases/search_courses_usecase.dart';
import 'package:lms_mobile_app/src/features/courses/domain/usecases/watch_courses_usecase.dart';
import 'package:lms_mobile_app/src/features/courses/domain/usecases/toggle_save_course_usecase.dart';
import 'course_event.dart';
import 'course_state.dart';

class CourseBloc extends Bloc<CourseEvent, CourseState> {
  final GetCoursesUseCase getCoursesUseCase;
  final SearchCoursesUseCase searchCoursesUseCase;
  final ToggleSaveCourseUseCase toggleSaveCourseUseCase;
  final GetSavedCoursesUseCase getSavedCoursesUseCase;
  final RefreshCoursesUseCase refreshCoursesUseCase;
  final WatchCoursesUseCase watchCoursesUseCase;
  final AddCourseUseCase addCourseUseCase;

  CourseBloc({
    required this.getCoursesUseCase,
    required this.searchCoursesUseCase,
    required this.toggleSaveCourseUseCase,
    required this.getSavedCoursesUseCase,
    required this.refreshCoursesUseCase,
    required this.watchCoursesUseCase,
    required this.addCourseUseCase,
  }) : super(const CourseInitial()) {
    on<GetCoursesEvent>(_onGetCourses);
    on<WatchCoursesEvent>(_onWatchCourses);
    on<SearchCoursesEvent>(_onSearchCourses);
    on<ToggleSaveCourseEvent>(_onToggleSaveCourse);
    on<GetSavedCoursesEvent>(_onGetSavedCourses);
    on<RefreshCoursesEvent>(_onRefreshCourses);
    on<AddCourseEvent>(_onAddCourse);

    Future.microtask(() => add(const WatchCoursesEvent()));
  }

  Future<void> _onGetCourses(
    GetCoursesEvent event,
    Emitter<CourseState> emit,
  ) async {
    emit(const CourseLoading());

    try {
      final courses = await getCoursesUseCase();
      emit(CourseLoaded(courses: courses));
    } catch (e) {
      emit(CourseFailure(message: 'Failed to load courses'));
    }
  }

  Future<void> _onWatchCourses(
    WatchCoursesEvent event,
    Emitter<CourseState> emit,
  ) async {
    await emit.forEach<List<CourseEntity>>(
      watchCoursesUseCase(),
      onData: (courses) => CourseLoaded(courses: courses),
      onError: (error, stackTrace) {
        return const CourseFailure(
          message: 'Failed to sync courses from Firestore',
        );
      },
    );
  }

  Future<void> _onSearchCourses(
    SearchCoursesEvent event,
    Emitter<CourseState> emit,
  ) async {
    emit(const CourseLoading());

    try {
      if (event.query.isEmpty) {
        final courses = await getCoursesUseCase();
        emit(CourseLoaded(courses: courses, searchQuery: ''));
      } else {
        final courses = await searchCoursesUseCase(event.query);
        emit(CourseLoaded(courses: courses, searchQuery: event.query));
      }
    } catch (e) {
      emit(CourseFailure(message: 'Search failed'));
    }
  }

  Future<void> _onToggleSaveCourse(
    ToggleSaveCourseEvent event,
    Emitter<CourseState> emit,
  ) async {
    try {
      await toggleSaveCourseUseCase(event.courseId);

      // Reload courses to reflect changes
      if (state is CourseLoaded) {
        final currentState = state as CourseLoaded;
        final courses = await getCoursesUseCase();
        emit(
          CourseLoaded(courses: courses, searchQuery: currentState.searchQuery),
        );
      }
    } catch (e) {
      emit(CourseFailure(message: 'Failed to toggle save'));
    }
  }

  Future<void> _onGetSavedCourses(
    GetSavedCoursesEvent event,
    Emitter<CourseState> emit,
  ) async {
    emit(const CourseLoading());

    try {
      final courses = await getSavedCoursesUseCase();
      emit(SavedCoursesLoaded(courses: courses));
    } catch (e) {
      emit(CourseFailure(message: 'Failed to load saved courses'));
    }
  }

  Future<void> _onRefreshCourses(
    RefreshCoursesEvent event,
    Emitter<CourseState> emit,
  ) async {
    try {
      await refreshCoursesUseCase();

      // Reload courses
      final courses = await getCoursesUseCase();
      emit(CourseLoaded(courses: courses));
    } catch (e) {
      emit(CourseFailure(message: 'Failed to refresh courses'));
    }
  }

  Future<void> _onAddCourse(
    AddCourseEvent event,
    Emitter<CourseState> emit,
  ) async {
    try {
      await addCourseUseCase(event.course);
      await refreshCoursesUseCase();
    } catch (e) {
      emit(CourseFailure(message: 'Failed to add course'));
    }
  }
}
