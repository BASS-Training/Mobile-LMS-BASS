import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:lms_mobile_app/src/features/catalog/domain/entities/catalog_course_entity.dart';
import 'package:lms_mobile_app/src/features/catalog/domain/entities/catalog_page_entity.dart';
import 'package:lms_mobile_app/src/features/catalog/domain/repositories/catalog_repository.dart';
import 'package:lms_mobile_app/src/features/catalog/presentation/bloc/catalog_bloc.dart';
import 'package:lms_mobile_app/src/features/catalog/presentation/bloc/catalog_event.dart';
import 'package:lms_mobile_app/src/features/catalog/presentation/bloc/catalog_state.dart';

void main() {
  test('respons pencarian lama tidak menimpa pencarian terbaru', () async {
    final repository = _ControlledCatalogRepository();
    final bloc = CatalogBloc(repository: repository);
    addTearDown(bloc.close);

    bloc.add(const SearchCatalogEvent('old'));
    await bloc.stream.firstWhere(
      (state) => state.query == 'old' && state.status == CatalogStatus.loading,
    );
    bloc.add(const SearchCatalogEvent('new'));
    await bloc.stream.firstWhere(
      (state) => state.query == 'new' && state.status == CatalogStatus.loading,
    );

    repository.requests['new']!.complete(_page('new'));
    await bloc.stream.firstWhere(
      (state) => state.status == CatalogStatus.loaded,
    );

    repository.requests['old']!.complete(const CatalogPageEntity.empty());
    await Future<void>.delayed(Duration.zero);

    expect(bloc.state.query, 'new');
    expect(bloc.state.courses.single.id, 'new');
  });

  test('respons detail lama tidak menimpa detail terbaru', () async {
    final repository = _ControlledCatalogRepository();
    final bloc = CatalogBloc(repository: repository);
    addTearDown(bloc.close);

    bloc.add(const LoadCatalogDetailEvent('old'));
    await _waitUntil(() => repository.detailRequests.containsKey('old'));
    bloc.add(const LoadCatalogDetailEvent('new'));
    await _waitUntil(() => repository.detailRequests.containsKey('new'));

    repository.detailRequests['new']!.complete(_course('new'));
    await bloc.stream.firstWhere(
      (state) =>
          state.detailStatus == CatalogDetailStatus.loaded &&
          state.detailCourse?.id == 'new',
    );

    repository.detailRequests['old']!.complete(_course('old'));
    await Future<void>.delayed(Duration.zero);

    expect(bloc.state.detailCourse?.id, 'new');
  });
}

Future<void> _waitUntil(bool Function() predicate) async {
  final deadline = DateTime.now().add(const Duration(seconds: 2));
  while (!predicate()) {
    if (DateTime.now().isAfter(deadline)) {
      fail('Condition was not met before timeout.');
    }
    await Future<void>.delayed(Duration.zero);
  }
}

CatalogCourseEntity _course(String id) => CatalogCourseEntity(
  id: id,
  title: '$id detail',
  description: '',
  instructor: '',
  lessonCount: 1,
  isFree: true,
  isPaid: false,
  priceLabel: 'Gratis',
  sections: const [],
);

CatalogPageEntity _page(String id) {
  return CatalogPageEntity(
    courses: [
      CatalogCourseEntity(
        id: id,
        title: '$id result',
        description: '',
        instructor: '',
        lessonCount: 1,
        isFree: true,
        isPaid: false,
        priceLabel: 'Gratis',
        sections: const [],
      ),
    ],
    currentPage: 1,
    lastPage: 1,
    total: 1,
    hasMorePages: false,
    showPrice: false,
  );
}

class _ControlledCatalogRepository implements CatalogRepository {
  final Map<String?, Completer<CatalogPageEntity>> requests = {
    'old': Completer<CatalogPageEntity>(),
    'new': Completer<CatalogPageEntity>(),
  };
  final Map<String, Completer<CatalogCourseEntity?>> detailRequests = {};

  @override
  Future<CatalogPageEntity> getCatalog({
    String? query,
    String? harga,
    int page = 1,
    int perPage = 20,
  }) {
    return requests[query]!.future;
  }

  @override
  Future<CatalogCourseEntity?> getDetail(String catalogId) {
    return (detailRequests[catalogId] = Completer<CatalogCourseEntity?>())
        .future;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
