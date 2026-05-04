// import 'package:flutter/material.dart';
// import 'package:mini_lms_bass_training/data/sources/dummy_data.dart';
// import 'package:mini_lms_bass_training/data/sources/local_storage.dart';
// import 'package:mini_lms_bass_training/data/models/course.dart';

// class CourseProvider extends ChangeNotifier {
//   List<Course> _courses = [];
//   List<Course> _filteredCourses = [];
//   String _searchQuery = '';

//   List<Course> get courses => _courses;
//   List<Course> get filteredCourses => _filteredCourses;
//   String get searchQuery => _searchQuery;

//   CourseProvider() {
//     _loadCourses();
//   }

//   void _loadCourses() {
//     _courses = DummyData.getCourses();
//     _updateCompletionStatus();
//     _filteredCourses = _courses;
//   }

//   void _updateCompletionStatus() {
//     final completedLessons = LocalStorage.getCompletedLessons();
//     for (var course in _courses) {
//       for (var lesson in course.lessons) {
//         lesson.isCompleted = completedLessons.contains(lesson.id);
//       }
//     }
//   }

//   void search(String query) {
//     _searchQuery = query;
//     if (query.isEmpty) {
//       _filteredCourses = _courses;
//     } else {
//       _filteredCourses = _courses
//           .where(
//             (course) =>
//                 course.title.toLowerCase().contains(query.toLowerCase()) ||
//                 course.description.toLowerCase().contains(query.toLowerCase()),
//           )
//           .toList();
//     }
//     notifyListeners();
//   }

//   Course? getCourseById(String id) {
//     try {
//       return _courses.firstWhere((course) => course.id == id);
//     } catch (e) {
//       return null;
//     }
//   }

//   void toggleSaveCourse(String courseId) {
//     final courseIndex = _courses.indexWhere((c) => c.id == courseId);
//     if (courseIndex != -1) {
//       _courses[courseIndex].isSaved = !_courses[courseIndex].isSaved;
//       notifyListeners();
//     }
//   }

//   List<Course> getSavedCourses() {
//     return _courses.where((c) => c.isSaved).toList();
//   }

//   void refreshCourses() {
//     _updateCompletionStatus();
//     if (_searchQuery.isNotEmpty) {
//       search(_searchQuery);
//     } else {
//       _filteredCourses = _courses;
//     }
//     notifyListeners();
//   }
// }
