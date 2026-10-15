import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lms_mobile_app/src/features/authentication/domain/entities/user_entity.dart';
import 'package:lms_mobile_app/src/features/authentication/domain/repositories/auth_repository.dart';
import 'package:lms_mobile_app/src/features/authentication/domain/usecases/get_current_user_usecase.dart';
import 'package:lms_mobile_app/src/features/authentication/domain/usecases/login_usecase.dart';
import 'package:lms_mobile_app/src/features/authentication/domain/usecases/logout_usecase.dart';
import 'package:lms_mobile_app/src/features/authentication/domain/usecases/register.usecase.dart';
import 'package:lms_mobile_app/src/features/authentication/presentation/bloc/auth/auth_bloc.dart';
import 'package:lms_mobile_app/src/features/catalog/domain/entities/catalog_course_entity.dart';
import 'package:lms_mobile_app/src/features/catalog/domain/entities/catalog_page_entity.dart';
import 'package:lms_mobile_app/src/features/catalog/domain/entities/course_sales_profile.dart';
import 'package:lms_mobile_app/src/features/catalog/domain/repositories/catalog_repository.dart';
import 'package:lms_mobile_app/src/features/catalog/presentation/bloc/catalog_bloc.dart';
import 'package:lms_mobile_app/src/features/catalog/presentation/screens/catalog_detail_screen.dart';

void main() {
  testWidgets('detail katalog menampilkan profil penjualan dan FAQ', (
    tester,
  ) async {
    final authRepository = _GuestAuthRepository();
    final authBloc = AuthBloc(
      loginUseCase: LoginUseCase(authRepository),
      registerUseCase: RegisterUseCase(authRepository),
      logoutUseCase: LogoutUseCase(authRepository),
      getCurrentUserUseCase: GetCurrentUserUseCase(authRepository),
    );
    final catalogBloc = CatalogBloc(
      repository: _CatalogRepository(
        course: const CatalogCourseEntity(
          id: 'free-course',
          title: 'Bass Dasar',
          description: '<p>Isi course</p>',
          instructor: 'Pengajar lama',
          lessonCount: 3,
          isFree: true,
          isPaid: false,
          priceLabel: 'Gratis',
          shortDescription: 'Headline sama',
          salesProfile: CourseSalesProfile(
            headline: 'Headline sama',
            learningBenefits: 'Bisa bermain bass',
            targetAudience: 'Pemula',
            requirements: 'Punya bass',
            level: 'beginner',
            estimatedDurationMinutes: 45,
            faq: [CourseSalesFaq(question: 'Cocok?', answer: 'Ya')],
          ),
          instructors: [
            CatalogInstructor(
              id: '7',
              name: 'Guru Bass',
              bioHtml: '<p>Berpengalaman</p>',
            ),
          ],
        ),
      ),
    );
    addTearDown(authBloc.close);
    addTearDown(catalogBloc.close);
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider.value(value: authBloc),
          BlocProvider.value(value: catalogBloc),
        ],
        child: MaterialApp(
          theme: ThemeData(splashFactory: NoSplash.splashFactory),
          home: const CatalogDetailScreen(catalogId: 'free-course'),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('Headline sama'), findsOneWidget);
    expect(find.text('45 menit'), findsOneWidget);
    expect(find.text('Guru Bass'), findsWidgets);
    expect(find.text('Bisa bermain bass'), findsOneWidget);
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -500));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cocok?'));
    await tester.pumpAndSettle();
    expect(find.text('Ya'), findsOneWidget);
  });
  testWidgets('tamu diminta login dan tidak ditawari enrollment langsung', (
    tester,
  ) async {
    final authRepository = _GuestAuthRepository();
    final authBloc = AuthBloc(
      loginUseCase: LoginUseCase(authRepository),
      registerUseCase: RegisterUseCase(authRepository),
      logoutUseCase: LogoutUseCase(authRepository),
      getCurrentUserUseCase: GetCurrentUserUseCase(authRepository),
    );
    final catalogRepository = _CatalogRepository();
    final catalogBloc = CatalogBloc(repository: catalogRepository);
    addTearDown(authBloc.close);
    addTearDown(catalogBloc.close);

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider.value(value: authBloc),
          BlocProvider.value(value: catalogBloc),
        ],
        child: const MaterialApp(
          home: CatalogDetailScreen(catalogId: 'free-course'),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('Masuk untuk Mengikuti'), findsOneWidget);
    expect(find.text('Ikuti Gratis'), findsNothing);
    expect(catalogRepository.enrollCalls, 0);
  });

  testWidgets('detail course berbayar tidak menampilkan informasi harga', (
    tester,
  ) async {
    final authRepository = _GuestAuthRepository();
    final authBloc = AuthBloc(
      loginUseCase: LoginUseCase(authRepository),
      registerUseCase: RegisterUseCase(authRepository),
      logoutUseCase: LogoutUseCase(authRepository),
      getCurrentUserUseCase: GetCurrentUserUseCase(authRepository),
    );
    final catalogRepository = _CatalogRepository(
      course: _CatalogRepository.paidCourse,
    );
    final catalogBloc = CatalogBloc(repository: catalogRepository);
    addTearDown(authBloc.close);
    addTearDown(catalogBloc.close);

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider.value(value: authBloc),
          BlocProvider.value(value: catalogBloc),
        ],
        child: const MaterialApp(
          home: CatalogDetailScreen(catalogId: 'paid-course'),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('Kursus Eksternal'), findsOneWidget);
    expect(find.text('Berbayar'), findsNothing);
    expect(find.text('Rp 99.000'), findsNothing);
    expect(find.text('Harga'), findsNothing);
    expect(find.byIcon(Icons.payments_outlined), findsNothing);
    expect(find.text('Website'), findsOneWidget);
    expect(find.byIcon(Icons.open_in_new_rounded), findsOneWidget);
    expect(find.text('Masuk untuk Mengikuti'), findsNothing);
  });
}

class _CatalogRepository implements CatalogRepository {
  int enrollCalls = 0;

  final CatalogCourseEntity course;

  _CatalogRepository({this.course = freeCourse});

  static const freeCourse = CatalogCourseEntity(
    id: 'free-course',
    title: 'Bass Dasar',
    description: 'Pelajari teknik dasar bass.',
    instructor: 'Bass Training Academy',
    lessonCount: 3,
    isFree: true,
    isPaid: false,
    priceLabel: 'Gratis',
  );

  static const paidCourse = CatalogCourseEntity(
    id: 'paid-course',
    title: 'Kursus Eksternal',
    description: 'Pelajari materi lanjutan.',
    instructor: 'Bass Training Academy',
    lessonCount: 5,
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
  }) async => const CatalogPageEntity.empty();

  @override
  Future<CatalogCourseEntity?> getDetail(String catalogId) async => course;

  @override
  Future<void> enroll(String catalogId) async {
    enrollCalls++;
  }
}

class _GuestAuthRepository implements AuthRepository {
  @override
  Future<UserEntity?> getCurrentUser() async => null;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
