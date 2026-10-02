import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lms_mobile_app/src/core/config/constants/app_routes.dart';
import 'package:lms_mobile_app/src/features/authentication/presentation/screens/intro_screen.dart';

void main() {
  Future<GoRouter> pumpIntro(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final router = GoRouter(
      initialLocation: AppRoutes.intro,
      routes: [
        GoRoute(path: AppRoutes.intro, builder: (_, _) => const IntroScreen()),
        GoRoute(
          path: AppRoutes.catalog,
          builder: (_, _) => const Scaffold(body: Text('Katalog tamu')),
        ),
        GoRoute(
          path: AppRoutes.login,
          builder: (_, _) => const Scaffold(body: Text('Halaman login')),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pump();
    return router;
  }

  testWidgets('aksi Telusuri dan Mulai Belajar tetap tampil di setiap slide', (
    tester,
  ) async {
    await pumpIntro(tester);

    final browse = find.byKey(const ValueKey('browse-catalog-button'));
    final start = find.byKey(const ValueKey('start-learning-button'));
    expect(browse, findsOneWidget);
    expect(start, findsOneWidget);

    await tester.drag(find.byType(PageView), const Offset(-360, 0));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.textContaining('Pahami'), findsOneWidget);
    expect(browse, findsOneWidget);
    expect(start, findsOneWidget);
  });

  testWidgets('onboarding tidak overflow pada layar pendek', (tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 568));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final router = GoRouter(
      initialLocation: AppRoutes.intro,
      routes: [
        GoRoute(path: AppRoutes.intro, builder: (_, _) => const IntroScreen()),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.byKey(const ValueKey('browse-catalog-button')), findsOneWidget);
    expect(find.byKey(const ValueKey('start-learning-button')), findsOneWidget);
  });

  testWidgets('Telusuri membuka katalog tamu', (tester) async {
    final router = await pumpIntro(tester);

    await tester.tap(find.byKey(const ValueKey('browse-catalog-button')));
    await tester.pumpAndSettle();
    expect(router.routeInformationProvider.value.uri.path, AppRoutes.catalog);
    expect(find.text('Katalog tamu'), findsOneWidget);
  });

  testWidgets('Mulai Belajar membuka login', (tester) async {
    final router = await pumpIntro(tester);

    await tester.tap(find.byKey(const ValueKey('start-learning-button')));
    await tester.pumpAndSettle();
    expect(router.routeInformationProvider.value.uri.path, AppRoutes.login);
    expect(find.text('Halaman login'), findsOneWidget);
  });
}
