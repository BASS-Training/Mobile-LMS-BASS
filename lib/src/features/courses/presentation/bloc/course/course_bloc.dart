import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms_mobile_app/src/features/courses/domain/entities/course_entity.dart';
import 'package:lms_mobile_app/src/features/courses/domain/usecases/add_course_usecase.dart';
import 'package:lms_mobile_app/src/features/courses/domain/usecases/get_courses_usecase.dart';
import 'package:lms_mobile_app/src/features/courses/domain/usecases/get_cached_courses_usecase.dart';
import 'package:lms_mobile_app/src/features/courses/domain/usecases/get_saved_courses_usecase.dart';
import 'package:lms_mobile_app/src/features/courses/domain/usecases/refresh_courses_usecase.dart';
import 'package:lms_mobile_app/src/features/courses/domain/usecases/search_courses_usecase.dart';
import 'package:lms_mobile_app/src/features/courses/domain/usecases/watch_courses_usecase.dart';
import 'package:lms_mobile_app/src/features/courses/domain/usecases/toggle_save_course_usecase.dart';
import 'course_event.dart';
import 'course_state.dart';

/// Bloc utama daftar kursus. Contoh kanonik alur Presentation→Domain:
/// memetakan event (get/search/refresh/toggle-save/watch/add) ke usecase, lalu
/// emit state. Catatan pola: `WatchCoursesEvent` memakai stream (emit.forEach)
/// dan `ToggleSaveCourseEvent` memakai optimistic update. Lihat ARCHITECTURE.md §11.
class CourseBloc extends Bloc<CourseEvent, CourseState> {
  final GetCoursesUseCase getCoursesUseCase;
  final GetCachedCoursesUseCase getCachedCoursesUseCase;
  final SearchCoursesUseCase searchCoursesUseCase;
  final ToggleSaveCourseUseCase toggleSaveCourseUseCase;
  final GetSavedCoursesUseCase getSavedCoursesUseCase;
  final RefreshCoursesUseCase refreshCoursesUseCase;
  final WatchCoursesUseCase watchCoursesUseCase;
  final AddCourseUseCase addCourseUseCase;

  CourseBloc({
    required this.getCoursesUseCase,
    required this.getCachedCoursesUseCase,
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
    on<ResetCoursesEvent>(_onResetCourses);

    Future.microtask(() => add(const WatchCoursesEvent()));
  }

  void _onResetCourses(ResetCoursesEvent event, Emitter<CourseState> emit) {
    emit(const CourseInitial());
  }

  Future<void> _onGetCourses(
    GetCoursesEvent event,
    Emitter<CourseState> emit,
  ) async {
    // Cache-first: tampilkan data cache (disk) secara INSTAN tanpa skeleton bila
    // ada, lalu refresh diam-diam dari jaringan. Hanya tampilkan skeleton bila
    // benar-benar belum ada cache (mis. pertama kali login).
    final cached = await getCachedCoursesUseCase();
    if (cached.isNotEmpty) {
      emit(CourseLoaded(courses: cached));
    } else {
      emit(const CourseLoading());
    }

    try {
      final courses = await getCoursesUseCase();
      emit(CourseLoaded(courses: courses));
    } catch (e) {
      // Bila ada cache, biarkan cache tetap tampil (refresh gagal diam-diam).
      if (cached.isEmpty) {
        emit(CourseFailure(message: 'Failed to load courses'));
      }
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
          message: 'Failed to sync courses from Laravel API',
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
    final previous = state;

    // 1) Update optimistik agar ikon bookmark langsung berubah.
    if (previous is CourseLoaded) {
      final updated = previous.courses
          .map(
            (c) => c.id == event.courseId
                ? c.copyWith(isSaved: !c.isSaved)
                : c,
          )
          .toList();
      emit(CourseLoaded(courses: updated, searchQuery: previous.searchQuery));
    } else if (previous is SavedCoursesLoaded) {
      // Di layar "Kursus Tersimpan", toggle = mengeluarkan dari koleksi.
      final updated = previous.courses
          .where((c) => c.id != event.courseId)
          .toList();
      emit(SavedCoursesLoaded(courses: updated));
    }

    // 2) Persist ke backend. Jika gagal, kembalikan state semula.
    try {
      await toggleSaveCourseUseCase(event.courseId);
    } catch (e) {
      if (previous is CourseLoaded || previous is SavedCoursesLoaded) {
        emit(previous);
      }
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
    // Pull-to-refresh: jangan tampilkan skeleton — pertahankan data yang sedang
    // tampil sambil mengambil yang terbaru, lalu update di tempat.
    try {
      // getCourses already fetches from remote, saves to cache,
      // and reconciles completion status — no need to call refresh separately.
      final courses = await getCoursesUseCase();
      emit(CourseLoaded(courses: courses));
    } catch (e) {
      // Jika belum ada data tampil, baru tampilkan error; selain itu diam.
      if (state is! CourseLoaded) {
        emit(CourseFailure(message: 'Failed to refresh courses'));
      }
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
