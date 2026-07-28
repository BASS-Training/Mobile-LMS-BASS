import 'package:equatable/equatable.dart';

/// A lesson (backend Content) reference in the discussion hub's context
/// selector, with how many discussions it currently has.
class DiscussionLessonRef extends Equatable {
  final String contentId;
  final String lessonTitle;
  final String type;
  final int discussionCount;

  const DiscussionLessonRef({
    required this.contentId,
    required this.lessonTitle,
    required this.type,
    required this.discussionCount,
  });

  factory DiscussionLessonRef.fromJson(Map<String, dynamic> json) {
    int asInt(dynamic v) {
      if (v is int) return v;
      if (v is num) return v.toInt();
      return int.tryParse('$v') ?? 0;
    }

    return DiscussionLessonRef(
      contentId: '${json['contentId'] ?? ''}',
      lessonTitle: '${json['lessonTitle'] ?? 'Materi'}',
      type: '${json['type'] ?? ''}',
      discussionCount: asInt(json['discussionCount']),
    );
  }

  @override
  List<Object?> get props => [contentId, lessonTitle, type, discussionCount];
}

/// A course with its lessons, powering the hub's course dropdown + lesson chips.
class DiscussionCourseGroup extends Equatable {
  final String courseId;
  final String courseTitle;

  /// ISO-8601 tanggal dibuatnya kelas — untuk urutkan Terbaru/Terlama. Bisa null
  /// bila backend belum mengirimnya (fallback ke urutan courseId).
  final String? createdAt;
  final List<DiscussionLessonRef> lessons;

  const DiscussionCourseGroup({
    required this.courseId,
    required this.courseTitle,
    required this.lessons,
    this.createdAt,
  });

  factory DiscussionCourseGroup.fromJson(Map<String, dynamic> json) {
    final rawLessons = json['lessons'];
    final lessons = (rawLessons is List)
        ? rawLessons
              .whereType<Map>()
              .map((e) => DiscussionLessonRef.fromJson(Map<String, dynamic>.from(e)))
              .toList()
        : <DiscussionLessonRef>[];

    return DiscussionCourseGroup(
      courseId: '${json['courseId'] ?? ''}',
      courseTitle: '${json['courseTitle'] ?? 'Kelas'}',
      createdAt: json['createdAt']?.toString(),
      lessons: lessons,
    );
  }

  @override
  List<Object?> get props => [courseId, courseTitle, createdAt, lessons];
}
