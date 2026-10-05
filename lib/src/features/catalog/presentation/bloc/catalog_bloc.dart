import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/app_exception.dart';
import '../../domain/repositories/catalog_repository.dart';
import 'catalog_event.dart';
import 'catalog_state.dart';

class CatalogBloc extends Bloc<CatalogEvent, CatalogState> {
  final CatalogRepository repository;

  static const int _perPage = 20;

  /// Nomor urut request terakhir. Hasil request yang lebih tua dari request
  /// terbaru (misal pencarian datang saat load-more masih berjalan) dibuang
  /// agar daftar tidak tercampur data basi.
  int _requestSeq = 0;
  int _detailRequestSeq = 0;

  CatalogBloc({required this.repository}) : super(const CatalogState()) {
    on<LoadCatalogEvent>(_onLoad);
    on<SearchCatalogEvent>(_onSearch);
    on<LoadMoreCatalogEvent>(_onLoadMore);
    on<ChangeCatalogFilterEvent>(_onChangeFilter);
    on<LoadCatalogDetailEvent>(_onLoadDetail);
    on<EnrollCatalogCourseEvent>(_onEnroll);
    on<ResetCatalogEvent>((event, emit) {
      _requestSeq++;
      _detailRequestSeq++;
      emit(const CatalogState());
    });
  }

  String get _harga => switch (state.filter) {
    CatalogFilter.free => 'free',
    CatalogFilter.all => '',
  };

  Future<void> _onLoad(LoadCatalogEvent event, Emitter<CatalogState> emit) =>
      _fetch(1, emit, replace: true);

  Future<void> _onSearch(
    SearchCatalogEvent event,
    Emitter<CatalogState> emit,
  ) async {
    emit(state.copyWith(query: event.query.trim()));
    await _fetch(1, emit, replace: true);
  }

  Future<void> _onChangeFilter(
    ChangeCatalogFilterEvent event,
    Emitter<CatalogState> emit,
  ) async {
    emit(state.copyWith(filter: event.filter));
    await _fetch(1, emit, replace: true);
  }

  Future<void> _onLoadMore(
    LoadMoreCatalogEvent event,
    Emitter<CatalogState> emit,
  ) async {
    if (state.isLoadingMore ||
        !state.hasMorePages ||
        state.status != CatalogStatus.loaded) {
      return;
    }
    await _fetch(state.page + 1, emit, replace: false);
  }

  /// Ambil satu halaman katalog. [replace] = halaman pertama (refresh/search/
  /// filter), selain itu data di-append untuk infinite scroll.
  Future<void> _fetch(
    int page,
    Emitter<CatalogState> emit, {
    required bool replace,
    String failureMessage = 'Katalog belum dapat dimuat. Silakan coba lagi.',
  }) async {
    final requestId = ++_requestSeq;
    final query = state.query;
    final harga = _harga;

    if (replace) {
      emit(
        state.copyWith(
          status: CatalogStatus.loading,
          isLoadingMore: false,
          errorMessage: null,
        ),
      );
    } else {
      emit(state.copyWith(isLoadingMore: true, errorMessage: null));
    }

    try {
      final catalogPage = await repository.getCatalog(
        query: query.isEmpty ? null : query,
        harga: harga.isEmpty ? null : harga,
        page: page,
        perPage: _perPage,
      );
      if (isClosed || requestId != _requestSeq) return;
      emit(replace ? state.applied(catalogPage) : state.appended(catalogPage));
    } catch (error) {
      if (isClosed || requestId != _requestSeq) return;
      emit(
        state.copyWith(
          status: replace ? CatalogStatus.failure : state.status,
          isLoadingMore: false,
          errorMessage: _messageOf(error, failureMessage),
        ),
      );
    }
  }

  Future<void> _onLoadDetail(
    LoadCatalogDetailEvent event,
    Emitter<CatalogState> emit,
  ) async {
    final requestId = ++_detailRequestSeq;
    emit(
      state.copyWith(
        detailStatus: CatalogDetailStatus.loading,
        detailCourse: state.courseById(event.catalogId),
        detailErrorMessage: null,
      ),
    );

    try {
      final detail = await repository.getDetail(event.catalogId);
      if (isClosed || requestId != _detailRequestSeq) return;
      if (detail == null) {
        emit(
          state.copyWith(
            detailStatus: CatalogDetailStatus.failure,
            detailErrorMessage: 'Course sudah tidak tersedia.',
          ),
        );
        return;
      }
      emit(
        state.copyWith(
          detailStatus: CatalogDetailStatus.loaded,
          detailCourse: detail,
          detailErrorMessage: null,
        ),
      );
    } catch (error) {
      if (isClosed || requestId != _detailRequestSeq) return;
      emit(
        state.copyWith(
          detailStatus: CatalogDetailStatus.failure,
          detailErrorMessage: _messageOf(
            error,
            'Detail course belum dapat dimuat. Silakan coba lagi.',
          ),
        ),
      );
    }
  }

  Future<void> _onEnroll(
    EnrollCatalogCourseEvent event,
    Emitter<CatalogState> emit,
  ) async {
    final course =
        state.courseById(event.catalogId) ??
        (state.detailCourse?.id == event.catalogId ? state.detailCourse : null);
    if (course == null || !course.isFree || course.isEnrolled) return;

    emit(state.copyWith(enrollingId: event.catalogId, errorMessage: null));

    try {
      await repository.enroll(event.catalogId);
      if (isClosed) return;
      final enrolled = state.courses
          .map(
            (item) => item.id == event.catalogId
                ? item.copyWith(isEnrolled: true)
                : item,
          )
          .toList();
      final detail = state.detailCourse?.id == event.catalogId
          ? state.detailCourse?.copyWith(isEnrolled: true)
          : state.detailCourse;
      emit(
        state.copyWith(
          enrollingId: null,
          courses: enrolled,
          detailCourse: detail,
          errorMessage: null,
        ),
      );
    } catch (error) {
      if (isClosed) return;
      emit(
        state.copyWith(
          enrollingId: null,
          errorMessage: _messageOf(
            error,
            'Course belum dapat diikuti. Silakan coba lagi.',
          ),
        ),
      );
    }
  }

  String _messageOf(Object error, String fallback) {
    if (error is AppException) {
      final message = error.message.trim();
      if (message == 'Unauthenticated.') {
        return 'Sesi berakhir. Silakan masuk kembali.';
      }
      if (message.isNotEmpty) return message;
    }
    return fallback;
  }
}
