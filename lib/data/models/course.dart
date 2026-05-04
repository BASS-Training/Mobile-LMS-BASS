import 'lesson.dart';

class Course {
  final String id;
  final String title;
  final String description;
  final String instructor;
  final String color;
  final String icon;
  final int chaptersCount;
  final String duration;
  final List<Lesson> lessons;
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
    required this.lessons,
    this.isSaved = false,
  });

  int get completedLessons => lessons.where((l) => l.isCompleted).length;
  int get totalLessons => lessons.length;
  double get progressPercentage =>
      totalLessons > 0 ? (completedLessons / totalLessons) * 100 : 0;

  factory Course.fromJson(Map<String, dynamic> json) {
    var lessonsJson = (json['lessons'] ?? []) as List;
    List<Lesson> lessons = lessonsJson.map((l) => Lesson.fromJson(l)).toList();

    return Course(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      instructor: json['instructor'] ?? '',
      color: json['color'] ?? '#6C5CE7',
      icon: json['icon'] ?? '📚',
      chaptersCount: json['chaptersCount'] ?? 1,
      duration: json['duration'] ?? '0 hours',
      lessons: lessons,
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
      'lessons': lessons.map((l) => l.toJson()).toList(),
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
    List<Lesson>? lessons,
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
      lessons: lessons ?? this.lessons,
      isSaved: isSaved ?? this.isSaved,
    );
  }
}
