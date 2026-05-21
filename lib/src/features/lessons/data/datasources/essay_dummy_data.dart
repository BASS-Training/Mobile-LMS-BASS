import 'package:lms_mobile_app/src/features/lessons/domain/entities/essay_question_entity.dart';

class EssayDummyData {
  const EssayDummyData._();

  static List<EssayQuestionEntity> getQuestions(String lessonId) {
    final questions = _questionsByLessonId[lessonId];
    if (questions != null && questions.length >= 5) {
      return questions
          .asMap()
          .entries
          .map(
            (entry) => EssayQuestionEntity(
              id: 'local_${lessonId}_${entry.key + 1}',
              text: entry.value,
              order: entry.key + 1,
              maxScore: 1,
            ),
          )
          .toList();
    }

    const fallbackQuestions = [
      'Jelaskan pemahaman Anda terhadap materi pada lesson ini.',
      'Apa poin terpenting yang bisa Anda terapkan dari materi tersebut?',
      'Berikan satu contoh penerapan dalam situasi nyata.',
      'Apa tantangan yang mungkin muncul saat menerapkannya?',
      'Tuliskan kesimpulan singkat dari jawaban Anda.',
    ];

    return fallbackQuestions
        .asMap()
        .entries
        .map(
          (entry) => EssayQuestionEntity(
            id: 'local_${lessonId}_${entry.key + 1}',
            text: entry.value,
            order: entry.key + 1,
            maxScore: 1,
          ),
        )
        .toList();
  }

  static const Map<String, List<String>> _questionsByLessonId = {
    '1-4-4': [
      'Refleksikan satu situasi nyata di dunia kerja akuntansi yang menurut Anda rawan konflik etika.',
      'Jelaskan risiko profesional dan hukum yang mungkin terjadi pada kasus tersebut.',
      'Siapa saja pihak yang terdampak? Jelaskan dampak untuk minimal dua pihak.',
      'Keputusan apa yang paling bertanggung jawab menurut Anda? Jelaskan alasannya.',
      'Jika Anda menjadi pimpinan tim, kebijakan pencegahan apa yang akan Anda terapkan?',
    ],
    '2-4-6': [
      'Tuliskan satu masalah utama pertanian di wilayah Anda yang berkaitan dengan keberlanjutan.',
      'Jelaskan rencana praktik pertanian berkelanjutan yang paling realistis untuk masalah tersebut.',
      'Sumber daya apa yang dibutuhkan agar rencana itu bisa dijalankan?',
      'Apa tantangan implementasi terbesar dan bagaimana strategi mengatasinya?',
      'Indikator keberhasilan apa yang bisa dipakai untuk menilai hasil rencana Anda?',
    ],
    '3-4-5': [
      'Pilih satu kebijakan ekonomi publik yang Anda ketahui dan jelaskan konteksnya.',
      'Apa manfaat utama kebijakan tersebut bagi masyarakat?',
      'Apa dampak negatif yang mungkin muncul jika kebijakan diterapkan jangka panjang?',
      'Menurut Anda, kelompok masyarakat mana yang paling diuntungkan dan paling dirugikan?',
      'Berikan rekomendasi perbaikan kebijakan agar dampaknya lebih adil.',
    ],
    '4-4-6': [
      'Sebutkan satu keputusan desain paling penting yang Anda ambil pada proyek Anda.',
      'Jelaskan alasan visual di balik keputusan desain tersebut.',
      'Bagaimana keputusan desain itu menjawab kebutuhan target pengguna?',
      'Trade-off apa yang Anda hadapi saat memilih keputusan itu?',
      'Jika diberi kesempatan revisi, bagian mana yang akan Anda optimalkan dan kenapa?',
    ],
    '5-4-6': [
      'Identifikasi satu masalah konservasi keanekaragaman hayati di wilayah Anda.',
      'Jelaskan strategi konservasi yang paling memungkinkan untuk diterapkan.',
      'Pihak mana yang perlu dilibatkan agar strategi bisa berjalan efektif?',
      'Apa hambatan utama di lapangan dan bagaimana mitigasinya?',
      'Bagaimana cara mengukur keberhasilan strategi konservasi tersebut?',
    ],
    '6-4-5': [
      'Tuliskan satu keputusan hidup yang pernah Anda ambil dan konteksnya.',
      'Analisis keputusan tersebut dengan pendekatan etika (misal utilitarian/deontologi/virtue).',
      'Bagaimana logika berpikir Anda saat menimbang alternatif keputusan?',
      'Apa konsekuensi dari keputusan itu bagi diri Anda dan orang lain?',
      'Jika mengulang situasi yang sama, apakah Anda akan mengambil keputusan yang sama? Jelaskan.',
    ],
  };
}
