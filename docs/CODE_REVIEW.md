# Code Review — BASS Training Mobile App

> Tanggal Review: 17 September 2026
> Scope: 46 screen, 25 BLoC/Cubit, 74 widget

---

## 🔴 HIGH PRIORITY — Bug Fungsional

### 1. `copyWith` reset flag `submitted` ke `false`

- **File:** `lib/src/features/lessons/presentation/bloc/document_submission/document_submission_cubit.dart:39`
- **Masalah:** Setiap panggilan `copyWith` tanpa parameter `submitted` akan mereset flag ke `false`. Jika user submit dokumen, state `submitted: true` akan hilang saat `copyWith` dipanggil untuk field lain.
- **Fix:** Gunakan nullable sentinel pattern: `this.submitted` tanpa default `false`.

### 2. `copyWith` reset flag `saved` ke `false`

- **File:** `lib/src/features/instructor/presentation/cubit/document_grading_cubit.dart:38`
- **Masalah:** Sama seperti #1 — flag `saved` di-reset ke `false` setiap `copyWith` dipanggil.
- **Fix:** Sama — gunakan nullable sentinel.

### 3. `submit()` overwrite `saved: true` dengan `load()`

- **File:** `lib/src/features/instructor/presentation/cubit/essay_grading_cubit.dart:71-83`
- **Masalah:** `submit()` emit `saved: true` lalu langsung panggil `load()`. State berubah ke loading sebelum UI sempat menampilkan status tersimpan.
- **Fix:** Tambahkan delay kecil ataupisahkan state `saved` dari `loading`.

### 4. Pattern `saved` overwrite di `CaseStudyGradingCubit`

- **File:** `lib/src/features/instructor/presentation/cubit/case_study_grading_cubit.dart:58-74`
- **Masalah:** Sama — `submit()` panggil `load()` setelah emit `saved: true`.
- **Fix:** Sama — pisahkan state `saved` dari `loading`.

### 5. Optimistic toggle save ter-deduplicate oleh Equatable

- **File:** `lib/src/features/courses/presentation/bloc/course/course_bloc.dart:113-145`
- **Masalah:** Setelah optimistic update, state revert ke `previous`. Jika `previous` adalah `CourseLoaded` dengan list yang sama, Equatable deduplication akan suppress emit revert — UI menampilkan state stale.
- **Fix:** Force-emit atau gunakan state instance berbeda untuk revert.

### 6. No try/catch di `joinClassUseCase`

- **File:** `lib/src/features/home/presentation/bloc/home_bloc.dart:17-28`
- **Masalah:** `result.fold` diasumsikan selalu mengembalikan `Either`, tapi jika use case throw synchronous, BLoC crash.
- **Fix:** Bungkus dalam try/catch.

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

---

## 🟠 MEDIUM PRIORITY — State Management

### 12. No droppable transformer di `AuthBloc`

- **File:** `lib/src/features/authentication/presentation/bloc/auth/auth_bloc.dart:34-63`
- **Masalah:** Double-tap login bisa trigger 2x request parallel.
- **Fix:** Tambahkan `on<AuthLoginEvent>(transformer: droppable())`.

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

## Ringkasan Statistik

| Kategori | Jumlah |
|----------|--------|
| Total temuan | 30 |
| 🔴 High priority | 11 |
| 🟠 Medium priority | 11 |
| 🔵 Low priority | 8 |
| File unik terdampak | ~40 |
| Widget mega (>300 baris) | 4 |
| Bug fungsional | 6 |

---

## Checklist Pengembangan

- [ ] Fix bug `copyWith` reset flags (#1, #2)
- [ ] Fix `saved` overwrite pattern (#3, #4)
- [ ] Fix optimistic toggle state (#5)
- [ ] Add try/catch di home BLoC (#6)
- [ ] Pecah mega-widgets (#7, #8, #9)
- [ ] Konsistensi warna ke `AppColors` (#10)
- [ ] Tambahkan aksesibilitas (#11)
- [ ] Tambahkan droppable transformer (#12)
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
