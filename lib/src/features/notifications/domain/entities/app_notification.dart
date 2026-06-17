import 'package:equatable/equatable.dart';

/// A single item in the unified notification feed. Backed by either a Laravel
/// database notification (`source == 'notification'`) or a web announcement
/// (`source == 'announcement'`), merged server-side.
class AppNotification extends Equatable {
  final String id;
  final String source; // 'notification' | 'announcement'
  final String category; // discussion_reply | grade | new_content | announcement
  final String title;
  final String message;
  final String? courseTitle;
  final String? contentId;
  final String? lessonTitle;
  final String? discussionId;
  final bool isRead;
  final DateTime? createdAt;

  const AppNotification({
    required this.id,
    required this.source,
    required this.category,
    required this.title,
    required this.message,
    this.courseTitle,
    this.contentId,
    this.lessonTitle,
    this.discussionId,
    this.isRead = false,
    this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic v) {
      if (v is String && v.isNotEmpty) return DateTime.tryParse(v)?.toLocal();
      return null;
    }

    return AppNotification(
      id: '${json['id'] ?? ''}',
      source: '${json['source'] ?? 'notification'}',
      category: '${json['category'] ?? 'info'}',
      title: '${json['title'] ?? 'Notifikasi'}',
      message: '${json['message'] ?? ''}',
      courseTitle: json['courseTitle'] as String?,
      contentId: json['contentId'] as String?,
      lessonTitle: json['lessonTitle'] as String?,
      discussionId: json['discussionId'] as String?,
      isRead: json['isRead'] == true,
      createdAt: parseDate(json['createdAt']),
    );
  }

  AppNotification copyWith({bool? isRead}) => AppNotification(
    id: id,
    source: source,
    category: category,
    title: title,
    message: message,
    courseTitle: courseTitle,
    contentId: contentId,
    lessonTitle: lessonTitle,
    discussionId: discussionId,
    isRead: isRead ?? this.isRead,
    createdAt: createdAt,
  );

  @override
  List<Object?> get props => [id, source, category, isRead];
}
