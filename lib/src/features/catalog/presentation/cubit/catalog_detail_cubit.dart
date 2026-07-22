import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/catalog_course_entity.dart';
import '../../domain/usecases/enroll_free_course_usecase.dart';
import '../../domain/usecases/get_catalog_course_usecase.dart';

enum CatalogDetailStatus { loading, success, failure }

class CatalogDetailState extends Equatable {
  final CatalogDetailStatus status;
  final CatalogCourseEntity? course;
  final String? errorMessage;
  final bool isEnrolling;

  const CatalogDetailState({
    this.status = CatalogDetailStatus.loading,
    this.course,
    this.errorMessage,
    this.isEnrolling = false,
  });

  CatalogDetailState copyWith({
    CatalogDetailStatus? status,
    CatalogCourseEntity? course,
    String? errorMessage,
    bool? isEnrolling,
    bool clearError = false,
  }) {
    return CatalogDetailState(
      status: status ?? this.status,
      course: course ?? this.course,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isEnrolling: isEnrolling ?? this.isEnrolling,
    );
  }

  @override
  List<Object?> get props => [status, course, errorMessage, isEnrolling];
}

/// State halaman preview satu kursus etalase.
class CatalogDetailCubit extends Cubit<CatalogDetailState> {
  final GetCatalogCourseUseCase _getCourse;
  final EnrollFreeCourseUseCase _enrollFree;

  CatalogDetailCubit({
    required GetCatalogCourseUseCase getCourse,
    required EnrollFreeCourseUseCase enrollFree,
  }) : _getCourse = getCourse,
       _enrollFree = enrollFree,
       super(const CatalogDetailState());

  /// [seed] dipakai untuk menggambar header seketika dari kartu yang diketuk,
  /// sementara outline kurikulum menyusul dari jaringan.
  Future<void> load(String id, {CatalogCourseEntity? seed}) async {
    emit(
      state.copyWith(
        status: CatalogDetailStatus.loading,
        course: seed,
        clearError: true,
      ),
    );

    try {
      final course = await _getCourse(id);
      emit(state.copyWith(status: CatalogDetailStatus.success, course: course));
    } catch (error) {
      emit(
        state.copyWith(
          status: CatalogDetailStatus.failure,
          errorMessage: _readable(error),
        ),
      );
    }
  }

  /// Daftar ke kursus gratis. `true` bila berhasil.
  Future<bool> enrollFree() async {
    final course = state.course;
    if (course == null || state.isEnrolling) return false;

    emit(state.copyWith(isEnrolling: true, clearError: true));

    try {
      await _enrollFree(course.id);
      emit(
        state.copyWith(
          course: course.copyWith(isEnrolled: true),
          isEnrolling: false,
        ),
      );
      return true;
    } catch (error) {
      emit(state.copyWith(isEnrolling: false, errorMessage: _readable(error)));
      return false;
    }
  }

  String _readable(Object error) =>
      error.toString().replaceFirst('Exception: ', '').trim();
}
