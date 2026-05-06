import 'package:equatable/equatable.dart';

/// Value Object untuk merepresentasikan tipe lesson
/// Memberikan type safety untuk lesson types
class LessonType extends Equatable {
  static const String videoType = 'video';
  static const String documentType = 'document';
  static const String quizType = 'quiz';

  static const List<String> validTypes = [videoType, documentType, quizType];

  final String value;

  const LessonType._(this.value);

  /// Factory untuk create dari string dengan validasi
  factory LessonType.create(String value) {
    final normalizedValue = value.toLowerCase().trim();

    if (!validTypes.contains(normalizedValue)) {
      throw ArgumentError(
        'Invalid lesson type: $normalizedValue. Must be one of: $validTypes',
      );
    }

    return LessonType._(normalizedValue);
  }

  /// Named constructors untuk readability
  factory LessonType.video() => const LessonType._(videoType);
  factory LessonType.document() => const LessonType._(documentType);
  factory LessonType.quiz() => const LessonType._(quizType);

  /// Default lesson type
  factory LessonType.defaultType() => const LessonType._(documentType);

  /// Check methods untuk readability
  bool get isVideo => value == videoType;
  bool get isDocument => value == documentType;
  bool get isQuiz => value == quizType;

  /// Get icon representation
  String get icon {
    return switch (value) {
      videoType => '🎬',
      quizType => '❓',
      _ => '📄',
    };
  }

  /// Get display label
  String get label {
    return switch (value) {
      videoType => 'Video',
      quizType => 'Quiz',
      _ => 'Document',
    };
  }

  @override
  List<Object?> get props => [value];

  @override
  String toString() => value;
}
