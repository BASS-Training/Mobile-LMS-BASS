class Lesson {
  final String id;
  final String courseId;
  final String title;
  final String content;
  final String duration;
  final String type; // 'video', 'document', 'quiz'
  final String? youtubeVideoId;
  bool isCompleted;

  Lesson({
    required this.id,
    required this.courseId,
    required this.title,
    required this.content,
    required this.duration,
    this.type = 'document',
    this.youtubeVideoId,
    this.isCompleted = false,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: json['id'] ?? '',
      courseId: json['courseId'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      duration: json['duration'] ?? '0 min',
      type: json['type'] ?? 'document',
      youtubeVideoId: json['youtubeVideoId'],
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
      'type': type,
      'youtubeVideoId': youtubeVideoId,
      'isCompleted': isCompleted,
    };
  }

  Lesson copyWith({
    bool? isCompleted,
    String? type,
    String? youtubeVideoId,
  }) {
    return Lesson(
      id: id,
      courseId: courseId,
      title: title,
      content: content,
      duration: duration,
      type: type ?? this.type,
      youtubeVideoId: youtubeVideoId ?? this.youtubeVideoId,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
