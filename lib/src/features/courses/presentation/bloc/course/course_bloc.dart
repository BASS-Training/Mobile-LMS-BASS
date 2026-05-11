import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/course_usecase.dart';
import 'course_event.dart';
import 'course_state.dart';

class CourseBloc extends Bloc<CourseEvent, CourseState> {
  final GetCoursesUseCase getCoursesUseCase;
  final SearchCoursesUseCase searchCoursesUseCase;
  final ToggleSaveCourseUseCase toggleSaveCourseUseCase;
  final GetSavedCoursesUseCase getSavedCoursesUseCase;
  final RefreshCoursesUseCase refreshCoursesUseCase;

  CourseBloc({
    required this.getCoursesUseCase,
    required this.searchCoursesUseCase,
    required this.toggleSaveCourseUseCase,
    required this.getSavedCoursesUseCase,
    required this.refreshCoursesUseCase,
  }) : super(const CourseInitial()) {
    on<GetCoursesEvent>(_onGetCourses);
    on<SearchCoursesEvent>(_onSearchCourses);
    on<ToggleSaveCourseEvent>(_onToggleSaveCourse);
    on<GetSavedCoursesEvent>(_onGetSavedCourses);
    on<RefreshCoursesEvent>(_onRefreshCourses);
  }

  Future<void> _onGetCourses(
      GetCoursesEvent event, Emitter<CourseState> emit) async {
    emit(const CourseLoading());

    try {
      final courses = await getCoursesUseCase();
      emit(CourseLoaded(courses: courses));
    } catch (e) {
      emit(CourseFailure(message: 'Failed to load courses'));
    }
  }

  Future<void> _onSearchCourses(
      SearchCoursesEvent event, Emitter<CourseState> emit) async {
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
      ToggleSaveCourseEvent event, Emitter<CourseState> emit) async {
    try {
      await toggleSaveCourseUseCase(event.courseId);

      // Reload courses to reflect changes
      if (state is CourseLoaded) {
        final currentState = state as CourseLoaded;
        final courses = await getCoursesUseCase();
        emit(CourseLoaded(
          courses: courses,
          searchQuery: currentState.searchQuery,
        ));
      }
    } catch (e) {
      emit(CourseFailure(message: 'Failed to toggle save'));
    }
  }

  Future<void> _onGetSavedCourses(
      GetSavedCoursesEvent event, Emitter<CourseState> emit) async {
    emit(const CourseLoading());

    try {
      final courses = await getSavedCoursesUseCase();
      emit(SavedCoursesLoaded(courses: courses));
    } catch (e) {
      emit(CourseFailure(message: 'Failed to load saved courses'));
    }
  }

  Future<void> _onRefreshCourses(
      RefreshCoursesEvent event, Emitter<CourseState> emit) async {
    try {
      await refreshCoursesUseCase();

      // Reload courses
      final courses = await getCoursesUseCase();
      emit(CourseLoaded(courses: courses));
    } catch (e) {
      emit(CourseFailure(message: 'Failed to refresh courses'));
    }
  }
}
