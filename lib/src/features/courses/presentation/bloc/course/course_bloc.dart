import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms_mobile_app/src/features/courses/domain/entities/course_entity.dart';
import 'package:lms_mobile_app/src/features/courses/domain/usecases/add_course_usecase.dart';
import 'package:lms_mobile_app/src/features/courses/domain/usecases/get_courses_usecase.dart';
import 'package:lms_mobile_app/src/features/courses/domain/usecases/get_cached_courses_usecase.dart';
import 'package:lms_mobile_app/src/features/courses/domain/usecases/refresh_courses_usecase.dart';
import 'package:lms_mobile_app/src/features/courses/domain/usecases/toggle_save_course_usecase.dart';
import 'course_event.dart';
import 'course_state.dart';

/// Bloc utama daftar kursus. Get/refresh/mutasi diteruskan ke usecase, sedangkan
/// search memfilter canonical list di memori. Toggle-save memakai optimistic
/// update.
class CourseBloc extends Bloc<CourseEvent, CourseState> {
  final GetCoursesUseCase getCoursesUseCase;
  final GetCachedCoursesUseCase getCachedCoursesUseCase;
  final ToggleSaveCourseUseCase toggleSaveCourseUseCase;
  final RefreshCoursesUseCase refreshCoursesUseCase;
  final AddCourseUseCase addCourseUseCase;

  Future<List<CourseEntity>>? _coursesRequest;
  int _stateRequestId = 0;
  String _searchQuery = '';

  CourseBloc({
    required this.getCoursesUseCase,
    required this.getCachedCoursesUseCase,
    required this.toggleSaveCourseUseCase,
    required this.refreshCoursesUseCase,
    required this.addCourseUseCase,
  }) : super(const CourseInitial()) {
    on<GetCoursesEvent>(_onGetCourses);
    on<SearchCoursesEvent>(_onSearchCourses);
    on<ToggleSaveCourseEvent>(_onToggleSaveCourse);
    on<RefreshCoursesEvent>(_onRefreshCourses);
    on<AddCourseEvent>(_onAddCourse);
    on<ResetCoursesEvent>(_onResetCourses);
  }

  void _onResetCourses(ResetCoursesEvent event, Emitter<CourseState> emit) {
    _stateRequestId++;
    _searchQuery = '';
    emit(const CourseInitial());
  }

  Future<void> _onGetCourses(
    GetCoursesEvent event,
    Emitter<CourseState> emit,
  ) async {
    final requestId = ++_stateRequestId;
    final current = state;
    final previous = current is CourseLoaded ? current : null;

    // Cache-first: tampilkan data cache (disk) secara INSTAN tanpa skeleton bila
    // ada, lalu refresh diam-diam dari jaringan. Hanya tampilkan skeleton bila
    // benar-benar belum ada cache (mis. pertama kali login).
    final cached = await getCachedCoursesUseCase();
    if (!_isLatestRequest(requestId)) return;

    if (cached.isNotEmpty) {
      emit(_loadedState(cached));
    } else if (previous == null) {
      emit(const CourseLoading());
    }

    try {
      final courses = await _getCoursesDeduplicated();
      if (!_isLatestRequest(requestId)) return;
      emit(_loadedState(courses));
    } catch (e) {
      if (!_isLatestRequest(requestId)) return;
      // Bila ada cache, biarkan cache tetap tampil (refresh gagal diam-diam).
      if (cached.isEmpty && previous == null) {
        emit(CourseFailure(message: 'Failed to load courses'));
      }
    }
  }

  void _onSearchCourses(SearchCoursesEvent event, Emitter<CourseState> emit) {
    final query = event.query.trim().toLowerCase();
    if (query == _searchQuery) return;

    _searchQuery = query;
    final current = state;
    if (current is CourseLoaded) {
      emit(_loadedState(current.allCourses));
    }
  }

  Future<void> _onToggleSaveCourse(
    ToggleSaveCourseEvent event,
    Emitter<CourseState> emit,
  ) async {
    final previous = state;

    // 1) Update optimistik agar ikon bookmark langsung berubah.
    if (previous is CourseLoaded) {
      CourseEntity toggleSaved(CourseEntity course) {
        return course.id == event.courseId
            ? course.copyWith(isSaved: !course.isSaved)
            : course;
      }

      final updatedCourses = previous.courses.map(toggleSaved).toList();
      final updatedAllCourses = previous.allCourses.map(toggleSaved).toList();
      emit(
        CourseLoaded(
          courses: updatedCourses,
          allCourses: updatedAllCourses,
          searchQuery: previous.searchQuery,
        ),
      );
    }

    // 2) Persist ke backend. Jika gagal, kembalikan state semula.
    try {
      await toggleSaveCourseUseCase(event.courseId);
    } catch (e) {
      if (previous is CourseLoaded) {
        emit(previous);
      }
    }
  }

  Future<void> _onRefreshCourses(
    RefreshCoursesEvent event,
    Emitter<CourseState> emit,
  ) async {
    final requestId = ++_stateRequestId;

    // Pull-to-refresh: jangan tampilkan skeleton — pertahankan data yang sedang
    // tampil sambil mengambil yang terbaru, lalu update di tempat.
    try {
      // getCourses already fetches from remote, saves to cache,
      // and reconciles completion status — no need to call refresh separately.
      final courses = await _getCoursesDeduplicated();
      if (!_isLatestRequest(requestId)) return;
      emit(_loadedState(courses));
    } catch (e) {
      if (!_isLatestRequest(requestId)) return;
      // Jika belum ada data tampil, baru tampilkan error; selain itu diam.
      if (state is! CourseLoaded) {
        emit(CourseFailure(message: 'Failed to refresh courses'));
      }
    } finally {
      // Selalu beri tahu pemicu bahwa refresh selesai — bahkan saat data tidak
      // berubah (emit ditekan) atau gagal — agar indikator loading bisa mati.
      event.onComplete?.complete();
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

  Future<List<CourseEntity>> _getCoursesDeduplicated() {
    final activeRequest = _coursesRequest;
    if (activeRequest != null) return activeRequest;

    final request = _runCoursesRequest();
    _coursesRequest = request;
    return request;
  }

  Future<List<CourseEntity>> _runCoursesRequest() async {
    try {
      return await getCoursesUseCase();
    } finally {
      _coursesRequest = null;
    }
  }

  CourseLoaded _loadedState(List<CourseEntity> allCourses) {
    final visibleCourses = _searchQuery.isEmpty
        ? allCourses
        : allCourses
              .where(
                (course) =>
                    course.title.toLowerCase().contains(_searchQuery) ||
                    course.description.toLowerCase().contains(_searchQuery),
              )
              .toList();

    return CourseLoaded(
      courses: visibleCourses,
      allCourses: allCourses,
      searchQuery: _searchQuery,
    );
  }

  bool _isLatestRequest(int requestId) => requestId == _stateRequestId;
}
