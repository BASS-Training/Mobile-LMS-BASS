import 'package:equatable/equatable.dart';
import 'package:lms_mobile_app/src/features/courses/domain/entities/course_entity.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/entities/lesson_entity.dart';

/// Status sebuah tugas dari sudut pandang peserta.
enum AssignmentStatus {
  /// Terbuka tapi belum dikerjakan.
  todo,

  /// Sudah dikumpulkan, menunggu penilaian instruktur (khusus dokumen).
  submitted,

  /// Dinilai belum lulus — peserta perlu memperbaiki & kumpulkan ulang.
  failed,

  /// Dinilai lulus (khusus dokumen wajib-lulus).
  passed,

  /// Sudah dikerjakan/terkirim (essay & studi kasus).
  done,

  /// Materi belum ter-unlock, tugas belum bisa dibuka.
  locked,
}

/// Satu tugas peserta (essay / studi kasus / dokumen) yang diturunkan dari data
/// course yang sudah dimuat — tidak butuh endpoint tersendiri. Menyimpan
/// referensi [course] + indeks lesson agar bisa langsung dibuka seperti dari
/// dalam course.
class AssignmentTask extends Equatable {
  final CourseEntity course;
  final LessonEntity lesson;

  /// Indeks lesson di dalam `course.allLessons` (dipakai untuk navigasi).
  final int lessonIndex;
  final AssignmentStatus status;

  const AssignmentTask({
    required this.course,
    required this.lesson,
    required this.lessonIndex,
    required this.status,
  });

  String get courseTitle => course.title;
  String get type => lesson.type;

  bool get isLocked => status == AssignmentStatus.locked;
  bool get needsAction =>
      status == AssignmentStatus.todo || status == AssignmentStatus.failed;
  bool get isWaiting => status == AssignmentStatus.submitted;
  bool get isDone =>
      status == AssignmentStatus.passed || status == AssignmentStatus.done;

  @override
  List<Object?> get props => [course.id, lesson.id, lessonIndex, status];
}
