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
import 'package:lms_mobile_app/src/features/catalog/domain/repositories/catalog_repository.dart';
import 'package:lms_mobile_app/src/features/catalog/presentation/bloc/catalog_bloc.dart';
import 'package:lms_mobile_app/src/features/catalog/presentation/screens/catalog_detail_screen.dart';

void main() {
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
}

class _CatalogRepository implements CatalogRepository {
  int enrollCalls = 0;

  static const course = CatalogCourseEntity(
    id: 'free-course',
    title: 'Bass Dasar',
    description: 'Pelajari teknik dasar bass.',
    instructor: 'Bass Training Academy',
    lessonCount: 3,
    isFree: true,
    isPaid: false,
    priceLabel: 'Gratis',
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
