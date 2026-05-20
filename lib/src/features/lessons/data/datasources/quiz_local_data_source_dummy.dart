import 'package:lms_mobile_app/src/features/lessons/data/models/quiz_model.dart';

class QuizLocalDataSourceDummy {
  Quiz getQuizByLessonId(String lessonId) {
    switch (lessonId) {
      // Accounting Course Quizzes
      case '1-1-3': // Introduction Quiz
        return _getAccountingIntroQuiz();
      case '1-2-4': // Double Entry Quiz
        return _getAccountingDoubleEntryQuiz();
      case '1-3-5': // Statements Quiz
        return _getAccountingStatementsQuiz();
      case '1-4-3': // Final Review Quiz
        return _getAccountingFinalQuiz();

      // Agriculture Course Quizzes
      case '2-2-4': // Soil Quiz
        return _getAgricultureSoilQuiz();
      case '2-3-5': // Crop Production Quiz
        return _getAgricultureCropQuiz();
      case '2-4-5': // Advanced Agriculture Quiz
        return _getAgricultureAdvancedQuiz();

      // Economics Course Quizzes
      case '3-2-4': // Microeconomics Quiz
        return _getEconomicsMicroQuiz();
      case '3-3-4': // Macroeconomics Quiz
        return _getEconomicsMacroQuiz();
      case '3-4-4': // Global Economy Quiz
        return _getEconomicsGlobalQuiz();

      // Art & Design Course Quizzes
      case '4-2-4': // Principles Quiz
        return _getDesignPrinciplesQuiz();
      case '4-3-5': // Digital Design Quiz
        return _getDesignDigitalQuiz();

      // Biology Course Quizzes
      case '5-2-5': // Cellular Biology Quiz
        return _getBiologyCellularQuiz();
      case '5-3-5': // Genetics & Evolution Quiz
        return _getBiologyGeneticsQuiz();
      case '5-4-5': // Biosphere Quiz
        return _getBiologyBiosphereQuiz();

      default:
        return _getDefaultQuiz();
    }
  }

  // ============= ACCOUNTING QUIZZES =============
  static Quiz _getAccountingIntroQuiz() {
    return Quiz(
      title: 'Introduction to Accounting',
      totalQuestions: 10,
      timeLimit: 30,
      passingScore: 70,
      questions: [
        Question(
          text: 'Apa definisi akuntansi?',
          options: [
            'Proses mencatat transaksi keuangan',
            'Seni membuat keputusan bisnis',
            'Ilmu mengatur keuangan pribadi',
            'Teknik investasi saham',
          ],
          correctIndex: 0,
        ),
        Question(
          text: 'Siapa pengguna utama laporan keuangan?',
          options: ['Pengusaha', 'Investor', 'Kreditor', 'Semua jawaban benar'],
          correctIndex: 3,
        ),
        Question(
          text: 'Periode akuntansi standar adalah?',
          options: ['Triwulan', 'Semester', 'Tahun kalender', 'Dua tahun'],
          correctIndex: 2,
        ),
        Question(
          text: 'Akun mana yang termasuk aset?',
          options: ['Piutang', 'Hutang', 'Modal', 'Pendapatan'],
          correctIndex: 0,
        ),
        Question(
          text: 'Apa tujuan utama akuntansi?',
          options: [
            'Mengumpulkan uang',
            'Menyediakan informasi keuangan',
            'Menghindari pajak',
            'Meningkatkan penjualan',
          ],
          correctIndex: 1,
        ),
        Question(
          text: 'Standar akuntansi internasional adalah?',
          options: ['GAAP', 'IFRS', 'PSAK', 'SAK'],
          correctIndex: 1,
        ),
        Question(
          text: 'Siapa yang bertanggung jawab atas akurasi laporan keuangan?',
          options: ['Akuntan', 'Auditor', 'Manajemen', 'Pemegang saham'],
          correctIndex: 2,
        ),
        Question(
          text: 'Dokumen sumber dalam akuntansi adalah?',
          options: ['Jurnal', 'Faktur', 'Buku besar', 'Trial balance'],
          correctIndex: 1,
        ),
        Question(
          text: 'Cabang akuntansi yang mencatat transaksi harian adalah?',
          options: [
            'Akuntansi biaya',
            'Akuntansi keuangan',
            'Akuntansi manajemen',
            'Akuntansi pajak',
          ],
          correctIndex: 1,
        ),
        Question(
          text: 'Persamaan dasar akuntansi adalah?',
          options: [
            'Aset = Hutang + Modal',
            'Aset + Hutang = Modal',
            'Hutang = Aset - Modal',
            'Modal = Aset - Hutang',
          ],
          correctIndex: 0,
        ),
      ],
    );
  }

  static Quiz _getAccountingDoubleEntryQuiz() {
    return Quiz(
      title: 'Double Entry System',
      totalQuestions: 10,
      timeLimit: 30,
      passingScore: 70,
      questions: [
        Question(
          text: 'Dalam sistem double entry, setiap transaksi mencatat?',
          options: ['Satu akun', 'Dua akun', 'Tiga akun', 'Empat akun'],
          correctIndex: 1,
        ),
        Question(
          text: 'Debit aset berarti?',
          options: [
            'Mengurangi aset',
            'Menambah aset',
            'Aset tetap sama',
            'Aset menjadi negatif',
          ],
          correctIndex: 1,
        ),
        Question(
          text: 'Kredit hutang berarti?',
          options: [
            'Menambah hutang',
            'Mengurangi hutang',
            'Hutang tetap sama',
            'Hutang dihapus',
          ],
          correctIndex: 0,
        ),
        Question(
          text: 'Jurnal adalah?',
          options: [
            'Catatan transaksi harian',
            'Ringkasan akun',
            'Laporan akhir tahun',
            'Buku pembantu',
          ],
          correctIndex: 0,
        ),
        Question(
          text: 'Buku besar adalah?',
          options: [
            'Kumpulan akun individual',
            'Catatan transaksi',
            'Laporan keuangan',
            'Dokumen sumber',
          ],
          correctIndex: 0,
        ),
        Question(
          text: 'Posting adalah?',
          options: [
            'Pencatatan jurnal',
            'Transfer ke buku besar',
            'Pemeriksaan akun',
            'Penyusunan laporan',
          ],
          correctIndex: 1,
        ),
        Question(
          text: 'Trial balance dibuat untuk?',
          options: [
            'Menemukan kesalahan',
            'Menutup buku',
            'Menyiapkan laporan',
            'Keseimbangan debit-kredit',
          ],
          correctIndex: 3,
        ),
        Question(
          text: 'Saldo normal akun aset adalah?',
          options: ['Debit', 'Kredit', 'Netral', 'Tidak ada'],
          correctIndex: 0,
        ),
        Question(
          text: 'Saldo normal akun hutang adalah?',
          options: ['Debit', 'Kredit', 'Netral', 'Tidak ada'],
          correctIndex: 1,
        ),
        Question(
          text: 'Jika debit tidak sama dengan kredit, berarti?',
          options: [
            'Ada kesalahan',
            'Normal',
            'Tidak masalah',
            'Harus ditambah',
          ],
          correctIndex: 0,
        ),
      ],
    );
  }

  static Quiz _getAccountingStatementsQuiz() {
    return Quiz(
      title: 'Financial Statements',
      totalQuestions: 10,
      timeLimit: 30,
      passingScore: 70,
      questions: [
        Question(
          text: 'Laporan keuangan utama ada berapa?',
          options: ['2', '3', '4', '5'],
          correctIndex: 2,
        ),
        Question(
          text: 'Neraca menunjukkan?',
          options: [
            'Laba rugi',
            'Posisi keuangan',
            'Arus kas',
            'Perubahan modal',
          ],
          correctIndex: 1,
        ),
        Question(
          text: 'Laporan laba rugi menunjukkan?',
          options: [
            'Aset dan hutang',
            'Pendapatan dan beban',
            'Arus kas',
            'Modal akhir',
          ],
          correctIndex: 1,
        ),
        Question(
          text: 'Laporan arus kas menunjukkan?',
          options: [
            'Keuntungan bisnis',
            'Pergerakan kas',
            'Perubahan ekuitas',
            'Biaya operasional',
          ],
          correctIndex: 1,
        ),
        Question(
          text: 'Laporan perubahan ekuitas menunjukkan?',
          options: [
            'Perubahan modal',
            'Kinerja keuangan',
            'Arus kas',
            'Hutang',
          ],
          correctIndex: 0,
        ),
        Question(
          text: 'Aset lancar adalah aset yang?',
          options: [
            'Permanen',
            'Dapat diubah menjadi kas dalam 1 tahun',
            'Tidak berubah',
            'Sangat berharga',
          ],
          correctIndex: 1,
        ),
        Question(
          text: 'Analisis rasio digunakan untuk?',
          options: [
            'Menghitung pajak',
            'Mengevaluasi kinerja keuangan',
            'Membuat jurnal',
            'Posting ke buku besar',
          ],
          correctIndex: 1,
        ),
        Question(
          text: 'Rasio likuiditas mengukur?',
          options: [
            'Profitabilitas',
            'Kemampuan membayar hutang jangka pendek',
            'Efisiensi aset',
            'Pertumbuhan',
          ],
          correctIndex: 1,
        ),
        Question(
          text: 'Rasio profitabilitas mengukur?',
          options: [
            'Likuiditas',
            'Kemampuan menghasilkan laba',
            'Solvabilitas',
            'Efisiensi',
          ],
          correctIndex: 1,
        ),
        Question(
          text: 'ROA adalah singkatan dari?',
          options: [
            'Return on Account',
            'Return on Assets',
            'Return on Analysis',
            'Return on Allowance',
          ],
          correctIndex: 1,
        ),
      ],
    );
  }

  static Quiz _getAccountingFinalQuiz() {
    return Quiz(
      title: 'Final Review - Accounting',
      totalQuestions: 10,
      timeLimit: 35,
      passingScore: 70,
      questions: [
        Question(
          text: 'Prinsip dasar akuntansi yang memandu adalah?',
          options: ['GAAP', 'IFRS', 'Asumsi fundamental', 'Semua benar'],
          correctIndex: 3,
        ),
        Question(
          text: 'Akuntansi etis sangat penting karena?',
          options: [
            'Memenuhi hukum',
            'Menjaga kepercayaan publik',
            'Meningkatkan laba',
            'Mengurangi biaya',
          ],
          correctIndex: 1,
        ),
        Question(
          text: 'Penyimpangan dari standar akuntansi disebut?',
          options: ['Fraud', 'Error', 'Penyesuaian', 'Koreksi'],
          correctIndex: 0,
        ),
        Question(
          text: 'Audit dilakukan untuk?',
          options: [
            'Mencatat transaksi',
            'Memverifikasi keakuratan laporan',
            'Membuat jurnal',
            'Mengelola aset',
          ],
          correctIndex: 1,
        ),
        Question(
          text: 'Akuntan publik bersertifikat disebut?',
          options: ['CPA', 'CFO', 'CEO', 'COO'],
          correctIndex: 0,
        ),
        Question(
          text: 'Sistem akuntansi modern menggunakan?',
          options: [
            'Pembukuan manual',
            'Software akuntansi',
            'Papan tulis',
            'Kalkulator',
          ],
          correctIndex: 1,
        ),
        Question(
          text: 'Laporan keuangan konsolidasi digunakan untuk?',
          options: [
            'Satu perusahaan',
            'Grup perusahaan',
            'Divisi tertentu',
            'Departemen',
          ],
          correctIndex: 1,
        ),
        Question(
          text: 'Going concern adalah asumsi bahwa?',
          options: [
            'Perusahaan akan bubar',
            'Perusahaan akan terus beroperasi',
            'Perusahaan akan merger',
            'Perusahaan akan bangkrut',
          ],
          correctIndex: 1,
        ),
        Question(
          text: 'Transparansi dalam laporan keuangan penting untuk?',
          options: [
            'Mengurangi biaya',
            'Kepercayaan stakeholder',
            'Menambah aset',
            'Menghindari audit',
          ],
          correctIndex: 1,
        ),
        Question(
          text: 'Peran akuntansi dalam bisnis adalah?',
          options: [
            'Hanya mencatat',
            'Membantu pengambilan keputusan',
            'Menghitung gaji',
            'Mengelola HR',
          ],
          correctIndex: 1,
        ),
      ],
    );
  }

  // ============= AGRICULTURE QUIZZES =============
  static Quiz _getAgricultureSoilQuiz() {
    return Quiz(
      title: 'Soil Science',
      totalQuestions: 10,
      timeLimit: 30,
      passingScore: 70,
      questions: [
        Question(
          text: 'Tanah terdiri dari?',
          options: [
            'Mineral dan air',
            'Mineral, air, dan organisme',
            'Hanya bahan organik',
            'Hanya mineral',
          ],
          correctIndex: 1,
        ),
        Question(
          text: 'Tekstur tanah ditentukan oleh?',
          options: ['Warna', 'Ukuran partikel', 'Kelembaban', 'Suhu'],
          correctIndex: 1,
        ),
        Question(
          text: 'pH tanah netral adalah?',
          options: ['3', '5.5', '7', '9'],
          correctIndex: 2,
        ),
        Question(
          text: 'Tanah asam memiliki pH?',
          options: ['< 7', '= 7', '> 7', '>= 8'],
          correctIndex: 0,
        ),
        Question(
          text: 'Nutrisi utama tanaman adalah?',
          options: [
            'Nitrogen saja',
            'Nitrogen, Fosfor, Kalium',
            'Hanya Air',
            'Hanya Cahaya',
          ],
          correctIndex: 1,
        ),
        Question(
          text: 'Porositas tanah adalah?',
          options: [
            'Kepadatan',
            'Ruang pori dalam tanah',
            'Kesuburan',
            'Warna',
          ],
          correctIndex: 1,
        ),
        Question(
          text: 'Kapasitas pertukaran kation berkaitan dengan?',
          options: [
            'Drainase',
            'Kemampuan menyimpan nutrisi',
            'Tekstur',
            'Warna',
          ],
          correctIndex: 1,
        ),
        Question(
          text: 'Bahan organik tanah disebut?',
          options: ['Pasir', 'Humus', 'Liat', 'Kerikil'],
          correctIndex: 1,
        ),
        Question(
          text: 'Salinitas tanah tinggi akan?',
          options: [
            'Meningkatkan hasil panen',
            'Menghambat pertumbuhan tanaman',
            'Tidak ada efek',
            'Meningkatkan pH',
          ],
          correctIndex: 1,
        ),
        Question(
          text: 'Pemadatan tanah buruk karena?',
          options: [
            'Meningkatkan drainase',
            'Menghambat penetrasi akar',
            'Menambah nutrisi',
            'Mengurangi erosi',
          ],
          correctIndex: 1,
        ),
      ],
    );
  }

  static Quiz _getAgricultureCropQuiz() {
    return Quiz(
      title: 'Crop Production',
      totalQuestions: 10,
      timeLimit: 30,
      passingScore: 70,
      questions: [
        Question(
          text: 'Pemilihan tanaman harus mempertimbangkan?',
          options: [
            'Iklim dan tanah',
            'Warna saja',
            'Nama populer',
            'Harga benih',
          ],
          correctIndex: 0,
        ),
        Question(
          text: 'Jarak tanam mempengaruhi?',
          options: [
            'Warna daun',
            'Kompetisi nutrisi dan cahaya',
            'Kelembaban',
            'pH tanah',
          ],
          correctIndex: 1,
        ),
        Question(
          text: 'Hama utama dalam pertanian adalah?',
          options: ['Kupu-kupu', 'Semut', 'Belalang dan penggerek', 'Lebah'],
          correctIndex: 2,
        ),
        Question(
          text: 'Pengendalian hama organik menggunakan?',
          options: [
            'Pestisida kimia',
            'Musuh alami hama',
            'Pupuk kimia',
            'Antibiotik',
          ],
          correctIndex: 1,
        ),
        Question(
          text: 'Penyakit tanaman dapat disebabkan oleh?',
          options: [
            'Bakteri saja',
            'Virus, bakteri, jamur',
            'Hanya jamur',
            'Hanya air',
          ],
          correctIndex: 1,
        ),
        Question(
          text: 'Rotasi tanaman bertujuan untuk?',
          options: [
            'Menghemat lahan',
            'Menjaga kesuburan tanah',
            'Mengurangi air',
            'Menambah cuaca',
          ],
          correctIndex: 1,
        ),
        Question(
          text: 'Teknik tanam jajar legowo digunakan untuk?',
          options: [
            'Menghemat benih',
            'Meningkatkan hasil dan perawatan',
            'Mengurangi air',
            'Menghemat waktu',
          ],
          correctIndex: 1,
        ),
        Question(
          text: 'Irigasi tetes cocok untuk?',
          options: [
            'Tanah berawa',
            'Daerah kering dengan air terbatas',
            'Dataran rendah',
            'Musim hujan',
          ],
          correctIndex: 1,
        ),
        Question(
          text: 'Waktu panen optimal ditandai oleh?',
          options: [
            'Ukuran buah besar',
            'Tingkat kematangan fisiologis',
            'Cuaca bagus',
            'Keputusan petani',
          ],
          correctIndex: 1,
        ),
        Question(
          text: 'Hasil panen berhubungan dengan?',
          options: [
            'Kesehatan tanaman dan manajemen kebun',
            'Nama petani',
            'Warna tanah',
            'Jumlah hari',
          ],
          correctIndex: 0,
        ),
      ],
    );
  }

  static Quiz _getAgricultureAdvancedQuiz() {
    return Quiz(
      title: 'Advanced Agriculture',
      totalQuestions: 10,
      timeLimit: 35,
      passingScore: 70,
      questions: [
        Question(
          text: 'Sistem irigasi tetes membutuhkan?',
          options: [
            'Banyak air',
            'Air minimal dengan presisi',
            'Air mengalir deras',
            'Tidak perlu air',
          ],
          correctIndex: 1,
        ),
        Question(
          text: 'Pertanian berkelanjutan fokus pada?',
          options: [
            'Hasil maksimal jangka pendek',
            'Keseimbangan lingkungan jangka panjang',
            'Penggunaan pestisida',
            'Monokultur',
          ],
          correctIndex: 1,
        ),
        Question(
          text: 'Pertanian organik tidak menggunakan?',
          options: ['Air', 'Cahaya matahari', 'Pupuk sintetis', 'Benih'],
          correctIndex: 2,
        ),
        Question(
          text: 'Sertifikasi organik diperlukan untuk?',
          options: [
            'Menanam saja',
            'Menjual sebagai produk organik',
            'Irigasi',
            'Pemanenan',
          ],
          correctIndex: 1,
        ),
        Question(
          text: 'Kompos adalah?',
          options: [
            'Bahan organik terurai sebagai pupuk',
            'Pestisida alami',
            'Air untuk irigasi',
            'Alat pertanian',
          ],
          correctIndex: 0,
        ),
        Question(
          text: 'Pertanian presisi menggunakan?',
          options: [
            'Tenaga manusia',
            'Teknologi dan data untuk optimasi',
            'Alat manual',
            'Prediksi cuaca',
          ],
          correctIndex: 1,
        ),
        Question(
          text: 'Manfaat agroforestry adalah?',
          options: [
            'Hanya kayu',
            'Hasil panen dengan konservasi lahan',
            'Tidak ada hasil',
            'Kurang efisien',
          ],
          correctIndex: 1,
        ),
        Question(
          text: 'Konservasi air dalam pertanian penting karena?',
          options: [
            'Mahal',
            'Kelangkaan air dan efisiensi',
            'Tidak penting',
            'Hanya di musim kemarau',
          ],
          correctIndex: 1,
        ),
        Question(
          text: 'Bioteknologi dalam pertanian digunakan untuk?',
          options: [
            'Meningkatkan hasil dan ketahanan tanaman',
            'Mengurangi produksi',
            'Menghilangkan benih',
            'Menambah hama',
          ],
          correctIndex: 0,
        ),
        Question(
          text: 'Perubahan iklim mempengaruhi pertanian melalui?',
          options: [
            'Suhu, pola curah hujan, hama penyakit',
            'Hanya suhu',
            'Tidak mempengaruhi',
            'Hanya angin',
          ],
          correctIndex: 0,
        ),
      ],
    );
  }

  // ============= ECONOMICS QUIZZES =============
  static Quiz _getEconomicsMicroQuiz() {
    return Quiz(
      title: 'Microeconomics',
      totalQuestions: 10,
      timeLimit: 30,
      passingScore: 70,
      questions: [
        Question(
          text: 'Mikroekonomi mempelajari?',
          options: [
            'Ekonomi negara',
            'Pasar individual dan konsumen',
            'Inflasi global',
            'Kurs mata uang',
          ],
          correctIndex: 1,
        ),
        Question(
          text: 'Hukum permintaan menyatakan?',
          options: [
            'Saat harga naik, permintaan naik',
            'Saat harga naik, permintaan turun',
            'Harga tidak mempengaruhi permintaan',
            'Semua orang membeli sama',
          ],
          correctIndex: 1,
        ),
        Question(
          text: 'Kurva penawaran yang naik menunjukkan?',
          options: [
            'Hubungan negatif harga-kuantitas',
            'Hubungan positif harga-kuantitas',
            'Tidak ada hubungan',
            'Hubungan tetap',
          ],
          correctIndex: 1,
        ),
        Question(
          text: 'Keseimbangan pasar terjadi saat?',
          options: [
            'Harga paling tinggi',
            'Permintaan = Penawaran',
            'Pembeli puas',
            'Penjual puas',
          ],
          correctIndex: 1,
        ),
        Question(
          text: 'Elastisitas permintaan mengukur?',
          options: [
            'Kepuasan pembeli',
            'Sensitivitas perubahan kuantitas terhadap harga',
            'Jumlah uang',
            'Kepercayaan konsumen',
          ],
          correctIndex: 1,
        ),
        Question(
          text: 'Barang normal adalah barang yang?',
          options: [
            'Permintaan meningkat saat pendapatan meningkat',
            'Harganya normal',
            'Tidak ada kualitas',
            'Sama untuk semua',
          ],
          correctIndex: 0,
        ),
        Question(
          text: 'Struktur pasar monopolistik ditandai oleh?',
          options: [
            'Banyak penjual',
            'Satu penjual dominan',
            'Hanya pembeli',
            'Tidak ada penjual',
          ],
          correctIndex: 1,
        ),
        Question(
          text: 'Surplus konsumen adalah?',
          options: [
            'Harga yang dibayar',
            'Selisih harga kesediaan dan harga pasar',
            'Barang yang tidak terjual',
            'Biaya produksi',
          ],
          correctIndex: 1,
        ),
        Question(
          text: 'Eksternalitas negatif dapat menyebabkan?',
          options: [
            'Keuntungan sosial',
            'Kerugian bagi pihak ketiga',
            'Harga lebih rendah',
            'Produksi meningkat',
          ],
          correctIndex: 1,
        ),
        Question(
          text: 'Diskriminasi harga dilakukan untuk?',
          options: [
            'Menurunkan kualitas',
            'Menjual pada harga berbeda untuk segmen berbeda',
            'Meningkatkan biaya',
            'Mengurangi keuntungan',
          ],
          correctIndex: 1,
        ),
      ],
    );
  }

  static Quiz _getEconomicsMacroQuiz() {
    return Quiz(
      title: 'Macroeconomics',
      totalQuestions: 10,
      timeLimit: 30,
      passingScore: 70,
      questions: [
        Question(
          text: 'Makroekonomi mempelajari?',
          options: [
            'Pasar individual',
            'Ekonomi keseluruhan dan agregat',
            'Harga barang',
            'Perilaku pembeli',
          ],
          correctIndex: 1,
        ),
        Question(
          text: 'GDP adalah?',
          options: [
            'Gross Domestic Product (nilai produksi',
            'Government Domestic Policy',
            'Gross Debt Product',
            'General Development Plan',
          ],
          correctIndex: 0,
        ),
        Question(
          text: 'Inflasi adalah?',
          options: [
            'Penurunan harga',
            'Kenaikan tingkat harga umum',
            'Berkurangnya uang',
            'Pertumbuhan ekonomi',
          ],
          correctIndex: 1,
        ),
        Question(
          text: 'Pengangguran friksional disebabkan oleh?',
          options: [
            'Perubahan struktur ekonomi',
            'Pencarian pekerjaan baru',
            'Resesi',
            'Teknologi',
          ],
          correctIndex: 1,
        ),
        Question(
          text: 'Bank sentral mengontrol?',
          options: [
            'Harga barang',
            'Uang beredar dan suku bunga',
            'Gaji karyawan',
            'Rencana pembangunan',
          ],
          correctIndex: 1,
        ),
        Question(
          text: 'Kebijakan moneter ekspansif dilakukan saat?',
          options: [
            'Inflasi tinggi',
            'Resesi/pertumbuhan lambat',
            'Harga stabil',
            'Pengangguran rendah',
          ],
          correctIndex: 1,
        ),
        Question(
          text: 'Deficit anggaran negara adalah?',
          options: [
            'Pengeluaran > Pendapatan',
            'Pengeluaran < Pendapatan',
            'Pengeluaran = Pendapatan',
            'Tanpa hutang',
          ],
          correctIndex: 0,
        ),
        Question(
          text: 'Kurva Phillips menunjukkan hubungan antara?',
          options: [
            'Harga dan kualitas',
            'Inflasi dan pengangguran',
            'Upah dan produktivitas',
            'Tabungan dan investasi',
          ],
          correctIndex: 1,
        ),
        Question(
          text: 'Siklus bisnis terdiri dari?',
          options: [
            'Ekspansi, Puncak, Kontraksi, Dasar',
            'Naik dan Turun',
            'Stabil saja',
            'Tidak ada pola',
          ],
          correctIndex: 0,
        ),
        Question(
          text: 'Pertumbuhan ekonomi diukur melalui?',
          options: [
            'Jumlah penduduk',
            'Peningkatan GDP real',
            'Nilai uang',
            'Jumlah perusahaan',
          ],
          correctIndex: 1,
        ),
      ],
    );
  }

  static Quiz _getEconomicsGlobalQuiz() {
    return Quiz(
      title: 'Global Economy',
      totalQuestions: 10,
      timeLimit: 35,
      passingScore: 70,
      questions: [
        Question(
          text: 'Perdagangan internasional terjadi karena?',
          options: [
            'Kesamaan sumber daya',
            'Perbedaan keunggulan komparatif',
            'Regulasi sama',
            'Jarak dekat',
          ],
          correctIndex: 1,
        ),
        Question(
          text: 'Keuntungan komparatif adalah?',
          options: [
            'Biaya produksi terendah mutlak',
            'Biaya kesempatan terendah',
            'Harga paling mahal',
            'Tidak ada biaya',
          ],
          correctIndex: 1,
        ),
        Question(
          text: 'Tarif adalah?',
          options: [
            'Bea cukai impor/ekspor',
            'Harga barang',
            'Gaji karyawan',
            'Biaya asuransi',
          ],
          correctIndex: 0,
        ),
        Question(
          text: 'Kurs mata uang ditentukan oleh?',
          options: [
            'Pemerintah saja',
            'Permintaan dan penawaran valuta',
            'Bank saja',
            'Konsumen',
          ],
          correctIndex: 1,
        ),
        Question(
          text: 'Devaluasi mata uang dapat menyebabkan?',
          options: [
            'Impor lebih murah',
            'Ekspor lebih kompetitif',
            'Tidak ada efek',
            'Impor lebih mahal',
          ],
          correctIndex: 1,
        ),
        Question(
          text: 'FDI adalah?',
          options: [
            'Foreign Direct Investment',
            'Foreign Development Index',
            'Financial Data Input',
            'Fiscal Debt Index',
          ],
          correctIndex: 0,
        ),
        Question(
          text: 'Keuntungan FDI untuk negara penerima adalah?',
          options: [
            'Modal, teknologi, lapangan kerja',
            'Hanya uang',
            'Tidak ada keuntungan',
            'Meningkatkan inflasi',
          ],
          correctIndex: 0,
        ),
        Question(
          text: 'Globalisasi ekonomi ditandai dengan?',
          options: [
            'Isolasi ekonomi',
            'Integrasi pasar global',
            'Proteksionisme',
            'Perang dagang',
          ],
          correctIndex: 1,
        ),
        Question(
          text: 'Organisasi perdagangan global adalah?',
          options: ['IMF', 'World Bank', 'WTO', 'Semua benar'],
          correctIndex: 3,
        ),
        Question(
          text: 'Pembangunan berkelanjutan fokus pada?',
          options: [
            'Pertumbuhan jangka pendek',
            'Keseimbangan ekonomi, sosial, lingkungan',
            'Ekspor maksimal',
            'Konsumsi besar',
          ],
          correctIndex: 1,
        ),
      ],
    );
  }

  // ============= DESIGN QUIZZES =============
  static Quiz _getDesignPrinciplesQuiz() {
    return Quiz(
      title: 'Design Principles',
      totalQuestions: 10,
      timeLimit: 30,
      passingScore: 70,
      questions: [
        Question(
          text: 'Prinsip dasar desain adalah?',
          options: [
            'Warna saja',
            'Kesatuan, keseimbangan, irama, penekanan',
            'Hanya bentuk',
            'Tidak ada prinsip',
          ],
          correctIndex: 1,
        ),
        Question(
          text: 'Keseimbangan simetris dalam desain adalah?',
          options: [
            'Tidak seimbang',
            'Elemen identik di kedua sisi pusat',
            'Hanya satu sisi',
            'Tidak penting',
          ],
          correctIndex: 1,
        ),
        Question(
          text: 'Irama visual diciptakan dengan?',
          options: [
            'Mengulang elemen secara konsisten',
            'Warna gelap',
            'Teks besar',
            'Tanpa pola',
          ],
          correctIndex: 0,
        ),
        Question(
          text: 'Penekanan dalam desain adalah?',
          options: [
            'Membuat semua sama penting',
            'Menyoroti elemen tertentu',
            'Menghapus elemen',
            'Tidak relevan',
          ],
          correctIndex: 1,
        ),
        Question(
          text: 'Kontras dalam desain menciptakan?',
          options: [
            'Kejenuhan',
            'Daya tarik visual dan perhatian',
            'Kebingungan',
            'Ketidakseimbangan',
          ],
          correctIndex: 1,
        ),
        Question(
          text: 'Ruang negatif (whitespace) berguna untuk?',
          options: [
            'Menambah elemen',
            'Memberikan napas visual dan kejelasan',
            'Mengisi semua area',
            'Membuat desain penuh',
          ],
          correctIndex: 1,
        ),
        Question(
          text: 'Tipografi yang baik harus?',
          options: [
            'Sebanyak mungkin font',
            'Mudah dibaca dan konsisten',
            'Berukuran besar semua',
            'Warna-warni',
          ],
          correctIndex: 1,
        ),
        Question(
          text: 'Grid dalam desain membantu?',
          options: [
            'Membuat desain acak',
            'Mengatur elemen dengan terstruktur',
            'Menghapus elemen',
            'Tidak penting',
          ],
          correctIndex: 1,
        ),
        Question(
          text: 'Harmoni warna yang baik adalah?',
          options: [
            'Semua warna cerah',
            'Warna yang menyatu dan menyenangkan mata',
            'Warna gelap saja',
            'Tanpa warna',
          ],
          correctIndex: 1,
        ),
        Question(
          text: 'Skala dalam desain berkaitan dengan?',
          options: [
            'Ukuran absolut',
            'Ukuran relatif elemen satu sama lain',
            'Teks saja',
            'Tidak penting',
          ],
          correctIndex: 1,
        ),
      ],
    );
  }

  static Quiz _getDesignDigitalQuiz() {
    return Quiz(
      title: 'Digital Design',
      totalQuestions: 10,
      timeLimit: 30,
      passingScore: 70,
      questions: [
        Question(
          text: 'UI adalah?',
          options: [
            'User Interface - tampilan visual',
            'User Integration',
            'Universal Internet',
            'Unknown Information',
          ],
          correctIndex: 0,
        ),
        Question(
          text: 'UX adalah?',
          options: [
            'User Experience - pengalaman pengguna',
            'User Expansion',
            'Universal Exchange',
            'Unknown eXperiment',
          ],
          correctIndex: 0,
        ),
        Question(
          text: 'Responsive design adalah?',
          options: [
            'Desain yang hanya untuk desktop',
            'Desain yang menyesuaikan berbagai ukuran layar',
            'Desain yang berubah warna',
            'Desain yang bergerak',
          ],
          correctIndex: 1,
        ),
        Question(
          text: 'Wireframe digunakan untuk?',
          options: [
            'Warna akhir',
            'Struktur dasar layout',
            'Tipografi',
            'Fotografi',
          ],
          correctIndex: 1,
        ),
        Question(
          text: 'Mockup menunjukkan?',
          options: [
            'Struktur saja',
            'Representasi visual mendekati hasil akhir',
            'Teks saja',
            'Data',
          ],
          correctIndex: 1,
        ),
        Question(
          text: 'Prototype digunakan untuk?',
          options: [
            'Presentasi final',
            'Testing interaktivitas sebelum produksi',
            'Dokumentasi',
            'Hanya gambaran',
          ],
          correctIndex: 1,
        ),
        Question(
          text: 'CTA (Call To Action) dalam desain adalah?',
          options: [
            'Tombol yang mendorong tindakan pengguna',
            'Cerpen tentang aksi',
            'Cerita tentang desain',
            'Tidak penting',
          ],
          correctIndex: 0,
        ),
        Question(
          text: 'Aksesibilitas desain digital berarti?',
          options: [
            'Hanya untuk profesional',
            'Dapat digunakan semua orang termasuk disabilitas',
            'Hanya warna cerah',
            'Sangat rumit',
          ],
          correctIndex: 1,
        ),
        Question(
          text: 'Loading time dalam UX penting karena?',
          options: [
            'Tidak penting',
            'Mempengaruhi pengalaman pengguna',
            'Hanya untuk server',
            'Tidak relevan',
          ],
          correctIndex: 1,
        ),
        Question(
          text: 'User testing dilakukan untuk?',
          options: [
            'Menunjukkan desain jadi',
            'Mendapatkan feedback dari pengguna nyata',
            'Menghapus fitur',
            'Tidak perlu dilakukan',
          ],
          correctIndex: 1,
        ),
      ],
    );
  }

  // ============= BIOLOGY QUIZZES =============
  static Quiz _getBiologyCellularQuiz() {
    return Quiz(
      title: 'Cellular Biology',
      totalQuestions: 10,
      timeLimit: 30,
      passingScore: 70,
      questions: [
        Question(
          text: 'Sel adalah?',
          options: [
            'Organel kecil',
            'Unit terkecil kehidupan',
            'Jaringan',
            'Organ',
          ],
          correctIndex: 1,
        ),
        Question(
          text: 'Perbedaan utama sel prokariotik dan eukariotik?',
          options: [
            'Ukuran saja',
            'Membran inti dan organel',
            'Warna',
            'Tidak ada perbedaan',
          ],
          correctIndex: 1,
        ),
        Question(
          text: 'Fungsi mitokondria adalah?',
          options: [
            'Fotosintesis',
            'Produksi energi (ATP)',
            'Penyimpanan makanan',
            'Sintesis protein',
          ],
          correctIndex: 1,
        ),
        Question(
          text: 'Kloroplas ditemukan pada?',
          options: [
            'Sel hewan',
            'Sel tumbuhan (fotosintesis)',
            'Sel bakteri',
            'Sel jamur',
          ],
          correctIndex: 1,
        ),
        Question(
          text: 'DNA tersimpan dalam?',
          options: [
            'Mitokondria saja',
            'Nukleus (sel eukariotik)',
            'Sitoplasma saja',
            'Vakuola',
          ],
          correctIndex: 1,
        ),
        Question(
          text: 'Ribosom berfungsi untuk?',
          options: [
            'Produksi energi',
            'Sintesis protein',
            'Penyimpanan lemak',
            'Fotosintesis',
          ],
          correctIndex: 1,
        ),
        Question(
          text: 'Membran sel berfungsi untuk?',
          options: [
            'Hanya perlindungan',
            'Perlindungan dan kontrol pertukaran zat',
            'Hanya respirasi',
            'Hanya fotosintesis',
          ],
          correctIndex: 1,
        ),
        Question(
          text: 'Mitosis menghasilkan?',
          options: [
            'Gamet',
            'Dua sel anak identik',
            'Empat sel',
            'Sel yang berbeda',
          ],
          correctIndex: 1,
        ),
        Question(
          text: 'Meiosis terjadi untuk?',
          options: [
            'Pertumbuhan tubuh',
            'Produksi gamet (sel seks)',
            'Perbaikan jaringan',
            'Produksi energi',
          ],
          correctIndex: 1,
        ),
        Question(
          text: 'Apoptosis adalah?',
          options: [
            'Pembelahan sel',
            'Kematian sel terprogram',
            'Pertumbuhan sel',
            'Penyerapan nutrisi',
          ],
          correctIndex: 1,
        ),
      ],
    );
  }

  static Quiz _getBiologyGeneticsQuiz() {
    return Quiz(
      title: 'Genetics & Evolution',
      totalQuestions: 10,
      timeLimit: 30,
      passingScore: 70,
      questions: [
        Question(
          text: 'Gen adalah?',
          options: [
            'Kromosom utuh',
            'Unit pewarisan sifat di DNA',
            'Sel',
            'Protein',
          ],
          correctIndex: 1,
        ),
        Question(
          text: 'Alel adalah?',
          options: [
            'Protein',
            'Variasi gen untuk sifat sama',
            'Mitokondria',
            'Sel seks',
          ],
          correctIndex: 1,
        ),
        Question(
          text: 'Hukum segregasi Mendel menyatakan?',
          options: [
            'Semua sifat sama',
            'Alel terpisah saat pembelahan',
            'Tidak ada pemisahan',
            'Semua dominan',
          ],
          correctIndex: 1,
        ),
        Question(
          text: 'Dominan adalah?',
          options: [
            'Sifat yang selalu muncul',
            'Alel yang mengekspresikan sifatnya',
            'Sifat tersembunyi',
            'Tidak ada pengaruh',
          ],
          correctIndex: 1,
        ),
        Question(
          text: 'Mutasi adalah?',
          options: [
            'Pembelahan sel',
            'Perubahan susunan DNA',
            'Pertumbuhan',
            'Pemisahan alel',
          ],
          correctIndex: 1,
        ),
        Question(
          text: 'Evolusi adalah?',
          options: [
            'Perubahan spesies dalam waktu singkat',
            'Perubahan makhluk hidup jangka panjang',
            'Tidak ada perubahan',
            'Hanya migrasi',
          ],
          correctIndex: 1,
        ),
        Question(
          text: 'Seleksi alam adalah?',
          options: [
            'Pemilihan manusia',
            'Kelangsungan hidup individu yang cocok',
            'Mutasi',
            'Perkawinan acak',
          ],
          correctIndex: 1,
        ),
        Question(
          text: 'Adaptasi adalah?',
          options: [
            'Kesamaan sifat',
            'Penyesuaian organism dengan lingkungan',
            'Migrasi',
            'Reproduksi',
          ],
          correctIndex: 1,
        ),
        Question(
          text: 'Spesiasi adalah?',
          options: [
            'Pemisahan geografis',
            'Terbentuknya spesies baru',
            'Perpanjangan hidup',
            'Penurunan populasi',
          ],
          correctIndex: 1,
        ),
        Question(
          text: 'Bukti evolusi termasuk?',
          options: [
            'Hanya fosil',
            'Fosil, homologi, biogeografi',
            'Hanya DNA',
            'Hanya perilaku',
          ],
          correctIndex: 1,
        ),
      ],
    );
  }

  static Quiz _getBiologyBiosphereQuiz() {
    return Quiz(
      title: 'Ecology & Biosphere',
      totalQuestions: 10,
      timeLimit: 35,
      passingScore: 70,
      questions: [
        Question(
          text: 'Ekosistem adalah?',
          options: [
            'Hanya flora',
            'Komunitas + lingkungan fisik',
            'Hanya fauna',
            'Hanya air',
          ],
          correctIndex: 1,
        ),
        Question(
          text: 'Rantai makanan menunjukkan?',
          options: [
            'Semua organism sama',
            'Aliran energi dari produsen ke konsumen',
            'Tidak ada aliran',
            'Hanya herbivora',
          ],
          correctIndex: 1,
        ),
        Question(
          text: 'Produsen dalam rantai makanan adalah?',
          options: [
            'Herbivora',
            'Organisme fotosintetik (tumbuhan)',
            'Karnivora',
            'Omnivora',
          ],
          correctIndex: 1,
        ),
        Question(
          text: 'Konsumen primer adalah?',
          options: ['Pemangsa puncak', 'Herbivora', 'Pengurai', 'Detritivora'],
          correctIndex: 1,
        ),
        Question(
          text: 'Biodiversitas adalah?',
          options: [
            'Hanya keragaman gen',
            'Keragaman spesies dan genetik',
            'Kesamaan organism',
            'Tidak ada variasi',
          ],
          correctIndex: 1,
        ),
        Question(
          text: 'Bioma adalah?',
          options: [
            'Satu habitat kecil',
            'Region dengan iklim dan organism serupa',
            'Satu spesies',
            'Satu pulau',
          ],
          correctIndex: 1,
        ),
        Question(
          text: 'Suksesi ekosistem adalah?',
          options: [
            'Tidak ada perubahan',
            'Perubahan komunitas seiring waktu',
            'Penurunan populasi',
            'Stagnasi',
          ],
          correctIndex: 1,
        ),
        Question(
          text: 'Daur biogeokimia penting karena?',
          options: [
            'Estetika',
            'Sirkulasi nutrisi di ekosistem',
            'Hanya hiburan',
            'Tidak penting',
          ],
          correctIndex: 1,
        ),
        Question(
          text: 'Ancaman terbesar biodiversitas adalah?',
          options: [
            'Cuaca',
            'Hilang habitat, perubahan iklim, polusi',
            'Hanya penyakit',
            'Cuaca ekstrem',
          ],
          correctIndex: 1,
        ),
        Question(
          text: 'Konservasi bertujuan untuk?',
          options: [
            'Meningkatkan populasi saja',
            'Melindungi spesies dan ekosistem',
            'Menghentikan semua aktivitas',
            'Tidak ada tujuan',
          ],
          correctIndex: 1,
        ),
      ],
    );
  }

  // ============= DEFAULT QUIZ (fallback) =============
  static Quiz _getDefaultQuiz() {
    return Quiz(
      title: 'Default Quiz',
      totalQuestions: 2,
      timeLimit: 30,
      passingScore: 70,
      questions: [
        Question(
          text: 'Ini adalah soal default untuk quiz yang tidak terdaftar',
          options: ['Opsi 1', 'Opsi 2', 'Opsi 3', 'Opsi 4'],
          correctIndex: 0,
        ),
        Question(
          text: 'Silakan beri tahu tentang lesson ID yang Anda gunakan',
          options: ['Opsi 1', 'Opsi 2', 'Opsi 3', 'Opsi 4'],
          correctIndex: 0,
        ),
      ],
    );
  }

  /// Dummy data untuk pengembangan (kept for backward compatibility)
  static Quiz getDummyQuiz() {
    return _getDefaultQuiz();
  }
}