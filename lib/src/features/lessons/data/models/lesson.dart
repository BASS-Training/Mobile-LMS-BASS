class Lesson {
  final String id;
  final String courseId;
  final String title;
  final String content;
  final String duration;
  final String type; // 'video', 'text', 'document', 'quiz', 'essay'
  final String? youtubeVideoId;
  final String? documentUrl;
  final List<String> imageUrls;
  bool isCompleted;

  Lesson({
    required this.id,
    required this.courseId,
    required this.title,
    required this.content,
    required this.duration,
    this.type = 'text',
    this.youtubeVideoId,
    this.documentUrl,
    this.imageUrls = const [],
    this.isCompleted = false,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    final content = (json['content'] ?? json['body'] ?? '') as String;
    final videoSource =
        json['youtubeVideoId'] ??
        json['youtubeVideoUrl'] ??
        (json['type'] == 'video' ? content : null);
    final documentUrl =
        json['documentUrl'] ?? json['filePath'] ?? json['file_path'];

    return Lesson(
      id: json['id'] ?? '',
      courseId: json['courseId'] ?? '',
      title: json['title'] ?? '',
      content: content,
      duration: json['duration'] ?? '0 min',
      type: json['type'] ?? 'text',
      youtubeVideoId: videoSource,
      documentUrl: documentUrl,
      isCompleted: json['isCompleted'] ?? false,
      imageUrls: (json['imageUrls'] as List<dynamic>?)
              ?.whereType<String>()
              .where((s) => s.isNotEmpty)
              .toList() ??
          [],
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
      'documentUrl': documentUrl,
      'imageUrls': imageUrls,
      'isCompleted': isCompleted,
    };
  }

  Lesson copyWith({
    bool? isCompleted,
    String? type,
    String? youtubeVideoId,
    String? documentUrl,
    List<String>? imageUrls,
  }) {
    return Lesson(
      id: id,
      courseId: courseId,
      title: title,
      content: content,
      duration: duration,
      type: type ?? this.type,
      youtubeVideoId: youtubeVideoId ?? this.youtubeVideoId,
      documentUrl: documentUrl ?? this.documentUrl,
      imageUrls: imageUrls ?? this.imageUrls,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
