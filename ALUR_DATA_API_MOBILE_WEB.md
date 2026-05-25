# Alur Data Mobile + Web + API + Database

Dokumen ini menjelaskan dengan bahasa sederhana bagaimana data diambil dari database, bagaimana API dibuat dan bekerja, bagaimana Flutter memakai Dio untuk memanggil API, dan bagaimana data yang sama bisa dipakai oleh web dan mobile.

## Istilah Penting

Di project ini ada perbedaan penamaan antara mobile dan Laravel:

- `lesson` di mobile = `content` di Laravel
- `section` di mobile = `lesson` di Laravel
- `course` sama di mobile dan Laravel

Ini penting karena kalau salah mapping, data progress bisa terlihat tidak sinkron walaupun sebenarnya tersimpan di database.

## Gambaran Besar

Ada 2 jalur utama pengambilan data:

1. Web Laravel
- Browser membuka halaman web
- Request masuk ke route web Laravel
- Controller Laravel mengambil data dari database
- Data ditampilkan ke Blade view

2. Mobile Flutter
- Screen Flutter memanggil BLoC / repository
- Repository memakai Dio untuk request ke API Laravel
- API Laravel mengambil data dari database
- API mengembalikan JSON
- Flutter membaca JSON dan menampilkan ke UI

## Alur Web

Contoh alur ketika web membuka halaman nilai atau progress:

1. User buka halaman di browser.
2. Route web memanggil controller.
3. Controller menjalankan query ke model Eloquent.
4. Model membaca data dari tabel database.
5. Controller mengolah hasil query.
6. Controller mengirim data ke Blade view.
7. Blade menampilkan data ke halaman web.

Contoh file yang sering terlibat:

- [routes/web.php](../LMS_LARAVEL/routes/web.php)
- [ProgressController.php](../LMS_LARAVEL/app/Http/Controllers/ProgressController.php)
- [CourseApiController.php](../LMS_LARAVEL/app/Http/Controllers/Api/CourseApiController.php)
- [QuizApiController.php](../LMS_LARAVEL/app/Http/Controllers/Api/QuizApiController.php)
- [EssayApiController.php](../LMS_LARAVEL/app/Http/Controllers/Api/EssayApiController.php)

## Alur Mobile

Contoh alur ketika mobile membuka course, quiz, essay, atau halaman hasil:

1. User membuka screen Flutter.
2. Screen mengirim event ke BLoC.
3. BLoC memanggil use case.
4. Use case memanggil repository.
5. Repository memilih sumber data:
- remote API via Dio
- local cache / local storage sebagai fallback
6. Dio mengirim HTTP request ke Laravel API.
7. Laravel API membaca database dan mengembalikan JSON.
8. Repository mengubah JSON menjadi model/entity.
9. BLoC mengirim state ke UI.
10. UI menampilkan data ke user.

Contoh file Flutter yang terlibat:

- [api_endpoints.dart](../lms_mobile_app/lib/src/core/config/constants/api_endpoints.dart)
- [course_remote_data_source_impl.dart](../lms_mobile_app/lib/src/features/courses/data/datasources/course_remote_data_source_impl.dart)
- [quiz_remote_datasource_impl.dart](../lms_mobile_app/lib/src/features/lessons/data/datasources/quiz_remote_datasource_impl.dart)
- [essay_remote_datasource_impl.dart](../lms_mobile_app/lib/src/features/lessons/data/datasources/essay_remote_datasource_impl.dart)
- [lesson_result_remote_impl.dart](../lms_mobile_app/lib/src/features/lessons/data/repositories/lesson_result_remote_impl.dart)
- [lesson_module.dart](../lms_mobile_app/lib/src/core/di/modules/lesson_module.dart)

## Apa Itu Dio

Dio adalah library HTTP client di Flutter untuk mengirim request ke server.

Secara sederhana, Dio melakukan hal ini:

- `GET` untuk mengambil data
- `POST` untuk mengirim data
- `PUT/PATCH` untuk mengubah data
- `DELETE` untuk menghapus data

Di project ini, Dio dipakai untuk memanggil endpoint Laravel API.

Contoh:

- ambil daftar course
- ambil quiz berdasarkan lesson/content
- submit quiz
- submit essay
- autosave draft essay
- mark lesson complete
- ambil history nilai dan hasil

### Kenapa Dio perlu token?

Karena data user harus aman dan spesifik per akun.

Biasanya request dikirim dengan header seperti:

```http
Authorization: Bearer <token>
```

Token ini dihasilkan saat login, lalu dipakai lagi pada request berikutnya supaya server tahu siapa user yang sedang request.

## Bagaimana API Dibuat di Laravel

Laravel API dibuat lewat 3 bagian utama:

1. Route
- Ditulis di [routes/api.php](../LMS_LARAVEL/routes/api.php)
- Route menentukan URL mana yang dipanggil dan controller mana yang menjalankan logikanya

2. Controller
- Controller menerima request dari mobile atau web
- Controller memvalidasi user dan parameter
- Controller mengambil data dari model/database
- Controller mengembalikan response JSON

3. Model / Eloquent
- Model mewakili tabel database
- Relasi antar tabel didefinisikan di model
- Eloquent memudahkan query seperti `with()`, `whereHas()`, `syncWithoutDetaching()`, dan lain-lain

Contoh sederhana route API:

```php
Route::middleware('mobile.api.user')->group(function () {
    Route::get('/mobile/courses', [CourseApiController::class, 'index']);
    Route::post('/mobile/quizzes/{quiz}/attempts/{attempt}/submit', [QuizApiController::class, 'submitAttempt']);
});
```

Artinya:

- URL tersebut hanya bisa diakses user mobile yang sudah login
- request akan masuk ke controller yang ditentukan
- controller lalu memproses data

## Bagaimana API Mengambil Data

Urutannya biasanya seperti ini:

1. Laravel menerima request.
2. Middleware mengecek autentikasi.
3. Controller memanggil model.
4. Model melakukan query ke database.
5. Laravel mengembalikan response JSON.

Contoh pola query:

- `Course::query()` untuk memulai query course
- `with([...])` untuk eager loading relasi
- `whereHas(...)` untuk memfilter berdasarkan relasi
- `first()` / `get()` untuk mengambil hasil

### Contoh di Course API

[CourseApiController.php](../LMS_LARAVEL/app/Http/Controllers/Api/CourseApiController.php) mengambil course beserta section dan content lalu menandai apakah sebuah content sudah selesai untuk user tersebut.

Contoh alurnya:

- ambil course yang sudah di-enroll user
- eager load `lessons.contents.quiz`
- untuk setiap content, cek `hasCompletedContent($content)`
- response JSON mengirim `isCompleted` ke mobile

Ini penting supaya mobile bisa menampilkan progress yang sama dengan web.

## Bagaimana Data Quiz Bekerja

### 1. Ambil quiz

Mobile memanggil endpoint quiz, misalnya:

- `GET /api/mobile/quizzes/by-lesson/{contentId}`

Controller Laravel akan:

- mencari quiz yang terhubung ke content/lesson
- mengambil question dan option
- mengecek apakah user sudah pernah submit
- mengecek apakah user sudah lulus
- mengirim JSON ke mobile

### 2. Start attempt

Saat user mulai quiz, mobile memanggil:

- `POST /api/mobile/quizzes/{quiz}/attempts`

Laravel akan membuat record `quiz_attempts`.

### 3. Submit attempt

Saat user selesai quiz, mobile memanggil:

- `POST /api/mobile/quizzes/{quiz}/attempts/{attempt}/submit`

Laravel akan:

- validasi jawaban
- menghitung score
- menentukan lulus atau tidak
- menyimpan jawaban ke `question_answers`
- menyimpan score dan `passed` ke `quiz_attempts`
- jika lulus, menandai content selesai di pivot `content_user`

### 4. Kenapa quiz web dan mobile bisa sinkron?

Karena sumber kebenaran ada di database Laravel.

Begitu quiz disimpan di server:

- web bisa baca `quiz_attempts`
- mobile bisa baca endpoint results/attempt history
- status completed bisa muncul di dua platform

## Bagaimana Data Essay Bekerja

### 1. Ambil essay

Mobile memanggil:

- `GET /api/mobile/essays/by-lesson/{content}`

Laravel akan mengambil:

- content essay
- daftar essay question
- submission user jika sudah ada

### 2. Draft / autosave

Saat user baru mengetik jawaban tapi belum submit, mobile menyimpan draft.

Di project ini draft disimpan:

- lokal di device
- dan juga bisa disinkronkan ke server lewat endpoint draft

Tujuannya supaya draft tidak hilang dan bisa terlihat juga di web.

### 3. Submit essay

Saat user submit essay, mobile memanggil:

- `POST /api/mobile/essays/{content}/submit`

Laravel akan:

- menyimpan `essay_submissions`
- menyimpan `essay_answers`
- menandai `content_user.completed = true`
- mengembalikan response ke mobile

### 4. Kenapa essay bisa tampak sama di web dan mobile?

Karena draft dan submission disimpan ke database yang sama.

Jadi:

- kalau submit di mobile, web bisa baca hasilnya
- kalau submit di web, mobile bisa baca submission itu saat reload data

## Bagaimana History Nilai / Hasil Bekerja

Ini bagian yang sempat bikin bingung.

### Problem sebelumnya

Sebelumnya mobile masih menyimpan history hasil hanya di LocalStorage.

Akibatnya:

- setelah reinstall APK, LocalStorage kosong
- halaman `Nilai & Hasil` jadi kosong
- hasil quiz yang sudah ada di web tidak ikut muncul di mobile

### Solusi sekarang

Mobile sekarang memakai repository hasil yang mengambil data dari server dulu, lalu cache lokal sebagai cadangan.

Alurnya:

1. mobile buka halaman nilai
2. repository memanggil endpoint results Laravel
3. Laravel mengambil semua `quiz_attempts` dan `essay_submissions` milik user untuk course itu
4. Laravel mengubah data menjadi JSON list attempt
5. Flutter mengubah JSON itu menjadi `LessonAttempt`
6. UI menampilkan hasil
7. hasil juga disimpan ke LocalStorage untuk fallback

Jadi setelah reinstall:

- data server tetap ada
- mobile bisa tarik ulang hasil dari Laravel
- halaman nilai tetap terisi

## Database Yang Dipakai

Beberapa tabel yang paling sering terlibat:

- `users` → data akun
- `courses` → data course
- `lessons` → lesson pada web / section pada mobile
- `contents` → content pada web / lesson pada mobile
- `quiz_attempts` → riwayat percobaan quiz
- `question_answers` → jawaban per question quiz
- `essay_submissions` → submission essay
- `essay_answers` → jawaban essay per question
- `content_user` → pivot completion content
- `lesson_user` → pivot completion lesson
- `course_user` / enrollment pivot → user enrolled ke course

## Kenapa Status Completion Bisa Sinkron Tapi Nilai Tidak

Karena completion dan history hasil adalah dua hal berbeda.

- Completion biasanya hanya butuh pivot `content_user` atau `lesson_user`
- History hasil butuh tabel attempt/submission seperti `quiz_attempts` dan `essay_submissions`

Jadi walaupun content selesai sudah sinkron, kalau history hasil masih local-only, maka halaman nilai bisa kosong setelah reinstall.

## Ringkasan Alur End-to-End

### Mobile login

- Flutter login via Dio
- Laravel auth mengembalikan token
- token disimpan di local storage
- token dipakai untuk request berikutnya

### Mobile ambil course

- Flutter memanggil `/mobile/courses`
- Laravel ambil course yang sesuai user
- Laravel kirim JSON course + sections + contents
- mobile tampilkan daftar course

### Mobile / web kerjakan quiz

- submit quiz tersimpan di `quiz_attempts`
- jawaban tersimpan di `question_answers`
- jika lulus, `content_user` ditandai selesai
- web dan mobile sama-sama baca data yang sama

### Mobile / web kerjakan essay

- draft bisa disimpan
- submission tersimpan di `essay_submissions`
- jawaban tersimpan di `essay_answers`
- jika submit, completion ikut diperbarui

### Halaman Nilai & Hasil

- mobile ambil data attempt dari server
- server mengembalikan semua hasil course itu
- mobile bisa tampilkan ulang walau app diinstall ulang

## Kenapa Mapping Nama Harus Diperhatikan

Karena mobile dan Laravel tidak selalu memakai istilah yang sama.

Contoh:

- mobile `section` = Laravel `lesson`
- mobile `lesson` = Laravel `content`

Kalau request salah mengirim ID:

- completion bisa masuk ke record yang salah
- history hasil bisa tidak muncul
- halaman detail bisa kosong

## Cara Mudah Membaca Arsitektur Ini

Kalau kamu bingung, ingat 4 kata kunci ini:

1. UI
- layar Flutter atau Blade web

2. Request
- mobile pakai Dio, web pakai route Laravel

3. Controller
- tempat Laravel menerima dan memproses request

4. Database
- sumber data utama untuk progress, nilai, dan submission

## Kesimpulan Singkat

- Web dan mobile harus membaca database yang sama.
- Completion sinkron lewat pivot table completion.
- Nilai quiz/essay sinkron lewat attempt/submission tables.
- Flutter memakai Dio untuk memanggil API Laravel.
- Laravel API dibuat dari route → controller → model → JSON response.
- Kalau data hilang setelah reinstall, itu biasanya karena sebelumnya masih hanya tersimpan lokal, bukan di server.

## File Penting Untuk Dibaca Setelah Ini

- [routes/api.php](../LMS_LARAVEL/routes/api.php)
- [CourseApiController.php](../LMS_LARAVEL/app/Http/Controllers/Api/CourseApiController.php)
- [QuizApiController.php](../LMS_LARAVEL/app/Http/Controllers/Api/QuizApiController.php)
- [EssayApiController.php](../LMS_LARAVEL/app/Http/Controllers/Api/EssayApiController.php)
- [CourseResultsApiController.php](../LMS_LARAVEL/app/Http/Controllers/Api/CourseResultsApiController.php)
- [api_endpoints.dart](../lms_mobile_app/lib/src/core/config/constants/api_endpoints.dart)
- [lesson_module.dart](../lms_mobile_app/lib/src/core/di/modules/lesson_module.dart)
- [lesson_result_remote_impl.dart](../lms_mobile_app/lib/src/features/lessons/data/repositories/lesson_result_remote_impl.dart)
- [results_list_screen.dart](../lms_mobile_app/lib/src/features/lessons/presentation/screens/results_list_screen.dart)
