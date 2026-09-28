import 'package:equatable/equatable.dart';

class CatalogSectionEntity extends Equatable {
  final String title;
  final int lessonCount;

  const CatalogSectionEntity({required this.title, required this.lessonCount});

  @override
  List<Object?> get props => [title, lessonCount];
}

class CatalogCourseEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final String instructor;
  final String? thumbnailUrl;
  final String? externalUrl;
  final int lessonCount;
  final bool isFree;
  final bool isPaid;
  final num? price;
  final String priceLabel;
  final List<CatalogSectionEntity> sections;
  final int? totalContents;
  final bool isEnrolled;

  const CatalogCourseEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.instructor,
    required this.lessonCount,
    required this.isFree,
    required this.isPaid,
    required this.priceLabel,
    this.thumbnailUrl,
    this.externalUrl,
    this.price,
    this.sections = const [],
    this.totalContents,
    this.isEnrolled = false,
  });

  CatalogCourseEntity copyWith({
    String? description,
    String? thumbnailUrl,
    String? externalUrl,
    int? lessonCount,
    bool? isFree,
    bool? isPaid,
    num? price,
    String? priceLabel,
    List<CatalogSectionEntity>? sections,
    int? totalContents,
    bool? isEnrolled,
  }) {
    return CatalogCourseEntity(
      id: id,
      title: title,
      description: description ?? this.description,
      instructor: instructor,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      externalUrl: externalUrl ?? this.externalUrl,
      lessonCount: lessonCount ?? this.lessonCount,
      isFree: isFree ?? this.isFree,
      isPaid: isPaid ?? this.isPaid,
      price: price ?? this.price,
      priceLabel: priceLabel ?? this.priceLabel,
      sections: sections ?? this.sections,
      totalContents: totalContents ?? this.totalContents,
      isEnrolled: isEnrolled ?? this.isEnrolled,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    instructor,
    thumbnailUrl,
    externalUrl,
    lessonCount,
    isFree,
    isPaid,
    price,
    priceLabel,
    sections,
    totalContents,
    isEnrolled,
  ];
}
