/// Route name constants
/// Digunakan untuk navigation di seluruh app
class AppRoutes {
  // Splash
  static const String splash = '/splash';

  // Intro
  static const String intro = '/intro';

  // Auth
  static const String authHub = '/auth-hub';
  static const String login = '/login';
  static const String register = '/register';
  static const String verifyEmail = '/verify-email-otp';
  static const String forgotPassword = '/forgot-password';
  static const String changePassword = '/change-password';
  static const String changeEmail = '/change-email';
  static const String deleteAccount = '/delete-account';

  // Main
  static const String main = '/main';
  static const String home = '/home';
  static const String courses = '/courses';
  static const String savedCourses = '/saved-courses';
  static const String certificates = '/certificates';
  static const String profile = '/profile';
  static const String editProfile = '/edit-profile';
  static const String joinClass = '/join-class';
  static const String notifications = '/notifications-center';
  static const String discussionHub = '/discussions';
  static const String discussionCourse = '/discussions/course';
  static const String discussionThread = '/discussion-thread';
  static const String achievements = '/achievements';
  static const String agenda = '/agenda';
  // Penugasan peserta: agregasi tugas (essay/studi kasus/dokumen) yang perlu
  // dikerjakan / menunggu penilaian, lintas course yang sudah ter-unlock.
  static const String assignments = '/assignments';

  // Course Details
  static const String courseDetail = '/course-detail';
  static const String courseResults = '/course-results';

  // Lesson Details
  static const String lessonDetail = '/lesson-detail';
  static const String videoLessonDetail = '/lesson-video-detail';
  static const String textLessonDetail = '/lesson-text-detail';
  static const String documentLessonDetail = '/lesson-document-detail';
  static const String quizLessonDetail = '/lesson-quiz-detail';
  static const String essayLessonDetail = '/lesson-essay-detail';
  static const String imageLessonDetail = '/lesson-image-detail';
  static const String zoomLessonDetail = '/lesson-zoom-detail';
  static const String caseStudyLessonDetail = '/lesson-case-study-detail';
  static const String feedbackLessonDetail = '/lesson-feedback-detail';

  // Result Details
  static const String quizResultDetail = '/quiz-result-detail';
  static const String essayResultDetail = '/essay-result-detail';
  static const String caseStudyResultDetail = '/case-study-result-detail';

  // Certificate Details
  static const String certificateDetail = '/certificate-detail';
  static const String certificateList = '/certificate-list';

  // Instructor / admin
  // Panel instruktur (dashboard pengelolaan) — kini dibuka sebagai halaman
  // dari Home, bukan lagi menggantikan Home.
  static const String instructorHub = '/instructor/hub';
  static const String instructorParticipants = '/instructor/participants';
  static const String instructorParticipantDetail =
      '/instructor/participant-detail';
  static const String instructorGradingQueue = '/instructor/grading-queue';
  static const String instructorEssayGrading = '/instructor/grade-essay';
  static const String instructorCaseStudyGrading = '/instructor/grade-case-study';
  static const String instructorDocumentGrading = '/instructor/grade-document';

  // Games
  static const String gamesHub = '/games';
  static const String game2048 = '/games/2048';
  static const String gameSchulte = '/games/schulte';
  static const String gameStackTower = '/games/stack-tower';
  static const String gameFlappy = '/games/flappy';
}
