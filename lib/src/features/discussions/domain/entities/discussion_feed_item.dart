import 'package:equatable/equatable.dart';

/// One row in the discussion hub feed: a topic with its lesson/course context
/// and recent-activity metadata. Tapping it opens the lesson's discussion
/// thread ([contentId] == backend content id).
class DiscussionFeedItem extends Equatable {
  final String id;
  final String title;
  final String snippet;
  final String contentId;
  final String lessonTitle;
  final String courseTitle;
  final String authorName;
  final int repliesCount;
  final DateTime? lastActivityAt;

  const DiscussionFeedItem({
    required this.id,
    required this.title,
    required this.snippet,
    required this.contentId,
    required this.lessonTitle,
    required this.courseTitle,
    required this.authorName,
    required this.repliesCount,
    this.lastActivityAt,
  });

  factory DiscussionFeedItem.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic v) {
      if (v is String && v.isNotEmpty) return DateTime.tryParse(v)?.toLocal();
      return null;
    }

    int asInt(dynamic v) {
      if (v is int) return v;
      if (v is num) return v.toInt();
      return int.tryParse('$v') ?? 0;
    }

    return DiscussionFeedItem(
      id: '${json['id'] ?? ''}',
      title: '${json['title'] ?? '(Tanpa judul)'}',
      snippet: '${json['snippet'] ?? ''}',
      contentId: '${json['contentId'] ?? ''}',
      lessonTitle: '${json['lessonTitle'] ?? ''}',
      courseTitle: '${json['courseTitle'] ?? ''}',
      authorName: '${json['authorName'] ?? 'Pengguna'}',
      repliesCount: asInt(json['repliesCount']),
      lastActivityAt: parseDate(json['lastActivityAt']),
    );
  }

  @override
  List<Object?> get props => [id, repliesCount, lastActivityAt];
}
