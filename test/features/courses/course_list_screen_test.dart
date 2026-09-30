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
import 'package:lms_mobile_app/src/features/courses/domain/entities/course_entity.dart';
import 'package:lms_mobile_app/src/features/courses/domain/repositories/course_repository.dart';
import 'package:lms_mobile_app/src/features/courses/domain/usecases/add_course_usecase.dart';
import 'package:lms_mobile_app/src/features/courses/domain/usecases/get_cached_courses_usecase.dart';
import 'package:lms_mobile_app/src/features/courses/domain/usecases/get_courses_usecase.dart';
import 'package:lms_mobile_app/src/features/courses/domain/usecases/refresh_courses_usecase.dart';
import 'package:lms_mobile_app/src/features/courses/domain/usecases/toggle_save_course_usecase.dart';
import 'package:lms_mobile_app/src/features/courses/presentation/bloc/course/course_bloc.dart';
import 'package:lms_mobile_app/src/features/courses/presentation/bloc/course/course_state.dart';
import 'package:lms_mobile_app/src/features/courses/presentation/screens/course_list_screen.dart';

void main() {
  testWidgets('search menunggu debounce dan hanya mengirim query terbaru', (
    tester,
  ) async {
    final authRepository = _FakeAuthRepository();
    final courseRepository = _FakeCourseRepository();
    final authBloc = AuthBloc(
      loginUseCase: LoginUseCase(authRepository),
      registerUseCase: RegisterUseCase(authRepository),
      logoutUseCase: LogoutUseCase(authRepository),
      getCurrentUserUseCase: GetCurrentUserUseCase(authRepository),
    );
    final courseBloc = CourseBloc(
      getCoursesUseCase: GetCoursesUseCase(courseRepository),
      getCachedCoursesUseCase: GetCachedCoursesUseCase(courseRepository),
      toggleSaveCourseUseCase: ToggleSaveCourseUseCase(courseRepository),
      refreshCoursesUseCase: RefreshCoursesUseCase(courseRepository),
      addCourseUseCase: AddCourseUseCase(courseRepository),
    );
    addTearDown(authBloc.close);
    addTearDown(courseBloc.close);

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider.value(value: authBloc),
          BlocProvider.value(value: courseBloc),
        ],
        child: const MaterialApp(home: CourseListScreen()),
      ),
    );
    await tester.pump();
    expect(courseBloc.state, isA<CourseLoaded>());

    final searchField = find.byType(TextField);
    await tester.enterText(searchField, ' Bass ');
    await tester.pump(const Duration(milliseconds: 300));
    await tester.enterText(searchField, ' Groove ');
    await tester.pump(const Duration(milliseconds: 399));

    expect((courseBloc.state as CourseLoaded).searchQuery, isEmpty);

    await tester.pump(const Duration(milliseconds: 1));
    await tester.pump();

    expect((courseBloc.state as CourseLoaded).searchQuery, 'groove');
  });
}

class _FakeAuthRepository implements AuthRepository {
  @override
  Future<UserEntity?> getCurrentUser() async => null;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeCourseRepository implements CourseRepository {
  @override
  Future<List<CourseEntity>> getCachedCourses() async => const [];

  @override
  Future<List<CourseEntity>> getCourses() async => const [];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
