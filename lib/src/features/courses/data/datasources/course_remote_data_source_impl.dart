import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:lms_mobile_app/src/core/services/firebase_initializer.dart';
import 'package:lms_mobile_app/src/features/courses/data/datasources/course_remote_data_source.dart';
import 'package:lms_mobile_app/src/features/courses/data/datasources/dummy_data.dart';
import '../models/course.dart';

/// Firebase Firestore-backed course data source dengan fallback ke dummy data.
class CourseRemoteDataSourceImpl implements CourseRemoteDataSource {
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  @override
  Future<List<Course>> getCourses() async {
    if (!await _isFirebaseReady()) {
      return DummyData.getCourses();
    }

    final snapshot = await _firestore.collection('courses').get();
    if (snapshot.docs.isEmpty) {
      return DummyData.getCourses();
    }

    return _mergeWithDummyCourses(snapshot.docs.map(_courseFromDoc).toList());
  }

  @override
  Stream<List<Course>> watchCourses() {
    return _watchCoursesFromFirestore().handleError((_) {
      return DummyData.getCourses();
    });
  }

  @override
  Future<Course?> getCourseById(String id) async {
    if (!await _isFirebaseReady()) {
      return _findDummyCourseById(id);
    }

    final doc = await _firestore.collection('courses').doc(id).get();
    if (doc.exists && doc.data() != null) {
      return _courseFromMap(doc.data()!, fallbackId: doc.id);
    }

    return _findDummyCourseById(id);
  }

  @override
  Future<List<Course>> searchCourses(String query) async {
    final courses = await getCourses();
    if (query.trim().isEmpty) {
      return courses;
    }

    final normalized = query.toLowerCase();
    return courses
        .where(
          (course) =>
              course.title.toLowerCase().contains(normalized) ||
              course.description.toLowerCase().contains(normalized) ||
              course.instructor.toLowerCase().contains(normalized),
        )
        .toList();
  }

  @override
  Future<void> toggleSaveCourse(String courseId) async {
    // Phase 2 fokus sync course content; save state tetap ditangani local storage.
  }

  @override
  Future<void> addCourse(Course course) async {
    if (!await _isFirebaseReady()) {
      return;
    }

    await _firestore.collection('courses').doc(course.id).set(course.toJson());
  }

  @override
  Future<List<Course>> getSavedCourses() async {
    // Saved state masih dikelola di local storage.
    throw UnimplementedError('Saved courses masih local-only');
  }

  Stream<List<Course>> _watchCoursesFromFirestore() {
    return _firestore.collection('courses').snapshots().map((snapshot) {
      if (snapshot.docs.isEmpty) {
        return DummyData.getCourses();
      }
      return _mergeWithDummyCourses(snapshot.docs.map(_courseFromDoc).toList());
    });
  }

  Future<bool> _isFirebaseReady() async {
    await FirebaseInitializer.ensureInitialized();
    return FirebaseInitializer.isInitialized;
  }

  Course _courseFromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    return _courseFromMap(doc.data(), fallbackId: doc.id);
  }

  Course _courseFromMap(
    Map<String, dynamic> data, {
    required String fallbackId,
  }) {
    final payload = Map<String, dynamic>.from(data);
    payload['id'] = payload['id'] ?? fallbackId;
    return Course.fromJson(payload);
  }

  Course? _findDummyCourseById(String id) {
    for (final course in DummyData.getCourses()) {
      if (course.id == id) {
        return course;
      }
    }
    return null;
  }

  List<Course> _mergeWithDummyCourses(List<Course> remoteCourses) {
    final mergedCourses = <String, Course>{};

    for (final course in DummyData.getCourses()) {
      mergedCourses[course.id] = course;
    }

    for (final course in remoteCourses) {
      mergedCourses[course.id] = course;
    }

    return mergedCourses.values.toList();
  }
}
