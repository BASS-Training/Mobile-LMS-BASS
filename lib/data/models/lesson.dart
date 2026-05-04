class Lesson {
  final String id;
  final String courseId;
  final String title;
  final String content;
  final String duration;
  bool isCompleted;

  Lesson({
    required this.id,
    required this.courseId,
    required this.title,
    required this.content,
    required this.duration,
    this.isCompleted = false,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: json['id'] ?? '',
      courseId: json['courseId'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      duration: json['duration'] ?? '0 min',
      isCompleted: json['isCompleted'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'courseId': courseId,
      'title': title,
      'content': content,
      'duration': duration,
      'isCompleted': isCompleted,
    };
  }

  Lesson copyWith({bool? isCompleted}) {
    return Lesson(
      id: id,
      courseId: courseId,
      title: title,
      content: content,
      duration: duration,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
