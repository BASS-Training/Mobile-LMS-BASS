import 'package:equatable/equatable.dart';
import 'package:lms_mobile_app/src/features/courses/domain/entities/course_entity.dart';

class HomeStatsEntity extends Equatable {
  final int totalCourses;
  final int completedCourses;
  final int incompleteCourses;
  final int overallProgressPercentage;
  final int totalLessons;
  final int completedLessons;
  final int totalQuizzes;
  final int completedQuizzes;
  final List<CourseEntity> completedCourseList;

  const HomeStatsEntity({
    required this.totalCourses,
    required this.completedCourses,
    required this.incompleteCourses,
    required this.overallProgressPercentage,
    required this.totalLessons,
    required this.completedLessons,
    required this.totalQuizzes,
    required this.completedQuizzes,
    required this.completedCourseList,
  });

  /// Snapshot serba-nol yang aman dipakai saat data kursus belum tersedia,
  /// mis. membuka Pencapaian sebelum stats termuat atau dari akun pengelola.
  /// Mencegah crash cast null di rute Pencapaian.
  static const HomeStatsEntity empty = HomeStatsEntity(
    totalCourses: 0,
    completedCourses: 0,
    incompleteCourses: 0,
    overallProgressPercentage: 0,
    totalLessons: 0,
    completedLessons: 0,
    totalQuizzes: 0,
    completedQuizzes: 0,
    completedCourseList: [],
  );

  /// Factory ini akan membersihkan SEMUA looping yang ada di UI Home Screen
  factory HomeStatsEntity.fromCourses(List<CourseEntity> courses) {
    final completedCoursesList = courses.where((c) => c.progressPercentage == 100).toList();
    final completedCoursesCount = completedCoursesList.length;
    final totalCoursesCount = courses.length;

    int totalLessons = 0;
    int completedLessons = 0;
    int totalQuizzes = 0;
    int completedQuizzes = 0;

    for (final course in courses) {
      totalLessons += course.totalLessons;
      completedLessons += course.completedLessons;

      final quizzes = course.allLessons.where((l) => l.type == 'quiz');
      totalQuizzes += quizzes.length;
      completedQuizzes += quizzes.where((q) => q.isCompleted).length;
    }

    final overallProgress = totalLessons > 0 
        ? ((completedLessons / totalLessons) * 100).toInt() 
        : 0;

    return HomeStatsEntity(
      totalCourses: totalCoursesCount,
      completedCourses: completedCoursesCount,
      incompleteCourses: totalCoursesCount - completedCoursesCount,
      overallProgressPercentage: overallProgress,
      totalLessons: totalLessons,
      completedLessons: completedLessons,
      totalQuizzes: totalQuizzes,
      completedQuizzes: completedQuizzes,
      completedCourseList: completedCoursesList,
    );
  }

  @override
  List<Object?> get props => [
    totalCourses, completedCourses, incompleteCourses, overallProgressPercentage,
    totalLessons, completedLessons, totalQuizzes, completedQuizzes, completedCourseList
  ];
}