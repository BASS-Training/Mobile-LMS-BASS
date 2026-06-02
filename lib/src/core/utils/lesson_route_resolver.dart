import 'package:lms_mobile_app/src/core/config/constants/app_routes.dart';

class LessonRouteResolver {
  const LessonRouteResolver._();

  static String routeForType(String type) {
    switch (type.toLowerCase()) {
      case 'video':
        return AppRoutes.videoLessonDetail;
      case 'document':
        return AppRoutes.documentLessonDetail;
      case 'quiz':
        return AppRoutes.quizLessonDetail;
      case 'essay':
        return AppRoutes.essayLessonDetail;
      case 'image':
        return AppRoutes.imageLessonDetail;
      case 'zoom':
        return AppRoutes.zoomLessonDetail;
      case 'text':
      default:
        return AppRoutes.textLessonDetail;
    }
  }
}
