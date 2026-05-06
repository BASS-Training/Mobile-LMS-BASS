import 'lesson.dart';
import 'course_section.dart';

class Course {
  final String id;
  final String title;
  final String description;
  final String instructor;
  final String color;
  final String icon;
  final int chaptersCount;
  final String duration;
  final List<CourseSection> sections;
  bool isSaved;

  Course({
    required this.id,
    required this.title,
    required this.description,
    required this.instructor,
    required this.color,
    required this.icon,
    required this.chaptersCount,
    required this.duration,
    required this.sections,
    this.isSaved = false,
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
      chaptersCount: json['chaptersCount'] ?? 1,
      duration: json['duration'] ?? '0 hours',
      sections: sections,
      isSaved: json['isSaved'] ?? false,
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
      'chaptersCount': chaptersCount,
      'duration': duration,
      'sections': sections.map((s) => s.toJson()).toList(),
      'isSaved': isSaved,
    };
  }

  Course copyWith({
    String? id,
    String? title,
    String? description,
    String? instructor,
    String? color,
    String? icon,
    int? chaptersCount,
    String? duration,
    List<CourseSection>? sections,
    bool? isSaved,
  }) {
    return Course(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      instructor: instructor ?? this.instructor,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      chaptersCount: chaptersCount ?? this.chaptersCount,
      duration: duration ?? this.duration,
      sections: sections ?? this.sections,
      isSaved: isSaved ?? this.isSaved,
    );
  }
}
