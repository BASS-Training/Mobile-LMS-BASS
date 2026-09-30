import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:lms_mobile_app/src/core/error/app_exception.dart';
import 'package:lms_mobile_app/src/features/catalog/domain/entities/catalog_course_entity.dart';
import 'package:lms_mobile_app/src/features/catalog/domain/entities/catalog_page_entity.dart';
import 'package:lms_mobile_app/src/features/catalog/domain/repositories/catalog_repository.dart';
import 'package:lms_mobile_app/src/features/catalog/presentation/bloc/catalog_bloc.dart';
import 'package:lms_mobile_app/src/features/catalog/presentation/bloc/catalog_event.dart';
import 'package:lms_mobile_app/src/features/catalog/presentation/bloc/catalog_state.dart';

void main() {
  late _FakeCatalogRepository repository;
  late CatalogBloc bloc;

  setUp(() {
    repository = _FakeCatalogRepository();
    bloc = CatalogBloc(repository: repository);
  });

  tearDown(() => bloc.close());

  Future<void> loadCatalog() async {
    bloc.add(const LoadCatalogEvent());
    await bloc.stream.firstWhere(
      (state) => state.status == CatalogStatus.loaded,
    );
  }

  test('memuat katalog halaman pertama dari repository', () async {
    await loadCatalog();

    expect(bloc.state.courses, hasLength(20));
    expect(bloc.state.page, 1);
    expect(bloc.state.hasMorePages, isTrue);
    expect(bloc.state.query, isEmpty);
    expect(repository.lastQuery, isNull);
    expect(repository.lastHarga, isNull);
  });

  test('filter gratis diteruskan ke repository', () async {
    await loadCatalog();

    bloc.add(const ChangeCatalogFilterEvent(CatalogFilter.free));
    final filtered = await bloc.stream.firstWhere(
      (state) =>
          state.filter == CatalogFilter.free &&
          state.status == CatalogStatus.loaded &&
          state.courses.isNotEmpty &&
          state.courses.every((course) => course.isFree),
    );

    expect(repository.lastHarga, 'free');
    // 24 course gratis ada, halaman pertama hanya memuat 20 (perPage).
    expect(filtered.courses, hasLength(20));
    expect(filtered.visibleCourses, hasLength(20));
    expect(filtered.hasMorePages, isTrue);
  });

  test('pencarian diteruskan sebagai q dan menyaring hasil', () async {
    await loadCatalog();

    bloc.add(const SearchCatalogEvent('Groove'));
    final searched = await bloc.stream.firstWhere(
      (state) =>
          state.query == 'Groove' &&
          state.status == CatalogStatus.loaded &&
          state.courses.isNotEmpty &&
          state.courses.every((course) => course.title.contains('Groove')),
    );

    expect(repository.lastQuery, 'Groove');
    expect(searched.courses, hasLength(2));
  });

  test('load more meng-append halaman berikutnya', () async {
    await loadCatalog();

    bloc.add(const LoadMoreCatalogEvent());
    final more = await bloc.stream.firstWhere(
      (state) => state.courses.length > 20,
    );

    expect(repository.lastPage, 2);
    expect(repository.lastPerPage, 20);
    expect(more.courses, hasLength(25));
    expect(more.page, 2);
    expect(more.hasMorePages, isFalse);
    expect(more.isLoadingMore, isFalse);
  });

  test('load more diabaikan saat tidak ada halaman berikutnya', () async {
    await loadCatalog();
    bloc.add(const LoadMoreCatalogEvent());
    await bloc.stream.firstWhere((state) => state.courses.length > 20);

    final callsBefore = repository.getCatalogCalls;
    bloc.add(const LoadMoreCatalogEvent());
    await Future<void>.delayed(Duration.zero);

    expect(repository.getCatalogCalls, callsBefore);
  });

  test('load detail mengambil data course dari repository', () async {
    await loadCatalog();

    bloc.add(const LoadCatalogDetailEvent('paid-course'));
    final detail = await bloc.stream.firstWhere(
      (state) => state.detailStatus == CatalogDetailStatus.loaded,
    );

    expect(detail.detailCourse?.id, 'paid-course');
    expect(detail.detailCourse?.isPaid, isTrue);
    expect(detail.detailCourse?.priceLabel, 'Rp 99.000');
  });

  test('load detail course yang tidak ada berakhir failure', () async {
    bloc.add(const LoadCatalogDetailEvent('missing-course'));
    final failed = await bloc.stream.firstWhere(
      (state) => state.detailStatus == CatalogDetailStatus.failure,
    );

    expect(failed.detailCourse, isNull);
    expect(failed.detailErrorMessage, 'Course sudah tidak tersedia.');
  });

  test(
    'website handoff loading, cegah request ganda, lalu hasil dibersihkan',
    () async {
      final completer = Completer<String>();
      repository.webSessionCompleter = completer;

      bloc.add(const RequestCatalogWebsiteEvent('paid-course'));
      final loading = await bloc.stream.firstWhere(
        (state) => state.openingWebsiteId == 'paid-course',
      );

      expect(loading.websiteUrl, isNull);
      bloc.add(const RequestCatalogWebsiteEvent('paid-course'));
      await Future<void>.delayed(Duration.zero);
      expect(repository.webSessionCalls, 1);

      completer.complete('https://example.com/auth/handoff/sekali-pakai');
      final success = await bloc.stream.firstWhere(
        (state) => state.websiteUrl != null,
      );

      expect(success.openingWebsiteId, isNull);
      expect(
        success.websiteUrl,
        'https://example.com/auth/handoff/sekali-pakai',
      );

      bloc.add(const ClearCatalogWebsiteEvent());
      final cleared = await bloc.stream.firstWhere(
        (state) =>
            state.openingWebsiteId == null &&
            state.websiteUrl == null &&
            state.websiteErrorMessage == null,
      );
      expect(cleared.websiteUrl, isNull);
    },
  );

  test('gagal membuat website handoff menampilkan pesan server', () async {
    repository.webSessionError = ValidationException(
      message: 'Kursus tidak ditemukan.',
    );

    bloc.add(const RequestCatalogWebsiteEvent('missing-course'));
    final failed = await bloc.stream.firstWhere(
      (state) => state.websiteErrorMessage != null,
    );

    expect(failed.openingWebsiteId, isNull);
    expect(failed.websiteUrl, isNull);
    expect(failed.websiteErrorMessage, 'Kursus tidak ditemukan.');
  });

  test('enrollment gratis memperbarui status katalog', () async {
    await loadCatalog();

    bloc.add(const EnrollCatalogCourseEvent('free-course'));
    final enrolled = await bloc.stream.firstWhere(
      (state) => state.courseById('free-course')?.isEnrolled == true,
    );

    expect(repository.enrolledIds, contains('free-course'));
    expect(enrolled.enrollingId, isNull);
    expect(enrolled.errorMessage, isNull);
  });

  test('course berbayar tidak dapat dienroll', () async {
    await loadCatalog();

    bloc.add(const EnrollCatalogCourseEvent('paid-course'));
    await Future<void>.delayed(Duration.zero);

    expect(repository.enrolledIds, isEmpty);
    expect(bloc.state.courseById('paid-course')?.isEnrolled, isFalse);
  });

  test('gagal enroll menampilkan pesan error dari server', () async {
    await loadCatalog();

    bloc.add(const EnrollCatalogCourseEvent('throwing-course'));
    final failed = await bloc.stream.firstWhere(
      (state) => state.errorMessage != null && state.enrollingId == null,
    );

    expect(
      failed.errorMessage,
      'Kursus ini tidak dapat diikuti langsung dari aplikasi.',
    );
    expect(repository.enrolledIds, isEmpty);
    expect(failed.courseById('throwing-course')?.isEnrolled, isFalse);
  });
}

class _FakeCatalogRepository implements CatalogRepository {
  final Set<String> enrolledIds = {};
  int getCatalogCalls = 0;
  String? lastQuery;
  String? lastHarga;
  int lastPage = 0;
  int lastPerPage = 0;
  int webSessionCalls = 0;
  Completer<String>? webSessionCompleter;
  Object? webSessionError;

  final List<CatalogCourseEntity> _all;

  _FakeCatalogRepository()
    : _all = [
        _course(
          id: 'free-course',
          title: 'Groove Basics',
          lessonCount: 4,
          isFree: true,
        ),
        _course(
          id: 'paid-course',
          title: 'Advanced Groove',
          lessonCount: 8,
          isFree: false,
          priceLabel: 'Rp 99.000',
        ),
        _course(
          id: 'throwing-course',
          title: 'Timing Course',
          lessonCount: 6,
          isFree: true,
        ),
        for (var index = 0; index < 22; index++)
          _course(
            id: 'filler-$index',
            title: 'Filler Course $index',
            lessonCount: 1,
            isFree: true,
          ),
      ];

  static CatalogCourseEntity _course({
    required String id,
    required String title,
    required int lessonCount,
    required bool isFree,
    String priceLabel = 'Gratis',
  }) {
    return CatalogCourseEntity(
      id: id,
      title: title,
      description: 'Deskripsi $title',
      instructor: 'Instructor',
      lessonCount: lessonCount,
      isFree: isFree,
      isPaid: !isFree,
      priceLabel: isFree ? 'Gratis' : priceLabel,
      sections: const [],
    );
  }

  @override
  Future<CatalogPageEntity> getCatalog({
    String? query,
    String? harga,
    int page = 1,
    int perPage = 20,
  }) async {
    getCatalogCalls++;
    lastQuery = query;
    lastHarga = harga;
    lastPage = page;
    lastPerPage = perPage;

    var filtered = _all;
    if (query != null && query.isNotEmpty) {
      final needle = query.toLowerCase();
      filtered = filtered
          .where((course) => course.title.toLowerCase().contains(needle))
          .toList();
    }
    if (harga == 'free') {
      filtered = filtered.where((course) => course.isFree).toList();
    } else if (harga == 'paid') {
      filtered = filtered.where((course) => course.isPaid).toList();
    }

    final total = filtered.length;
    final lastPageCount = total == 0 ? 1 : (total / perPage).ceil();
    final start = (page - 1) * perPage;
    final end = start + perPage > total ? total : start + perPage;
    final slice = start >= total
        ? <CatalogCourseEntity>[]
        : filtered.sublist(start, end);

    return CatalogPageEntity(
      courses: slice
          .map(
            (course) =>
                course.copyWith(isEnrolled: enrolledIds.contains(course.id)),
          )
          .toList(),
      currentPage: page,
      lastPage: lastPageCount,
      total: total,
      hasMorePages: page < lastPageCount,
      showPrice: false,
    );
  }

  @override
  Future<CatalogCourseEntity?> getDetail(String catalogId) async {
    for (final course in _all) {
      if (course.id == catalogId) {
        return course.copyWith(isEnrolled: enrolledIds.contains(catalogId));
      }
    }
    return null;
  }

  @override
  Future<String> createWebSession(String catalogId) async {
    webSessionCalls++;
    final error = webSessionError;
    if (error != null) throw error;
    final completer = webSessionCompleter;
    if (completer != null) return completer.future;
    return 'https://example.com/auth/handoff/$catalogId';
  }

  @override
  Future<void> enroll(String catalogId) async {
    if (catalogId == 'throwing-course') {
      throw ValidationException(
        message: 'Kursus ini tidak dapat diikuti langsung dari aplikasi.',
      );
    }
    enrolledIds.add(catalogId);
  }
}
