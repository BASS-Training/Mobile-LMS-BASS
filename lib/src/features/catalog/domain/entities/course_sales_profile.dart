import 'package:equatable/equatable.dart';

class CourseSalesFaq extends Equatable {
  const CourseSalesFaq({required this.question, required this.answer});

  final String question;
  final String answer;

  @override
  List<Object?> get props => [question, answer];
}

class CourseSalesProfile extends Equatable {
  const CourseSalesProfile({
    this.headline,
    this.targetAudience,
    this.learningBenefits,
    this.requirements,
    this.level,
    this.estimatedDurationMinutes,
    this.language,
    this.promoVideoUrl,
    this.faq = const [],
  });

  final String? headline;
  final String? targetAudience;
  final String? learningBenefits;
  final String? requirements;
  final String? level;
  final int? estimatedDurationMinutes;
  final String? language;
  final String? promoVideoUrl;
  final List<CourseSalesFaq> faq;

  String? get levelLabel => switch (level) {
    'beginner' => 'Pemula',
    'intermediate' => 'Menengah',
    'advanced' => 'Mahir',
    'all_levels' => 'Semua Level',
    _ => level,
  };

  String? get durationLabel {
    final minutes = estimatedDurationMinutes;
    if (minutes == null || minutes <= 0) return null;
    final hours = minutes ~/ 60;
    final rest = minutes % 60;
    return [if (hours > 0) '$hours jam', if (rest > 0) '$rest menit'].join(' ');
  }

  @override
  List<Object?> get props => [
    headline,
    targetAudience,
    learningBenefits,
    requirements,
    level,
    estimatedDurationMinutes,
    language,
    promoVideoUrl,
    faq,
  ];
}

class CatalogInstructor extends Equatable {
  const CatalogInstructor({
    required this.id,
    required this.name,
    this.avatarUrl,
    this.bioHtml,
  });

  final String id;
  final String name;
  final String? avatarUrl;
  final String? bioHtml;

  @override
  List<Object?> get props => [id, name, avatarUrl, bioHtml];
}
