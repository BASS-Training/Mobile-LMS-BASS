# Analisis Alur dan Struktur Project LMS Mobile App

## Ringkasan Singkat
Project ini **sudah mengarah ke Clean Architecture**, tetapi **belum clean architecture penuh**.

Alasannya:
- Lapisan `presentation`, `domain`, dan `data` sudah dipisah dengan cukup jelas.
- Ada `repository abstraction`, `usecase`, `bloc`, dan `mapper`.
- Namun, masih ada beberapa **kebocoran layer**: beberapa file di `presentation` masih import model dan mapper dari `data`, sehingga UI belum benar-benar hanya bergantung pada domain.
- Beberapa business rule juga masih menempel di model data dan screen, bukan sepenuhnya di domain.

Kesimpulan praktis:
- Untuk **proyek kecil sampai menengah**: struktur ini sudah cukup nyaman dipakai dan relatif mudah dimodifikasi.
- Untuk **jangka panjang** dan fitur yang makin banyak: masih perlu dirapikan lagi supaya maintenance tetap aman dan tidak makin saling bergantung.

---

## Gambaran Besar Arsitektur
Struktur project ini dibagi menjadi beberapa lapisan utama:

- `presentation/`  
  Menangani UI, screen, widget, event, state, dan bloc.
- `domain/`  
  Menyimpan entity, kontrak repository, dan usecase.
- `data/`  
  Menyimpan model data, mapper, repository implementation, dan sumber data lokal.
- `config/`  
  Berisi theme dan service locator.
- `utils/`  
  Berisi konstanta dan validator.

Alur datanya kira-kira seperti ini:

1. User membuka app.
2. `main.dart` menyiapkan storage, dependency injection, dan root app.
3. Screen memanggil `Bloc`.
4. `Bloc` memanggil `UseCase`.
5. `UseCase` memanggil `Repository` interface.
6. `Repository Implementation` mengambil data dari dummy data atau local storage.
7. Data diubah lewat `Mapper` menjadi `Entity`.
8. UI menampilkan data dari entity tersebut.

---

## Titik Masuk Aplikasi

### `lib/main.dart`
Fungsi utama file ini:
- memastikan Flutter binding siap,
- menginisialisasi `LocalStorage` berbasis Hive,
- menyiapkan service locator,
- menjalankan `MainApp`.

Yang dilakukan di sini:
- `LocalStorage.init()` dipanggil dulu supaya box Hive siap dipakai.
- `ServiceLocator().setupServiceLocator()` menyiapkan dependency untuk bloc, usecase, dan repository.
- `MultiBlocProvider` menyediakan `AuthBloc`, `CourseBloc`, dan `LessonBloc` ke seluruh aplikasi.
- `MaterialApp` mengatur tema, route, dan navigation.

Jadi, `main.dart` adalah pusat bootstrap aplikasi, bukan pusat business logic.

### Routing di `main.dart`
Route utama yang terlihat:
- `/login` -> `LoginScreen`
- `/home` -> `MainScreen(initialTab: 0)`
- `/courses` -> `MainScreen(initialTab: 1)`
- `/course-detail` -> `CourseDetailScreen`
- `/lesson-detail` -> `LessonDetailScreen`

Artinya navigasi app cukup sederhana dan masih dikelola langsung dari root app.

---

## Dependency Injection

### `lib/config/service_locator.dart`
File ini menghubungkan semua layer.

Urutan wiring-nya:
- buat instance repository implementation,
- buat usecase dari repository tersebut,
- buat bloc dari usecase,
- expose bloc lewat getter.

Contoh alurnya:
- `AuthRepositoryImpl` -> `LoginUseCase`, `LogoutUseCase` -> `AuthBloc`
- `CourseRepositoryImpl` -> `GetCoursesUseCase`, `SearchCoursesUseCase`, dst. -> `CourseBloc`
- `LessonRepositoryImpl` -> `IsLessonCompletedUseCase`, `ToggleLessonCompletionUseCase`, dst. -> `LessonBloc`

Maknanya:
- repository bertugas ambil dan simpan data,
- usecase jadi jembatan aturan bisnis,
- bloc menjadi penghubung UI ke logika.

Kelebihan pendekatan ini:
- dependency utama terpusat,
- lebih mudah ganti implementasi repository nanti,
- alur tanggung jawab cukup jelas.

Kekurangannya:
- masih manual, belum memakai DI container yang lebih scalable,
- semua instance dibuat di satu tempat, sehingga ketika app membesar file ini bisa jadi padat.

---

## Lapisan Domain

### `lib/domain/entities/`
Entity adalah representasi inti data bisnis yang dipakai app.

Yang ada di sini:
- `UserEntity`
- `LessonEntity`
- `CourseSectionEntity`
- `CourseEntity`

#### `CourseEntity`
Ini entity paling penting untuk alur course.

Field utamanya:
- `id`
- `title`
- `description`
- `instructor`
- `color`
- `icon`
- `chaptersCount`
- `duration`
- `sections`
- `lessons`
- `isSaved`

Getter penting:
- `allLessons`
- `completedLessons`
- `totalLessons`
- `progressPercentage`

Maknanya:
- entity ini tidak cuma menyimpan data mentah,
- entity juga menghitung progress course.

Ini bagus karena business rule progress ada di domain entity, bukan di UI saja.

### `lib/domain/repositories/`
Ini adalah kontrak repository.

Contohnya:
- `AuthRepository`
- `CourseRepository`
- `LessonRepository`

Fungsi file kontrak ini:
- mendefinisikan apa yang boleh dilakukan domain,
- membuat domain tidak tergantung langsung ke data source konkret.

Ini salah satu ciri yang sudah sesuai dengan Clean Architecture.

### `lib/domain/usecases/`
Usecase di project ini masih sederhana dan kebanyakan hanya meneruskan panggilan repository.

Contoh:
- `LoginUseCase`
- `GetCoursesUseCase`
- `SearchCoursesUseCase`
- `ToggleSaveCourseUseCase`
- `IsLessonCompletedUseCase`
- `ToggleLessonCompletionUseCase`

Fungsi utamanya:
- memisahkan UI dari repository,
- menjadi tempat aturan bisnis bila nanti dibutuhkan validasi atau orkestrasi tambahan.

Saat ini usecase masih tipis, tapi strukturnya sudah benar.

---

## Lapisan Data

### `lib/data/models/`
Model di sini adalah bentuk data konkret yang dipakai di sisi data layer.

Contohnya:
- `User`
- `Lesson`
- `CourseSection`
- `Course`

Model ini punya:
- factory `fromJson`
- method `toJson`
- beberapa getter turunan seperti `lessons`, `completedLessons`, `totalLessons`, `progressPercentage`

Maknanya:
- model ini masih cukup kaya logika,
- tidak hanya jadi DTO pasif.

Ini berguna untuk prototipe atau app sederhana, tetapi untuk clean architecture yang ketat, logika seperti progress lebih aman dipusatkan di domain entity.

### `lib/data/mappers/`
Mapper bertugas mengubah model data ke entity domain dan sebaliknya.

Yang ada:
- `UserMapper`
- `LessonMapper`
- `CourseMapper`

Contoh penting di `CourseMapper`:
- `CourseMapper.toDomain(Course model)`
- `CourseMapper.fromDomain(CourseEntity entity)`

Fungsi utamanya:
- menjaga domain tetap bebas dari bentuk data persistence/UI,
- membuat perubahan struktur data lebih terisolasi.

Ini bagian yang sangat baik untuk maintainability.

### `lib/data/repositories/`
Repository implementation menghubungkan domain ke sumber data.

Yang ada:
- `AuthRepositoryImpl`
- `CourseRepositoryImpl`
- `LessonRepositoryImpl`

#### `CourseRepositoryImpl`
Ini inti alur course.

Fungsinya:
- `getCourses()` mengambil daftar course dari `DummyData`,
- `_updateCompletionStatus()` sinkronkan status lesson selesai dari `LocalStorage`,
- `searchCourses(query)` filter course berdasarkan judul dan deskripsi,
- `toggleSaveCourse(courseId)` ubah status saved,
- `getSavedCourses()` ambil course yang disimpan,
- `refreshCourses()` refresh status completion.

Catatan penting:
- repository ini masih memakai data lokal statik, bukan API atau database remote.
- jadi alurnya masih sangat cocok untuk demo, prototipe, atau MVP.

#### `LessonRepositoryImpl`
Fungsinya:
- cek completion status lesson,
- toggle completion,
- mark complete/incomplete,
- hitung jumlah lesson selesai,
- refresh status.

Repository ini pada dasarnya adalah adapter ke `LocalStorage`.

#### `AuthRepositoryImpl`
Fungsinya:
- validasi email dan password sederhana,
- membuat user simulasi,
- login tanpa backend nyata,
- logout dan getCurrentUser masih placeholder.

Artinya auth saat ini masih mock atau fake implementation.

### `lib/data/sources/`
Ada dua sumber data utama.

#### `dummy_data.dart`
Ini sumber course dan lesson statik.

Fungsinya:
- menyediakan konten course untuk aplikasi,
- menjadi backing data untuk semua list course dan section.

Strukturnya sudah cukup rapi:
- course punya sections,
- section punya lessons,
- lesson punya `type` seperti `video`, `document`, `quiz`.

Karena lesson type dipakai di UI, field ini harus tetap konsisten di data dan mapper.

#### `local_storage.dart`
Ini penyimpanan lokal berbasis Hive.

Fungsi utamanya:
- menyimpan daftar lesson yang sudah selesai,
- membaca status completion,
- menghapus status progress,
- menyediakan statistik progress.

Jadi, progress belajar user bersifat persisten walau app ditutup.

---

## Lapisan Presentation

### `lib/presentation/bloc/`
Blocs menghubungkan event UI dengan usecase.

#### `AuthBloc`
Alurnya:
- `AuthLoginEvent` -> panggil `LoginUseCase` -> emit `AuthSuccess` atau `AuthFailure`
- `AuthLogoutEvent` -> panggil `LogoutUseCase`
- `AuthClearErrorEvent` -> reset error state

Catatan:
- ada `Future.delayed` untuk simulasi network delay.
- berarti auth belum benar-benar berbasis server.

#### `CourseBloc`
Ini pengelola state course.

Event utama:
- `GetCoursesEvent`
- `SearchCoursesEvent`
- `ToggleSaveCourseEvent`
- `GetSavedCoursesEvent`
- `RefreshCoursesEvent`

State utama:
- `CourseInitial`
- `CourseLoading`
- `CourseLoaded`
- `CourseFailure`
- `SavedCoursesLoaded`

Alur kerjanya:
- ambil course,
- cari course,
- toggle saved,
- ambil saved courses,
- refresh progress.

#### `LessonBloc`
Ini mengatur status completion lesson.

Event utama:
- cek completion,
- toggle completion,
- mark complete,
- mark incomplete,
- refresh completion.

State utama:
- `LessonInitial`
- `LessonLoading`
- `LessonCompletionChecked`
- `LessonCompletionToggled`
- `LessonMarkedComplete`
- `LessonMarkedIncomplete`
- `LessonFailure`

### `lib/presentation/screens/`

#### `HomeScreen`
Fungsi utamanya:
- menampilkan sambutan user,
- menampilkan search bar,
- menampilkan statistik kursus dan progress,
- menampilkan rekomendasi course.

Alur penting di screen ini:
- `initState()` memanggil `GetCoursesEvent`,
- search bar memicu `SearchCoursesEvent`,
- statistik dihitung dari state `CourseLoaded`,
- nama user diambil dari `AuthBloc`.

Ini screen dashboard utama aplikasi.

#### `CourseListScreen`
Fungsi utamanya:
- menampilkan semua course dalam grid,
- menyediakan pencarian course,
- membuka detail course,
- mengubah status saved course.

Alur:
- `initState()` memanggil `GetCoursesEvent`,
- input search memicu `SearchCoursesEvent`,
- item course dibangun dari `CourseEntity` lalu dikonversi ke model untuk UI,
- tombol save memicu `ToggleSaveCourseEvent`.

#### `CourseDetailScreen`
Ini layar detail course yang paling menunjukkan alur domain ke UI.

Fungsinya:
- menampilkan header course,
- menampilkan informasi instructor dan durasi,
- menampilkan deskripsi course,
- menampilkan progress course,
- menampilkan sections dan lessons,
- membuka lesson detail,
- toggle status saved course.

Alur data yang terjadi:
- screen menerima `Course` model dari route,
- data diubah ke `CourseEntity`,
- jika state `CourseLoaded` tersedia, data terbaru diambil dari bloc,
- lalu dikonversi kembali ke model untuk rendering UI.

Catatan:
- bagian section dan lesson sudah cukup matang,
- progress section dihitung per section,
- status completed lesson ditampilkan langsung di UI.

#### `LessonDetailScreen`
Fungsi utamanya:
- menampilkan isi lesson,
- cek completion status saat screen dibuka,
- toggle status complete/incomplete,
- navigasi ke lesson sebelumnya dan berikutnya,
- refresh progress course saat kembali.

Alur penting:
- `initState()` memanggil `CheckLessonCompletionEvent`,
- tombol complete memanggil `ToggleLessonCompletionEvent`,
- setelah status berubah, `CourseBloc` di-refresh supaya progress course ikut update.

Ini menunjukkan hubungan antar state sudah cukup terhubung dengan baik.

### `lib/presentation/widgets/`
Widget yang terlihat penting:
- `course_card.dart`
- `lesson_tile.dart`
- `bottom_nav_bar.dart`
- `statistics_card.dart`
- `progress_indicator.dart`
- `feature_card.dart`

Perannya:
- memecah UI menjadi komponen yang bisa dipakai ulang,
- menjaga screen tidak terlalu gemuk,
- membuat tampilan lebih konsisten.

Namun, beberapa widget masih import model dari data layer, jadi belum benar-benar bersih secara arsitektur.

---

## Alur Fitur Utama End-to-End

### 1. Login
1. User masuk ke `LoginScreen`.
2. `AuthBloc` menerima event login.
3. `AuthBloc` memanggil `LoginUseCase`.
4. `LoginUseCase` memanggil `AuthRepository`.
5. `AuthRepositoryImpl` memvalidasi input lalu membuat user simulasi.
6. State berubah ke `AuthSuccess` dan user bisa masuk ke app.

### 2. Melihat daftar course
1. `HomeScreen` atau `CourseListScreen` memanggil `GetCoursesEvent`.
2. `CourseBloc` memanggil `GetCoursesUseCase`.
3. Usecase memanggil `CourseRepositoryImpl`.
4. Repository mengambil data dari `DummyData`.
5. Data dipetakan ke `CourseEntity`.
6. UI menampilkan course dan statistik progress.

### 3. Mencari course
1. User mengetik di search bar.
2. UI memanggil `SearchCoursesEvent`.
3. `CourseBloc` memanggil `SearchCoursesUseCase`.
4. Repository memfilter data course berdasarkan judul dan deskripsi.
5. Hasil ditampilkan ulang di screen.

### 4. Menyimpan course
1. User menekan bookmark.
2. UI memanggil `ToggleSaveCourseEvent`.
3. `CourseBloc` memanggil `ToggleSaveCourseUseCase`.
4. Repository mengubah flag `isSaved`.
5. `CourseBloc` memuat ulang data supaya UI konsisten.

### 5. Membuka course detail
1. User tap course card.
2. Route mengirim `Course` ke `CourseDetailScreen`.
3. Screen menampilkan sections dan lesson.
4. Progress dihitung dari `CourseEntity`.

### 6. Menandai lesson selesai
1. User membuka `LessonDetailScreen`.
2. Screen mengecek completion status lesson.
3. User menekan tombol complete/incomplete.
4. `LessonBloc` memanggil usecase completion.
5. `LessonRepositoryImpl` menyimpan status ke `LocalStorage`.
6. `CourseBloc` di-refresh agar progress course ikut berubah.

---

## Apakah Sudah Clean Architecture?

### Jawaban jujur
**Belum sepenuhnya.**

### Yang sudah sesuai
- Sudah ada pemisahan layer `presentation`, `domain`, dan `data`.
- Ada `repository abstraction` di domain.
- Ada `usecase` sebagai perantara logika aplikasi.
- Ada `mapper` untuk konversi data ke domain.
- UI tidak langsung mengakses storage.

### Yang belum sesuai sepenuhnya
- Beberapa file di `presentation` masih import `data/models` dan `data/mappers`.
- UI kadang masih berurusan langsung dengan model data, bukan hanya entity domain.
- Business rule tertentu masih tersebar di model dan screen.
- `ServiceLocator` masih manual dan mulai terasa padat.
- Data source masih dummy/local, jadi belum ada pemisahan data source yang lebih lengkap seperti remote/local repository pattern yang lebih jelas.

### Contoh kebocoran layer yang terlihat
Di beberapa file presentation ada import langsung ke data layer, misalnya:
- `HomeScreen` import `CourseMapper` dari data layer.
- `CourseDetailScreen` import `Course`, `CourseSection`, dan `Lesson` dari data layer.
- `LessonDetailScreen` import model data langsung.
- beberapa widget juga import model data langsung.

Ini berarti presentation belum sepenuhnya bergantung hanya pada domain.

---

## Apakah Mudah Dimodifikasi Jangka Panjang?

### Jawaban singkat
**Cukup mudah untuk sekarang, tapi belum ideal untuk jangka panjang kalau project terus membesar.**

### Kenapa masih cukup mudah
- Struktur folder sudah terpisah jelas.
- Alur state sudah memakai bloc.
- Repository bisa diganti tanpa banyak mengubah UI jika boundary-nya dijaga.
- Mapper membantu meminimalkan dampak perubahan struktur data.

### Kenapa belum ideal untuk jangka panjang
- Presentation masih terlalu tahu bentuk data dari layer bawah.
- Ada duplikasi logika progress antara model dan entity.
- `ServiceLocator` manual bisa makin sulit dirawat saat dependency bertambah.
- Screen mulai memuat cukup banyak logika tampilan dan perhitungan.
- Karena data masih dummy/local, transisi ke backend nyata nanti akan butuh refactor tambahan.

---

## Penilaian Maintenance

### Nilai kuat
- Struktur dasar sudah rapi.
- Feature utama sudah terpecah per layer.
- Progress course dan lesson sudah memiliki alur yang masuk akal.
- Domain entity sudah dipakai untuk perhitungan penting.

### Risiko maintenance
- Kalau fitur baru bertambah, kebocoran layer akan membuat perubahan lebih mahal.
- Jika `Course` dan `Lesson` model berubah, beberapa screen dan widget kemungkinan ikut terdampak langsung.
- Penambahan API, pagination, caching, dan error handling serius akan menuntut refactor di data layer.

### Kesimpulan maintenance
- **Medium maintainability sekarang**.
- **Bisa jadi high maintainability** kalau boundary layer diperketat.

---

## Saran Perbaikan Prioritas

### Prioritas 1: Bersihkan dependency di presentation
- Hindari import `data/models` di screen dan widget.
- Presentation sebaiknya pakai entity/domain model saja.
- Pindahkan kebutuhan transformasi data ke bloc atau usecase bila perlu.

### Prioritas 2: Pusatkan business rule di domain
- Logika progress, total lesson, dan completed lesson sebaiknya dominan di entity/domain.
- Kurangi logika yang sama di model data.

### Prioritas 3: Pisahkan source data lebih jelas
- Kalau nanti ada backend, buat pemisahan `remote datasource` dan `local datasource`.
- Repository hanya jadi orkestrator sumber data.

### Prioritas 4: Perkuat dependency injection
- Kalau project makin besar, pertimbangkan DI container yang lebih scalable daripada singleton manual.

### Prioritas 5: Kurangi logika UI yang terlalu berat
- Screen sebaiknya fokus render dan event handling.
- Perhitungan statistik bisa dipindah ke bloc/entity/helper domain.

---

## Kesimpulan Akhir
Project ini **sudah punya fondasi arsitektur yang bagus** dan **sudah mendekati Clean Architecture**, terutama pada pemisahan `bloc`, `usecase`, `repository`, dan `mapper`.

Tetapi kalau dinilai secara ketat, **belum clean architecture penuh** karena masih ada kebocoran antara presentation dan data layer, serta beberapa logika bisnis masih tersebar di beberapa tempat.

Kalau targetnya:
- **dipakai sekarang dengan nyaman**: ya, sudah cukup baik.
- **dibawa berkembang dalam jangka panjang**: bisa, tetapi sebaiknya dirapikan lagi supaya lebih tahan terhadap perubahan fitur, API, dan kompleksitas.
