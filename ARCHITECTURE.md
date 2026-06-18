# 🏛️ Panduan Arsitektur & Onboarding — BASS Academy Mobile

> Baca juga `README.md` untuk ringkasan fitur & cara setup. Dokumen ini fokus pada **alur teknis**.

---

## 1. Gambaran Besar

Aplikasi ini adalah **klien mobile** dari LMS BASS. Ia **tidak menyimpan data sendiri** sebagai sumber kebenaran — sumber kebenaran ada di **backend Laravel** (`../LMS_LARAVEL`) yang diakses lewat REST API ber-prefiks **`/api/mobile`** dengan autentikasi **token Sanctum**. Penyimpanan lokal (Hive) hanya untuk **sesi, cache, dan preferensi**.

```
┌─────────────────────┐        HTTP + Bearer token        ┌─────────────────────┐
│   Aplikasi Flutter  │  ───────────────────────────────► │   Backend Laravel    │
│  (lms_mobile_app)   │  ◄─────────────────────────────── │  (LMS_LARAVEL)       │
│                     │        JSON {status, data}        │  + DB bersama web    │
└─────────────────────┘                                   └─────────────────────┘
        │
        └── Hive (lokal): token sesi, cache, preferensi tema, skor game
```

Karena DB dibagi dengan aplikasi web, fitur seperti **diskusi, nilai, notifikasi** otomatis **sinkron** antara mobile & web.

---

## 2. Stack Teknologi

| Peran | Pustaka |
|---|---|
| UI | Flutter (Material), font Poppins, brand merah `#DC0000` |
| State management | `flutter_bloc` — **Bloc** (fitur kompleks, berbasis event) & **Cubit** (fitur sederhana) |
| Dependency Injection | `get_it` (service locator) + modul per-fitur |
| Navigasi | `go_router` |
| HTTP | `dio` (+ interceptor token & logging) |
| Penyimpanan lokal | `hive` / `hive_flutter` |
| Form | `formz` |
| Functional error | `dartz` (`Either`/`Failure`) di sebagian fitur |

---

## 3. Model Lapisan (Clean Architecture)

Setiap fitur dipecah ke **tiga lapisan**. Aturan emasnya: **dependensi hanya mengarah ke dalam** (Presentation → Domain ← Data). Domain **tidak tahu** apa pun soal Flutter, dio, atau Hive.

```
┌──────────────────────────────────────────────────────────────┐
│ PRESENTATION  (lib/src/features/<f>/presentation/)            │
│   screens/ widgets/  → UI                                     │
│   bloc/ atau cubit/  → state management (Bloc/Cubit)          │
│   Hanya: render UI + kirim event + tampilkan state.           │
└───────────────┬──────────────────────────────────────────────┘
                │ memanggil
┌───────────────▼──────────────────────────────────────────────┐
│ DOMAIN  (lib/src/features/<f>/domain/)  ← paling independen   │
│   entities/      → objek bisnis murni (Equatable)             │
│   repositories/  → KONTRAK (abstract class), bukan implementasi│
│   usecases/      → satu aksi bisnis = satu class              │
└───────────────┬──────────────────────────────────────────────┘
                │ diimplementasikan oleh
┌───────────────▼──────────────────────────────────────────────┐
│ DATA  (lib/src/features/<f>/data/)                            │
│   models/        → DTO (JSON ⇆ Dart)                          │
│   mappers/       → Model ⇆ Entity                             │
│   datasources/   → remote (dio) / local (Hive)               │
│   repositories/  → implementasi kontrak Domain               │
└──────────────────────────────────────────────────────────────┘
```

**Kenapa begini?** Domain bisa diuji tanpa Flutter, dan implementasi Data (API/cache) bisa diganti tanpa menyentuh UI. UI bergantung pada **kontrak** (interface) di Domain, bukan pada dio/Hive langsung.

---

## 4. Peta Folder

```
lib/
├─ main.dart                      # Entry point: orientasi, flavor, DI, runApp
└─ src/
   ├─ core/                       # Fondasi lintas-fitur (tak terikat 1 fitur)
   │  ├─ config/
   │  │  ├─ flavor_config.dart    # Pilih env dev/staging/prod + apiBaseUrl
   │  │  └─ constants/            # api_endpoints.dart, app_routes.dart, app_strings.dart
   │  ├─ di/
   │  │  ├─ injector.dart         # ServiceLocator: rangkai semua modul DI
   │  │  └─ modules/              # Satu modul DI per fitur (auth, course, ...)
   │  ├─ network/
   │  │  └─ dio_error.dart        # dioErrorMessage(): map DioException → pesan
   │  ├─ routes/
   │  │  └─ app_router.dart       # Konfigurasi GoRouter + auth redirect
   │  ├─ error/                   # Failure & Exception
   │  └─ utils/                   # local_storage.dart, app_logger.dart, dll.
   │
   ├─ shared/                     # Dipakai banyak fitur (UI & util generik)
   │  ├─ styles/                  # AppColors, AppShadows, AppMeasures, tipografi
   │  ├─ theme/                   # Tema terang/gelap + ThemeController
   │  ├─ widgets/                 # BrandAppBar, AppEmptyState, PressScale, ...
   │  ├─ dialogs/  states/  utils/
   │
   └─ features/                   # Setiap fitur = domain/ + data/ + presentation/
      ├─ authentication/  home/         courses/      lessons/
      ├─ discussions/     notifications/ achievements/ certificates/
      ├─ games/           instructor/    main/
```

**Aturan penempatan cepat:**
- Logika bisnis baru → `features/<f>/domain/usecases/`.
- Panggilan API baru → `features/<f>/data/datasources/`.
- Layar/komponen baru → `features/<f>/presentation/`.
- Widget/warna yang dipakai >1 fitur → `shared/`.
- Hal global (router, dio, storage) → `core/`.

---

## 5. Alur Startup Aplikasi

Berikut urutan saat aplikasi dijalankan (`lib/main.dart`):

```
main()
 ├─ kunci orientasi ke potret
 ├─ FlavorConfig.init(...)              # dev saat debug, prod saat release (kReleaseMode)
 ├─ ServiceLocator().setupServiceLocator()
 │     ├─ CoreModule.register()         # Hive (LocalStorage.init) + FlavorConfig
 │     ├─ NetworkModule.register()      # buat Dio + AuthInterceptor + Logging
 │     └─ <Feature>Module.register()    # auth, home, course, lesson, ... (lihat injector.dart)
 └─ runApp(MainApp)
        └─ MaterialApp.router(routerConfig: AppRouter.router)
              └─ redirect berbasis AuthBloc:
                   - belum login  → /intro
                   - sudah login  → /main (tab Home)
                   - /splash tak pernah di-redirect (menunggu sesi dipulihkan)
```

---

## 6. Dependency Injection (`get_it`)

DI dipusatkan di **`core/di/injector.dart`** (kelas `ServiceLocator`). Ia memanggil `register()` setiap modul di `core/di/modules/`. Pola modul:

```dart
class CourseModule {
  static void register(GetIt getIt) {
    if (getIt.isRegistered<CourseBloc>()) return;   // idempoten

    // Data → Domain → Presentation
    final repo = CourseRepositoryImpl(remote: ...);
    final getCourses = GetCoursesUseCase(repo);
    getIt.registerFactory(() => CourseBloc(getCoursesUseCase: getCourses, ...));
  }
}
```

Konvensi registrasi:
- `registerLazySingleton` → objek hidup-lama (Repository, Dio, Bloc global seperti `AuthBloc`/`NotificationsCubit`).
- `registerFactory` → instance baru tiap kali (Bloc/Cubit per-layar).
- `registerFactoryParam` → factory yang butuh argumen runtime (mis. `DiscussionCubit` dengan `contentId`).

**Menambah dependensi?** Daftarkan di modul fiturnya, lalu pastikan modul itu dipanggil di `ServiceLocator.setupServiceLocator()`.

---

## 7. Jaringan (Networking)

Dibuat di **`core/di/modules/network_module.dart`**:
- `Dio` dengan `baseUrl = FlavorConfig.instance.apiBaseUrl` (sudah termasuk `/api/mobile`).
- **`AuthInterceptor`** — menyisipkan `Authorization: Bearer <token>` dari `LocalStorage.getAuthToken()` ke setiap request.
- **`LoggingInterceptor`** — hanya mencetak metadata + durasi (sengaja **tidak** mencetak body penuh agar tidak membekukan UI).
- Endpoint terdaftar di `core/config/constants/api_endpoints.dart`.
- Error dio dipetakan ke pesan ramah lewat `core/network/dio_error.dart` → `dioErrorMessage(e, fallback)`.

Bentuk respons API yang umum: `{ "status": ..., "data": ... }`. DataSource membaca `res.data['data']`.

---

## 8. Penyimpanan Lokal (Hive)

- **`core/utils/local_storage.dart`** — box utama `mini_lms_box`: token & user sesi, status "intro dilihat", preferensi tema, progres lesson lokal, draft esai, dll.
- Fitur tertentu punya **box sendiri**: skor game (`bass_games_box`), perayaan achievement (`bass_achievements_box`).
- Hive di-`init` sekali di `CoreModule.register()` (`LocalStorage.init()`); box per-fitur dibuka **lazy** saat pertama dipakai.

---

## 9. Navigasi (`go_router`)

- Semua rute didefinisikan di **`core/routes/app_router.dart`**; nama path sebagai konstanta di **`core/config/constants/app_routes.dart`**.
- Navigasi: `context.push(AppRoutes.xxx, extra: <argumen>)`.
- Argumen kompleks dikirim via **`state.extra`** (sebuah `Map` atau entity), lalu dibaca di `builder` rute.
- Layar yang butuh Bloc/Cubit dibungkus `BlocProvider` di dalam `builder` rute (lihat contoh `discussionThread`, `quizLessonDetail`).
- `redirect` global menjaga gerbang autentikasi berdasarkan `AuthBloc`.

---

## 10. State Management

- **Bloc** (berbasis `Event` → `State`) untuk alur kompleks: `CourseBloc`, `LessonBloc`, `AuthBloc`, asesmen, dll. File: `bloc/<x>/<x>_bloc.dart`, `_event.dart`, `_state.dart`.
- **Cubit** (memanggil method langsung) untuk yang lebih sederhana: `NotificationsCubit`, `DiscussionStructureCubit`, dll.
- State sebaiknya **immutable** + `Equatable`. Pakai pola `status` enum + `copyWith`.
- UI hanya **mengirim event / memanggil method** dan **membangun ulang dari state**. Jangan menaruh logika bisnis di widget.

---

## 11. Alur Data End-to-End (contoh nyata: memuat daftar kursus)

Telusuri ini di kode untuk memahami pola yang dipakai di **semua** fitur:

```
1. UI            HomeScreen / CoursesScreen  → context.read<CourseBloc>().add(GetCoursesEvent())
2. Bloc          CourseBloc._onGetCourses    → emit(CourseLoading()); panggil GetCoursesUseCase()
3. UseCase       GetCoursesUseCase           → repository.getCourses()         (lewat kontrak)
4. Repository    CourseRepositoryImpl        → remoteDataSource.fetchCourses()
5. DataSource    CourseRemoteDataSourceImpl  → dio.get(ApiEndpoints.courses)   (+ Bearer token)
6. Mapping       CourseMapper / model        → JSON → CourseModel → CourseEntity
7. Balik ke UI   emit(CourseLoaded(courses)) → BlocBuilder membangun ulang daftar
```

Catatan pola nyata di `CourseBloc`:
- **Optimistic update** pada `ToggleSaveCourseEvent` (UI berubah dulu, rollback bila API gagal).
- **Stream** via `WatchCoursesEvent` + `emit.forEach` untuk sinkronisasi berkelanjutan.

---

## 12. Resep: Menambah Fitur Baru

Ikuti urutan ini (dari dalam ke luar — Domain dulu):

1. **Buat folder** `lib/src/features/<fitur>/` dengan `domain/`, `data/`, `presentation/`.
2. **Domain:**
   - `domain/entities/<x>_entity.dart` — objek bisnis (`Equatable`).
   - `domain/repositories/<x>_repository.dart` — `abstract class` (kontrak).
   - `domain/usecases/<aksi>_usecase.dart` — satu aksi per class.
3. **Data:**
   - `data/models/<x>_model.dart` — DTO + `fromJson`/`toJson`.
   - `data/datasources/<x>_remote_datasource.dart` (+ `_impl.dart`) — panggilan `dio`.
   - `data/repositories/<x>_repository_impl.dart` — implementasi kontrak Domain.
   - tambahkan endpoint di `core/config/constants/api_endpoints.dart`.
4. **Presentation:**
   - `presentation/bloc|cubit/` — state management.
   - `presentation/screens/` + `widgets/` — UI (pakai token `shared/styles/`).
5. **DI:** buat `core/di/modules/<fitur>_module.dart`, daftarkan di `ServiceLocator.setupServiceLocator()`.
6. **Rute:** tambah konstanta di `app_routes.dart`, daftarkan `GoRoute` di `app_router.dart`.
7. **Verifikasi:** `dart format .` && `flutter analyze` (wajib bersih) && `flutter test`.

> Fitur **`authentication`** dan **`courses`** adalah contoh kanonik yang lengkap di ketiga lapisan — jadikan rujukan saat ragu.

---

## 13. Konvensi Penting

- **Dokumentasi:** pakai dartdoc `///` (bukan `//`) untuk class/method/file publik. Jelaskan **"kenapa"**, bukan mengulang "apa". Setiap file kunci diawali header `///` singkat (peran file + posisinya di alur).
- **Desain:** selalu pakai token dari `shared/styles/` (`AppColors`, `AppShadows`, `AppMeasures`) agar konsisten & ramah dark mode. Jangan hardcode warna/ukuran.
- **Penamaan:** file `snake_case`; class `PascalCase`; satu UseCase = satu aksi.
- **Lokalisasi:** teks pengguna berbahasa **Indonesia**.
- **Mutu sebelum PR:** `dart format .` dan `flutter analyze` harus lulus tanpa isu.

---

## 14. Peta Fitur

| Fitur | Inti |
|---|---|
| `authentication` | Login/registrasi (token Sanctum), profil, gerbang sesi. Contoh kanonik 3 lapisan. |
| `main` | `MainScreen` + bottom navigation (Home/Kursus/…). |
| `home` | Dashboard: lanjut belajar, ringkasan progres, teaser pencapaian. |
| `courses` | Daftar/detail kursus, simpan kursus, pencarian. |
| `lessons` | Materi multi-tipe (teks/video/dokumen/gambar/kuis/esai/studi kasus/feedback/zoom) + asesmen + diskusi per-materi. |
| `discussions` | Hub diskusi terstruktur (kursus → lesson) + thread; sinkron web. |
| `notifications` | Lonceng + feed gabungan (diskusi/nilai/materi baru/pengumuman). |
| `achievements` | Lencana bertingkat + level/poin + perayaan (Duolingo-style), dari stat nyata. |
| `certificates` | Lihat & unduh sertifikat. |
| `games` | Mini games penyegar (skor lokal Hive). |
| `instructor` | Mode instruktur: pantau progres & nilai esai/studi kasus. |

---

## 15. Referensi Cepat (Perintah)

```bash
flutter pub get          # Pasang dependency (WAJIB setelah merge/checkout)
flutter run              # Jalankan (debug → flavor development)
dart format .            # Rapikan format
flutter analyze          # Static analysis (harus bersih)
flutter test             # Unit & widget test
flutter build apk --release       # Build Android (flavor production)
```

> ⚠️ Setelah `git merge`/`checkout` yang menyentuh `pubspec.*`, **selalu** jalankan `flutter pub get` sebelum run — folder `.dart_tool/` tidak ikut commit.

---

_Dokumen ini hidup — perbarui saat alur/konvensi berubah agar tetap menjadi sumber kebenaran bagi developer berikutnya._
