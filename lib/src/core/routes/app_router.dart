import 'package:flutter/material.dart';
import '../constants/app_routes.dart';

/// Route generator untuk navigasi aplikasi
class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      // Auth routes
      case AppRoutes.login:
        return _buildRoute(
          routeName: settings.name,
          builder: (context) => const SizedBox(), // TODO: LoginScreen
          settings: settings,
        );

      // Home route
      case AppRoutes.home:
      case AppRoutes.mainScreen:
        return _buildRoute(
          routeName: settings.name,
          builder: (context) => const SizedBox(), // TODO: MainScreen
          settings: settings,
        );

      // Course routes
      case AppRoutes.courseList:
        return _buildRoute(
          routeName: settings.name,
          builder: (context) => const SizedBox(), // TODO: CourseListScreen
          settings: settings,
        );

      case AppRoutes.courseDetail:
        return _buildRoute(
          routeName: settings.name,
          builder: (context) => const SizedBox(), // TODO: CourseDetailScreen
          settings: settings,
        );

      // Lesson routes
      case AppRoutes.lessonDetail:
        return _buildRoute(
          routeName: settings.name,
          builder: (context) => const SizedBox(), // TODO: LessonDetailScreen
          settings: settings,
        );

      case AppRoutes.lessonVideoDetail:
        return _buildRoute(
          routeName: settings.name,
          builder: (context) =>
              const SizedBox(), // TODO: VideoLessonDetailScreen
          settings: settings,
        );

      case AppRoutes.lessonDocumentDetail:
        return _buildRoute(
          routeName: settings.name,
          builder: (context) =>
              const SizedBox(), // TODO: DocumentLessonDetailScreen
          settings: settings,
        );

      // Certificate routes
      case AppRoutes.certificateList:
        return _buildRoute(
          routeName: settings.name,
          builder: (context) => const SizedBox(), // TODO: CertificateListScreen
          settings: settings,
        );

      case AppRoutes.certificateDetail:
        return _buildRoute(
          routeName: settings.name,
          builder: (context) =>
              const SizedBox(), // TODO: CertificateDetailScreen
          settings: settings,
        );

      // Profile routes
      case AppRoutes.profile:
        return _buildRoute(
          routeName: settings.name,
          builder: (context) => const SizedBox(), // TODO: ProfileScreen
          settings: settings,
        );

      // Default route
      default:
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(title: const Text('Page Not Found')),
            body: Center(child: Text('Route ${settings.name} not found')),
          ),
          settings: settings,
        );
    }
  }

  /// Build material route dengan smooth animation
  static MaterialPageRoute<T> _buildRoute<T>({
    required String? routeName,
    required WidgetBuilder builder,
    required RouteSettings settings,
  }) {
    return MaterialPageRoute<T>(builder: builder, settings: settings);
  }

  /// Navigate to route
  static Future<dynamic> navigateTo(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.pushNamed(context, routeName, arguments: arguments);
  }

  /// Replace current route
  static Future<dynamic> replaceRoute(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.pushReplacementNamed(
      context,
      routeName,
      arguments: arguments,
    );
  }

  /// Pop current route
  static void pop(BuildContext context, {dynamic result}) {
    Navigator.pop(context, result);
  }

  /// Pop until specific route
  static void popUntil(BuildContext context, String routeName) {
    Navigator.popUntil(context, ModalRoute.withName(routeName));
  }
}
