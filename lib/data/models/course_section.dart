import 'package:lms_mobile_app/data/models/lesson.dart';

class CourseSection {
  final String id;
  final String courseId;
  final int sectionNumber;
  final String title;
  final String description;
  final List<Lesson> lessons;

  CourseSection({
    required this.id,
    required this.courseId,
    required this.sectionNumber,
    required this.title,
    required this.description,
    required this.lessons,
  });

  int get completedLessons => lessons.where((l) => l.isCompleted).length;
  int get totalLessons => lessons.length;
  double get progressPercentage =>
      totalLessons == 0 ? 0 : (completedLessons / totalLessons) * 100;
  bool get isFullyCompleted => completedLessons == totalLessons;

  factory CourseSection.fromJson(Map<String, dynamic> json) {
    return CourseSection(
      id: json['id'] ?? '',
      courseId: json['courseId'] ?? '',
      sectionNumber: json['sectionNumber'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      lessons: (json['lessons'] as List<dynamic>?)
              ?.map((l) => Lesson.fromJson(l as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'courseId': courseId,
      'sectionNumber': sectionNumber,
      'title': title,
      'description': description,
      'lessons': lessons.map((l) => l.toJson()).toList(),
    };
  }

  CourseSection copyWith({
    String? id,
    String? courseId,
    int? sectionNumber,
    String? title,
    String? description,
    List<Lesson>? lessons,
  }) {
    return CourseSection(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      sectionNumber: sectionNumber ?? this.sectionNumber,
      title: title ?? this.title,
      description: description ?? this.description,
      lessons: lessons ?? this.lessons,
    );
  }
}
