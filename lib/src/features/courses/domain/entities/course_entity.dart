import 'package:equatable/equatable.dart';
import 'package:lms_mobile_app/src/features/courses/domain/value_objects/progress.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/entities/lesson_entity.dart';
import 'course_section_entity.dart';

class CourseEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final String instructor;
  final String color;
  final String icon;

  /// Optional cover image uploaded on the web (absolute URL), or `null` to use
  /// the default gradient + emoji cover.
  final String? thumbnailUrl;
  final int chaptersCount;
  final String duration;
  final List<CourseSectionEntity> sections;
  final List<LessonEntity> lessons;
  final bool isSaved;

  /// Whether the current user owns / is enrolled in this course.
  ///
  /// Owned courses are fully accessible; unowned ("catalog") courses are shown
  /// as a locked preview that points the learner to purchase on the web.
  /// Defaults to `true` so existing behaviour (the API only returns the user's
  /// own courses) is unchanged until the backend exposes an enrollment flag.
  final bool isOwned;

  const CourseEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.instructor,
    required this.color,
    required this.icon,
    this.thumbnailUrl,
    required this.chaptersCount,
    required this.duration,
    required this.sections,
    required this.lessons,
    this.isSaved = false,
    this.isOwned = true,
  });

  List<LessonEntity> get allLessons => sections.isNotEmpty
      ? sections.expand((section) => section.lessons).toList()
      : lessons;

  /// Get progress value object (source of truth untuk progress calculation)
  Progress get progress {
    final completedCount = allLessons
        .where((lesson) => lesson.isCompleted)
        .length;
    final totalCount = allLessons.length;
    return Progress.create(
      completedCount: completedCount,
      totalCount: totalCount,
    );
  }

  /// Convenience getters untuk backward compatibility
  int get completedLessons => progress.completedCount;
  int get totalLessons => progress.totalCount;
  double get progressPercentage => progress.percentage;

  /// Logika Bisnis: Menentukan apakah materi terbuka atau terkunci.
  ///
  /// Meniru aturan web (`ContentController::getUnlockedContents`) yang terdiri
  /// dari dua gerbang berlapis:
  /// 1. **Berurutan** — sebuah materi terbuka hanya bila materi tepat sebelumnya
  ///    sudah selesai.
  /// 2. **Prasyarat antar-section** — bila section pemilik materi ini punya
  ///    prasyarat (di-set admin di web), section ini terkunci sampai section
  ///    prasyarat tersebut selesai; kecuali section prasyaratnya opsional.
  ///
  /// Dulu mobile hanya menegakkan gerbang (1), sehingga prasyarat non-berurutan
  /// (mis. lesson 5 wajib lesson 2, bukan 4) diabaikan dan tidak konsisten
  /// dengan web. Sekarang keduanya ditegakkan.
  bool isLessonUnlocked(LessonEntity lesson) {
    final lessonIndex = allLessons.indexOf(lesson);

    // Materi pertama di seluruh course selalu terbuka (samakan dengan web yang
    // selalu membuka indeks 0 — mencegah seluruh course terkunci).
    if (lessonIndex <= 0) return true;

    // Gerbang 1 — berurutan: materi sebelumnya harus selesai.
    final previousLesson = allLessons[lessonIndex - 1];
    if (!previousLesson.isCompleted) return false;

    // Gerbang 2 — prasyarat antar-section.
    return _isSectionPrerequisiteMet(lesson);
  }

  /// Apakah prasyarat section pemilik [lesson] sudah terpenuhi.
  ///
  /// Mengembalikan `true` (tidak mengunci) bila: section tak punya prasyarat,
  /// section prasyaratnya tak ditemukan (data tak lengkap — jangan mengunci
  /// karena data), atau prasyaratnya ditandai opsional. Selain itu, terpenuhi
  /// hanya bila seluruh materi di section prasyarat sudah selesai.
  bool _isSectionPrerequisiteMet(LessonEntity lesson) {
    // Struktur flat lama (tanpa sections) tidak mengenal prasyarat.
    if (sections.isEmpty) return true;

    // Cari section pemilik lesson ini.
    CourseSectionEntity? owner;
    for (final section in sections) {
      if (section.lessons.any((l) => l.id == lesson.id)) {
        owner = section;
        break;
      }
    }

    final prerequisiteId = owner?.prerequisiteId;
    if (prerequisiteId == null) return true;

    // Temukan section prasyaratnya.
    CourseSectionEntity? prerequisite;
    for (final section in sections) {
      if (section.id == prerequisiteId) {
        prerequisite = section;
        break;
      }
    }

    if (prerequisite == null || prerequisite.isOptional) return true;

    // Section prasyarat tanpa materi dianggap terpenuhi (selesai secara vacuous,
    // sesuai perilaku web) — mencegah kuncian permanen bila admin men-set
    // prasyarat ke section yang belum diisi.
    if (prerequisite.lessons.isEmpty) return true;

    return prerequisite.isFullyCompleted;
  }

  CourseEntity copyWith({bool? isSaved, bool? isOwned}) {
    return CourseEntity(
      id: id,
      title: title,
      description: description,
      instructor: instructor,
      color: color,
      icon: icon,
      thumbnailUrl: thumbnailUrl,
      chaptersCount: chaptersCount,
      duration: duration,
      sections: sections,
      lessons: lessons,
      isSaved: isSaved ?? this.isSaved,
      isOwned: isOwned ?? this.isOwned,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    instructor,
    color,
    icon,
    thumbnailUrl,
    chaptersCount,
    duration,
    sections,
    lessons,
    isSaved,
    isOwned,
  ];
}
