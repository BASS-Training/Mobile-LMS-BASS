class Lesson {
  final String id;
  final String courseId;
  final String title;
  final String content;
  final String duration;
  final String type; // 'video', 'text', 'quiz', 'essay'
  final String? youtubeVideoId;
  bool isCompleted;

  Lesson({
    required this.id,
    required this.courseId,
    required this.title,
    required this.content,
    required this.duration,
    this.type = 'text',
    this.youtubeVideoId,
    this.isCompleted = false,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    final content = (json['content'] ?? json['body'] ?? '') as String;
    final videoSource =
        json['youtubeVideoId'] ??
        json['youtubeVideoUrl'] ??
        (json['type'] == 'video' ? content : null);

    return Lesson(
      id: json['id'] ?? '',
      courseId: json['courseId'] ?? '',
      title: json['title'] ?? '',
      content: content,
      duration: json['duration'] ?? '0 min',
      type: json['type'] ?? 'text',
      youtubeVideoId: videoSource,
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

  Lesson copyWith({bool? isCompleted, String? type, String? youtubeVideoId}) {
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
