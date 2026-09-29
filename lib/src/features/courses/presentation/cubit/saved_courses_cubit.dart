import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms_mobile_app/src/features/courses/domain/entities/course_entity.dart';
import 'package:lms_mobile_app/src/features/courses/domain/usecases/get_saved_courses_usecase.dart';

enum SavedCoursesStatus { initial, loading, loaded, failure }

class SavedCoursesState extends Equatable {
  final SavedCoursesStatus status;
  final List<CourseEntity> courses;
  final String? errorMessage;

  const SavedCoursesState({
    this.status = SavedCoursesStatus.initial,
    this.courses = const [],
    this.errorMessage,
  });

  @override
  List<Object?> get props => [status, courses, errorMessage];
}

class SavedCoursesCubit extends Cubit<SavedCoursesState> {
  final GetSavedCoursesUseCase getSavedCoursesUseCase;

  SavedCoursesCubit({required this.getSavedCoursesUseCase})
    : super(const SavedCoursesState());

  Future<void> load() async {
    emit(const SavedCoursesState(status: SavedCoursesStatus.loading));

    try {
      final courses = await getSavedCoursesUseCase();
      if (isClosed) return;
      emit(
        SavedCoursesState(status: SavedCoursesStatus.loaded, courses: courses),
      );
    } catch (_) {
      if (isClosed) return;
      emit(
        const SavedCoursesState(
          status: SavedCoursesStatus.failure,
          errorMessage: 'Gagal memuat kursus tersimpan.',
        ),
      );
    }
  }
}
