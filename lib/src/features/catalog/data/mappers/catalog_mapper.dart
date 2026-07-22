import '../../domain/entities/catalog_course_entity.dart';
import '../models/catalog_course_model.dart';

/// Model (DTO) → Entity. Domain tidak boleh tahu bentuk JSON-nya.
class CatalogMapper {
  const CatalogMapper._();

  static CatalogCourseEntity toEntity(CatalogCourseModel model) {
    return CatalogCourseEntity(
      id: model.id,
      title: model.title,
      shortDescription: model.shortDescription,
      description: model.description,
      instructor: model.instructor,
      thumbnailUrl: model.thumbnailUrl,
      lessonsCount: model.lessonsCount,
      totalContents: model.totalContents,
      isFree: model.isFree,
      price: model.price,
      priceLabel: model.priceLabel,
      isEnrolled: model.isEnrolled,
      sections: model.sections.map(_sectionToEntity).toList(),
    );
  }

  static CatalogSectionEntity _sectionToEntity(CatalogSectionModel model) {
    return CatalogSectionEntity(
      id: model.id,
      sectionNumber: model.sectionNumber,
      title: model.title,
      lessons: model.lessons
          .map(
            (lesson) => CatalogLessonEntity(
              id: lesson.id,
              title: lesson.title,
              type: lesson.type,
            ),
          )
          .toList(),
    );
  }
}
