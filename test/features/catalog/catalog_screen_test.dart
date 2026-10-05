import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lms_mobile_app/src/features/catalog/domain/entities/catalog_course_entity.dart';
import 'package:lms_mobile_app/src/features/catalog/domain/entities/catalog_page_entity.dart';
import 'package:lms_mobile_app/src/features/catalog/domain/repositories/catalog_repository.dart';
import 'package:lms_mobile_app/src/features/catalog/presentation/bloc/catalog_bloc.dart';
import 'package:lms_mobile_app/src/features/catalog/presentation/screens/catalog_screen.dart';

void main() {
  testWidgets('katalog tidak menampilkan filter atau indikator pembayaran', (
    tester,
  ) async {
    final repository = _FakeCatalogRepository();
    final bloc = CatalogBloc(repository: repository);
    addTearDown(bloc.close);

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider.value(value: bloc, child: const CatalogScreen()),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('Kursus Eksternal'), findsOneWidget);
    expect(find.text('Semua'), findsOneWidget);
    expect(find.text('Gratis'), findsOneWidget);
    expect(find.text('Berbayar'), findsNothing);
    expect(find.text('Rp 99.000'), findsNothing);
    expect(find.byIcon(Icons.payments_outlined), findsNothing);
  });

  testWidgets('search menunggu debounce dan hanya mengirim query terbaru', (
    tester,
  ) async {
    final repository = _FakeCatalogRepository();
    final bloc = CatalogBloc(repository: repository);
    addTearDown(bloc.close);

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider.value(value: bloc, child: const CatalogScreen()),
      ),
    );
    await tester.pump();

    final searchField = find.byType(TextField);
    await tester.enterText(searchField, 'bass');
    await tester.pump(const Duration(milliseconds: 300));
    await tester.enterText(searchField, 'groove');
    await tester.pump(const Duration(milliseconds: 399));

    expect(repository.queries, isNot(contains('bass')));
    expect(repository.queries, isNot(contains('groove')));

    await tester.pump(const Duration(milliseconds: 1));
    await tester.pump();

    expect(repository.queries, isNot(contains('bass')));
    expect(repository.queries.last, 'groove');
  });

  testWidgets('query satu karakter membersihkan pencarian aktif', (
    tester,
  ) async {
    final repository = _FakeCatalogRepository();
    final bloc = CatalogBloc(repository: repository);
    addTearDown(bloc.close);

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider.value(value: bloc, child: const CatalogScreen()),
      ),
    );
    await tester.pump();

    final searchField = find.byType(TextField);
    await tester.enterText(searchField, 'bass');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump();
    expect(bloc.state.query, 'bass');

    await tester.enterText(searchField, 'b');
    await tester.pump();
    await tester.pump();

    expect(bloc.state.query, isEmpty);
    expect(repository.queries.last, isNull);
  });
}

class _FakeCatalogRepository implements CatalogRepository {
  final List<String?> queries = [];

  static const paidCourse = CatalogCourseEntity(
    id: 'paid-course',
    title: 'Kursus Eksternal',
    description: 'Deskripsi kursus',
    instructor: 'Bass Training Academy',
    lessonCount: 4,
    isFree: false,
    isPaid: true,
    price: 99000,
    priceLabel: 'Rp 99.000',
  );

  @override
  Future<CatalogPageEntity> getCatalog({
    String? query,
    String? harga,
    int page = 1,
    int perPage = 20,
  }) async {
    queries.add(query);
    return const CatalogPageEntity(
      courses: [paidCourse],
      currentPage: 1,
      lastPage: 1,
      total: 1,
      hasMorePages: false,
      showPrice: true,
    );
  }

  @override
  Future<void> enroll(String catalogId) => throw UnimplementedError();

  @override
  Future<CatalogCourseEntity?> getDetail(String catalogId) =>
      throw UnimplementedError();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
