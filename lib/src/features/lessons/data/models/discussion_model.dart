import '../../domain/entities/discussion_entity.dart';

/// Data models for the discussion API. Parse the backend JSON and convert to
/// domain entities (the relative time label is computed here so widgets stay
/// presentation-only).
class DiscussionReplyModel {
  final String id;
  final String body;
  final String authorId;
  final String authorName;
  final String? createdAt;

  const DiscussionReplyModel({
    required this.id,
    required this.body,
    required this.authorId,
    required this.authorName,
    this.createdAt,
  });

  factory DiscussionReplyModel.fromJson(Map<String, dynamic> json) {
    return DiscussionReplyModel(
      id: json['id']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      authorId: json['authorId']?.toString() ?? '',
      authorName: json['authorName']?.toString() ?? 'Pengguna',
      createdAt: json['createdAt']?.toString(),
    );
  }

  DiscussionReplyEntity toEntity() {
    return DiscussionReplyEntity(
      id: id,
      body: body,
      authorId: authorId,
      authorName: authorName,
      createdAtLabel: relativeTime(createdAt),
    );
  }
}

class DiscussionModel {
  final String id;
  final String title;
  final String body;
  final String authorId;
  final String authorName;
  final String? createdAt;
  final List<DiscussionReplyModel> replies;

  const DiscussionModel({
    required this.id,
    required this.title,
    required this.body,
    required this.authorId,
    required this.authorName,
    this.createdAt,
    this.replies = const [],
  });

  factory DiscussionModel.fromJson(Map<String, dynamic> json) {
    final rawReplies = json['replies'];
    return DiscussionModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      authorId: json['authorId']?.toString() ?? '',
      authorName: json['authorName']?.toString() ?? 'Pengguna',
      createdAt: json['createdAt']?.toString(),
      replies: rawReplies is List
          ? rawReplies
                .whereType<Map<String, dynamic>>()
                .map(DiscussionReplyModel.fromJson)
                .toList()
          : const [],
    );
  }

  DiscussionEntity toEntity() {
    return DiscussionEntity(
      id: id,
      title: title,
      body: body,
      authorId: authorId,
      authorName: authorName,
      createdAtLabel: relativeTime(createdAt),
      replies: replies.map((r) => r.toEntity()).toList(),
    );
  }
}

/// Human-friendly relative time (Indonesian) from an ISO-8601 timestamp.
String relativeTime(String? iso) {
  if (iso == null || iso.isEmpty) return '';
  final time = DateTime.tryParse(iso)?.toLocal();
  if (time == null) return '';

  final diff = DateTime.now().difference(time);
  if (diff.inSeconds < 60) return 'Baru saja';
  if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
  if (diff.inHours < 24) return '${diff.inHours} jam lalu';
  if (diff.inDays < 7) return '${diff.inDays} hari lalu';

  final d = time.day.toString().padLeft(2, '0');
  final m = time.month.toString().padLeft(2, '0');
  return '$d/$m/${time.year}';
}
