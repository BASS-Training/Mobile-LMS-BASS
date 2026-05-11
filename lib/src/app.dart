import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/config/app_config.dart';
import 'core/routes/app_router.dart';
import 'core/constants/app_routes.dart';
import 'shared/styles/styles.dart';
import 'core/utils/app_logger.dart';

/// Root application widget
class LmsApp extends StatelessWidget {
  final AppConfig appConfig;

  const LmsApp({Key? key, required this.appConfig}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Initialize logger
    AppLogger.init(isDevelopment: appConfig.isDevelopment);

    return MaterialApp(
      title: appConfig.appName,
      debugShowCheckedModeBanner: appConfig.isDevelopment,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,

      // Routes
      initialRoute: AppRoutes.home,
      onGenerateRoute: AppRouter.generateRoute,

      // Builder untuk global context
      builder: (context, child) {
        return child ?? const SizedBox();
      },
    );
  }
}
