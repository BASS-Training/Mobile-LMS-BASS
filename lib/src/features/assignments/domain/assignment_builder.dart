import 'package:lms_mobile_app/src/features/courses/domain/entities/course_entity.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/entities/lesson_entity.dart';
import 'entities/assignment_task.dart';

/// Membangun daftar tugas peserta dari course yang sudah dimuat.
///
/// Sumber kebenaran unlock & status memakai entity yang sama dengan tampilan
/// in-course ([CourseEntity.isLessonUnlocked], [LessonEntity]), jadi halaman
/// Penugasan selalu konsisten dengan yang dilihat peserta di dalam materi —
/// tanpa memerlukan endpoint terpisah.
class AssignmentBuilder {
  const AssignmentBuilder._();

  static List<AssignmentTask> fromCourses(List<CourseEntity> courses) {
    final tasks = <AssignmentTask>[];
    for (final course in courses) {
      final all = course.allLessons;
      for (var i = 0; i < all.length; i++) {
        final lesson = all[i];
        if (!_isAssignment(lesson)) continue;
        tasks.add(
          AssignmentTask(
            course: course,
            lesson: lesson,
            lessonIndex: i,
            status: _statusFor(lesson, course.isLessonUnlocked(lesson)),
          ),
        );
      }
    }

    tasks.sort((a, b) => _rank(a.status).compareTo(_rank(b.status)));
    return tasks;
  }

  /// Hanya konten yang butuh acc/penilaian instruktur: essay, studi kasus, dan
  /// dokumen yang mengaktifkan pengumpulan tugas. Kuis (auto-graded) dikecualikan.
  static bool _isAssignment(LessonEntity lesson) {
    switch (lesson.type.toLowerCase()) {
      case 'essay':
      case 'case_study':
        return true;
      case 'document':
        return lesson.collectSubmission;
      default:
        return false;
    }
  }

  static AssignmentStatus _statusFor(LessonEntity lesson, bool unlocked) {
    if (!unlocked) return AssignmentStatus.locked;

    if (lesson.type.toLowerCase() == 'document') {
      switch (lesson.submissionStatus) {
        case 'passed':
          return AssignmentStatus.passed;
        case 'submitted':
          return AssignmentStatus.submitted;
        case 'failed':
          return AssignmentStatus.failed;
        default:
          return AssignmentStatus.todo;
      }
    }

    // essay / studi kasus — belum ada status "menunggu vs dinilai" di sisi
    // klien, jadi cukup: selesai (terkirim) atau belum.
    return lesson.isCompleted ? AssignmentStatus.done : AssignmentStatus.todo;
  }

  /// Urutan tampil: perlu aksi → menunggu → selesai → terkunci.
  static int _rank(AssignmentStatus status) {
    switch (status) {
      case AssignmentStatus.todo:
      case AssignmentStatus.failed:
        return 0;
      case AssignmentStatus.submitted:
        return 1;
      case AssignmentStatus.passed:
      case AssignmentStatus.done:
        return 2;
      case AssignmentStatus.locked:
        return 3;
    }
  }
}
