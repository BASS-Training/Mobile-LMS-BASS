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