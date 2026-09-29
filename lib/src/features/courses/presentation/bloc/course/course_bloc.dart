import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms_mobile_app/src/features/courses/domain/entities/course_entity.dart';
import 'package:lms_mobile_app/src/features/courses/domain/usecases/add_course_usecase.dart';
import 'package:lms_mobile_app/src/features/courses/domain/usecases/get_courses_usecase.dart';
import 'package:lms_mobile_app/src/features/courses/domain/usecases/get_cached_courses_usecase.dart';
import 'package:lms_mobile_app/src/features/courses/domain/usecases/refresh_courses_usecase.dart';
import 'package:lms_mobile_app/src/features/courses/domain/usecases/search_courses_usecase.dart';
import 'package:lms_mobile_app/src/features/courses/domain/usecases/toggle_save_course_usecase.dart';
import 'course_event.dart';
import 'course_state.dart';

/// Bloc utama daftar kursus. Contoh kanonik alur Presentation→Domain:
/// memetakan event (get/search/refresh/toggle-save/add) ke usecase, lalu emit
/// state. `ToggleSaveCourseEvent` memakai optimistic update.
class CourseBloc extends Bloc<CourseEvent, CourseState> {
  final GetCoursesUseCase getCoursesUseCase;
  final GetCachedCoursesUseCase getCachedCoursesUseCase;
  final SearchCoursesUseCase searchCoursesUseCase;
  final ToggleSaveCourseUseCase toggleSaveCourseUseCase;
  final RefreshCoursesUseCase refreshCoursesUseCase;
  final AddCourseUseCase addCourseUseCase;

  Future<List<CourseEntity>>? _coursesRequest;
  int _stateRequestId = 0;

  CourseBloc({
    required this.getCoursesUseCase,
    required this.getCachedCoursesUseCase,
    required this.searchCoursesUseCase,
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
    emit(const CourseInitial());
  }

  Future<void> _onGetCourses(
    GetCoursesEvent event,
    Emitter<CourseState> emit,
  ) async {
    final requestId = ++_stateRequestId;

    // Cache-first: tampilkan data cache (disk) secara INSTAN tanpa skeleton bila
    // ada, lalu refresh diam-diam dari jaringan. Hanya tampilkan skeleton bila
    // benar-benar belum ada cache (mis. pertama kali login).
    final cached = await getCachedCoursesUseCase();
    if (!_isLatestRequest(requestId)) return;

    if (cached.isNotEmpty) {
      emit(CourseLoaded(courses: cached));
    } else {
      emit(const CourseLoading());
    }

    try {
      final courses = await _getCoursesDeduplicated();
      if (!_isLatestRequest(requestId)) return;
      emit(CourseLoaded(courses: courses));
    } catch (e) {
      if (!_isLatestRequest(requestId)) return;
      // Bila ada cache, biarkan cache tetap tampil (refresh gagal diam-diam).
      if (cached.isEmpty) {
        emit(CourseFailure(message: 'Failed to load courses'));
      }
    }
  }

  Future<void> _onSearchCourses(
    SearchCoursesEvent event,
    Emitter<CourseState> emit,
  ) async {
    final requestId = ++_stateRequestId;
    emit(const CourseLoading());

    try {
      if (event.query.isEmpty) {
        final courses = await _getCoursesDeduplicated();
        if (!_isLatestRequest(requestId)) return;
        emit(CourseLoaded(courses: courses, searchQuery: ''));
      } else {
        final courses = await searchCoursesUseCase(event.query);
        if (!_isLatestRequest(requestId)) return;
        emit(CourseLoaded(courses: courses, searchQuery: event.query));
      }
    } catch (e) {
      if (!_isLatestRequest(requestId)) return;
      emit(CourseFailure(message: 'Search failed'));
    }
  }

  Future<void> _onToggleSaveCourse(
    ToggleSaveCourseEvent event,
    Emitter<CourseState> emit,
  ) async {
    final previous = state;

    // 1) Update optimistik agar ikon bookmark langsung berubah.
    if (previous is CourseLoaded) {
      final updated = previous.courses
          .map(
            (c) => c.id == event.courseId ? c.copyWith(isSaved: !c.isSaved) : c,
          )
          .toList();
      emit(CourseLoaded(courses: updated, searchQuery: previous.searchQuery));
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
      emit(CourseLoaded(courses: courses));
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

  bool _isLatestRequest(int requestId) => requestId == _stateRequestId;
}
