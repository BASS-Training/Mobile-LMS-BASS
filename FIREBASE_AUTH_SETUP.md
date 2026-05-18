# Firebase Auth Setup untuk LMS Mobile App

Dokumentasi ini menjelaskan bagaimana cara menyiapkan Firebase Auth dan Firestore untuk aplikasi mobile LMS yang sementara menggunakan Firebase sebagai authentication backend.

## 🎯 Tujuan Phase 1

- **Temporary Auth Layer**: Firebase Auth + Firestore untuk sementara, nanti akan diganti ke website backend
- **Role-Based UI**: Pecah tampilan app berdasarkan role akun (participant vs instructor)
- **Fallback Behavior**: Jika Firebase tidak tersedia, app bisa tetap login pakai mock data

## 📋 Persyaratan

1. **Firebase Project** sudah dibuat di [Firebase Console](https://console.firebase.google.com)
2. **Flutter SDK** v3.11.5+ dengan support Firebase
3. **Android/iOS Native Config** siap didaftarkan ke Firebase

## 🔧 Langkah Setup

### 1. Buat Firebase Project

1. Buka [Firebase Console](https://console.firebase.google.com)
2. Klik "Add Project"
3. Isi nama project (contoh: `lms-mobile-bass-training`)
4. Pilih atau buat Google Analytics account (optional)
5. Klik "Create Project"

### 2. Register Android App di Firebase

1. Dari Firebase Console, pilih project yang baru dibuat
2. Klik "Add app" → pilih **Android**
3. Isi **Package Name**: `com.example.lms_mobile_app` (atau sesuaikan dengan app Anda)
   - Cek di `android/app/build.gradle.kts`:
     ```kotlin
     android {
         namespace = "com.example.lms_mobile_app"
     }
     ```
4. Isi **App Nickname** (contoh: "LMS Mobile - Android")
5. Klik "Register app"
6. **Download** file `google-services.json`
7. Letakkan di: `android/app/google-services.json`
8. Setup Android Module Dependencies:
   - Buka `android/build.gradle.kts` (top-level)
   - Tambahkan ke `plugins`:
     ```kotlin
     id("com.google.gms.google-services") version "4.4.0" apply false
     ```
   - Buka `android/app/build.gradle.kts`
   - Tambahkan ke top (setelah `plugins {`):
     ```kotlin
     id("com.google.gms.google-services")
     ```

### 3. Register iOS App di Firebase (Optional, untuk iOS)

1. Dari Firebase Console, klik "Add app" → pilih **iOS**
2. Isi **Bundle ID**: `com.example.lmsMobileApp` (atau cek di `ios/Runner.xcodeproj`)
3. Isi **App Nickname** (contoh: "LMS Mobile - iOS")
4. Klik "Register app"
5. **Download** file `GoogleService-Info.plist`
6. Buka `ios/Runner.xcworkspace` (bukan `.xcodeproj`)
7. Drag `GoogleService-Info.plist` ke Xcode, pastikan ditambahkan ke target "Runner"

### 4. Enable Firebase Services

1. Di Firebase Console, pilih project
2. Klik **Authentication** → "Get started"
3. Pilih **Email/Password**
4. Enable → Save
5. Klik **Firestore Database** → "Create database"
6. Pilih **Start in test mode** (untuk development)
7. Pilih region terdekat (contoh: `asia-southeast1` untuk Indonesia)
8. Klik "Create"

### 5. Setup Firestore Security Rules (Development Only)

**⚠️ Penting**: Rules di bawah HANYA untuk testing. Jangan pakai di production!

1. Di Firestore Console, klik tab **Rules**
2. Ganti dengan:
   ```firestore
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       match /users/{userId} {
         allow read, write: if request.auth.uid == userId;
       }
       match /courses/{document=**} {
         allow read: if request.auth != null;
         allow write: if request.auth != null && 
                      get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'instructor';
       }
       match /{document=**} {
         allow read, write: if false;
       }
     }
   }
   ```
3. Klik "Publish"

### 6. Test Firebase Connection

1. Jalankan app di emulator atau device:
   ```bash
   cd f:/Aplikasi\ Mobile\ Bass\ Training/lms_mobile_app
   flutter run
   ```

2. Di login screen, klik "Create an account"
3. Isi data:
   - **Nama**: Nama Lengkap
   - **Email**: email@example.com
   - **Password**: password123 (min 6 karakter)
4. Klik "Register"

5. **Verifikasi di Firebase Console**:
   - Buka **Authentication** → tab "Users"
   - Seharusnya ada user baru dengan email yang tadi didaftarkan

6. **Verifikasi di Firestore**:
   - Buka **Firestore Database**
   - Seharusnya ada collection `users` → document dengan user ID
   - Cek bahwa data ada: `name`, `email`, `role` (default: `participant`)

### 7. Test Role-Based UI

1. Login dengan akun yang baru didaftar
2. Lihat di **Home Screen**: seharusnya tidak ada banner "Mode Instruktur"
3. Klik tab **Profile**: seharusnya ada badge "PARTICIPANT"

### 8. Manually Create Instructor Account (Temporary)

Untuk testing role branching:

1. Di Firestore Console, buka collection `users`
2. Cari document dengan user ID yang ingin diubah jadi instruktur
3. Edit field `role`: ubah dari `participant` ke `instructor`
4. Save

Atau via CLI:
```bash
firebase firestore:set /databases/(default)/documents/users/{USER_ID} --data '{"name":"Nama Instruktur","email":"instructor@example.com","role":"instructor","id":"{USER_ID}"}'
```

5. Logout dari app, lalu login kembali
6. Lihat di **Home Screen**: seharusnya muncul banner "Mode Instruktur Aktif"
7. Di **Profile Screen**: seharusnya badge berubah ke "INSTRUCTOR"

## 🔐 Keamanan Temporary Setup

Saat ini:
- ✅ Auth firewall sudah aktif di Firestore (hanya user tertentu bisa akses data mereka)
- ⚠️ Test mode masih open, siap untuk development
- ⚠️ Jangan deploy ke production tanpa tighten security rules

Saat akan production:
1. Implement proper JWT token validation (bukan Firebase Auth langsung)
2. Set Firestore rules lebih strict berdasarkan website backend
3. Swap Firebase Auth ke backend website auth endpoint di `AuthRepositoryImpl`

## 🚀 Next Steps (Phase 2)

1. **Instruktur UI**: Tambahkan tombol "Edit Course", "Add Lesson" di screens yang relevan
2. **Firestore Listener**: Subscribe ke perubahan course/lesson, update participant UI real-time
3. **Sync Strategy**: Tentukan apakah course data bersumber dari Firestore atau tetap dummy

## 🐛 Troubleshooting

### "FirebaseException: [core/no-app] No Firebase App"

**Solusi**: Pastikan `google-services.json` sudah di `android/app/` dan `GoogleService-Info.plist` sudah di Xcode.

### "Permission denied for 'create' on 'users'"

**Solusi**: Pastikan security rules sudah publish dan memperbolehkan user authenticated membuat dokumen di `/users/{userId}`.

### "Email already in use"

**Solusi**: Akun sudah terdaftar. Gunakan email berbeda atau reset via Firebase Console → Authentication → Delete user.

### Fallback ke Mock Auth

Jika Firebase tidak initialized (development offline, konfigurasi tidak lengkap), app otomatis fallback ke mock auth dengan peringatan di console. Login akan tetap berfungsi dengan dummy data.

## 📞 Support

Jika ada error atau issue, cek:
1. Console logs (run `flutter run -v` untuk verbose)
2. Firebase Console → Logs untuk error dari backend
3. Pastikan network connectivity (Firebase perlu internet)

## 📚 Referensi

- [Firebase Flutter Documentation](https://firebase.flutter.dev/)
- [Firebase Authentication Guide](https://firebase.google.com/docs/auth)
- [Cloud Firestore Documentation](https://firebase.google.com/docs/firestore)
- [FlutterFire Plugins](https://github.com/firebase/flutterfire)
