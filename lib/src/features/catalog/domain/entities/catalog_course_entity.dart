import 'package:equatable/equatable.dart';

/// Kursus di etalase ("Jelajahi") — kursus yang BELUM tentu dimiliki user.
///
/// Sengaja dipisah dari [CourseEntity] milik fitur `courses`: entity itu
/// merepresentasikan kursus yang sudah diikuti (punya progres, section, dan
/// konten yang bisa dibuka), sementara ini hanya materi promosi + outline
/// terkunci. Menyatukannya akan memaksa CourseEntity punya banyak field
/// nullable yang tidak bermakna bagi kursus milik sendiri.
///
/// Catatan kebijakan: tidak ada field apa pun yang berkaitan dengan pembelian.
/// Mobile tidak menjual kursus (aturan anti-steering Google Play), jadi [price]
/// murni informatif dan bisa null bila server memilih menyembunyikannya.
class CatalogCourseEntity extends Equatable {
  final String id;
  final String title;
  final String shortDescription;

  /// Deskripsi panjang. Hanya terisi pada detail, kosong di kartu daftar.
  final String description;
  final String instructor;
  final String? thumbnailUrl;
  final int lessonsCount;

  /// Jumlah materi (content) di seluruh kursus. 0 bila belum dimuat detailnya.
  final int totalContents;

  final bool isFree;

  /// Nominal harga. `null` berarti gratis ATAU server sedang menyembunyikan
  /// harga — jangan pernah menyimpulkan "gratis" dari null; pakai [isFree].
  final int? price;

  /// Label siap tampil dari server: "Gratis", "Rp 250.000", atau "Berbayar".
  final String priceLabel;

  /// User sudah terdaftar di kursus ini (mis. hasil pembelian di web).
  final bool isEnrolled;

  /// Outline kurikulum — judul saja, tanpa isi. Kosong di kartu daftar.
  final List<CatalogSectionEntity> sections;

  const CatalogCourseEntity({
    required this.id,
    required this.title,
    this.shortDescription = '',
    this.description = '',
    this.instructor = '',
    this.thumbnailUrl,
    this.lessonsCount = 0,
    this.totalContents = 0,
    this.isFree = true,
    this.price,
    this.priceLabel = '',
    this.isEnrolled = false,
    this.sections = const [],
  });

  CatalogCourseEntity copyWith({bool? isEnrolled}) {
    return CatalogCourseEntity(
      id: id,
      title: title,
      shortDescription: shortDescription,
      description: description,
      instructor: instructor,
      thumbnailUrl: thumbnailUrl,
      lessonsCount: lessonsCount,
      totalContents: totalContents,
      isFree: isFree,
      price: price,
      priceLabel: priceLabel,
      isEnrolled: isEnrolled ?? this.isEnrolled,
      sections: sections,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    shortDescription,
    description,
    instructor,
    thumbnailUrl,
    lessonsCount,
    totalContents,
    isFree,
    price,
    priceLabel,
    isEnrolled,
    sections,
  ];
}

/// Satu bab kurikulum di halaman preview. Hanya judul + daftar judul materi.
class CatalogSectionEntity extends Equatable {
  final String id;
  final int sectionNumber;
  final String title;
  final List<CatalogLessonEntity> lessons;

  const CatalogSectionEntity({
    required this.id,
    required this.sectionNumber,
    required this.title,
    this.lessons = const [],
  });

  @override
  List<Object?> get props => [id, sectionNumber, title, lessons];
}

/// Judul + tipe materi. Sengaja TIDAK memuat body/URL file: isi kursus tidak
/// pernah dikirim server sebelum user benar-benar terdaftar.
class CatalogLessonEntity extends Equatable {
  final String id;
  final String title;
  final String type;

  const CatalogLessonEntity({
    required this.id,
    required this.title,
    required this.type,
  });

  @override
  List<Object?> get props => [id, title, type];
}
