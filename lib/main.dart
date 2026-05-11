import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms_mobile_app/src/core/di/injector.dart';
import 'package:lms_mobile_app/src/core/routes/app_router.dart';
import 'package:lms_mobile_app/src/shared/styles/app_theme.dart';
import 'package:lms_mobile_app/src/features/authentication/presentation/bloc/auth/auth_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Service Locator (which includes CoreModule init)
  final serviceLocator = ServiceLocator();
  await serviceLocator.setupServiceLocator();

  runApp(
    BlocProvider<AuthBloc>(
      create: (context) => serviceLocator.authBloc,
      child: MaterialApp.router(
        title: 'LMS Mobile App',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        routerConfig: AppRouter.router,
      ),
    ),
  );
}
