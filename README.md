<div align="center">

# 📚 BASS Academy — Aplikasi Mobile LMS

**Learning Management System (LMS) untuk akademi BASS (Bintang Anugrah Surya Semesta).**
Aplikasi mobile pendamping backend Laravel — tempat peserta belajar, mengerjakan asesmen, berdiskusi, dan meraih sertifikat, serta instruktur memantau & menilai peserta.

[![Flutter](https://img.shields.io/badge/Flutter-3.11%2B-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.11%2B-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![State](https://img.shields.io/badge/State-BLoC%20%2F%20Cubit-13B9FD)](https://bloclibrary.dev)
[![Architecture](https://img.shields.io/badge/Architecture-Clean-success)](#-arsitektur)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-3DDC84)](#)

</div>

> ℹ️ **Catatan nama:** "BASS" adalah **merek akademi** (singkatan *Bintang Anugrah Surya Semesta*), **bukan** alat musik bass. Ini adalah LMS multi-kursus serbaguna (gaya Udemy) untuk pelatihan vokasi/keprofesian — materinya lintas bidang (akuntansi, ekonomi, seni & desain, biologi, dll.).

---

## 📋 Daftar Isi

- [Tentang Aplikasi](#-tentang-aplikasi)
- [Fitur Utama](#-fitur-utama)
- [Tangkapan Layar](#-tangkapan-layar)
- [Untuk Pengguna](#-untuk-pengguna)
- [Untuk Pengembang](#-untuk-pengembang)
  - [Teknologi](#teknologi--paket-utama)
  - [Arsitektur](#-arsitektur)
  - [Struktur Folder](#-struktur-folder)
  - [Memulai (Setup)](#-memulai-setup)
  - [Konfigurasi Backend / API](#-konfigurasi-backend--api)
  - [Menjalankan & Build](#-menjalankan--build)
  - [Konvensi & Panduan Kontribusi](#-konvensi--panduan-kontribusi)
- [Pemecahan Masalah](#-pemecahan-masalah)

---

## 🎯 Tentang Aplikasi

Aplikasi ini adalah **klien mobile** dari LMS BASS. Backend-nya adalah aplikasi **Laravel 12** terpisah (`LMS_LARAVEL`) yang menyediakan REST API ber-autentikasi **Laravel Sanctum** di bawah prefiks `/api/mobile`. Data (kursus, materi, diskusi, nilai, notifikasi, sertifikat) **sinkron dua arah** antara aplikasi web dan mobile karena berbagi basis data yang sama.

Terdapat 4 peran pada platform: **Admin, Instruktur, Peserta, Event Organizer**. Aplikasi mobile fokus pada pengalaman **Peserta** dan **Instruktur**.

---

## ✨ Fitur Utama

| Modul | Deskripsi |
|---|---|
| 🔐 **Autentikasi** | Login & registrasi dengan token Sanctum; profil peserta lengkap (data diri, institusi, program, status AVPN). |
| 🏠 **Beranda** | Dashboard ringkas: lanjutkan belajar, ringkasan progres, kursus, tip harian, dan teaser pencapaian. |
| 📚 **Kursus & Materi** | Daftar kursus, detail kursus, dan materi multi-tipe: **teks, video, dokumen (PDF), gambar, kuis, esai, studi kasus, feedback, dan sesi Zoom**. |
| 📝 **Asesmen** | Kuis terkoreksi otomatis, esai & studi kasus yang dinilai instruktur, serta survei feedback (gaya Google Form). |
| 💬 **Diskusi** | Hub diskusi terstruktur (pilih kursus → lesson) + thread per-materi, sinkron dengan web. |
| 🔔 **Notifikasi** | Lonceng & feed yang menggabungkan balasan diskusi, nilai keluar, materi baru, dan pengumuman. |
| 🏆 **Pencapaian** | Halaman bergaya Duolingo: lencana **bertingkat** (Perunggu→Platinum), level & poin, plus dialog perayaan saat naik tingkat. |
| 🎮 **Mini Games** | Permainan penyegar: 2048, Schulte Table, Stack Tower, dan Flappy (skor tersimpan lokal). |
| 🎓 **Sertifikat** | Lihat & unduh sertifikat untuk kursus yang tuntas. |
| 👨‍🏫 **Mode Instruktur** | Pantau progres peserta dan nilai esai & studi kasus langsung dari mobile. |
| 🌗 **Tema Terang/Gelap** | Dukungan dark mode penuh (terang/gelap/ikuti sistem), dapat diatur dari Profil. |

---

## 📸 Tangkapan Layar

> Tambahkan tangkapan layar di sini. Contoh penataan (letakkan berkas di `docs/screenshots/`):
>
> | Beranda | Pencapaian | Diskusi |
> |---|---|---|
> | _(home.png)_ | _(achievements.png)_ | _(discussion.png)_ |

---

## 👤 Untuk Pengguna

### Alur singkat
1. **Masuk** dengan akun yang terdaftar (atau **daftar** sebagai peserta baru).
2. Di **Beranda**, lanjutkan materi terakhir atau jelajahi **Kursus**.
3. Buka sebuah materi → tonton/baca, kerjakan **kuis/esai/studi kasus**, atau ikut **diskusi**.
4. Pantau perkembangan di **Pencapaian** dan unduh **Sertifikat** saat kursus tuntas.
5. Atur tampilan (tema terang/gelap) dan data diri di **Profil**.

### Persyaratan perangkat
- **Android** (disarankan Android 5.0 / API 21 ke atas) atau **iOS**.
- Koneksi internet untuk menyinkronkan data dengan server LMS.

> Aplikasi terkunci dalam orientasi **potret**.

---

## 🛠️ Untuk Pengembang

### Teknologi & Paket Utama

| Area | Pilihan |
|---|---|
| Bahasa / SDK | Dart, Flutter `^3.11.5` |
| State management | `flutter_bloc` (BLoC & Cubit) |
| Dependency Injection | `get_it` (service locator modular) |
| Navigasi | `go_router` |
| Jaringan | `dio` (REST + token Sanctum) |
| Penyimpanan lokal | `hive` / `hive_flutter` |
| Form & validasi | `formz` |
| Lain-lain | `flutter_svg`, `flutter_html`, `syncfusion_flutter_pdfviewer`, `youtube_player_flutter`, `audioplayers`, `url_launcher`, `open_filex` |

Font: **Poppins**. Warna brand: merah `#DC0000`.

### 🏗️ Arsitektur

Proyek menerapkan **Clean Architecture** dengan tiga lapisan per fitur:

```
Presentation  →  UI (screens, widgets) + BLoC/Cubit. Hanya render & terima event.
Domain        →  Entities, kontrak Repository (interface), Usecases. Business rules, paling independen.
Data          →  Model/DTO, DataSource (remote/local), implementasi Repository.
```

**Aturan dependensi:** lapisan atas hanya bergantung pada lapisan bawah melalui **abstraksi**. Domain tidak boleh bergantung langsung pada Data atau Presentation.

**Alur data (contoh: ambil daftar kursus):**
```
UI → kirim Event → BLoC → panggil Usecase → Repository (interface)
   → DataSource (dio/Hive) → map ke Entity → balik ke UI via BLoC state
```

Setiap fitur mendaftarkan dependensinya melalui **modul DI** di `lib/src/core/di/modules/` (mis. `course_module.dart`, `achievement_module.dart`) yang dirangkai oleh `ServiceLocator` saat startup.

### 📁 Struktur Folder

```
lib/
├─ main.dart                     # Entry point + inisialisasi flavor & DI
└─ src/
   ├─ core/                      # Fondasi lintas-fitur
   │  ├─ config/                 # FlavorConfig, konstanta (rute, endpoint API)
   │  ├─ di/                     # ServiceLocator + modules/ (DI per fitur)
   │  ├─ network/                # Dio, interceptor, helper error
   │  ├─ routes/                 # GoRouter (app_router.dart)
   │  ├─ error/                  # Failure & exception
   │  └─ utils/                  # Utilitas umum
   ├─ shared/                    # Dipakai banyak fitur
   │  ├─ styles/                 # AppColors, AppShadows, AppMeasures, tipografi
   │  ├─ theme/                  # Tema terang/gelap + ThemeController
   │  ├─ widgets/                # Widget bersama (BrandAppBar, AppEmptyState, dll.)
   │  ├─ dialogs/  states/  utils/
   └─ features/                  # Tiap fitur = domain/ + data/ + presentation/
      ├─ authentication/   home/         courses/      lessons/
      ├─ discussions/      notifications/ achievements/ certificates/
      ├─ games/            instructor/    main/
```

### 🚀 Memulai (Setup)

**Prasyarat**
- Flutter SDK (channel *stable*, sesuai `pubspec.yaml` ≥ 3.11.5)
- Android Studio / SDK (untuk Android) atau Xcode (untuk iOS, hanya di macOS)
- Backend **LMS_LARAVEL** berjalan & dapat diakses dari perangkat/emulator

```bash
# 1. Masuk ke folder aplikasi mobile
cd lms_mobile_app

# 2. Pasang dependency
flutter pub get

# 3. Jalankan
flutter run
```

### 🔌 Konfigurasi Backend / API

Alamat API diatur di **`lib/src/core/config/flavor_config.dart`**. Flavor dipilih otomatis di `main.dart` berdasarkan mode build:

- **Debug / `flutter run`** → memakai `DevelopmentFlavorConfig`
- **Release / `flutter build`** → memakai `ProductionFlavorConfig`

Ubah `apiBaseUrl` sesuai lingkunganmu (perhatikan akhiran **`/api/mobile`**):

```dart
// Development — ganti dengan alamat backend kamu
class DevelopmentFlavorConfig {
  static const String apiBaseUrl = 'http://192.168.x.x:8000/api/mobile';
  ...
}
```

> 💡 **Tips:** untuk perangkat fisik, gunakan **alamat IP LAN** komputer (mis. `http://192.168.1.10:8000/...`), bukan `localhost`. Untuk emulator Android, `localhost` host bisa diakses lewat `http://10.0.2.2:8000/...`.

### 🧪 Menjalankan & Build

```bash
flutter pub get          # Pasang dependency
flutter run              # Jalankan di emulator/perangkat (mode debug)
dart format .            # Rapikan format kode
flutter analyze          # Static analysis (wajib bersih sebelum PR)
flutter test             # Unit & widget test

# Build rilis
flutter build apk --release      # Android APK
flutter build appbundle --release # Android App Bundle (Play Store)
flutter build ios --release      # iOS (macOS + Xcode)
```

### 🤝 Konvensi & Panduan Kontribusi

- Patuhi **Clean Architecture**: pisahkan `domain/`, `data/`, `presentation/` per fitur.
- Gunakan **BLoC/Cubit** untuk logika & state; jangan menaruh business logic di dalam widget.
- Daftarkan dependensi baru lewat **modul DI** di `core/di/modules/`.
- Pakai **token desain** dari `shared/styles/` (mis. `AppColors`, `AppShadows`) — hindari warna/ukuran hardcode agar konsisten & ramah dark mode.
- Pastikan `dart format .` dan `flutter analyze` **lulus tanpa isu** sebelum membuat PR.

**Menambah fitur baru**
1. Buat branch: `feature/<nama-fitur>`.
2. Buat `lib/src/features/<nama-fitur>/` dengan sub-folder `domain/`, `data/`, `presentation/`.
3. Buat modul DI di `core/di/modules/<nama-fitur>_module.dart` dan daftarkan di `ServiceLocator`.
4. Daftarkan rute baru di `core/routes/app_router.dart` (+ konstanta di `core/config/constants/`).
5. Tambah/perbarui test; jalankan format & analyze; sertakan tangkapan layar bila ada perubahan UI.

---

## 🐞 Pemecahan Masalah

| Gejala | Kemungkinan penyebab & solusi |
|---|---|
| Gagal login / data tak muncul | `apiBaseUrl` salah atau backend tidak terjangkau. Cek IP LAN, port `:8000`, dan akhiran `/api/mobile`. |
| Perangkat fisik tak bisa konek | Gunakan IP LAN komputer, bukan `localhost`; pastikan satu jaringan & firewall mengizinkan port. |
| `DI / bloc not found` | Dependensi belum diregistrasi — pastikan modulnya dipanggil di `ServiceLocator.setupServiceLocator()`. |
| Aset tidak tampil | Periksa path di `pubspec.yaml` (`assets/`) lalu jalankan `flutter pub get`. |
| Error rute / argumen | Cek nama rute di `core/routes/app_router.dart` dan tipe `state.extra` yang dikirim. |

---

<div align="center">

Dibuat dengan ❤️ menggunakan **Flutter** untuk **BASS Academy**.
Menemukan bug atau punya ide? Silakan buka **Issue** atau kirim **Pull Request**.

</div>
