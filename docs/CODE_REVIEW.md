# Code Review — BASS Training Mobile App

> Tanggal Review: 17 September 2026
> Scope: 46 screen, 25 BLoC/Cubit, 74 widget

> **Status audit terakhir: 30 September 2026** — seluruh 32 temuan diperiksa
> ulang terhadap kode saat ini.
>
> Legenda: ✅ selesai/diverifikasi · 🟡 sebagian · 🔴 masih terbuka

---

## 🔴 HIGH PRIORITY — Bug Fungsional

### 1. `copyWith` reset flag `submitted` ke `false`

- **File:** `lib/src/features/lessons/presentation/bloc/document_submission/document_submission_cubit.dart:39`
- **Masalah:** Setiap panggilan `copyWith` tanpa parameter `submitted` akan mereset flag ke `false`. Jika user submit dokumen, state `submitted: true` akan hilang saat `copyWith` dipanggil untuk field lain.
- **Fix:** Gunakan nullable sentinel pattern: `this.submitted` tanpa default `false`.
- **Status (30 Sep 2026):** ✅ **Selesai** — `submitted ?? this.submitted`, plus
  reset eksplisit `submitted: false` di awal `submit()` agar tepi false→true tetap
  ada untuk pengumpulan berikutnya. Commit `d2ffa44`; test:
  `test/features/lessons/document_submission_cubit_test.dart`.

### 2. `copyWith` reset flag `saved` ke `false`

- **File:** `lib/src/features/instructor/presentation/cubit/document_grading_cubit.dart:38`
- **Masalah:** Sama seperti #1 — flag `saved` di-reset ke `false` setiap `copyWith` dipanggil.
- **Fix:** Sama — gunakan nullable sentinel.
- **Status (30 Sep 2026):** ✅ **Selesai** — `saved ?? this.saved`, selaras dengan
  `EssayGradingState`/`CaseStudyGradingState` yang sudah benar. Commit `d2ffa44`;
  test: `test/features/instructor/document_grading_cubit_test.dart`.

### 3. `submit()` overwrite `saved: true` dengan `load()`

- **File:** `lib/src/features/instructor/presentation/cubit/essay_grading_cubit.dart:71-83`
- **Masalah:** `submit()` emit `saved: true` lalu langsung panggil `load()`. State berubah ke loading sebelum UI sempat menampilkan status tersimpan.
- **Fix:** Tambahkan delay kecil ataupisahkan state `saved` dari `loading`.
- **Status (30 Sep 2026):** ✅ **Selesai (Batch B)** — flag `saved` dihapus dari
  ketiga state: audit membuktikan tidak ada UI yang membacanya (feedback
  "tersimpan" sudah datang dari `bool` return `submit()` + SnackBar). Flash
  spinner diatasi dengan guard `status == loading && detail == null` agar konten
  tetap tampil selama penyegaran. Test: `essay_grading_cubit_test.dart`,
  `instructor_essay_grading_screen_test.dart`.

### 4. Pattern `saved` overwrite di `CaseStudyGradingCubit`

- **File:** `lib/src/features/instructor/presentation/cubit/case_study_grading_cubit.dart:58-74`
- **Masalah:** Sama — `submit()` panggil `load()` setelah emit `saved: true`.
- **Fix:** Sama — pisahkan state `saved` dari `loading`.
- **Status (30 Sep 2026):** ✅ **Selesai (Batch B)** — sama dengan #3; guard
  `status == loading && review == null` di layar studi kasus. Test:
  `case_study_grading_cubit_test.dart`.

### 5. Optimistic toggle save ter-deduplicate oleh Equatable

- **File:** `lib/src/features/courses/presentation/bloc/course/course_bloc.dart:113-145`
- **Masalah:** Setelah optimistic update, state revert ke `previous`. Jika `previous` adalah `CourseLoaded` dengan list yang sama, Equatable deduplication akan suppress emit revert — UI menampilkan state stale.
- **Fix:** Force-emit atau gunakan state instance berbeda untuk revert.
- **Status (30 Sep 2026):** ✅ **Tidak berlaku** — `previous` sudah di-capture
  sebelum emit optimis sejak commit `8cf0722` (3 Jun 2026). Karena itu revert
  selalu dibandingkan terhadap state optimis yang berbeda, jadi tidak pernah
  dideduplikasi oleh Equatable.

### 6. No try/catch di `joinClassUseCase`

- **File:** `lib/src/features/home/presentation/bloc/home_bloc.dart:17-28`
- **Masalah:** `result.fold` diasumsikan selalu mengembalikan `Either`, tapi jika use case throw synchronous, BLoC crash.
- **Fix:** Bungkus dalam try/catch.
- **Status (30 Sep 2026):** ✅ **Selesai** — `try/catch` + guard `isClosed`;
  exception kini menjadi `HomeJoinClassFailure` alih-alih meninggalkan state di
  `loading`. Commit `d2ffa44`; test: `test/features/home/home_bloc_test.dart`.

---

## 🔴 HIGH PRIORITY — UI/Layout

### 7. Mega-widget `DocumentSubmissionPanel` (732 baris)

- **File:** `lib/src/features/lessons/presentation/widgets/document_submission/document_submission_panel.dart`
- **Masalah:** 10+ method helper, 2 dialog konfirmasi, file picking, URL launching, dan BlocConsumer — semua dalam satu file.
- **Fix:** Pecah menjadi:
  - `DocumentSubmissionHeader`
  - `DocumentSubmissionStatusBanner`
  - `DocumentSubmissionFileCard`
  - `DocumentSubmissionUploadArea`
  - `DocumentSubmissionHistory`
  - Orkestrasi tetap di parent panel

### 8. Mega-widget `DiscussionPanel` (588 baris)

- **File:** `lib/src/features/lessons/presentation/widgets/discussion/discussion_panel.dart`
- **Masalah:** `_EmptyView`, `_ErrorView`, `_ThreadTile`, `_ReplyTile`, `_AuthorRow`, `_InlineComposer`, `_NewTopicComposer` — semua dalam satu file.
- **Fix:** Pecah ke file terpisah dalam folder `discussion/`.

### 9. Mega-widget `LessonDrawer` (406 baris)

- **File:** `lib/src/features/lessons/presentation/widgets/lesson_drawer.dart`
- **Masalah:** Drawer header + progress, section expansion tiles, individual lesson items — campur jadi satu.
- **Fix:** Pecah menjadi:
  - `LessonDrawerHeader`
  - `LessonSectionTile`
  - `LessonDrawerItem`

### 10. Hardcoded warna bypass `AppColors`

- **File:** 10+ file (lihat daftar lengkap di bawah)
- **Masalah:** `Colors.green`, `Colors.red`, `Color(0xFF...)` digunakan langsung tanpa melalui `AppColors`. Tidak konsisten dan tidak dark-mode ready.
- **File terdampak:**
  - `quiz_performance_overview.dart` — `Colors.green`, `Colors.orange`, `Colors.blue`, `Colors.purple`
  - `quiz_question_review_item.dart` — `Colors.green`, `Colors.red`, `Colors.white`
  - `lesson_drawer.dart` — `Color(0xFFFFF7F4)`, `Color(0xFFFDFDFF)`, `Colors.green`, `Colors.grey`
  - `quiz_attempt_history_chips.dart` — `Color(0xFFEFF2F7)`
  - `quiz_hero_card.dart` — `Color(0xFF0EA5E9)`, `Color(0xFF22C55E)`, `Color(0xFFFF8A3D)`
  - `quiz_leaderboard_card.dart` — `Color(0xFFE0A400)`, `Color(0xFF9AA0A6)`, `Color(0xFFCD7F32)`
  - `discussion_button.dart` — `Color(0xFFDC0000)`
  - `course_lesson_tile.dart` — beberapa `Color(0xFF...)`
- **Fix:** Tambahkan semantic color ke `AppColors` dan referensikan dari semua widget.

### 11. Hampir nol aksesibilitas (`Semantics`/`tooltip`)

- **File:** 74 widget
- **Masalah:** Hanya 3 tooltip dan 1 Semantics widget ditemukan. Interactive elements (button, card, quiz option) tidak punya aksesibilitas.
- **Widget yang perlu diprioritaskan:**
  - Icon-only buttons (back, menu, save, bell)
  - Quiz option cards
  - `ProgressRing` (label: "Progress: X%")
  - `AchievementMedal` (label: locked/unlocked)
- **Fix:** Tambahkan `Semantics` wrapper dan `tooltip` parameter.
- **Status (30 Sep 2026):** 🟡 **Sebagian** — jumlah `tooltip` naik dari 3 menjadi
  11; `Semantics` naik dari 1 menjadi 4
  (`intro_screen.dart:359`, `home_recommended_courses.dart:200`,
  `question_navigator_widget.dart:106`, `app_empty_state.dart:51`), tetapi masih
  jauh dari kebutuhan (46 screen / 74 widget).

---

## 🟠 MEDIUM PRIORITY — State Management

### 12. No droppable transformer di `AuthBloc`

- **File:** `lib/src/features/authentication/presentation/bloc/auth/auth_bloc.dart:34-63`
- **Masalah:** Double-tap login bisa trigger 2x request parallel.
- **Fix:** Tambahkan `on<AuthLoginEvent>(transformer: droppable())`.
- **Status (30 Sep 2026):** ✅ **Selesai (Batch C)** — tanpa dependensi baru:
  `bloc_concurrency` batal dipakai karena `pubspec.lock` repo tidak dapat
  dipenuhi SDK mesin ini (Dart 3.11.5 vs syarat `>=3.12.0`, `pub get` akan
  menurunkan 21 paket). Diganti flag `_credentialOpInFlight` yang di-reset di
  `finally`, bukan guard state yang dapat dilewati saat event lain mengubah
  state. Login dan register memakai semantik droppable yang sama; generation
  auth juga membuang hasil restore/login lama. Guard UI tetap ada
  (`login_screen.dart:225`). Test mencakup login/register ganda, silang
  login-register, dan restore session yang selesai di tengah login.

### 13. 4 state class identik di `LessonBloc`

- **File:** `lib/src/features/lessons/presentation/bloc/lesson/lesson_state.dart:21-55`
- **Masalah:** `LessonCompletionChecked`, `LessonCompletionToggled`, `LessonMarkedComplete`, `LessonMarkedIncomplete` — semua structurally identical (hanya bawa `lessonId`).
- **Fix:** Gabung jadi 1 `LessonActionSuccess` dengan enum `LessonActionType`.

### 14. God-state `EssayState` (12 field)

- **File:** `lib/src/features/lessons/presentation/bloc/essay/essay_state.dart:4-108`
- **Masalah:** Mix UI state, data state, dan transient messages dalam satu class.
- **Fix:** Pisahkan menjadi sub-state atau gunakan nested state pattern.

### 15. `dynamic attempt` di `QuizSubmitted`

- **File:** `lib/src/features/lessons/presentation/bloc/quiz/quiz_state.dart:67-87`
- **Masalah:** `dynamic` defeat type safety dan Equatable comparison.
- **Fix:** Typing yang benar atau gunakan `Map<String, dynamic>`.

### 16. Artificial 700ms delay di production

- **File:** `lib/src/features/lessons/presentation/bloc/essay/essay_bloc.dart:122`
- **Masalah:** `Future.delayed(700ms)` untuk "UX simulation" — tidak seharusnya di production.
- **Fix:** Hapus delay.

### 17. `_msg()` helper di-copy-paste di 10+ file

- **File:**
  - `notifications_cubit.dart`
  - `certificate_cubit.dart`
  - `discussion_structure_cubit.dart`
  - `discussion_feed_cubit.dart`
  - `instructor_overview_cubit.dart`
  - `essay_grading_cubit.dart`
  - `document_grading_cubit.dart`
  - `case_study_grading_cubit.dart`
  - `document_submission_cubit.dart`
  - `discussion_cubit.dart`
- **Fix:** Ekstrak ke `lib/src/core/utils/error_utils.dart`.

---

## 🟠 MEDIUM PRIORITY — Widget Duplication

### 18. Gradient header diduplikasi di 6+ tempat

- **File:**
  - `quiz_intro_widget.dart:38-44`
  - `essay_page_header.dart:14-18`
  - `document_submission_panel.dart:157-163`
  - `lesson_drawer.dart:29-33, 154-157, 374-376`
- **Masalah:** `[AppColors.red, AppColors.tomato]` gradient + borderRadius 18-20 + boxShadow — identik di semua tempat.
- **Fix:** Buat `BrandSectionHeader` shared widget.

### 19. `_MetricDivider` dan `_StatDivider` identik

- **File:**
  - `home_summary_card.dart:146-155` — `_MetricDivider`
  - `home_instructor_summary.dart:183-193` — `_StatDivider`
- **Fix:** Ekstrak ke `MetricDivider` shared widget.

### 20. `_overline()` identik di hero cards

- **File:**
  - `home_continue_learning.dart:151-161`
  - `home_continue_grading.dart:125-135`
- **Fix:** Ekstrak ke `HeroOverline` shared widget.

### 21. Missing `key()` di dynamic lists

- **File:**
  - `quiz_questions_widget.dart:133-141`
  - `quiz_question_review_item.dart:72`
  - `course_section_accordion.dart:135-142`
  - `home_quick_actions.dart:188`
  - `month_calendar.dart:193-218`
  - `quiz_leaderboard_card.dart:72`
- **Fix:** Tambahkan `key: ValueKey(...)`.

### 22. Nama file `_widget.dart` tidak konsisten

- **File:** 11 file di `lib/src/features/lessons/presentation/widgets/`
- **Masalah:** Suffix `_widget.dart` tidak dipakai di widget lain.
- **Fix:** Rename: `quiz_intro.dart`, `quiz_questions.dart`, `option_card.dart`, dll.

---

## 🔵 LOW PRIORITY — Best Practice

### 23. `_sparkle()` identik di 3 CustomPainter

- **File:**
  - `quiz_artwork.dart:216-228`
  - `learning_artwork.dart:247-258`
  - `achievement_artwork.dart:160-172`
- **Fix:** Ekstrak ke mixin atau static helper.

### 24. `AppColors.violet` tidak konsisten

- **File:** `lib/src/shared/widgets/form_fields.dart:71, 84, 127`
- **Masalah:** Waktu `violet` tidak seharmonis brand palette merah.
- **Fix:** Ganti ke `AppColors.brandText` atau `AppColors.brandPrimary`.

### 25. `AuthRegisterSuccess` dead code

- **File:** `lib/src/features/authentication/presentation/bloc/auth/auth_state.dart:31-38`
- **Masalah:** State ini didefinisikan tapi tidak pernah di-emit (selalu `AuthSuccess` yang di-emit).
- **Fix:** Hapus atau gunakan.

### 26. No pagination di `DiscussionFeedCubit`

- **File:** `lib/src/features/discussions/presentation/cubit/discussion_feed_cubit.dart:38-52`
- **Masalah:** Load semua item sekaligus — tidak scalable.
- **Fix:** Implementasi `loadMore()` dengan pagination.

### 27. `Future.microtask` di constructor BLoC

- **File:**
  - `auth_bloc.dart:31`
  - `course_bloc.dart:47`
- **Masalah:** Event bisa fire setelah BLoC di-dispose.
- **Fix:** Guard dengan `if (!isClosed)` atau pindah ke `on<AppStarted>`.
- **Status (30 Sep 2026):** ✅ **Selesai (Batch C)** — CourseBloc sudah bersih,
  AuthBloc kini `if (isClosed) return;` sebelum `add`. Catatan: guard `isClosed`
  **tidak cukup** untuk `add()` — `Bloc.close()` menutup event controller lebih
  dulu (`bloc` 8.1.4 `bloc.dart:282`) sedangkan `isClosed` mengacu ke state
  controller (`bloc_base.dart:80`), jadi ditambah `try/on StateError` sebagai
  jaring pengaman. Test: "bloc ditutup sebelum microtask tidak menambah event".

### 28. Status enum mulai `loading` tanpa `initial`

- **File:**
  - `essay_grading_cubit.dart:6` — `EssayGradingStatus { loading, loaded, error }`
  - `document_grading_cubit.dart:6` — `DocGradingStatus { loading, loaded, error }`
  - `case_study_grading_cubit.dart:5` — `CaseGradingStatus { loading, loaded, error }`
- **Masalah:** Cubit langsung mulai dalam state `loading` (default enum value), UI tampilkan spinner sebelum aksi apapun.
- **Fix:** Tambahkan `initial` sebagai value pertama.

### 29. `QuizResultWidget` monolitik (286 baris)

- **File:** `lib/src/features/lessons/presentation/widgets/quiz/quiz_result_widget.dart`
- **Fix:** Pecah menjadi `QuizResultHeroCard`, `QuizResultScoreCard`, `QuizResultInfoBox`, `QuizResultNavigation`.

### 30. `LessonDrawerItem` butuh `key()`

- **File:** `lib/src/features/lessons/presentation/widgets/lesson_drawer.dart`
- **Fix:** Tambahkan `ValueKey` pada lesson items.

---

## Temuan Audit Lanjutan — Batch C

### 31. Race response auth terlambat menghidupkan sesi setelah logout

- **Prioritas:** 🔴 High
- **File:**
  - `lib/src/features/authentication/data/repositories/auth_repository_impl.dart`
  - `lib/src/features/authentication/presentation/bloc/auth/auth_bloc.dart`
  - `lib/src/core/utils/local_storage.dart`
- **Masalah:** Restore session/login/register/profile/OTP yang masih berjalan
  dapat menyimpan user lama atau emit `AuthSuccess` setelah logout. Timeout
  BLoC juga tidak membatalkan request Dio, sedangkan token dan user disimpan
  pada dua key sehingga mutasi dapat terlihat setengah selesai.
- **Status (30 Sep 2026):** ✅ **Selesai (Batch C)** — sesi disimpan atomik pada
  satu key `auth_session` dengan fallback migrasi key legacy, tombstone logout,
  dan revision untuk conditional save/clear. Repository memakai operation
  epoch + `CancelToken`, logout lokal selesai lebih dulu dan revokasi server
  berjalan best-effort dengan header token lama. AuthBloc memakai generation
  bersama untuk restore/login/register/logout. Test mencakup response/error
  terlambat, logout vs login, timeout cancellation, secondary auth mutation,
  migrasi legacy, tombstone, dan revision lama.

### 32. `BlocProvider(create:)` menutup singleton milik GetIt

- **Prioritas:** 🟠 Medium
- **File:** `lib/main.dart:99-107`
- **Masalah:** `AuthBloc` dan `LessonBloc` didaftarkan sebagai lazy singleton,
  tetapi `BlocProvider(create:)` menganggap instance miliknya dan menutupnya
  saat provider dilepas. GetIt kemudian dapat mengembalikan BLoC yang sudah
  ditutup; `AppRouter` juga memegang singleton `AuthBloc` yang sama.
- **Status (30 Sep 2026):** ✅ **Selesai (Batch C)** — keduanya memakai
  `BlocProvider.value`, sehingga lifecycle singleton tetap dimiliki GetIt/app.

---

## Ringkasan Statistik

| Kategori | Jumlah |
|----------|--------|
| Total temuan | 32 |
| 🔴 High priority | 12 |
| 🟠 Medium priority | 12 |
| 🔵 Low priority | 8 |
| File unik terdampak | ~40 |
| Widget mega (>300 baris) | 4 |
| Bug fungsional | 8 |

### Status Audit (30 Sep 2026)

| Status | Jumlah | Temuan |
|--------|--------|--------|
| ✅ Selesai / tidak berlaku | 10 | #1, #2, #3, #4, #5, #6, #12, #27, #31, #32 |
| 🟡 Sebagian | 1 | #11 |
| 🔴 Masih terbuka | 21 | sisanya |

Detail status tiap temuan ditulis pada baris `Status (30 Sep 2026)` di bawah
bagian masing-masing.

---

## Checklist Pengembangan

- [x] Fix bug `copyWith` reset flags (#1, #2)
- [x] Fix `saved` overwrite pattern (#3, #4) — flag `saved` dihapus + guard spinner
- [x] Fix optimistic toggle state (#5) — tidak berlaku, kode sudah benar
- [x] Add try/catch di home BLoC (#6)
- [ ] Pecah mega-widgets (#7, #8, #9)
- [ ] Konsistensi warna ke `AppColors` (#10)
- [ ] Tambahkan aksesibilitas (#11) — sebagian: tooltip 11, `Semantics` 4
- [x] Tambahkan semantik droppable (#12) — flag in-flight + generation, tanpa dependensi
- [ ] Simplifikasi `LessonBloc` states (#13)
- [ ] Refactor `EssayState` (#14)
- [ ] Typing `attempt` field (#15)
- [ ] Hapus artificial delay (#16)
- [ ] Ekstrak `_msg()` ke shared utility (#17)
- [ ] Buat shared `BrandSectionHeader` (#18)
- [ ] Buat shared `MetricDivider` (#19)
- [ ] Buat shared `HeroOverline` (#20)
- [ ] Tambahkan `key()` di dynamic lists (#21)
- [ ] Rename file `_widget.dart` (#22)
