/// API Endpoints configuration
/// Format: /path/to/endpoint
class ApiEndpoints {
  // Auth
  static const String login = '/auth/login';
  static const String logout = '/auth/logout';
  static const String register = '/auth/register';
  static const String getCurrentUser = '/auth/me';
  static const String refreshToken = '/auth/refresh-token';

  // Courses
  static const String getCourses = '/courses';
  static const String getCourseById = '/courses/{id}';
  static const String searchCourses = '/courses/search';
  static const String getCourseProgress = '/courses/{id}/progress';
  static const String enrollByToken = '/enroll';
  static const String savedCourses = '/courses/saved';
  static const String toggleSaveCourse = '/courses/{id}/save';

  // Lessons
  static const String getLessons = '/courses/{courseId}/lessons';
  static const String getLessonById = '/courses/{courseId}/lessons/{id}';
  static const String markLessonComplete = '/lessons/{id}/complete';
  static const String markLessonIncomplete = '/lessons/{id}/incomplete';

  // Quizzes
  static const String getQuizByLesson = '/quizzes/by-lesson/{id}';
  static const String startQuizAttempt = '/quizzes/{quiz}/attempts';
  static const String submitQuizAttempt =
      '/quizzes/{quiz}/attempts/{attempt}/submit';

  // Essays
  static const String getEssayByLesson = '/essays/by-lesson/{id}';
  static const String submitEssay = '/essays/{id}/submit';
  static const String autosaveEssay = '/essays/{id}/draft';

  // Case Studies (studi kasus)
  static const String getCaseStudyByLesson = '/case-studies/by-lesson/{id}';
  static const String submitCaseStudy = '/case-studies/{id}/submit';
  static const String autosaveCaseStudy = '/case-studies/{id}/draft';
  static const String downloadCaseStudy = '/case-studies/{id}/download';

  // Feedback (form survei, tanpa penilaian)
  static const String getFeedbackByLesson = '/feedback/by-lesson/{id}';
  static const String submitFeedback = '/feedback/{id}/submit';

  // Discussions (lesson = backend content.id)
  static const String getDiscussions = '/lessons/{contentId}/discussions';
  static const String createDiscussion = '/lessons/{contentId}/discussions';
  static const String createReply = '/discussions/{discussionId}/replies';

  // Certificates
  static const String getCertificates = '/certificates';
  static const String getCertificateById = '/certificates/{id}';

  // Profile
  static const String getProfile = '/profile';
  static const String updateProfile = '/profile';

  // Instructor / admin (mobile): peserta, progres, dan penilaian.
  static const String instructorDashboard = '/instructor/dashboard';
  static const String instructorGlobalGradingQueue = '/instructor/grading-queue';
  static const String courseParticipants = '/courses/{id}/participants';
  static const String courseGradingQueue = '/courses/{id}/grading-queue';
  static const String essaySubmissionDetail = '/essays/submissions/{id}';
  static const String gradeEssaySubmission = '/essays/submissions/{id}/grade';
  static const String caseStudySubmissionDetail =
      '/case-studies/submissions/{id}';
  static const String gradeCaseStudySubmission =
      '/case-studies/submissions/{id}/grade';
}
