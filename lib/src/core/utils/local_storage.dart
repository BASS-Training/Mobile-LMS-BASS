import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

/// Penyimpanan lokal berbasis Hive (box utama `mini_lms_box`).
///
/// Satu-satunya sumber untuk data ringan di perangkat: token & user sesi,
/// status "intro dilihat", preferensi tema, progres lesson lokal, draft esai,
/// dan riwayat attempt. Di-`init` sekali di [CoreModule]. Fitur lain (game,
/// achievement) memakai box-nya sendiri. Lihat ARCHITECTURE.md §8.
class LocalStorage {
  static const String _boxName = 'mini_lms_box';
  static const String _completedLessonsKey = 'completed_lessons';
  static const String _essayDraftPrefix = 'essay_draft_';
  static const String _essaySubmittedPrefix = 'essay_submitted_';
  static const String _lessonAttemptPrefix = 'lesson_attempts_';
  static const String _recentCoursesKey = 'recent_courses';
  static const String _authTokenKey = 'auth_token';
  static const String _authUserKey = 'auth_user';
  static const String _introSeenKey = 'intro_seen';
  static const String _gameSoundMutedKey = 'game_sound_muted';
  static const String _themeModeKey = 'theme_mode';
  static const String _coursesCacheKey = 'courses_cache';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(_boxName);
    await _migrateLegacyGlobalProgress();
  }

  static Box get _box => Hive.box(_boxName);

  /// Suffix unik per akun agar progres lokal (lesson selesai, draft esai,
  /// attempt, dst.) tidak pernah bocor antar-akun di perangkat yang sama.
  /// Memakai id user pada sesi tersimpan; `guest` saat belum login.
  static String _userScope() {
    final user = getAuthUser();
    final id = user?['id'];
    final idStr = id?.toString() ?? '';
    return idStr.isEmpty ? 'guest' : idStr;
  }

  /// Bungkus sebuah key dasar menjadi key yang ter-scope ke user aktif.
  static String _scoped(String baseKey) => '${baseKey}__u_${_userScope()}';

  /// Hapus key progres global versi lama (sebelum namespacing per-user) supaya
  /// tidak ada lagi data yang bocor lintas akun. Dijalankan sekali saat init.
  static Future<void> _migrateLegacyGlobalProgress() async {
    const legacyKeys = [_completedLessonsKey, _recentCoursesKey];
    for (final key in legacyKeys) {
      if (_box.containsKey(key)) {
        await _box.delete(key);
      }
    }
  }

  // Mark lesson as completed
  static Future<void> markLessonComplete(String lessonId) async {
    final completedLessons = getCompletedLessons();
    if (!completedLessons.contains(lessonId)) {
      completedLessons.add(lessonId);
      await _box.put(_scoped(_completedLessonsKey), completedLessons);
    }
  }

  // Unmark lesson as completed
  static Future<void> unmarkLessonComplete(String lessonId) async {
    final completedLessons = getCompletedLessons();
    completedLessons.remove(lessonId);
    await _box.put(_scoped(_completedLessonsKey), completedLessons);
  }

  // Get all completed lessons
  static List<String> getCompletedLessons() {
    final list = _box.get(_scoped(_completedLessonsKey), defaultValue: <String>[]);
    return List<String>.from(list);
  }

  // Check if lesson is completed
  static bool isLessonCompleted(String lessonId) {
    return getCompletedLessons().contains(lessonId);
  }

  // Clear all completed lessons
  static Future<void> clearAllProgress() async {
    await _box.delete(_scoped(_completedLessonsKey));
  }

  static List<String> getRecentCourses() {
    final list = _box.get(_scoped(_recentCoursesKey), defaultValue: <String>[]);
    return List<String>.from(list);
  }

  static Future<void> recordRecentCourse(String courseId) async {
    final recentCourses = getRecentCourses();
    recentCourses.remove(courseId);
    recentCourses.insert(0, courseId);

    if (recentCourses.length > 10) {
      recentCourses.removeRange(10, recentCourses.length);
    }

    await _box.put(_scoped(_recentCoursesKey), recentCourses);
  }

  static Future<void> clearRecentCourses() async {
    await _box.delete(_scoped(_recentCoursesKey));
  }

  static Future<void> saveAuthSession({
    required String token,
    required Map<String, dynamic> user,
  }) async {
    await _box.put(_authTokenKey, token);
    await _box.put(_authUserKey, jsonEncode(user));
  }

  static String? getAuthToken() {
    final token = _box.get(_authTokenKey);
    return token is String && token.isNotEmpty ? token : null;
  }

  static Map<String, dynamic>? getAuthUser() {
    final raw = _box.get(_authUserKey);
    if (raw is! String || raw.isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map) {
        return decoded.map((key, value) => MapEntry(key.toString(), value));
      }
    } catch (_) {}

    return null;
  }

  static Future<void> clearAuthSession() async {
    await _box.delete(_authTokenKey);
    await _box.delete(_authUserKey);
    // Buang cache course agar data akun sebelumnya tidak bocor ke akun lain.
    await _box.delete(_coursesCacheKey);
  }

  // ===== Cache daftar course (untuk tampilan cache-first yang instan) =====
  // Menyimpan payload `data` mentah dari API courses sebagai string JSON, lalu
  // dibaca kembali saat startup untuk menampilkan data terakhir tanpa menunggu
  // jaringan. Direfresh diam-diam di belakang setiap kali fetch berhasil.
  static Future<void> saveCoursesCache(String coursesJson) async {
    await _box.put(_coursesCacheKey, coursesJson);
  }

  static List<Map<String, dynamic>>? getCoursesCache() {
    final raw = _box.get(_coursesCacheKey);
    if (raw is! String || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded
            .whereType<Map>()
            .map((e) => e.map((k, v) => MapEntry(k.toString(), v)))
            .toList();
      }
    } catch (_) {}
    return null;
  }

  static bool hasSeenIntro() {
    return _box.get(_introSeenKey, defaultValue: false) == true;
  }

  static Future<void> markIntroSeen() async {
    await _box.put(_introSeenKey, true);
  }

  // Whether game sound effects are muted (shared across all mini games).
  static bool isGameSoundMuted() {
    return _box.get(_gameSoundMutedKey, defaultValue: false) == true;
  }

  static Future<void> setGameSoundMuted(bool muted) async {
    await _box.put(_gameSoundMutedKey, muted);
  }

  // Theme mode preference: 'light' (default) | 'dark' | 'system'.
  static String getThemeMode() {
    final v = _box.get(_themeModeKey, defaultValue: 'light');
    return v is String ? v : 'light';
  }

  static Future<void> setThemeMode(String mode) async {
    await _box.put(_themeModeKey, mode);
  }

  // Get progress statistics
  static Map<String, dynamic> getProgress() {
    final completedLessons = getCompletedLessons();
    return {
      'completedCount': completedLessons.length,
      'completedLessons': completedLessons,
    };
  }

  static String _essayDraftKey(String lessonId) {
    return _scoped('$_essayDraftPrefix$lessonId');
  }

  static String _essaySubmittedKey(String lessonId) {
    return _scoped('$_essaySubmittedPrefix$lessonId');
  }

  static Future<void> markEssaySubmitted(String lessonId) async {
    await _box.put(_essaySubmittedKey(lessonId), true);
  }

  static Future<void> unmarkEssaySubmitted(String lessonId) async {
    await _box.delete(_essaySubmittedKey(lessonId));
  }

  static bool isEssaySubmitted(String lessonId) {
    return _box.get(_essaySubmittedKey(lessonId), defaultValue: false) == true;
  }

  static Map<int, String> getEssayDraftAnswers(String lessonId) {
    final raw = _box.get(
      _essayDraftKey(lessonId),
      defaultValue: <dynamic, dynamic>{},
    );
    if (raw is! Map) {
      return <int, String>{};
    }

    final result = <int, String>{};
    raw.forEach((key, value) {
      final index = int.tryParse(key.toString());
      if (index == null) return;
      result[index] = value?.toString() ?? '';
    });

    return result;
  }

  static Future<void> saveEssayDraftAnswer({
    required String lessonId,
    required int questionIndex,
    required String answer,
  }) async {
    final current = getEssayDraftAnswers(lessonId);
    current[questionIndex] = answer;
    await _box.put(
      _essayDraftKey(lessonId),
      current.map((key, value) => MapEntry(key.toString(), value)),
    );
  }

  static Future<void> saveEssayDraftAnswers({
    required String lessonId,
    required Map<int, String> answers,
  }) async {
    await _box.put(
      _essayDraftKey(lessonId),
      answers.map((key, value) => MapEntry(key.toString(), value)),
    );
  }

  static Future<void> clearEssayDraft(String lessonId) async {
    await _box.delete(_essayDraftKey(lessonId));
  }

  static String _lessonAttemptsKey(String courseId) {
    return _scoped('$_lessonAttemptPrefix$courseId');
  }

  static List<Map<String, dynamic>> getLessonAttempts(String courseId) {
    final raw = _box.get(
      _lessonAttemptsKey(courseId),
      defaultValue: <dynamic>[],
    );

    if (raw is! List) {
      return <Map<String, dynamic>>[];
    }

    return raw
        .whereType<Map>()
        .map(
          (entry) => entry.map((key, value) => MapEntry(key.toString(), value)),
        )
        .toList();
  }

  static Future<void> saveLessonAttempts({
    required String courseId,
    required List<Map<String, dynamic>> attempts,
  }) async {
    await _box.put(_lessonAttemptsKey(courseId), attempts);
  }

  static Future<void> clearLessonAttempts(String courseId) async {
    await _box.delete(_lessonAttemptsKey(courseId));
  }
}
