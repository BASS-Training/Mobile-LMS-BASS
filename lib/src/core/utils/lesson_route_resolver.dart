import 'package:lms_mobile_app/src/core/config/constants/app_routes.dart';

/// Memetakan tipe konten/materi (text/video/quiz/essay/document/image/zoom/
/// case_study/feedback) ke nama rute layar detail yang sesuai.
///
/// Dengan ini pemanggil cukup tahu `type`-nya; logika routing per-tipe
/// terpusat di sini (default → layar teks).
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
      case 'case_study':
        return AppRoutes.caseStudyLessonDetail;
      case 'feedback':
        return AppRoutes.feedbackLessonDetail;
      case 'text':
      default:
        return AppRoutes.textLessonDetail;
    }
  }
}
