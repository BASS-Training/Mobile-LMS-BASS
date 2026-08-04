/// API Endpoints configuration
/// Format: /path/to/endpoint
class ApiEndpoints {
  // Auth
  static const String login = '/auth/login';
  static const String logout = '/auth/logout';
  static const String register = '/auth/register';
  static const String getCurrentUser = '/auth/me';
  static const String refreshToken = '/auth/refresh-token';

  /// Hapus permanen akun peserta yang sedang login (DELETE, butuh konfirmasi
  /// password). Wajib App Store Guideline 5.1.1(v).
  static const String deleteAccount = '/auth/account';

  // Verifikasi email (OTP) — butuh login
  static const String sendEmailOtp = '/auth/email/send-otp';
  static const String verifyEmailOtp = '/auth/email/verify-otp';

  // Ubah email (pola verifikasi-dulu) — butuh login. OTP dikirim ke email baru.
  static const String sendChangeEmailOtp = '/auth/email/change/send-otp';
  static const String changeEmail = '/auth/email/change';

  // Password (OTP reset publik + ganti saat login)
  static const String sendPasswordOtp = '/auth/password/send-otp';
  static const String resetPassword = '/auth/password/reset';
  static const String changePassword = '/auth/password/change';

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
  static const String quizLeaderboard = '/quizzes/{quiz}/leaderboard';

  // Essays
  static const String getEssayByLesson = '/essays/by-lesson/{id}';
  static const String submitEssay = '/essays/{id}/submit';
  static const String autosaveEssay = '/essays/{id}/draft';

  // Case Studies (studi kasus)
  static const String getCaseStudyByLesson = '/case-studies/by-lesson/{id}';
  static const String submitCaseStudy = '/case-studies/{id}/submit';
  static const String autosaveCaseStudy = '/case-studies/{id}/draft';
  static const String downloadCaseStudy = '/case-studies/{id}/download';

  // Pengumpulan tugas dokumen (konten tipe 'document' dgn collect_submission)
  static const String getDocumentSubmission =
      '/document-submissions/by-lesson/{id}';
  static const String uploadDocumentSubmission =
      '/document-submissions/{id}/upload';
  static const String removeDocumentSubmissionFile =
      '/document-submissions/{id}/file';
  static const String submitDocumentSubmission =
      '/document-submissions/{id}/submit';
  static const String manageDocumentSubmissions =
      '/document-submissions/{id}/manage';
  static const String gradeDocumentSubmission =
      '/document-submissions/{id}/grade';

  // Feedback (form survei, tanpa penilaian)
  static const String getFeedbackByLesson = '/feedback/by-lesson/{id}';
  static const String submitFeedback = '/feedback/{id}/submit';

  // Discussions (lesson = backend content.id)
  static const String discussionsFeed = '/discussions';
  static const String discussionsStructure = '/discussions/structure';
  static const String getDiscussions = '/lessons/{contentId}/discussions';
  static const String createDiscussion = '/lessons/{contentId}/discussions';
  static const String createReply = '/discussions/{discussionId}/replies';

  // Certificates (aturan kelayakan & PDF sama persis dengan web)
  static const String certificates = '/certificates';
  static const String generateCertificate = '/certificates/{course}/generate';

  // Profile
  static const String getProfile = '/profile';
  static const String updateProfile = '/profile';

  // Agenda (sesi terjadwal/Zoom mendatang lintas course)
  static const String agenda = '/agenda';

  // Agenda pribadi peserta (per-user, sinkron lintas device)
  static const String personalAgenda = '/agenda/personal';
  static const String personalAgendaItem = '/agenda/personal/{id}';

  // Best score mini-game (per-user)
  static const String gameScores = '/games/scores';
  static const String gameScoresMerge = '/games/scores/merge';

  // Baseline perayaan achievement (per-user)
  static const String achievementTiers = '/achievements/tiers';
  static const String achievementTiersSync = '/achievements/tiers/sync';

  // Notifications (gabungan: notifikasi DB + pengumuman web)
  static const String notifications = '/notifications';
  static const String notificationsUnreadCount = '/notifications/unread-count';
  static const String notificationsMarkRead = '/notifications/mark-read';
  static const String notificationsMarkAllRead = '/notifications/mark-all-read';

  // Instructor / admin (mobile): peserta, progres, dan penilaian.
  static const String instructorDashboard = '/instructor/dashboard';
  static const String instructorGlobalGradingQueue = '/instructor/grading-queue';
  static const String courseParticipants = '/courses/{id}/participants';
  static const String participantProgress =
      '/courses/{courseId}/participants/{userId}/progress';
  static const String courseGradingQueue = '/courses/{id}/grading-queue';
  static const String essaySubmissionDetail = '/essays/submissions/{id}';
  static const String gradeEssaySubmission = '/essays/submissions/{id}/grade';
  static const String caseStudySubmissionDetail =
      '/case-studies/submissions/{id}';
  static const String gradeCaseStudySubmission =
      '/case-studies/submissions/{id}/grade';
}
