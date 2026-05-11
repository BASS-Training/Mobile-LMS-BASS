/// API Endpoints configuration
/// Format: /path/to/endpoint
class ApiEndpoints {
  // Auth
  static const String login = '/auth/login';
  static const String logout = '/auth/logout';
  static const String register = '/auth/register';
  static const String refreshToken = '/auth/refresh-token';

  // Courses
  static const String getCourses = '/courses';
  static const String getCourseById = '/courses/{id}';
  static const String searchCourses = '/courses/search';
  static const String getCourseProgress = '/courses/{id}/progress';

  // Lessons
  static const String getLessons = '/courses/{courseId}/lessons';
  static const String getLessonById = '/courses/{courseId}/lessons/{id}';
  static const String markLessonComplete = '/lessons/{id}/complete';
  static const String markLessonIncomplete = '/lessons/{id}/incomplete';

  // Certificates
  static const String getCertificates = '/certificates';
  static const String getCertificateById = '/certificates/{id}';

  // Profile
  static const String getProfile = '/profile';
  static const String updateProfile = '/profile';
}
