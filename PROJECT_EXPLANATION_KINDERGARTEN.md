# Penjelasan Project Super Sederhana (Gaya Ngajarin Anak TK)

## Halo, ini aplikasi apa sih?
Bayangkan kamu punya sekolah kecil di HP.
Di sekolah ini ada:
- daftar kursus,
- daftar pelajaran di tiap kursus,
- tombol centang kalau pelajaran sudah selesai.

Project kamu itu seperti "sekolah mini" yang rapi.

---

## Kita pakai cerita: Rumah Besar dengan 3 Lantai
Aplikasi kamu seperti rumah besar 3 lantai.

- Lantai 1: Presentation (tempat yang terlihat user)
- Lantai 2: Domain (otak aturan)
- Lantai 3: Data (gudang data)

Agar rumah rapi, tiap lantai punya tugas sendiri.

---

## Lantai 1: Presentation (muka aplikasi)
Ini bagian yang user lihat dan sentuh.

Di sini ada:
- layar login,
- layar home,
- layar daftar kursus,
- layar detail kursus,
- layar detail lesson,
- widget-widget cantik.

### Tugasnya apa?
- menampilkan data,
- menangkap klik user,
- mengirim permintaan ke "otak" (Bloc).

### Contoh gampang
User ketik di kolom cari.
Layar bilang ke Bloc: "tolong carikan kursus ya".

---

## Lantai 2: Domain (otak utama)
Ini bagian aturan inti aplikasi.

Di sini ada:
- Entity (bentuk data inti),
- Repository interface (janji fungsi),
- UseCase (langkah kerja bisnis).

### Bayangin begini
- Entity = kartu identitas data.
- Repository interface = daftar janji: "aku bisa ambil kursus, cari kursus, simpan kursus".
- UseCase = resep langkah kerja.

### Kenapa penting?
Karena otak ini tidak peduli UI cantik atau tidak.
Otak juga tidak peduli data datang dari internet atau dari file lokal.
Otak cuma peduli aturan.

---

## Lantai 3: Data (gudang)
Ini tempat data disimpan dan diambil.

Di sini ada:
- Model data,
- Mapper (penerjemah),
- Repository impl (pelaksana janji),
- DummyData,
- LocalStorage (Hive).

### Contoh gampang
- DummyData = buku latihan contoh.
- LocalStorage = kotak penyimpanan bintang selesai.
- Mapper = penerjemah bahasa gudang ke bahasa otak.

---

## Siapa itu Bloc? (satpam + kurir)
Bloc itu seperti satpam pintar.

Kerja Bloc:
1. menerima pesan dari layar (event),
2. minta tolong ke usecase,
3. kirim hasil balik ke layar (state).

### Event itu apa?
Event = "permintaan" dari user.
Contoh:
- GetCoursesEvent
- SearchCoursesEvent
- ToggleSaveCourseEvent

### State itu apa?
State = "kondisi sekarang" aplikasi.
Contoh:
- loading,
- data berhasil,
- gagal.

---

## Alur super detail dari awal buka aplikasi

## 1) App dinyalakan
File utama: lib/main.dart

Yang terjadi:
1. Flutter disiapkan.
2. Hive storage dibuka.
3. Service locator disiapkan.
4. Bloc disuntikkan ke seluruh app.
5. App menampilkan halaman login.

Sederhananya:
"Bangun rumah, isi petugas, baru buka pintu ke user."

---

## 2) User login
Bagian yang bekerja:
- LoginScreen
- AuthBloc
- LoginUseCase
- AuthRepositoryImpl

Langkahnya:
1. User isi email dan password.
2. AuthBloc menerima event login.
3. AuthBloc panggil LoginUseCase.
4. UseCase panggil repository.
5. Repository cek email/password sederhana.
6. Kalau lolos, user dianggap berhasil login.
7. UI pindah ke halaman utama.

Catatan jujur:
Ini masih login simulasi, belum login server sungguhan.

---

## 3) Home ambil daftar kursus
Bagian yang bekerja:
- HomeScreen
- CourseBloc
- GetCoursesUseCase
- CourseRepositoryImpl
- DummyData

Langkahnya:
1. HomeScreen dibuka.
2. HomeScreen mengirim GetCoursesEvent.
3. CourseBloc memproses dan panggil usecase.
4. UseCase panggil repository.
5. Repository ambil data dari DummyData.
6. Repository cek LocalStorage untuk lesson yang sudah selesai.
7. Data dipetakan jadi entity.
8. UI menampilkan daftar dan statistik.

---

## 4) User mencari kursus
Langkahnya:
1. User ketik kata di search bar.
2. UI kirim SearchCoursesEvent.
3. Bloc panggil SearchCoursesUseCase.
4. Repository filter judul/deskripsi.
5. Hasil baru ditampilkan.

---

## 5) User simpan kursus (bookmark)
Langkahnya:
1. User tekan ikon simpan.
2. UI kirim ToggleSaveCourseEvent.
3. Bloc panggil ToggleSaveCourseUseCase.
4. Repository ubah status isSaved.
5. Bloc memuat ulang data agar UI sinkron.

---

## 6) User buka detail kursus
Yang terlihat:
- judul,
- instruktur,
- durasi,
- progress,
- sections,
- daftar lesson.

Saat user klik lesson:
- app pindah ke LessonDetailScreen.

---

## 7) User tandai lesson selesai
Langkahnya:
1. LessonDetailScreen dibuka.
2. Screen cek status selesai via LessonBloc.
3. User tekan tombol complete/incomplete.
4. LessonBloc panggil ToggleLessonCompletionUseCase.
5. Repository lesson simpan status ke LocalStorage.
6. CourseBloc di-refresh supaya progress di layar lain ikut update.

Sederhananya:
"kasih bintang di lesson, lalu papan nilai kursus ikut berubah."

---

## Kenapa progress bisa tetap ada walau app ditutup?
Karena disimpan di Hive LocalStorage.

Artinya:
- kalau lesson 1 selesai hari ini,
- besok buka app lagi,
- lesson 1 tetap selesai.

---

## Apakah project ini sudah Clean Architecture?
Jawaban anak TK tapi jujur: "Sudah lumayan rapi, tapi belum rapi banget."

### Yang sudah bagus
- Sudah dipisah jadi presentation, domain, data.
- Sudah ada bloc, usecase, repository, mapper.
- UI tidak langsung sentuh storage.

### Yang belum bersih total
- Beberapa file UI masih ambil model langsung dari data layer.
- UI masih ikut tahu hal yang seharusnya jadi urusan domain/data.
- Ada logika yang tersebar di banyak tempat.

Jadi ini:
- bukan berantakan,
- tapi belum level "super bersih".

---

## Apakah mudah dimodifikasi jangka panjang?
Jawaban sederhana:
- sekarang: cukup mudah,
- nanti saat fitur banyak: bisa mulai berat kalau tidak dirapikan.

Kenapa masih lumayan mudah:
- struktur sudah terpisah,
- alur event-state jelas,
- repository jadi titik kontrol data.

Kenapa bisa berat nanti:
- batas antar layer belum ketat,
- sebagian UI masih ketergantungan ke data model,
- kalau API backend masuk, perlu refactor tambahan.

---

## Bayangan masa depan (bahasa mudah)
Supaya rumah makin kuat:
1. Lantai 1 jangan ambil barang langsung ke gudang.
2. Semua aturan hitung pindah ke otak domain.
3. Gudang dibagi: gudang lokal dan gudang internet.
4. Tambah tes otomatis supaya kalau ada perubahan tidak rusak diam-diam.

Kalau ini dilakukan, project kamu bisa:
- lebih gampang diperbesar,
- lebih gampang ganti backend,
- lebih aman dirawat tim lama atau tim baru.

---

## Ringkasan akhir super simpel
Project kamu itu sudah seperti rumah yang bagus pondasinya.

Sudah ada:
- ruang tamu (UI),
- ruang otak (domain),
- gudang (data).

Yang perlu diperbaiki:
- jangan biarkan ruang tamu sering masuk gudang,
- biarkan ruang otak jadi pengatur utama.

Kalau itu dirapikan, project kamu akan lebih tahan lama dan maintenance jadi jauh lebih enak.
