class DocumentSectionEntity {
  final String title;
  final List<String> paragraphs;
  final List<String> bullets;

  DocumentSectionEntity({
    required this.title,
    required this.paragraphs,
    required this.bullets,
  });

  /// Generate UI-friendly dummy sections. UI should call this instead of
  /// constructing dummy data itself.
  static List<DocumentSectionEntity> generateDummy(String content) {
    return [
      DocumentSectionEntity(
        title: 'Ringkasan Materi',
        paragraphs: [
          content.isNotEmpty
              ? content
              : 'Materi utama akan diambil dari backend. Untuk sementara, ini adalah teks dummy yang menjelaskan isi pembelajaran secara rapi dan terstruktur.',
          'Bagian ini menjelaskan konsep inti pembelajaran secara singkat agar mudah dipahami sebelum masuk ke poin yang lebih detail.',
        ],
        bullets: const [],
      ),
      DocumentSectionEntity(
        title: 'Poin Penting',
        paragraphs: const [],
        bullets: const [
          'Pahami definisi dasar dan tujuan materi.',
          'Perhatikan alur penjelasan dari awal sampai akhir.',
          'Catat istilah penting yang muncul di dalam materi.',
        ],
      ),
      DocumentSectionEntity(
        title: 'Kesimpulan',
        paragraphs: const [
          'Setelah membaca materi ini, diharapkan Anda sudah memahami inti pembahasan dan siap lanjut ke lesson berikutnya.',
          'Jika ada yang belum jelas, gunakan ruang diskusi pada lesson video atau diskusi terpisah di backend nanti.',
        ],
        bullets: const [],
      ),
    ];
  }
}
