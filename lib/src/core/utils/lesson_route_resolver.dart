import 'package:lms_mobile_app/src/core/config/constants/app_routes.dart';

class LessonRouteResolver {
  const LessonRouteResolver._();

  static String routeForType(String type) {
    switch (type.toLowerCase()) {
      case 'video':
        return AppRoutes.videoLessonDetail;
      case 'quiz':
        return AppRoutes.quizLessonDetail;
      case 'essay':
        return AppRoutes.essayLessonDetail;
      case 'document':
      default:
        return AppRoutes.documentLessonDetail;
    }
  }
}
