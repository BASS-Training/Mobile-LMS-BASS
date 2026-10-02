import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms_mobile_app/src/core/config/constants/app_strings.dart';
import 'package:lms_mobile_app/src/core/config/flavor_config.dart';

// Core - Theme & DI
import 'package:lms_mobile_app/src/shared/styles/app_colors.dart';
import 'package:lms_mobile_app/src/shared/styles/app_theme.dart';
import 'package:lms_mobile_app/src/shared/theme/theme_controller.dart';
import 'package:lms_mobile_app/src/core/di/injector.dart';
import 'package:lms_mobile_app/src/core/routes/app_router.dart';

// Domain Entities
// BLoCs
import 'package:lms_mobile_app/src/features/authentication/presentation/bloc/auth/auth_bloc.dart';
import 'package:lms_mobile_app/src/features/authentication/presentation/bloc/auth/auth_state.dart';
import 'package:lms_mobile_app/src/features/catalog/presentation/bloc/catalog_bloc.dart';
import 'package:lms_mobile_app/src/features/catalog/presentation/bloc/catalog_event.dart';
import 'package:lms_mobile_app/src/features/courses/presentation/bloc/course/course_bloc.dart';
import 'package:lms_mobile_app/src/features/courses/presentation/bloc/course/course_event.dart';
import 'package:lms_mobile_app/src/features/home/presentation/bloc/home_bloc.dart';
import 'package:lms_mobile_app/src/features/lessons/data/repositories/quiz_repository_impl.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/bloc/lesson/lesson_bloc.dart';

/// Entry point aplikasi.
///
/// Urutannya: kunci orientasi ke potret → pilih flavor (development saat debug,
/// production saat release via [kReleaseMode]) → rangkai seluruh dependency lewat
/// [ServiceLocator] → jalankan [MainApp] yang menyetir navigasi dengan go_router.
/// Lihat ARCHITECTURE.md §5 (Alur Startup).
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock the whole app to portrait — no landscape, on any screen.
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  if (kReleaseMode) {
    // Jika aplikasi di-build untuk rilis (Production)
    FlavorConfig.init(
      flavor: ProductionFlavorConfig.config.flavor,
      apiBaseUrl: ProductionFlavorConfig.config.apiBaseUrl,
      enableLogging: ProductionFlavorConfig.config.enableLogging,
      enableMockData: ProductionFlavorConfig.config.enableMockData,
    );
  } else {
    // Jika aplikasi di-run dari VS Code (Development)
    FlavorConfig.init(
      flavor: DevelopmentFlavorConfig.config.flavor,
      apiBaseUrl: DevelopmentFlavorConfig.config.apiBaseUrl,
      enableLogging: DevelopmentFlavorConfig.config.enableLogging,
      enableMockData: DevelopmentFlavorConfig.config.enableMockData,
    );
  }

  // Initialize Service Locator (which includes CoreModule init)
  final serviceLocator = ServiceLocator();
  await serviceLocator.setupServiceLocator();

  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    // Rebuild when the OS switches light/dark while in "system" mode.
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final sl = ServiceLocator().locator;

    return MultiBlocProvider(
      providers: [
        // BlocProvider.value: instance ini lazySingleton di GetIt dan juga
        // dipakai AppRouter (refreshListenable/redirect). create: akan menutup
        // singleton itu saat provider dilepas, lalu siapa pun yang mengambilnya
        // lagi dari GetIt mendapat bloc yang sudah mati.
        BlocProvider<AuthBloc>.value(value: sl<AuthBloc>()),
        BlocProvider<CatalogBloc>(create: (context) => sl<CatalogBloc>()),
        BlocProvider<CourseBloc>(create: (context) => sl<CourseBloc>()),
        BlocProvider<HomeBloc>(create: (context) => sl<HomeBloc>()),
        BlocProvider<LessonBloc>.value(value: sl<LessonBloc>()),
      ],
      // Reset data yang bergantung pada akun saat sesi masuk/keluar. Ini juga
      // memaksa katalog yang semula dimuat sebagai tamu mengambil ulang status
      // enrollment dan akses program memakai token akun yang baru masuk.
      child: BlocListener<AuthBloc, AuthState>(
        listenWhen: (prev, curr) {
          if (curr is AuthLoggedOut) return true;
          if (curr is! AuthSuccess) return false;
          return prev is! AuthSuccess || prev.user.id != curr.user.id;
        },
        listener: (context, state) {
          context.read<CourseBloc>().add(const ResetCoursesEvent());
          context.read<CatalogBloc>().add(const ResetCatalogEvent());
          if (state is AuthLoggedOut) {
            // Cache quiz statis hanya perlu dibuang saat sesi berakhir agar
            // status lulus tidak terbawa ke akun berikutnya.
            QuizRepositoryImpl.clearStaticCache();
          }
        },
        child: ListenableBuilder(
          listenable: ThemeController.instance,
          builder: (context, _) {
            final platform =
                WidgetsBinding.instance.platformDispatcher.platformBrightness;
            final brightness = ThemeController.instance.resolveBrightness(
              platform,
            );
            // Drive the theme-aware AppColors getters used across the app.
            AppColors.brightness = brightness;

            return MaterialApp.router(
              // Keying by brightness forces a clean remount on theme change so
              // even cached `const` subtrees repaint with the new palette.
              key: ValueKey(brightness),
              title: AppStrings.appName,
              theme: AppTheme.theme,
              debugShowCheckedModeBanner: false,
              routerConfig: AppRouter.router,
            );
          },
        ),
      ),
    );
  }
}
