

import 'package:lms_mobile_app/src/features/lessons/data/models/lesson.dart';

import 'course_section.dart';

class Course {
  final String id;
  final String title;
  final String description;
  final String instructor;
  final String color;
  final String icon;

  /// Optional cover image uploaded on the web. When present, the card and
  /// detail header show it instead of the default gradient + emoji cover.
  final String? thumbnailUrl;
  final int chaptersCount;
  final String duration;
  final List<CourseSection> sections;
  bool isSaved;

  /// Whether the authenticated user is enrolled in / owns this course.
  final bool isOwned;

  Course({
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
    this.isSaved = false,
    this.isOwned = true,
  });

  // Convenience getter for all lessons (flatten from sections)
  List<Lesson> get lessons {
    return sections.expand((s) => s.lessons).toList();
  }

  factory Course.fromJson(Map<String, dynamic> json) {
    var sectionsJson = (json['sections'] ?? []) as List;
    List<CourseSection> sections = sectionsJson
        .map((s) => CourseSection.fromJson(s as Map<String, dynamic>))
        .toList();

    return Course(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      instructor: json['instructor'] ?? '',
      color: json['color'] ?? '#6C5CE7',
      icon: json['icon'] ?? '📚',
      // API kirim camelCase `thumbnailUrl`; snake_case dijaga untuk kompatibilitas.
      // String kosong diperlakukan sebagai null agar tidak mencoba memuat URL kosong.
      thumbnailUrl: () {
        final raw = json['thumbnailUrl'] ?? json['thumbnail_url'] ?? json['thumbnail'];
        if (raw is String && raw.trim().isNotEmpty) return raw;
        return null;
      }(),
      chaptersCount: json['chaptersCount'] ?? 1,
      duration: json['duration'] ?? '0 hours',
      sections: sections,
      // API mengirim `is_saved` (snake_case); `isSaved` dipertahankan untuk cache lokal.
      isSaved: json['is_saved'] ?? json['isSaved'] ?? false,
      // Backend may expose enrollment via `is_enrolled` or `is_owned`.
      // Absent => assume owned (current API only returns the user's courses).
      isOwned: json['is_enrolled'] ?? json['is_owned'] ?? json['isOwned'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'instructor': instructor,
      'color': color,
      'icon': icon,
      'thumbnailUrl': thumbnailUrl,
      'chaptersCount': chaptersCount,
      'duration': duration,
      'sections': sections.map((s) => s.toJson()).toList(),
      'isSaved': isSaved,
      'isOwned': isOwned,
    };
  }

  Course copyWith({
    String? id,
    String? title,
    String? description,
    String? instructor,
    String? color,
    String? icon,
    String? thumbnailUrl,
    int? chaptersCount,
    String? duration,
    List<CourseSection>? sections,
    bool? isSaved,
    bool? isOwned,
  }) {
    return Course(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      instructor: instructor ?? this.instructor,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      chaptersCount: chaptersCount ?? this.chaptersCount,
      duration: duration ?? this.duration,
      sections: sections ?? this.sections,
      isSaved: isSaved ?? this.isSaved,
      isOwned: isOwned ?? this.isOwned,
    );
  }
}
