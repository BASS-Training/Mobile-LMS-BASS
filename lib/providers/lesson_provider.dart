// import 'package:flutter/material.dart';
// import 'package:mini_lms_bass_training/data/sources/local_storage.dart';
// import 'package:mini_lms_bass_training/data/models/lesson.dart';

// class LessonProvider extends ChangeNotifier {
//   final Map<String, bool> _lessonCompletionStatus = {};

//   LessonProvider() {
//     _loadCompletionStatus();
//   }

//   void _loadCompletionStatus() {
//     final completedLessons = LocalStorage.getCompletedLessons();
//     for (var lessonId in completedLessons) {
//       _lessonCompletionStatus[lessonId] = true;
//     }
//   }

//   bool isLessonCompleted(String lessonId) {
//     return _lessonCompletionStatus[lessonId] ?? false;
//   }

//   Future<void> toggleLessonCompletion(String lessonId) async {
//     final isCompleted = _lessonCompletionStatus[lessonId] ?? false;

//     if (isCompleted) {
//       await LocalStorage.unmarkLessonComplete(lessonId);
//       _lessonCompletionStatus[lessonId] = false;
//     } else {
//       await LocalStorage.markLessonComplete(lessonId);
//       _lessonCompletionStatus[lessonId] = true;
//     }

//     notifyListeners();
//   }

//   Future<void> markLessonComplete(String lessonId) async {
//     if (!isLessonCompleted(lessonId)) {
//       await LocalStorage.markLessonComplete(lessonId);
//       _lessonCompletionStatus[lessonId] = true;
//       notifyListeners();
//     }
//   }

//   Future<void> markLessonIncomplete(String lessonId) async {
//     if (isLessonCompleted(lessonId)) {
//       await LocalStorage.unmarkLessonComplete(lessonId);
//       _lessonCompletionStatus[lessonId] = false;
//       notifyListeners();
//     }
//   }

//   int getCompletedLessonsCount() {
//     return _lessonCompletionStatus.values.where((v) => v).length;
//   }

//   void updateLessonCompletion(Lesson lesson) {
//     _lessonCompletionStatus[lesson.id] = lesson.isCompleted;
//     notifyListeners();
//   }

//   Future<void> refreshCompletionStatus() async {
//     _loadCompletionStatus();
//     notifyListeners();
//   }
// }
