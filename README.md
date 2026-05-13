dart format .
# LMS Mobile App — Mobile Learning for Bass Training

Versi dokumentasi yang lebih lengkap untuk pengguna dan pengembang.

## Ringkasan Singkat

- Platform: Flutter (Dart)
- Tujuan: Aplikasi mobile Learning Management System (LMS) untuk pelatihan bass
- Arsitektur: Clean Architecture (Domain / Data / Presentation)
- State management: BLoC (`flutter_bloc`) atau pola serupa

README ini memberikan panduan instalasi, arsitektur, alur pengembangan, dan referensi cepat untuk kontributor.

---

## Untuk Pengguna (End-User)

### Fitur Utama

- Dashboard dengan progress belajar dan statistik
- Daftar kursus dan detail kursus
- Materi pelajaran: video, dokumen, kuis, dan tugas
- Sertifikat untuk kursus yang terselesaikan
- Otentikasi pengguna dan manajemen profil

### Cepat Mulai (User)

1. Pastikan perangkat Anda memenuhi persyaratan Android/iOS.
2. Jalankan aplikasi yang sudah dibuild oleh maintainer, atau ikuti bagian "Menjalankan Aplikasi" di bawah jika ingin build sendiri.

---

## Untuk Pengembang

### Prasyarat

- Flutter SDK (stable channel), versi sesuai `pubspec.yaml`
- Java JDK & Android SDK (untuk Android)
- Xcode (untuk iOS, macOS only)

### Menjalankan di Lokal

```bash
# Pasang dependency
flutter pub get

# Jalankan aplikasi pada emulator atau perangkat fisik
flutter run
```

Perintah lain yang sering dipakai:

```bash
dart format .
flutter analyze
flutter test
flutter build apk --release
```

### Struktur Kode (Ringkasan)

- `lib/` — kode aplikasi utama
	- `lib/src/features/` — setiap fitur (home, courses, lessons, auth, dll.)
	- `lib/src/core/` — konfigurasi aplikasi (routing, tema, DI, error handling)
	- `lib/src/shared/` — widget dan utilitas bersama
- `assets/` — gambar, icon, dan aset media
- `android/`, `ios/`, `windows/`, `macos/`, `web/`, `linux/` — platform-specific

Untuk arsitektur detil, lihat dokumentasi arsitektur: ARCHITECTURE_GUIDE.md

### Panduan Pengembangan

- Ikuti prinsip Clean Architecture: pisahkan Domain, Data, dan Presentation.
- Gunakan BLoC (atau pattern yang disepakati) untuk business logic dan state.
- Jangan letakkan logika pada widget; buat unit test untuk usecases dan bloc.
- Registrasi dependency pada modul DI agar mudah isolasi fitur.

### Menambahkan Fitur Baru

1. Buat branch fitur: `feature/<nama-fitur>`.
2. Buat folder fitur di `lib/src/features/<nama-fitur>/` dengan struktur domain/data/presentation.
3. Tambahkan unit test untuk logic fitur (usecase/repository/bloc).
4. Pastikan `dart format .` dan `flutter analyze` lulus sebelum PR.

---

## Testing

- Unit & widget tests: `flutter test`
- Integration tests: sesuaikan konfigurasi (lihat folder `test_driver` atau `integration_test` jika ada)

---

## Debugging & Troubleshooting

- Error DI / BLoC not found: pastikan modul di-register pada startup (`main.dart`).
- Masalah routing: periksa router/route names di `lib/src/core/`.
- Masalah asset tidak muncul: pastikan `pubspec.yaml` menyertakan path `assets/` dan jalankan `flutter pub get`.

Jika menemukan issue teknis, mohon buatkan issue di repository dengan langkah reproduksi dan log terkait.

---

## Kontribusi

Silakan buka issue atau buat Pull Request. Panduan singkat:

1. Fork repo dan buat branch baru.
2. Sertakan deskripsi perubahan dan screenshot bila UI berubah.
3. Tambahkan atau perbarui test jika perlu.
4. Pastikan formatting dan lint lulus.

---

## Referensi & Dokumen Tambahan

- Panduan arsitektur: ARCHITECTURE_GUIDE.md
- Dokumen lengkap proyek: DOKUMENTASI_LENGKAP_PROJECT.md
- Panduan migrasi: MIGRATION_GUIDE.md

Lihat juga `pubspec.yaml` untuk daftar dependensi dan versi yang digunakan.

---

## Lisensi & Kontak

Jika ada pertanyaan atau ingin berkolaborasi, silakan buka issue atau hubungi maintainer proyek.

Terima kasih telah menggunakan atau berkontribusi pada proyek ini. Semoga membantu dalam pembelajaran bass dan pengembangan Flutter! 🎸🚀
