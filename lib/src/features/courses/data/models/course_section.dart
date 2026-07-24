import 'package:lms_mobile_app/src/features/lessons/data/models/lesson.dart';

class CourseSection {
  final String id;
  final String courseId;
  final int sectionNumber;
  final String title;
  final String description;
  final List<Lesson> lessons;

  /// Id section prasyarat (backend: `prerequisite_id`). Section ini tetap
  /// terkunci sampai section ber-id ini diselesaikan. `null` = tanpa prasyarat.
  final String? prerequisiteId;

  /// Bila section ini dijadikan prasyarat section lain, `true` berarti boleh
  /// dilewati (tidak mengunci). Mengikuti `is_optional` di web.
  final bool isOptional;

  CourseSection({
    required this.id,
    required this.courseId,
    required this.sectionNumber,
    required this.title,
    required this.description,
    required this.lessons,
    this.prerequisiteId,
    this.isOptional = false,
  });

  factory CourseSection.fromJson(Map<String, dynamic> json) {
    return CourseSection(
      id: json['id'] ?? '',
      courseId: json['courseId'] ?? '',
      sectionNumber: json['sectionNumber'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      // Nullable & default aman agar cache JSON lama (tanpa field ini) tetap
      // ter-parse tanpa error.
      prerequisiteId: json['prerequisiteId'] as String?,
      isOptional: json['isOptional'] as bool? ?? false,
      lessons:
          (json['lessons'] as List<dynamic>?)
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
      'prerequisiteId': prerequisiteId,
      'isOptional': isOptional,
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
    String? prerequisiteId,
    bool? isOptional,
  }) {
    return CourseSection(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      sectionNumber: sectionNumber ?? this.sectionNumber,
      title: title ?? this.title,
      description: description ?? this.description,
      lessons: lessons ?? this.lessons,
      prerequisiteId: prerequisiteId ?? this.prerequisiteId,
      isOptional: isOptional ?? this.isOptional,
    );
  }
}
