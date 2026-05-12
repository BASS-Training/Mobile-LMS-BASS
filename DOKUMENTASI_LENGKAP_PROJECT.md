# 📚 DOKUMENTASI LENGKAP LMS MOBILE APP

**Versi:** 0.1.0  
**Framework:** Flutter + BLoC  
**Bahasa:** Dart  
**Target Platform:** Android, iOS, Web  

---

## 🎯 DAFTAR ISI

1. [Pengenalan Project](#pengenalan-project)
2. [Arsitektur & Clean Architecture](#arsitektur--clean-architecture)
3. [Alur Aplikasi (Workflow)](#alur-aplikasi-workflow)
4. [Struktur Folder & File](#struktur-folder--file)
5. [Penjelasan Setiap Module Feature](#penjelasan-setiap-module-feature)
6. [Penjelasan Detail File Per File](#penjelasan-detail-file-per-file)
7. [Flow Data & Lifecycle](#flow-data--lifecycle)
8. [Dependency Injection System](#dependency-injection-system)

---

## 🏠 Pengenalan Project

### Tujuan Aplikasi
**LMS Mobile App** adalah aplikasi mobile untuk e-learning yang memungkinkan pengguna:
- ✅ Login dan manage akun pribadi
- ✅ Melihat dan mengakses course (pelajaran)
- ✅ Menonton video lessons, membaca dokumen, dan mengerjakan quiz
- ✅ Melacak progress belajar (berapa % sudah selesai)
- ✅ Menyimpan course favorit
- ✅ Mendapatkan sertifikat setelah menyelesaikan course

### Tech Stack
```
📱 UI Framework      → Flutter + Material Design 3
🔄 State Management  → BLoC (Business Logic Component)
🛣️  Routing          → GoRouter
💾 Local Storage     → Hive (untuk cache data)
🎥 Video Player      → YouTube Player Flutter
📦 Package Manager   → pub.dev
🏗️  Architecture      → Clean Architecture (Domain + Data + Presentation)
```

### Current Status
```
✅ Authentication Module    - SELESAI (login)
✅ Course Module            - SELESAI (list, detail, search, save)
✅ Lesson Module            - SELESAI (video, document, quiz)
✅ Certificate Module       - BASIC (preview/download placeholder)
🔄 Profile Module           - IN PROGRESS
⚠️  Backend Integration      - BELUM (masih dummy data)
```

---

## 🏗️ Arsitektur & Clean Architecture

### Konsep Dasar Clean Architecture

Clean Architecture membagi project menjadi 3 layer yang independent:

```
┌─────────────────────────────────────────────────────┐
│         PRESENTATION LAYER (UI/UX)                  │
│  • Screens       - Halaman yang ditampilkan user    │
│  • BLoCs         - Logic untuk handle user action   │
│  • Widgets       - Reusable UI components           │
│  • Models (UI)   - Data model untuk UI              │
└─────────────────────────────────────────────────────┘
                         ↕️ 
┌─────────────────────────────────────────────────────┐
│         DOMAIN LAYER (Business Logic)               │
│  • Entities      - Pure data classes (bukan model)  │
│  • Repositories  - Abstract contracts (interface)   │
│  • UseCases      - Business logic reusable          │
│  • ValueObjects  - Value-based objects              │
└─────────────────────────────────────────────────────┘
                         ↕️ 
┌─────────────────────────────────────────────────────┐
│         DATA LAYER (Storage & API)                  │
│  • Repositories  - Implementasi dari domain         │
│  • DataSources   - Remote API & Local Storage       │
│  • Models        - Data model dari API/Storage      │
│  • Mappers       - Convert model ↔ entity           │
└─────────────────────────────────────────────────────┘
```

### Keuntungan Clean Architecture
✅ **Independence** - Tidak tergantung framework  
✅ **Testability** - Mudah di-unit test  
✅ **Maintainability** - Kode terstruktur & terorganisir  
✅ **Scalability** - Mudah menambah feature baru  
✅ **Flexibility** - Mudah ganti implementation (API, DB, dll)  

---

## 🔄 Alur Aplikasi (Workflow)

### 1️⃣ Application Startup Flow

```
🚀 main.dart
    ↓
    ├─→ WidgetsFlutterBinding.ensureInitialized()
    │   (Siapkan Flutter engine)
    │
    ├─→ ServiceLocator().setupServiceLocator()
    │   ├─→ CoreModule.register()
    │   │   ├─→ LocalStorage.init() (Inisialisasi Hive)
    │   │   └─→ FlavorConfig.init() (Set environment: dev/staging/prod)
    │   │
    │   ├─→ NetworkModule.register() (Setup network/API)
    │   │
    │   └─→ Feature Modules Register
    │       ├─→ AuthModule.register()
    │       ├─→ CourseModule.register()
    │       ├─→ LessonModule.register()
    │       └─→ CertificateModule.register()
    │
    └─→ runApp(MainApp())
        └─→ MaterialApp.router()
            ├─→ MultiBlocProvider (provide BLoCs ke subtree)
            │   ├─→ AuthBloc
            │   ├─→ CourseBloc
            │   └─→ LessonBloc
            │
            └─→ Router Setup (GoRouter untuk navigation)
                └─→ Initial Route: /login
```

**Penjelasan Sederhana:**
1. Aplikasi dimulai dari `main()` function
2. Siapkan Flutter engine dan inisialisasi local storage (Hive)
3. Daftarkan semua dependency ke ServiceLocator (untuk Dependency Injection)
4. Jalankan aplikasi dengan MaterialApp dan setup routing
5. Sediakan semua BLoC ke seluruh app via MultiBlocProvider
6. Buka halaman login sebagai halaman pertama

---

### 2️⃣ Authentication (Login) Flow

```
📱 LoginScreen (User input email & password)
    ↓
    └─→ BlocListener mendeteksi state change
        │
        ├─→ Tampilkan loading spinner
        │
        └─→ User tekan tombol "Login"
            ↓
            context.read<AuthBloc>().add(AuthLoginEvent(email, password))
            │
            ├─→ AuthBloc menerima event
            │   ↓
            │   ├─→ emit(AuthLoading()) - tampilkan loading
            │   │
            │   ├─→ call LoginUseCase.call(email, password)
            │   │   ├─→ LoginUseCase adalah business logic
            │   │   └─→ Memanggil AuthRepository.login()
            │   │
            │   ├─→ AuthRepositoryImpl.login() (Data Layer)
            │   │   ├─→ Validate email & password
            │   │   ├─→ (Harusnya call API remote, tp sekarang dummy)
            │   │   ├─→ Buat User object dengan email
            │   │   └─→ Return UserEntity
            │   │
            │   ├─→ BLoC emit(AuthSuccess(user)) ✅
            │   │   atau emit(AuthFailure(message)) ❌
            │   │
            │   └─→ LoginScreen mendeteksi AuthSuccess
            │       ↓
            │       └─→ context.go('/main') - navigate ke home
            │
            └─→ Jika AuthFailure
                └─→ Tampilkan error SnackBar
```

**User Journey:**
1. Buka app → lihat login screen
2. Input email & password
3. Klik "Login"
4. App validate input
5. Kirim ke server (simulation saja dulu)
6. Jika success → navigate ke home
7. Jika error → tampilkan pesan error

**State yang terlibat:**
- `AuthInitial` - Awal
- `AuthLoading` - Sedang login
- `AuthSuccess(user)` - Login berhasil, simpan user data
- `AuthFailure(message)` - Login gagal
- `AuthLoggedOut` - User logout

---

### 3️⃣ Course List Flow

```
🏠 MainScreen / HomeScreen
    ↓
    ├─→ onInitState()
    │   └─→ context.read<CourseBloc>().add(GetCoursesEvent())
    │       ├─→ BLoC emit(CourseLoading())
    │       │
    │       ├─→ call GetCoursesUseCase.call()
    │       │   └─→ CourseRepository.getCourses()
    │       │
    │       ├─→ CourseRepositoryImpl.getCourses()
    │       │   ├─→ Try: call remoteDataSource.getCourses()
    │       │   │   (API belum ready, throws exception)
    │       │   │
    │       │   └─→ Catch: fallback ke localDataSource.getCourses()
    │       │       ├─→ CourseLocalDataSourceImpl.getCourses()
    │       │       ├─→ Load dari cache internal (in-memory)
    │       │       ├─→ Jika cache kosong, load dari DummyData.getCourses()
    │       │       └─→ Return List<Course>
    │       │
    │       ├─→ Convert model → entity via CourseMapper.toDomain()
    │       │
    │       └─→ emit(CourseLoaded(courses))
    │
    └─→ BlocBuilder rebuild UI dengan data courses
        ├─→ Tampilkan loading circle
        ├─→ Atau tampilkan grid courses
        └─→ Atau tampilkan error message
```

**Data Path:**
```
DummyData 
  ↓
CourseLocalDataSource.getCourses() 
  ↓
CourseRepository.getCourses() 
  ↓
GetCoursesUseCase.call() 
  ↓
CourseBloc 
  ↓
CourseLoaded state 
  ↓
BlocBuilder rebuild UI
```

**Dummy Data Source:**
- File: `lib/src/features/courses/data/datasources/dummy_data.dart`
- Berisi hard-coded 5 courses (Accounting, Agriculture, Economics, Art, Biology)
- Setiap course punya sections, setiap section punya lessons

---

### 4️⃣ Lesson (Video) Flow

```
📹 CourseDetailScreen 
    ↓
    └─→ User klik lesson → navigate ke VideoLessonDetailScreen
        │
        └─→ VideoLessonDetailScreen(lesson, course, lessonIndex)
            │
            ├─→ Check lesson.type
            │   ├─→ "video" → load YouTubePlayerController
            │   ├─→ "document" → DocumentLessonDetailScreen
            │   └─→ "quiz" → QuizLessonDetailScreen
            │
            ├─→ YoutubePlayerController init dengan videoId
            │   └─→ Video embed dari YouTube
            │
            ├─→ BlocListener mendeteksi LessonBloc state
            │
            ├─→ User bisa:
            │   ├─→ Tonton video
            │   ├─→ Mark Lesson Complete (update LocalStorage)
            │   ├─→ Next Lesson
            │   └─→ Previous Lesson
            │
            └─→ Saat mark complete:
                ├─→ context.read<LessonBloc>().add(MarkLessonCompleteEvent(lessonId))
                │
                ├─→ LessonBloc call MarkLessonCompleteUseCase
                │   └─→ LessonRepository.markLessonComplete(lessonId)
                │
                ├─→ LocalStorage.markLessonComplete(lessonId)
                │   └─→ Update Hive box dengan lesson yang completed
                │
                └─→ emit(LessonMarkedComplete)
                    └─→ Update UI (tampilkan checkmark)
```

**Lesson Types:**
1. **Video** - Embed YouTube video dengan player controls
2. **Document** - Tampilkan text/markdown dengan sections & bullets
3. **Quiz** - Interactive quiz dengan multiple choice questions

---

### 5️⃣ Quiz Flow

```
📝 QuizLessonDetailScreen
    ↓
    ├─→ onInitState()
    │   └─→ Load quiz data via GetQuizUseCase
    │       ├─→ QuizRepository.getQuizByLessonId(lessonId)
    │       ├─→ QuizLocalDataSource.getQuizByLessonId(lessonId)
    │       ├─→ QuizDummyData.getQuizByLessonId(lessonId)
    │       └─→ Return Quiz object
    │
    ├─→ Tampilkan QuizIntroWidget (pengenalan quiz)
    │   ├─→ Total questions: 10
    │   ├─→ Time limit: 30 menit
    │   ├─→ Passing score: 70%
    │   └─→ Tombol "Start Quiz"
    │
    └─→ User klik Start Quiz
        │
        ├─→ Tampilkan QuizQuestionsWidget
        │   ├─→ Pertanyaan ke-n (dari total 10)
        │   ├─→ 4 pilihan jawaban (A, B, C, D)
        │   ├─→ User select answer
        │   │   └─→ onSelectAnswer(index) → update answers map
        │   │
        │   ├─→ Navigation buttons
        │   │   ├─→ Previous (jika bukan soal pertama)
        │   │   ├─→ Next (jika bukan soal terakhir)
        │   │   └─→ Submit Answers (jika soal terakhir)
        │   │
        │   └─→ Question Navigator
        │       ├─→ Grid 5x2 untuk jump ke soal tertentu
        │       ├─→ Hijau = sudah dijawab
        │       ├─→ Biru = soal aktif sekarang
        │       └─→ Abu-abu = belum dijawab
        │
        └─→ User klik Submit Answers
            │
            ├─→ Calculate score
            │   ├─→ Hitung berapa jawaban yang benar
            │   ├─→ Hitung percentage (benar/total * 100)
            │   └─→ Cek apakah passed (>= 70%)
            │
            ├─→ Tampilkan QuizResultWidget
            │   ├─→ Sertifikat atau "Not Passed" banner
            │   ├─→ Score: 80%
            │   ├─→ Correct: 8 / Total: 10
            │   ├─→ Jika passed:
            │   │   ├─→ Mark lesson complete otomatis
            │   │   └─→ Tombol "Next Lesson"
            │   │
            │   └─→ Jika not passed:
            │       └─→ Tombol "Back to Course"
            │
            └─→ Jika passed, mark lesson completion
                └─→ LessonBloc.add(MarkLessonCompleteEvent)
```

---

### 6️⃣ Certificate Flow

```
🏆 MainScreen → Saved Courses / Certificates Tab
    ↓
    ├─→ Load completed courses (progress = 100%)
    │   └─→ GetSavedCoursesUseCase / filter courses dengan progress 100%
    │
    └─→ Tampilkan CertificateListScreen
        ├─→ List courses yang sudah completed
        │   └─→ Setiap item = CertificateListTile
        │
        └─→ User klik certificate
            └─→ Navigate ke CertificateDetailScreen
                ├─→ Tampilkan certificate preview (custom painter mountains)
                ├─→ Tombol "Download" (placeholder - belum implement)
                ├─→ Tombol "Share" (placeholder - belum implement)
                └─→ Detail certificate
                    ├─→ Certificate Holder: [User Name]
                    ├─→ Course Title: [Course Name]
                    ├─→ Issue Date: 6 Mei 2026
                    └─→ Expiry Date: 6 Mei 2031
```

---

## 📁 Struktur Folder & File

```
lms_mobile_app/
│
├── 📄 main.dart                          [ENTRY POINT - Aplikasi dimulai dari sini]
│   └─ Fungsi main() yang memanggil runApp(MainApp)
│
└── lib/src/
    │
    ├── 🔐 features/                      [FEATURE MODULES - Setiap feature independent]
    │   │
    │   ├── authentication/               [AUTH FEATURE]
    │   │   ├── domain/
    │   │   │   ├── entities/
    │   │   │   │   └── user_entity.dart  [Pure data class user]
    │   │   │   ├── repositories/
    │   │   │   │   └── auth_repository.dart [Abstract contract]
    │   │   │   └── usecases/
    │   │   │       └── auth_usecase.dart [Business logic: LoginUseCase, LogoutUseCase]
    │   │   │
    │   │   ├── data/
    │   │   │   ├── models/
    │   │   │   │   └── user.dart         [Data model dari API]
    │   │   │   ├── repositories/
    │   │   │   │   └── auth_repository_impl.dart [Implementasi interface]
    │   │   │   └── mappers/
    │   │   │       └── user_mapper.dart  [Convert User ↔ UserEntity]
    │   │   │
    │   │   └── presentation/
    │   │       ├── screens/
    │   │       │   └── login_screen.dart [UI halaman login]
    │   │       └── bloc/
    │   │           ├── auth/
    │   │           │   ├── auth_bloc.dart     [State management]
    │   │           │   ├── auth_event.dart    [User action]
    │   │           │   └── auth_state.dart    [App state]
    │   │           └── ...
    │   │
    │   ├── courses/                      [COURSE FEATURE]
    │   │   ├── domain/
    │   │   │   ├── entities/
    │   │   │   │   ├── course_entity.dart
    │   │   │   │   └── course_section_entity.dart
    │   │   │   ├── repositories/
    │   │   │   │   └── course_repository.dart
    │   │   │   ├── usecases/
    │   │   │   │   └── course_usecase.dart
    │   │   │   └── value_objects/
    │   │   │       └── progress.dart     [Value object untuk progress calculation]
    │   │   │
    │   │   ├── data/
    │   │   │   ├── models/
    │   │   │   │   ├── course.dart
    │   │   │   │   └── course_section.dart
    │   │   │   ├── datasources/
    │   │   │   │   ├── course_local_data_source.dart    [Abstract]
    │   │   │   │   ├── course_local_data_source_impl.dart
    │   │   │   │   ├── course_remote_data_source.dart   [Abstract]
    │   │   │   │   ├── course_remote_data_source_impl.dart
    │   │   │   │   └── dummy_data.dart   [Mock data untuk development]
    │   │   │   ├── repositories/
    │   │   │   │   └── course_repository_impl.dart
    │   │   │   └── mappers/
    │   │   │       └── course_mapper.dart
    │   │   │
    │   │   └── presentation/
    │   │       ├── screens/
    │   │       │   ├── main_screen.dart        [Bottom nav dengan 4 tab]
    │   │       │   ├── home_screen.dart        [Tab 0 - Overview]
    │   │       │   ├── course_list_screen.dart [Tab 1 - Semua course]
    │   │       │   └── course_detail_screen.dart
    │   │       ├── bloc/
    │   │       │   └── course/
    │   │       │       ├── course_bloc.dart
    │   │       │       ├── course_event.dart
    │   │       │       └── course_state.dart
    │   │       └── widgets/
    │   │           ├── course_card.dart   [Reusable UI component]
    │   │           └── ...
    │   │
    │   ├── lessons/                      [LESSON FEATURE]
    │   │   ├── domain/
    │   │   │   ├── entities/
    │   │   │   │   ├── lesson_entity.dart
    │   │   │   │   ├── document_section_entity.dart
    │   │   │   │   └── quiz_entity.dart
    │   │   │   ├── repositories/
    │   │   │   │   ├── lesson_repository.dart
    │   │   │   │   └── quiz_repository.dart
    │   │   │   └── usecases/
    │   │   │       ├── lesson_usecase.dart
    │   │   │       └── get_quiz_usecase.dart
    │   │   │
    │   │   ├── data/
    │   │   │   ├── models/
    │   │   │   │   ├── lesson.dart
    │   │   │   │   ├── quiz_model.dart
    │   │   │   │   └── document_lesson_model.dart
    │   │   │   ├── datasources/
    │   │   │   │   ├── quiz_local_datasource.dart
    │   │   │   │   ├── quiz_local_datasource_impl.dart
    │   │   │   │   ├── quiz_dummy_data.dart
    │   │   │   │   └── quiz_local_data_source.dart
    │   │   │   ├── repositories/
    │   │   │   │   ├── lesson_repository_impl.dart
    │   │   │   │   └── quiz_repository_impl.dart
    │   │   │   └── mappers/
    │   │   │       └── lesson_mapper.dart
    │   │   │
    │   │   └── presentation/
    │   │       ├── screens/
    │   │       │   ├── lesson_detail_screen.dart
    │   │       │   ├── video_lesson_detail_screen.dart
    │   │       │   ├── document_lesson_detail_screen.dart
    │   │       │   └── quiz_lesson_detail_screen.dart
    │   │       ├── bloc/
    │   │       │   ├── lesson/
    │   │       │   │   ├── lesson_bloc.dart
    │   │       │   │   ├── lesson_event.dart
    │   │       │   │   └── lesson_state.dart
    │   │       │   └── quiz/
    │   │       │       ├── quiz_bloc.dart
    │   │       │       └── ... [Quiz state/event]
    │   │       └── widgets/
    │   │           ├── lesson_tile.dart
    │   │           ├── lesson_drawer.dart
    │   │           ├── quiz/
    │   │           │   ├── quiz_intro_widget.dart
    │   │           │   ├── quiz_questions_widget.dart
    │   │           │   ├── quiz_result_widget.dart
    │   │           │   ├── question_navigator_widget.dart
    │   │           │   ├── option_card_widget.dart
    │   │           │   ├── info_card_widget.dart
    │   │           │   └── instruction_card_widget.dart
    │   │           └── ...
    │   │
    │   └── certificates/                 [CERTIFICATE FEATURE - BASIC]
    │       ├── domain/
    │       │   ├── entities/
    │       │   ├── repositories/
    │       │   └── usecases/
    │       ├── data/
    │       │   ├── models/
    │       │   ├── datasources/
    │       │   └── repositories/
    │       └── presentation/
    │           ├── screens/
    │           │   ├── certificate_list_screen.dart
    │           │   └── certificate_detail_screen.dart
    │           └── widgets/
    │               └── certificate_list_tile.dart
    │
    ├── 🔧 core/                          [SHARED CORE INFRASTRUCTURE]
    │   │
    │   ├── di/                           [DEPENDENCY INJECTION - ServiceLocator]
    │   │   ├── injector.dart             [Main orchestrator - setup semua DI]
    │   │   └── modules/
    │   │       ├── core_module.dart      [Init storage, config, etc]
    │   │       ├── network_module.dart   [Setup HTTP client]
    │   │       ├── auth_module.dart      [DI untuk auth feature]
    │   │       ├── course_module.dart    [DI untuk course feature]
    │   │       ├── lesson_module.dart    [DI untuk lesson feature]
    │   │       └── certificate_module.dart
    │   │
    │   ├── config/                       [CONFIGURATION]
    │   │   ├── flavor_config.dart        [Dev/Staging/Production config]
    │   │   └── constants/
    │   │       ├── app_strings.dart      [String constants (i18n ready)]
    │   │       ├── app_routes.dart       [Route path constants]
    │   │       └── api_endpoints.dart    [API endpoint constants]
    │   │
    │   ├── error/                        [ERROR HANDLING]
    │   │   ├── app_exception.dart        [Exception classes]
    │   │   ├── failures.dart             [Failure classes untuk domain]
    │   │   └── error_handler.dart        [Exception → Failure converter]
    │   │
    │   ├── routes/                       [NAVIGATION]
    │   │   └── app_router.dart           [GoRouter setup - semua routes]
    │   │
    │   └── utils/                        [UTILITY FUNCTIONS]
    │       ├── local_storage.dart        [Hive storage wrapper]
    │       └── validators.dart           [Input validation]
    │
    └── 🎨 shared/                        [SHARED RESOURCES]
        │
        ├── styles/                       [UI STYLING - Consistency]
        │   ├── app_colors.dart           [Color palette - primary, secondary, etc]
        │   ├── app_typography.dart       [Font styles - heading, body, etc]
        │   ├── app_measures.dart         [Spacing values - padding, margin, radius]
        │   └── app_theme.dart            [ThemeData untuk MaterialApp]
        │
        ├── widgets/                      [REUSABLE WIDGETS]
        │   ├── bottom_nav_bar.dart       [Custom bottom navigation]
        │   ├── buttons.dart              [PrimaryButton, SecondaryButton, etc]
        │   ├── form_fields.dart          [AppTextField, AppDropdownField]
        │   ├── progress_indicator.dart   [CourseProgressIndicator]
        │   ├── statistics_card.dart      [Reusable card widget]
        │   ├── feature_card.dart         [Card untuk feature showcase]
        │   └── ...
        │
        ├── dialogs/                      [DIALOG COMPONENTS]
        │   └── app_dialog.dart           [AppDialog, ConfirmationDialog, LoadingDialog]
        │
        └── states/                       [SHARED STATE ENUMS]
            └── view_state.dart           [ViewState enum - initial, loading, success, error]
```

**Legend:**
- 🔐 = Private/Feature-specific
- 🔧 = Infrastructure/Core
- 🎨 = Shared UI Resources

---

## 📚 Penjelasan Setiap Module Feature

### 🔐 Authentication Module (`lib/src/features/authentication/`)

**Tujuan:** Handle login/logout dan session management user

#### Domain Layer (`domain/`)

**UserEntity** (`entities/user_entity.dart`)
```dart
class UserEntity {
  final String id;        // User ID dari database
  final String name;      // Nama lengkap user
  final String email;     // Email user
}
```
- Pure data class (tidak punya method logic kompleks)
- Digunakan di domain & presentation layer
- Immutable (tidak bisa diubah setelah create)

**AuthRepository** (Abstract - `repositories/auth_repository.dart`)
```dart
abstract class AuthRepository {
  Future<UserEntity?> login(String email, String password);
  Future<void> logout();
  Future<UserEntity?> getCurrentUser();
}
```
- Contract/interface yang mendefinisikan aksi apa saja yang bisa dilakukan
- Implementasinya ada di data layer
- Berguna untuk testing (bisa dibuat mock)

**UseCases** (`usecases/auth_usecase.dart`)
- `LoginUseCase` - wrap login logic
- `LogoutUseCase` - wrap logout logic
- Setiap UseCase punya 1 file dan 1 method `call()`

#### Data Layer (`data/`)

**User Model** (`models/user.dart`)
```dart
class User {
  final String id, name, email;
  
  // Bisa convert dari/ke JSON (untuk API)
  factory User.fromJson(Map json) { ... }
  Map<String, dynamic> toJson() { ... }
}
```
- Data class dari API/storage
- Berbeda dengan UserEntity (punya JSON conversion)

**AuthRepositoryImpl** (`repositories/auth_repository_impl.dart`)
- Implementasi dari AuthRepository interface
- Menggabungkan data dari local & remote
- Fallback strategy: try remote → fallback ke local

**UserMapper** (`mappers/user_mapper.dart`)
```dart
class UserMapper {
  static UserEntity toDomain(User model) { ... }
  static User fromDomain(UserEntity entity) { ... }
}
```
- Convert model ↔ entity
- Satu arah untuk domain, satu arah untuk data

#### Presentation Layer (`presentation/`)

**LoginScreen** (`screens/login_screen.dart`)
- UI form login
- TextField untuk email & password
- Button login
- BlocListener untuk handle success/error
- BlocBuilder untuk loading state

**AuthBloc** (`bloc/auth/auth_bloc.dart`)
- State machine untuk authentication
- Handle AuthLoginEvent → LoginUseCase → emit AuthSuccess/AuthFailure
- Simpan user data di state

**Auth States** (`bloc/auth/auth_state.dart`)
- `AuthInitial` - awal
- `AuthLoading` - sedang process
- `AuthSuccess(user)` - berhasil, simpan user
- `AuthFailure(message)` - gagal, tampilkan error

---

### 📖 Course Module (`lib/src/features/courses/`)

**Tujuan:** Display, search, save courses

#### Domain Layer

**CourseEntity** & **CourseSectionEntity**
- Pure data classes
- Punya convenience getters untuk progress calculation

**CourseRepository** (Abstract)
```dart
Future<List<CourseEntity>> getCourses();
Future<CourseEntity?> getCourseById(String id);
Future<List<CourseEntity>> searchCourses(String query);
Future<void> toggleSaveCourse(String courseId);
Future<List<CourseEntity>> getSavedCourses();
Future<void> refreshCourses();
```

**UseCases**
- `GetCoursesUseCase` - fetch semua courses
- `SearchCoursesUseCase` - search by keyword
- `ToggleSaveCourseUseCase` - save/unsave course
- Dll...

#### Data Layer

**Course Model** & **CourseSection Model**
- Dari API/Dummy data
- Bisa convert dari/ke JSON

**Data Sources** (2 jenis)

1. **CourseRemoteDataSource** (Abstract)
   - Interface untuk API calls
   - Belum implemented (backend belum ready)

2. **CourseLocalDataSource** (Abstract)
   - Interface untuk local cache
   - Implementasi menggunakan in-memory cache + DummyData

**DummyData** (`datasources/dummy_data.dart`)
- Hard-coded 5 courses dengan sections & lessons
- Digunakan development sebelum backend ready
- Nanti bisa diganti dengan real API calls

**CourseRepositoryImpl**
- Strategy: Try remote → fallback ke local
- Jika remote timeout/error, load dari cache/dummy
- Simpan result ke cache untuk offline support

#### Presentation Layer

**MainScreen** (`screens/main_screen.dart`)
- 4 tab: Home, Courses, Saved, Profile
- Bottom navigation bar
- Host untuk 4 screens utama

**HomeScreen** (`screens/home_screen.dart`)
- Overview dashboard
- Statistics cards (total courses, progress, etc)
- Recent courses carousel
- Search box
- Join class token input (placeholder)

**CourseListScreen** (`screens/course_list_screen.dart`)
- Grid view semua courses
- Search functionality
- Click course → detail screen

**CourseDetailScreen** (`screens/course_detail_screen.dart`)
- Course preview (icon, title, instructor)
- About course section
- Progress indicator
- Sections list dengan lessons di dalamnya
- Click lesson → lesson detail screen

**CourseBloc**
- State machine untuk course operations
- Events: GetCourses, Search, ToggleSave, GetSaved, Refresh
- States: CourseLoading, CourseLoaded, CourseFailure

---

### 📹 Lesson Module (`lib/src/features/lessons/`)

**Tujuan:** Display lesson content (video/document/quiz), track completion

#### Domain Layer

**LessonEntity**
- id, courseId, title, content
- duration, type ("video", "document", "quiz")
- isCompleted (completion status)
- youtubeVideoId (untuk video lessons)

**DocumentSectionEntity**
- title, paragraphs[], bullets[]
- Struktur untuk document lessons

**QuizEntity** & Related
- QuestionEntity (text, options, correctIndex)
- QuizResultEntity (score, total, percentage, passed)

**Repositories** (Abstract)
- `LessonRepository` - lesson completion tracking
- `QuizRepository` - quiz data retrieval

**UseCases**
- `IsLessonCompletedUseCase`
- `MarkLessonCompleteUseCase`
- `GetQuizUseCase`

#### Data Layer

**Lesson Model** & **Quiz Model**
- Dari API/storage
- JSON conversion

**Quiz Sources**
- `QuizLocalDataSource` - abstract
- `QuizLocalDataSourceImpl` - implementasi
- `QuizDummyData` - hard-coded 40+ quizzes untuk setiap lesson

**Repositories Impl**
- `LessonRepositoryImpl` - wrap LocalStorage calls
- `QuizRepositoryImpl` - get quiz dari local source

#### Presentation Layer

**Lesson Detail Screens** (3 jenis)
1. **VideoLessonDetailScreen**
   - YouTube player
   - Video controls
   - Mark complete button
   - Lesson drawer (navigate lessons)
   - Comments section

2. **DocumentLessonDetailScreen**
   - Text content dengan sections
   - Scroll-able
   - Mark complete button

3. **QuizLessonDetailScreen**
   - Intro → Questions → Result flow
   - Quiz timer (30 min)
   - Question navigator (jump to Q)
   - Answer validation
   - Score calculation

**Lesson Bloc**
- Events: MarkLessonComplete, ToggleLessonCompletion, Refresh
- States: LessonMarkedComplete, LessonFailure

**Quiz Bloc**
- Separate dari LessonBloc
- Handle quiz-specific logic

**Quiz Widgets** (Modular)
- `QuizIntroWidget` - info & start button
- `QuizQuestionsWidget` - question display & options
- `QuizResultWidget` - score & feedback
- `QuestionNavigatorWidget` - jump to question
- `OptionCardWidget` - answer choice
- Helper widgets: `InfoCardWidget`, `InstructionCardWidget`, `ScoreItemWidget`

---

### 🏆 Certificate Module (`lib/src/features/certificates/`)

**Status:** BASIC - mostly placeholder

**Screens:**
1. **CertificateListScreen** - list completed courses
2. **CertificateDetailScreen** - certificate preview & info
   - Custom painter (mountain decoration)
   - Download & Share buttons (placeholder)
   - Certificate details (holder, course, dates)

**Current Implementation:**
- Filter courses dengan progress = 100%
- Tampilkan sebagai certificates
- Nanti bisa add: PDF generation, email, signature verification

---

## 📄 Penjelasan Detail File Per File

### 1️⃣ `lib/main.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms_mobile_app/src/core/di/injector.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 1. Setup Dependency Injection
  final serviceLocator = ServiceLocator();
  await serviceLocator.setupServiceLocator();
  
  // 2. Run app
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final serviceLocator = ServiceLocator();
    
    return MultiBlocProvider(
      // 3. Provide BLoCs ke seluruh widget tree
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => serviceLocator.authBloc,
        ),
        BlocProvider<CourseBloc>(
          create: (context) => serviceLocator.courseBloc,
        ),
        BlocProvider<LessonBloc>(
          create: (context) => serviceLocator.lessonBloc,
        ),
      ],
      child: MaterialApp.router(
        title: 'LMS Mobile',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        routerConfig: AppRouter.router,
      ),
    );
  }
}
```

**Penjelasan:**
1. `WidgetsFlutterBinding.ensureInitialized()` - Siapkan Flutter engine sebelum async operations
2. `ServiceLocator().setupServiceLocator()` - Register semua dependencies
3. `MultiBlocProvider` - Sediakan BLoCs ke seluruh app
4. `MaterialApp.router` - Setup routing dengan GoRouter
5. Initial route adalah `/login` (lihat `app_router.dart`)

---

### 2️⃣ `lib/src/core/di/injector.dart`

```dart
class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();
  
  factory ServiceLocator() => _instance;
  ServiceLocator._internal();
  
  /// Master setup function - dipanggil di main()
  Future<void> setupServiceLocator() async {
    // 1. Core (harus pertama)
    await CoreModule.register();
    
    // 2. Network
    await NetworkModule.register();
    
    // 3. Features
    AuthModule.register();
    CourseModule.register();
    LessonModule.register();
    CertificateModule.register();
  }
  
  // Getters untuk BLoCs
  AuthBloc get authBloc => AuthModule.authBloc;
  CourseBloc get courseBloc => CourseModule.courseBloc;
  LessonBloc get lessonBloc => LessonModule.lessonBloc;
}
```

**Konsep:**
- **Singleton Pattern** - cuma ada 1 instance ServiceLocator di seluruh app
- **Lazy Initialization** - dependencies dibuat saat diakses (via getter)
- **Module Pattern** - setiap feature punya DI module sendiri

---

### 3️⃣ `lib/src/core/di/modules/core_module.dart`

```dart
class CoreModule {
  static Future<void> register() async {
    // 1. Initialize LocalStorage (Hive)
    await LocalStorage.init();
    
    // 2. Initialize FlavorConfig
    if (!FlavorConfig.isInitialized) {
      FlavorConfig.init(
        flavor: AppFlavor.development,
        apiBaseUrl: DevelopmentFlavorConfig.apiBaseUrl,
        enableLogging: DevelopmentFlavorConfig.enableLogging,
        enableMockData: DevelopmentFlavorConfig.enableMockData,
      );
    }
  }
}
```

**Tanggung Jawab:**
- Initialize storage (Hive boxes)
- Setup configuration (dev/staging/prod)
- Logger setup (opsional)
- Ini adalah foundation untuk modules lainnya

---

### 4️⃣ `lib/src/core/utils/local_storage.dart`

```dart
class LocalStorage {
  static const String _completedLessonsKey = 'completed_lessons';
  
  static Future<void> init() async {
    // Initialize Hive boxes
    await Hive.initFlutter();
    // Register adapters jika perlu
  }
  
  static Future<void> markLessonComplete(String lessonId) async {
    final box = await Hive.box(_completedLessonsKey);
    final completed = Set<String>.from(box.get(_completedLessonsKey, defaultValue: []) as List);
    completed.add(lessonId);
    await box.put(_completedLessonsKey, completed.toList());
  }
  
  static bool isLessonCompleted(String lessonId) {
    final box = Hive.box(_completedLessonsKey);
    final completed = List<String>.from(box.get(_completedLessonsKey, defaultValue: []) as List);
    return completed.contains(lessonId);
  }
  
  static List<String> getCompletedLessons() {
    final box = Hive.box(_completedLessonsKey);
    return List<String>.from(box.get(_completedLessonsKey, defaultValue: []) as List);
  }
}
```

**Fungsi:**
- Wrapper untuk Hive (local database)
- Store completed lesson IDs
- Call dari LessonRepository untuk persist completion status
- Survival offline - data tetap ada even saat offline

---

### 5️⃣ `lib/src/features/courses/data/datasources/dummy_data.dart`

```dart
class DummyData {
  static List<Course> getCourses() {
    return [
      // Course 1: Accounting
      Course(
        id: '1',
        title: 'Accounting',
        description: 'Learn accounting fundamentals...',
        instructor: 'Pak Bayu',
        color: '#A29BFE',
        icon: '📊',
        chaptersCount: 4,
        duration: '8 hours',
        sections: [
          CourseSection(
            id: '1-s1',
            courseId: '1',
            sectionNumber: 1,
            title: 'Introduction',
            description: 'Get started...',
            lessons: [
              Lesson(
                id: '1-1-1',
                courseId: '1',
                title: 'What is Accounting?',
                content: 'Overview...',
                duration: '20 min',
                type: 'video',
                youtubeVideoId: 'dQw4w9WgXcQ',
              ),
              // ... more lessons
            ],
          ),
          // ... more sections
        ],
      ),
      // ... more courses (Agriculture, Economics, Art, Biology)
    ];
  }
}
```

**Berisi:**
- 5 courses dengan hierarchy: Course → Sections → Lessons
- Hard-coded data untuk development
- Setiap course punya sections dengan lessons
- Lesson types: "video", "document", "quiz"

---

### 6️⃣ Flow File Relasi

**Ketika user klik "Load Courses" di HomeScreen:**

```
HomeScreen.onInitState()
    ↓
context.read<CourseBloc>().add(GetCoursesEvent())
    ↓
CourseBloc._onGetCourses()
    ├─→ emit(CourseLoading())
    ├─→ getCoursesUseCase.call()
    │   └─→ courseRepository.getCourses()
    │       ├─→ CourseRemoteDataSource.getCourses() [throws exception]
    │       ├─→ catch, fallback:
    │       └─→ CourseLocalDataSource.getCourses()
    │           └─→ DummyData.getCourses() [returns List<Course>]
    │
    ├─→ _updateCompletionStatus(courses)
    │   └─→ Check LocalStorage untuk completed lessons
    │       └─→ Update lesson.isCompleted flag
    │
    ├─→ _mapCoursesToEntities(courses)
    │   └─→ CourseMapper.toDomain()
    │       └─→ Convert Course model → CourseEntity
    │
    └─→ emit(CourseLoaded(courses: entities))
        └─→ BlocBuilder rebuild UI
            └─→ GridView render course cards
```

---

## 🔀 Flow Data & Lifecycle

### Data Flow (Request ke Display)

```
[Remote API] 
    ↓ 
[LocalDataSource (cache)] 
    ↓ 
[Repository] 
    ↓ 
[UseCase] 
    ↓ 
[BLoC] 
    ↓ 
[State Management] 
    ↓ 
[BlocBuilder / BlocListener] 
    ↓ 
[UI Widget]
```

### BLoC Lifecycle

```
1. CREATE
   ↓ BLoC instance dibuat di DI module
   
2. PROVIDE
   ↓ Via BlocProvider di MultiBlocProvider
   
3. LISTEN (selama widget lifecycle)
   ├─ Event masuk → Process
   ├─ Emit state baru
   └─ UI rebuild
   
4. CLOSE
   ↓ BLoC di-close saat widget dispose
   ↓ Cleanup resources
```

### Widget Lifecycle dengan BLoC

```
StatefulWidget (e.g., HomeScreen)
    ├─ initState()
    │   └─→ context.read<CourseBloc>().add(GetCoursesEvent())
    │
    ├─ build()
    │   └─→ BlocBuilder<CourseBloc, CourseState>
    │       └─→ (context, state) {
    │           if (state is CourseLoading) → show spinner
    │           if (state is CourseLoaded) → show grid
    │           if (state is CourseFailure) → show error
    │       }
    │
    └─ dispose()
        └─→ _controller.dispose(), etc
```

---

## 🔐 Dependency Injection System

### Pattern: Service Locator dengan Module Separation

```
┌─────────────────────────────────┐
│   ServiceLocator (main DI)      │
│  ├─ CoreModule                  │
│  ├─ NetworkModule               │
│  ├─ AuthModule                  │
│  ├─ CourseModule                │
│  ├─ LessonModule                │
│  └─ CertificateModule           │
└─────────────────────────────────┘

Setiap module punya:
  ├─ register() - setup dependencies
  └─ getters - expose instances
```

### Contoh: CourseModule.register()

```dart
class CourseModule {
  static late CourseBloc _courseBloc;
  
  static void register() {
    // 1. Data Sources
    CourseLocalDataSource localDataSource = CourseLocalDataSourceImpl();
    CourseRemoteDataSource remoteDataSource = CourseRemoteDataSourceImpl();
    
    // 2. Repository
    CourseRepository repository = CourseRepositoryImpl(
      localDataSource: localDataSource,
      remoteDataSource: remoteDataSource,
    );
    
    // 3. Use Cases
    GetCoursesUseCase getCoursesUseCase = GetCoursesUseCase(repository);
    SearchCoursesUseCase searchCoursesUseCase = SearchCoursesUseCase(repository);
    // ... more use cases
    
    // 4. BLoC
    _courseBloc = CourseBloc(
      getCoursesUseCase: getCoursesUseCase,
      searchCoursesUseCase: searchCoursesUseCase,
      // ... more use cases
    );
  }
  
  static CourseBloc get courseBloc => _courseBloc;
}
```

**Dependency Chain:**
```
BLoC ← UseCase ← Repository ← DataSources
```

**Keuntungan:**
- ✅ Mudah inject mock untuk testing
- ✅ Loose coupling antar layer
- ✅ Centralized dependency management

---

## 🎯 User Journey Example: Complete Quiz

### Scenario: User mengerjakan quiz dan lulus

```
1. User buka VideoLessonDetailScreen
   └─→ Lesson type = "quiz"
   └─→ Navigate ke QuizLessonDetailScreen

2. QuizLessonDetailScreen init
   ├─→ Load quiz data via GetQuizUseCase
   │   └─→ QuizRepository.getQuizByLessonId('1-1-3')
   │       └─→ QuizDummyData._getAccountingIntroQuiz()
   │           └─→ Return Quiz(totalQuestions: 10, timeLimit: 30, ...)
   │
   └─→ Tampilkan QuizIntroWidget

3. User klik "Start Quiz"
   ├─→ Tampilkan QuizQuestionsWidget
   ├─→ Show question 1 of 10
   └─→ User select answers satu per satu (A, C, B, A, ...)

4. User submit answers
   ├─→ Calculate score
   │   └─→ Compare answers dengan correctIndex
   │       └─→ Score: 8/10 = 80%
   │
   ├─→ Passed? 80% >= 70% → YES
   │
   ├─→ Tampilkan QuizResultWidget
   │   ├─→ Green banner "Selamat!"
   │   ├─→ Score: 80%
   │   ├─→ Tombol "Pelajaran Berikutnya"
   │   └─→ Tombol "Kembali ke Kursus"
   │
   └─→ Mark lesson as complete
       └─→ LessonBloc.add(MarkLessonCompleteEvent('1-1-3'))
           └─→ LocalStorage.markLessonComplete('1-1-3')
               └─→ Hive store: completed_lessons = [..., '1-1-3']

5. Course progress update
   └─→ CourseBloc refresh courses
       └─→ CourseEntity.progress recalculate
           └─→ Jika semua lessons = 100% completed
               └─→ Course bisa generate certificate
```

---

## 💾 Storage & Persistence

### Hive (Local Database)

**Setup di CoreModule.register():**
```dart
await LocalStorage.init();
// Initialize Hive boxes untuk:
// - completed_lessons (List<String>)
// - saved_courses (jika diimplementasikan)
```

**Usage via LocalStorage wrapper:**
```dart
// Mark lesson complete
LocalStorage.markLessonComplete('lesson-id');

// Check if lesson completed
bool completed = LocalStorage.isLessonCompleted('lesson-id');

// Get all completed lessons
List<String> completed = LocalStorage.getCompletedLessons();
```

**Benefit:**
- ✅ Persist data offline
- ✅ Fast access (in-memory cache)
- ✅ Survive app restart
- ✅ No server needed untuk read

---

## 🌐 API Integration (Future)

### Remote Data Source (Belum Implement)

**File:** `lib/src/features/courses/data/datasources/course_remote_data_source_impl.dart`

```dart
class CourseRemoteDataSourceImpl implements CourseRemoteDataSource {
  // TODO: Implementasikan ketika endpoint ready
  @override
  Future<List<Course>> getCourses() async {
    // final response = await httpClient.get('$baseUrl/courses');
    // if (response.statusCode == 200) {
    //   return (json.decode(response.body) as List)
    //       .map((c) => Course.fromJson(c))
    //       .toList();
    // }
    throw UnimplementedError('Backend belum siap');
  }
}
```

### Fallback Strategy

```
CourseRepository.getCourses()
    ├─ TRY: remoteDataSource.getCourses()
    │   ├─ Success → simpan ke cache → return
    │   └─ Error → catch
    │
    └─ FALLBACK: localDataSource.getCourses()
        ├─ Cache ada → return
        └─ Cache kosong → load DummyData
```

**Keuntungan:**
- ✅ Offline support (fallback ke local)
- ✅ Cache mechanism (reduce API calls)
- ✅ Smooth transition (dari dummy → real API)

---

## 🚀 How to Extend (Menambah Feature Baru)

### Template untuk Feature Baru (e.g., "Progress Tracking")

**1. Create Folder Structure**
```
lib/src/features/progress_tracking/
├── domain/
│   ├── entities/
│   │   └── progress_entity.dart
│   ├── repositories/
│   │   └── progress_repository.dart
│   └── usecases/
│       └── progress_usecase.dart
├── data/
│   ├── models/
│   │   └── progress_model.dart
│   ├── datasources/
│   │   └── progress_local_data_source.dart
│   └── repositories/
│       └── progress_repository_impl.dart
└── presentation/
    ├── screens/
    │   └── progress_screen.dart
    └── bloc/
        ├── progress_bloc.dart
        ├── progress_event.dart
        └── progress_state.dart
```

**2. Implement Domain Layer**
```dart
// entities/progress_entity.dart
class ProgressEntity {
  final String courseId;
  final int completedLessons;
  final int totalLessons;
  double get percentage => (completedLessons / totalLessons) * 100;
}

// repositories/progress_repository.dart
abstract class ProgressRepository {
  Future<ProgressEntity> getCourseProgress(String courseId);
}

// usecases/progress_usecase.dart
class GetCourseProgressUseCase {
  final ProgressRepository repository;
  Future<ProgressEntity> call(String courseId) => repository.getCourseProgress(courseId);
}
```

**3. Implement Data Layer**
```dart
// models/progress_model.dart
class ProgressModel {
  // ... with fromJson/toJson
}

// datasources/progress_local_data_source.dart
class ProgressLocalDataSourceImpl implements ProgressLocalDataSource {
  @override
  Future<ProgressModel> getCourseProgress(String courseId) async {
    // Load dari Hive atau calculate dari completed lessons
  }
}

// repositories/progress_repository_impl.dart
class ProgressRepositoryImpl implements ProgressRepository {
  @override
  Future<ProgressEntity> getCourseProgress(String courseId) async {
    final model = await localDataSource.getCourseProgress(courseId);
    return ProgressMapper.toDomain(model);
  }
}
```

**4. Implement Presentation Layer**
```dart
// bloc/progress_bloc.dart
class ProgressBloc extends Bloc<ProgressEvent, ProgressState> {
  final GetCourseProgressUseCase getCourseProgressUseCase;
  
  ProgressBloc({required this.getCourseProgressUseCase}) : super(ProgressInitial()) {
    on<GetCourseProgressEvent>(_onGetProgress);
  }
  
  Future<void> _onGetProgress(GetCourseProgressEvent event, Emitter<ProgressState> emit) async {
    emit(ProgressLoading());
    try {
      final progress = await getCourseProgressUseCase(event.courseId);
      emit(ProgressLoaded(progress));
    } catch (e) {
      emit(ProgressFailure('Failed to load progress'));
    }
  }
}

// screens/progress_screen.dart
class ProgressScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProgressBloc, ProgressState>(
      builder: (context, state) {
        if (state is ProgressLoading) return CircularProgressIndicator();
        if (state is ProgressLoaded) {
          return Text('Progress: ${state.progress.percentage}%');
        }
        return SizedBox.shrink();
      },
    );
  }
}
```

**5. Register DI Module**
```dart
// core/di/modules/progress_module.dart
class ProgressModule {
  static late ProgressBloc _progressBloc;
  
  static void register() {
    ProgressLocalDataSource localDataSource = ProgressLocalDataSourceImpl();
    ProgressRepository repository = ProgressRepositoryImpl(localDataSource: localDataSource);
    GetCourseProgressUseCase useCase = GetCourseProgressUseCase(repository);
    
    _progressBloc = ProgressBloc(getCourseProgressUseCase: useCase);
  }
  
  static ProgressBloc get progressBloc => _progressBloc;
}
```

**6. Update ServiceLocator**
```dart
// core/di/injector.dart
Future<void> setupServiceLocator() async {
  await CoreModule.register();
  await NetworkModule.register();
  
  AuthModule.register();
  CourseModule.register();
  LessonModule.register();
  CertificateModule.register();
  ProgressModule.register();  // ← ADD HERE
}

ProgressBloc get progressBloc => ProgressModule.progressBloc;
```

**7. Use in Widget**
```dart
// Provide BLoC
MultiBlocProvider(
  providers: [
    // ... existing
    BlocProvider<ProgressBloc>(create: (_) => serviceLocator.progressBloc),
  ],
  child: app,
)

// Use in widget
context.read<ProgressBloc>().add(GetCourseProgressEvent('course-1'));
```

---

## 📊 Architecture Diagram

```
┌──────────────────────────────────────────────────────────────┐
│                     PRESENTATION LAYER                       │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────┐  │
│  │   Screens    │  │    BLoCs     │  │    Widgets       │  │
│  │ • Login      │  │ • Auth       │  │ • CourseCard     │  │
│  │ • Home       │  │ • Course     │  │ • LessonTile     │  │
│  │ • Courses    │  │ • Lesson     │  │ • QuizQuestion   │  │
│  │ • Lesson     │  │ • Quiz       │  │ • AppButton      │  │
│  │ • Quiz       │  │ • Progress   │  │ • AppTextField   │  │
│  │ • Cert       │  │              │  │ • Progress Bar   │  │
│  └──────────────┘  └──────────────┘  └──────────────────┘  │
└──────────────────────────────────────────────────────────────┘
                            ↕️ (Events/States)
┌──────────────────────────────────────────────────────────────┐
│                     DOMAIN LAYER                             │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────┐  │
│  │   Entities   │  │  Repositories│  │   Use Cases      │  │
│  │ • User       │  │ • Auth       │  │ • LoginUseCase   │  │
│  │ • Course     │  │ • Course     │  │ • GetCourses     │  │
│  │ • Section    │  │ • Lesson     │  │ • SearchCourses  │  │
│  │ • Lesson     │  │ • Quiz       │  │ • MarkComplete   │  │
│  │ • Quiz       │  │ • Progress   │  │ • GetQuiz        │  │
│  │ • Progress   │  │              │  │ • GetProgress    │  │
│  └──────────────┘  └──────────────┘  └──────────────────┘  │
└──────────────────────────────────────────────────────────────┘
                            ↕️ (Clean Interface)
┌──────────────────────────────────────────────────────────────┐
│                     DATA LAYER                               │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────┐  │
│  │   Models     │  │   Mappers    │  │  Repositories    │  │
│  │ • User       │  │ • UserMapper │  │ • AuthImpl        │  │
│  │ • Course     │  │ • CourseMap  │  │ • CourseImpl      │  │
│  │ • Lesson     │  │ • LessonMap  │  │ • LessonImpl      │  │
│  │ • Quiz       │  │ • QuizMapper │  │ • ProgressImpl    │  │
│  │ • Progress   │  │ • ProgressM  │  │                  │  │
│  └──────────────┘  └──────────────┘  └──────────────────┘  │
│                                                               │
│  ┌──────────────┐  ┌──────────────┐                         │
│  │ Local Sources│  │ Remote Sourc │                         │
│  │ • LocalData  │  │ • RemoteData │                         │
│  │ • DummyData  │  │   (Not Ready)│                         │
│  │ • Hive Cache │  │              │                         │
│  └──────────────┘  └──────────────┘                         │
└──────────────────────────────────────────────────────────────┘
                            ↕️ (Network/Storage)
┌──────────────────────────────────────────────────────────────┐
│                  EXTERNAL SERVICES                           │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  Remote API (Backend)  [NOT YET IMPLEMENTED]         │   │
│  │  GET /api/courses, /api/lessons, etc                 │   │
│  └──────────────────────────────────────────────────────┘   │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  Local Storage (Hive)  [IMPLEMENTED]                 │   │
│  │  completed_lessons box, saved_courses box, etc       │   │
│  └──────────────────────────────────────────────────────┘   │
└──────────────────────────────────────────────────────────────┘
```

---

## 🎓 Key Concepts & Terminology

### Clean Architecture Layers

| Layer | Tanggung Jawab | Independence |
|-------|---|---|
| **Presentation** | UI, UX, user interaction | Tergantung Domain |
| **Domain** | Business logic, rules | Independent (core) |
| **Data** | API calls, storage, caching | Implements Domain contracts |

### BLoC Pattern

| Component | Fungsi |
|-----------|--------|
| **Event** | User action (tombol diklik, data diminta) |
| **State** | Kondisi UI saat ini (loading, success, error) |
| **BLoC** | State machine yang process event → state |
| **Listener** | React saat state berubah |
| **Builder** | Rebuild UI saat state berubah |

### Dependency Injection

| Konsep | Penjelasan |
|--------|-----------|
| **Service Locator** | Central registry untuk dependencies |
| **Module** | Group related dependencies |
| **Singleton** | 1 instance untuk entire app |
| **Lazy Loading** | Create dependency hanya saat dibutuhkan |
| **Injection** | Pass dependency ke class via constructor |

### Data Flow

| Arah | Path |
|------|------|
| **Request** | UI → BLoC → UseCase → Repository → DataSource |
| **Response** | DataSource → Mapper → Entity → State → UI |
| **Persistence** | LocalStorage ← Repository ← DataSource |

---

## ✅ Checklist Features

### Currently Working ✅

- [x] Authentication (Login/Logout)
- [x] Course List & Search
- [x] Course Details
- [x] Save/Unsave Courses
- [x] Lesson Types (Video, Document, Quiz)
- [x] Mark Lesson Complete
- [x] Quiz with Multiple Choice
- [x] Quiz Scoring
- [x] Course Progress Tracking
- [x] Bottom Navigation (4 tabs)
- [x] Responsive Design (Mobile-first)

### Partially Working ⚠️

- [ ] Certificate Download (UI only, no PDF generation)
- [ ] Certificate Share (placeholder)
- [ ] Profile Management (basic display)

### TODO 🔄

- [ ] Backend API Integration (replace dummy data)
- [ ] User Authentication (real API)
- [ ] Push Notifications
- [ ] Offline Mode (complete)
- [ ] Analytics Tracking
- [ ] Social Features (comments, ratings)
- [ ] Admin Panel
- [ ] Advanced Certificates (PDF, signature)
- [ ] Video Streaming Optimization
- [ ] Unit Tests
- [ ] Integration Tests
- [ ] E2E Tests

---

## 📖 Resources & Documentation

- **Flutter Docs**: https://flutter.dev/docs
- **BLoC Pattern**: https://bloclibrary.dev
- **GoRouter**: https://pub.dev/packages/go_router
- **Hive**: https://pub.dev/packages/hive
- **Clean Architecture**: https://resocoder.com/clean-architecture-tdd
- **Dart Patterns**: https://dart.dev/guides/language/effective-dart

---

## 🤝 Contributing Guidelines

### Code Style
- Follow Dart style guide (dart analyze)
- Use meaningful variable names
- Add comments untuk logika kompleks
- Keep functions small & focused

### Git Commit Message
```
feat: Add quiz scoring feature
fix: Resolve course loading bug
refactor: Simplify lesson detail screen
docs: Update README
```

### Branch Naming
```
feature/quiz-feature
fix/course-loading-bug
refactor/lesson-screen
docs/update-readme
```

---

## 📞 Support & Contact

- **Issues**: Check existing issues atau create new
- **Discussions**: Use discussion board untuk pertanyaan umum
- **Email**: contact@example.com

---

**Terakhir Update:** 12 Mei 2026  
**Versi Dokumentasi:** 1.0  
**Status:** Production Ready (Core) + In Development (Features)

---

Semoga dokumentasi ini membantu! 🚀 Silakan tanya jika ada yang kurang jelas!
