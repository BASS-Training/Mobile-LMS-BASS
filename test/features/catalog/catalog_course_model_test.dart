import 'package:flutter_test/flutter_test.dart';
import 'package:lms_mobile_app/src/features/catalog/data/models/catalog_course_model.dart';
import 'package:lms_mobile_app/src/features/catalog/data/models/catalog_page_model.dart';

void main() {
  group('CatalogCourseModel', () {
    test(
      'detail parses sales profile and instructor without duplicating headline',
      () {
        final entity = CatalogCourseModel.fromJson({
          'id': '12',
          'title': 'Bass Dasar',
          'shortDescription': 'Kuasai bass',
          'description': '<p>Materi bass.</p>',
          'salesProfile': {
            'headline': 'Kuasai bass',
            'level': 'beginner',
            'estimatedDurationMinutes': 510,
            'learningBenefits': 'Ritme\nLagu pertama',
            'faq': [
              {'question': 'Untuk pemula?', 'answer': 'Ya.'},
              {'question': ' ', 'answer': 'kosong'},
            ],
          },
          'instructors': [
            {'id': 7, 'name': 'Guru', 'bioHtml': '<p>Pengajar bass</p>'},
          ],
          'showPrice': true,
        }).toEntity();

        expect(entity.shortDescription, 'Kuasai bass');
        expect(entity.description, '<p>Materi bass.</p>');
        expect(entity.salesProfile?.headline, 'Kuasai bass');
        expect(entity.salesProfile?.levelLabel, 'Pemula');
        expect(entity.salesProfile?.durationLabel, '8 jam 30 menit');
        expect(entity.salesProfile?.faq, hasLength(1));
        expect(entity.instructors.single.name, 'Guru');
        expect(entity.showPrice, isTrue);
      },
    );

    test('nullable sales profile and duration labels stay safe', () {
      final entity = CatalogCourseModel.fromJson({
        'id': '13',
        'title': 'Tanpa profil',
        'salesProfile': null,
      }).toEntity();
      expect(entity.salesProfile, isNull);
      expect(entity.instructors, isEmpty);
      expect(entity.showPrice, isFalse);

      for (final pair in [
        (45, '45 menit'),
        (480, '8 jam'),
        (510, '8 jam 30 menit'),
      ]) {
        final profile = CatalogCourseModel.fromJson({
          'id': '14',
          'salesProfile': {'estimatedDurationMinutes': pair.$1},
        }).toEntity().salesProfile!;
        expect(profile.durationLabel, pair.$2);
      }
    });
    test('memetakan item API (camelCase) menjadi entitas katalog', () {
      final model = CatalogCourseModel.fromJson({
        'id': 'catalog-1',
        'title': 'Bass Fundamental',
        'shortDescription': 'Deskripsi singkat',
        'instructor': 'Instructor',
        'thumbnailUrl': 'https://cdn.example.com/thumb.jpg',
        'lessonsCount': 12,
        'totalContents': 30,
        'isFree': true,
        'isPaid': false,
        'price': 0,
        'priceLabel': 'Gratis',
        'isEnrolled': true,
        'sections': [
          {
            'title': 'Dasar',
            'lessons': [
              {'id': 'lesson-1'},
              {'id': 'lesson-2'},
            ],
          },
        ],
        // Field lama yang sudah tidak dipakai harus diabaikan dengan aman.
        'duration': '4 jam',
        'external_url': 'https://example.com',
      });

      final entity = model.toEntity();

      expect(entity.id, 'catalog-1');
      expect(entity.description, 'Deskripsi singkat');
      expect(entity.instructor, 'Instructor');
      expect(entity.lessonCount, 12);
      expect(entity.totalContents, 30);
      expect(entity.thumbnailUrl, 'https://cdn.example.com/thumb.jpg');
      expect(entity.isFree, isTrue);
      expect(entity.isPaid, isFalse);
      expect(entity.priceLabel, 'Gratis');
      expect(entity.isEnrolled, isTrue);
      expect(entity.sections.single.title, 'Dasar');
      expect(entity.sections.single.lessonCount, 2);
    });

    test('memetakan asset dummy (snake_case) course berbayar', () {
      final model = CatalogCourseModel.fromJson({
        'id': 'catalog-002',
        'title': 'Groove & Timing Essentials',
        'description': 'Latih konsistensi tempo dan pocket.',
        'instructor': 'Bass Training Academy',
        'thumbnail_url': '',
        'duration': '5 jam',
        'lesson_count': 24,
        'access_type': 'external',
        'external_url': 'https://lms.basstrainingacademy.com',
        'sections': [
          {'title': 'Fondasi Timing', 'lesson_count': 6},
        ],
      });

      final entity = model.toEntity();

      expect(entity.id, 'catalog-002');
      expect(entity.description, 'Latih konsistensi tempo dan pocket.');
      expect(entity.lessonCount, 24);
      expect(entity.thumbnailUrl, isNull);
      expect(entity.isFree, isFalse);
      expect(entity.isPaid, isTrue);
      expect(entity.priceLabel, 'Berbayar');
      expect(entity.price, isNull);
      expect(entity.sections.single.lessonCount, 6);
    });

    test('priceLabel default mengikuti status gratis/berbayar', () {
      final free = CatalogCourseModel.fromJson({
        'id': 'free-1',
        'title': 'Gratis Course',
        'access_type': 'free',
      }).toEntity();
      final paid = CatalogCourseModel.fromJson({
        'id': 'paid-1',
        'title': 'Paid Course',
        'access_type': 'external',
      }).toEntity();

      expect(free.priceLabel, 'Gratis');
      expect(paid.priceLabel, 'Berbayar');
    });

    test('withEnrolled menyalin status keanggotaan', () {
      final model = CatalogCourseModel.fromJson({
        'id': 'catalog-1',
        'title': 'Bass Fundamental',
        'access_type': 'free',
      });

      final enrolled = model.withEnrolled(true);

      expect(enrolled.isEnrolled, isTrue);
      expect(enrolled.id, model.id);
      expect(model.isEnrolled, isFalse);
    });
  });

  group('CatalogPage', () {
    test('memetakan envelope list dan meta pagination', () {
      final page = CatalogPage.fromJson({
        'status': 'success',
        'message': 'ok',
        'data': [
          {
            'id': 'catalog-1',
            'title': 'Bass Fundamental',
            'shortDescription': 'Deskripsi',
            'instructor': 'Instructor',
            'isFree': true,
            'isPaid': false,
            'priceLabel': 'Gratis',
            'lessonsCount': 12,
          },
        ],
        'meta': {
          'pagination': {
            'currentPage': 2,
            'lastPage': 5,
            'perPage': 20,
            'total': 96,
            'hasMorePages': true,
          },
          'showPrice': true,
        },
      });

      expect(page.courses, hasLength(1));
      expect(page.currentPage, 2);
      expect(page.lastPage, 5);
      expect(page.perPage, 20);
      expect(page.total, 96);
      expect(page.hasMorePages, isTrue);
      expect(page.showPrice, isTrue);

      final entity = page.toEntity();
      expect(entity.courses.single.id, 'catalog-1');
      expect(entity.currentPage, 2);
      expect(entity.hasMorePages, isTrue);
      expect(entity.showPrice, isTrue);
    });

    test('tanpa meta pagination tetap aman dengan default', () {
      final page = CatalogPage.fromJson({'status': 'success', 'data': []});

      expect(page.courses, isEmpty);
      expect(page.currentPage, 1);
      expect(page.lastPage, 1);
      expect(page.hasMorePages, isFalse);
      expect(page.showPrice, isFalse);
    });
  });
}
