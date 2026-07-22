import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/catalog_result.dart';
import '../../domain/usecases/enroll_free_course_usecase.dart';
import '../../domain/usecases/get_catalog_usecase.dart';
import 'catalog_state.dart';

/// State management etalase kursus ("Jelajahi").
///
/// Cubit (bukan Bloc) karena alurnya sederhana: muat, cari, filter, dan satu
/// aksi daftar-gratis — tidak ada percabangan event yang rumit.
class CatalogCubit extends Cubit<CatalogState> {
  final GetCatalogUseCase _getCatalog;
  final EnrollFreeCourseUseCase _enrollFree;

  Timer? _searchDebounce;

  CatalogCubit({
    required GetCatalogUseCase getCatalog,
    required EnrollFreeCourseUseCase enrollFree,
  }) : _getCatalog = getCatalog,
       _enrollFree = enrollFree,
       super(const CatalogState());

  /// Muat ulang etalase dengan pencarian & filter yang sedang aktif.
  Future<void> load() async {
    emit(state.copyWith(status: CatalogStatus.loading, clearError: true));

    try {
      final result = await _getCatalog(
        query: state.query,
        filter: state.filter,
      );

      emit(
        state.copyWith(
          status: CatalogStatus.success,
          courses: result.courses,
          showPrice: result.showPrice,
          clearError: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: CatalogStatus.failure,
          errorMessage: _readable(error),
        ),
      );
    }
  }

  /// Pencarian dengan debounce — menunggu user berhenti mengetik supaya tidak
  /// membanjiri server satu request per huruf.
  void search(String query) {
    _searchDebounce?.cancel();
    emit(state.copyWith(query: query));

    _searchDebounce = Timer(const Duration(milliseconds: 400), () {
      if (!isClosed) load();
    });
  }

  void changeFilter(CatalogPriceFilter filter) {
    if (filter == state.filter) return;
    emit(state.copyWith(filter: filter));
    load();
  }

  /// Daftar ke kursus gratis. Mengembalikan pesan sukses bila berhasil, atau
  /// `null` bila gagal (pesan galat sudah masuk ke state).
  Future<String?> enrollFree(String courseId) async {
    emit(state.copyWith(enrollingCourseId: courseId, clearError: true));

    try {
      await _enrollFree(courseId);

      // Tandai kursus sebagai dimiliki tanpa memuat ulang seluruh etalase —
      // posisi scroll & hasil pencarian user tetap utuh.
      final updated = state.courses
          .map(
            (course) => course.id == courseId
                ? course.copyWith(isEnrolled: true)
                : course,
          )
          .toList();

      emit(state.copyWith(courses: updated, clearEnrolling: true));
      return 'Berhasil bergabung. Kursus sudah masuk ke daftar kursusmu.';
    } catch (error) {
      emit(
        state.copyWith(errorMessage: _readable(error), clearEnrolling: true),
      );
      return null;
    }
  }

  String _readable(Object error) =>
      error.toString().replaceFirst('Exception: ', '').trim();

  @override
  Future<void> close() {
    _searchDebounce?.cancel();
    return super.close();
  }
}
