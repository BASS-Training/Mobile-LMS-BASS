# Roadmap Refactor Teknis Menuju Clean Architecture yang Lebih Kuat

Dokumen ini adalah langkah praktis agar project lebih mudah dimodifikasi dan di-maintain dalam jangka panjang.

## Tujuan Utama
- Presentation hanya tahu domain, bukan data model.
- Business rules terkonsentrasi di domain.
- Data layer siap untuk local + remote source.
- Dependency injection lebih scalable.
- Kualitas naik lewat testing dan standar coding.

---

## Status Saat Ini (Baseline)
Yang sudah baik:
- Struktur layer sudah ada: presentation, domain, data.
- Sudah pakai bloc + usecase + repository abstraction + mapper.
- Persistence progress sudah ada via Hive.

Gap utama:
- Presentation masih import data model/mapper.
- Boundary layer belum ketat.
- Usecase masih banyak yang pass-through.
- Auth dan data source masih dummy.
- Test belum terlihat menjadi safety net utama.

---

## Prinsip Refactor
1. Refactor bertahap, jangan big bang.
2. Setiap tahap wajib tetap build dan bisa dijalankan.
3. Satu tahap fokus ke satu jenis perubahan.
4. Tambah test sebelum dan sesudah perubahan penting.

---

## Tahap 1 - Kunci Boundary Layer (Prioritas Tinggi)
Target:
- Hapus import data layer dari presentation.

Aksi:
1. Ubah kontrak data yang dipakai UI agar berbasis domain entity.
2. Di screen/widget, gunakan CourseEntity/LessonEntity untuk render.
3. Pindahkan proses fromDomain/toDomain keluar dari UI.
4. Jika ada kebutuhan view model, buat mapper di presentation sendiri atau bloc output model yang siap render.

Definition of Done:
- Tidak ada import data model di folder presentation.
- Tidak ada import data mapper di folder presentation.

Checklist verifikasi:
- Cari string import package:lms_mobile_app/data/ di presentation harus nol.

---

## Tahap 2 - Rapikan Domain Logic (Prioritas Tinggi)
Target:
- Semua aturan hitung inti ada di domain, bukan tersebar.

Aksi:
1. Pastikan hitung progress hanya memiliki satu source of truth.
2. Kurangi duplikasi getter progress di model data jika sudah ada di entity.
3. Tambahkan value objects bila perlu (misal Progress, Duration, LessonType) untuk memperjelas aturan.
4. Usecase yang sekarang pass-through mulai diisi validasi/orkestrasi bisnis.

Definition of Done:
- Rule progress tidak terduplikasi lintas model/entity/screen.
- Perubahan aturan bisnis cukup dilakukan di domain.

---

## Tahap 3 - Data Source Dipisah Jelas (Prioritas Tinggi)
Target:
- Repository implementation siap local + remote.

Aksi:
1. Buat kontrak source terpisah: CourseLocalDataSource, CourseRemoteDataSource.
2. Pindahkan DummyData menjadi salah satu implementasi data source.
3. Persiapkan remote adapter (REST client) meski endpoint belum final.
4. Terapkan strategi fallback/caching sederhana.

Contoh strategi:
- Coba remote dulu.
- Jika gagal, fallback ke local cache.
- Simpan hasil remote ke cache.

Definition of Done:
- Repository tidak langsung hardcode DummyData.
- Switching source bisa dilakukan tanpa ubah UI/domain.

---

## Tahap 4 - Dependency Injection yang Lebih Scalable
Target:
- Wiring dependency lebih modular dan mudah dikelola.

Aksi:
1. Pecah service locator per feature/module.
2. Pertimbangkan penggunaan DI framework untuk register singleton/factory lebih aman.
3. Pisahkan lifecycle object yang stateful vs stateless.
4. Dokumentasikan graph dependency.

Definition of Done:
- File DI tidak menjadi bottleneck tunggal yang membengkak.
- Menambah feature baru tidak menambah kompleksitas berlebihan.

---

## Tahap 5 - State Management Hardening
Target:
- Bloc lebih fokus ke orchestration, bukan transformasi berat.

Aksi:
1. Pindahkan kalkulasi berat dari screen ke bloc/domain.
2. Standarkan state: loading/success/empty/error.
3. Tambahkan error detail yang konsisten (message, code, retryability).
4. Hindari event yang memicu reload penuh jika cukup update parsial.

Definition of Done:
- UI menjadi lebih tipis.
- Rebuild berkurang, flow state lebih prediktif.

---

## Tahap 6 - Testing Strategy (Wajib untuk Jangka Panjang)
Target:
- Ada safety net sebelum perubahan besar.

Aksi:
1. Unit test domain entities dan usecases.
2. Unit test repository dengan mock data source.
3. Bloc test untuk event-state transition penting.
4. Widget test untuk screen kritis.

Prioritas test awal:
- perhitungan progress course,
- toggle lesson completion,
- search course,
- toggle saved course.

Definition of Done:
- Coverage area kritis tercapai.
- Refactor bisa dilakukan dengan risiko lebih rendah.

---

## Tahap 7 - Observability dan Error Handling
Target:
- Mudah melacak masalah produksi.

Aksi:
1. Standarkan kelas error/failure di domain/data.
2. Tambah logging terstruktur untuk flow penting.
3. Buat mapping error teknis ke pesan user-friendly.
4. Tambah global handler untuk unexpected exceptions.

Definition of Done:
- Error tidak lagi tersembunyi.
- Troubleshooting lebih cepat.

---

## Tahap 8 - Modularisasi Berdasarkan Feature
Target:
- Struktur folder mendukung skala tim dan skala fitur.

Aksi:
1. Pertimbangkan feature-first structure:
   - features/auth
   - features/course
   - features/lesson
2. Tiap feature punya data/domain/presentation sendiri.
3. Shared module untuk util umum dan design system.

Definition of Done:
- Menambah feature baru tidak perlu menyentuh terlalu banyak folder global.

---

## Rencana Eksekusi 8 Minggu (Contoh)
Minggu 1-2:
- Tahap 1 (boundary layer) + test dasar.

Minggu 3:
- Tahap 2 (domain logic consolidation).

Minggu 4-5:
- Tahap 3 (local/remote data source split).

Minggu 6:
- Tahap 4 dan 5 (DI + bloc hardening).

Minggu 7:
- Tahap 6 (testing expansion).

Minggu 8:
- Tahap 7 dan 8 (observability + modularisasi awal).

---

## Risiko dan Mitigasi
Risiko 1:
- Refactor memecah behavior existing.
Mitigasi:
- Tambah test sebelum pindah logic.

Risiko 2:
- Scope creep karena ingin sempurna sekaligus.
Mitigasi:
- Gunakan definition of done per tahap.

Risiko 3:
- Tim bingung dengan struktur baru.
Mitigasi:
- Buat dokumentasi singkat dan contoh alur per feature.

---

## KPI Keberhasilan Refactor
- Tidak ada import data layer di presentation.
- Waktu tambah fitur baru menurun.
- Bug regresi menurun setelah rilis.
- Test coverage area kritis meningkat.
- PR review lebih cepat karena boundary lebih jelas.

---

## Kesimpulan
Project ini sudah punya fondasi yang baik.
Dengan roadmap ini, kamu bisa naik dari "arsitektur cukup rapi" menjadi "arsitektur kuat untuk jangka panjang".

Prioritas mutlak:
1. Bersihkan boundary presentation-data.
2. Pusatkan business logic di domain.
3. Bangun safety net testing.

Jika 3 hal ini dilakukan dulu, maintenance akan terasa jauh lebih ringan, bahkan saat fitur terus bertambah.
