import 'package:equatable/equatable.dart';

/// Value Object untuk merepresentasikan progress pembelajaran
/// Consolidate semua logic hitung progress di satu tempat
class Progress extends Equatable {
  final int completedCount;
  final int totalCount;

  const Progress({required this.completedCount, required this.totalCount});

  /// Persentase progress (0-100)
  double get percentage =>
      totalCount > 0 ? (completedCount / totalCount) * 100 : 0;

  /// Apakah semua item sudah completed
  bool get isFullyCompleted => completedCount == totalCount && totalCount > 0;

  /// Apakah ada yang sudah dimulai (partially completed)
  bool get isPartiallyCompleted => completedCount > 0 && !isFullyCompleted;

  /// Apakah belum ada yang completed
  bool get isNotStarted => completedCount == 0;

  /// Factory constructor untuk validasi
  factory Progress.create({
    required int completedCount,
    required int totalCount,
  }) {
    // Validasi
    if (completedCount < 0) {
      throw ArgumentError('completedCount tidak boleh negatif');
    }
    if (totalCount < 0) {
      throw ArgumentError('totalCount tidak boleh negatif');
    }
    if (completedCount > totalCount) {
      throw ArgumentError('completedCount tidak boleh lebih dari totalCount');
    }

    return Progress(completedCount: completedCount, totalCount: totalCount);
  }

  /// Copy with override values
  Progress copyWith({int? completedCount, int? totalCount}) {
    return Progress.create(
      completedCount: completedCount ?? this.completedCount,
      totalCount: totalCount ?? this.totalCount,
    );
  }

  @override
  List<Object?> get props => [completedCount, totalCount];
}
