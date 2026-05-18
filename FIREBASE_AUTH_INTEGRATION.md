# Integrasi Firebase Auth & Role-Based UI — Dokumentasi Teknis

## 📋 Ringkasan Perubahan Phase 1

Fase ini menambahkan authentication berbasis Firebase dan branching UI berdasarkan role akun (participant/instructor) ke aplikasi mobile LMS.

**Status**: Phase 1 selesai — Auth dan branching UI siap ditest dengan Firebase. Phase 2 akan menambahkan instructor features dan Firestore sync.

---

## 🏗️ Arsitektur

### Auth Layer (Clean Architecture)

```
Presentation (UI)
  ├── LoginScreen
  ├── RegisterScreen
  ├── ProfileScreen (menampilkan role)
  └── AuthBloc (state management)

Domain (Business Logic)
  ├── AuthRepository (interface)
  └── UseCases:
      ├── LoginUseCase
      ├── RegisterUseCase
      ├── LogoutUseCase
      └── GetCurrentUserUseCase

Data (External Services)
  └── AuthRepositoryImpl
      ├── Firebase Auth signInWithEmailAndPassword
      ├── Firebase Auth createUserWithEmailAndPassword
      ├── Firestore users collection (read/write role)
      └── Fallback mock auth jika Firebase unavailable
```

### Role-Based UI

```
App Launch
  ├── AuthSessionRequestedEvent (restore sesi)
  └── Router Guard (based on AuthState)
      ├── If unauthenticated → /login
      └── If authenticated → /main
          └── MainScreen
              └── HomeScreen + CourseListScreen + SavedCourses + Profile
                  ├── If role == 'participant'
                  │   └── Lihat tampilan peserta (default)
                  └── If role == 'instructor'
                      └── Banner "Mode Instruktur Aktif" di home
```

---

## 📁 File & Perubahan Utama

### 1. Dependencies (`pubspec.yaml`)

**Ditambahkan**:
```yaml
firebase_core: ^3.8.0      # Core Firebase SDK
firebase_auth: ^5.3.3      # Email/password authentication
cloud_firestore: ^5.5.0    # User profile + role storage
```

### 2. Firebase Bootstrap (`lib/src/core/services/firebase_initializer.dart`)

**Baru**: Service untuk inisialisasi Firebase dengan fallback aman.

```dart
class FirebaseInitializer {
  static Future<void> ensureInitialized() async {
    // Tries Firebase.initializeApp()
    // Sets _isInitialized = true/false
  }
}
```

**Dipakai di**: `main.dart` sebelum ServiceLocator boot.

### 3. User Model + Entity

**`user_entity.dart`** (Domain):
- Tambah field: `role: String` (participant/instructor)

**`user.dart`** (Data):
- Tambah field: `role: String`
- JSON mapping: `role` ← Firestore `role` field

**`user_mapper.dart`**:
- Map role dari data layer ke domain

### 4. Auth Repository (`auth_repository_impl.dart`)

**Penggantian utama**: Mock login → Firebase Auth + Firestore.

**Fitur baru**:
- `login(email, password)` — Firebase signInWithEmailAndPassword + load profile dari Firestore
- `register(name, email, password, role)` — Firebase createUserWithEmailAndPassword + Firestore user doc
- `logout()` — Firebase signOut
- `getCurrentUser()` — Restore sesi dari Firebase currentUser + Firestore profile
- Fallback mock jika Firebase tidak tersedia

**Firestore Collection**: `users/{uid}`
```json
{
  "id": "uid",
  "name": "User Name",
  "email": "user@example.com",
  "role": "participant" // or "instructor"
}
```

### 5. Auth BLoC (`auth_bloc.dart`)

**Event baru**:
- `AuthRegisterEvent` — Handle register flow
- `AuthSessionRequestedEvent` — Auto-restore sesi saat app start

**Behavior baru**:
- Constructor trigger `AuthSessionRequestedEvent` untuk restore sesi
- `_onSessionRequested` memanggil `getCurrentUserUseCase`

### 6. Router Auth Guard (`app_router.dart`)

**Redirect logic**:
```dart
if (!isAuthenticated && !isOnAuthRoute) {
  return AppRoutes.login;  // Ke login jika belum login
}
if (isAuthenticated && isOnAuthRoute) {
  return AppRoutes.main;   // Ke main jika sudah login
}
```

**Stream refresh**: `GoRouter` listen ke `AuthBloc` stream untuk real-time redirect on state change.

**Route baru**: `/register` → `RegisterScreen()`

### 7. UI Perubahan

#### **RegisterScreen** (baru)
- Form: Name, Email, Password
- Role: default `participant` (hardcode)
- Submit: `AuthRegisterEvent` → Firebase + Firestore
- Link: "Sudah punya akun? Login" ke `/login`

#### **LoginScreen** (update)
- Link "Forgot Password?" → "Create an account" ke `/register`
- Hint: "Akun instruktur akan dibedakan dari role di Firestore"

#### **MainScreen** (update)
- `BlocBuilder<AuthBloc, AuthState>` untuk baca role dari sesi
- Pass `accountRole` ke HomeScreen

#### **HomeScreen** (update)
- Tambah parameter: `accountRole: String`
- Jika `accountRole == 'instructor'`:
  - Tampilkan banner: "Mode Instruktur Aktif — Kelola materi, kursus, dan update konten untuk peserta"

#### **ProfileScreen** (update)
- Tampilkan badge: `user.role.toUpperCase()` (PARTICIPANT / INSTRUCTOR)
- Logout button: trigger `AuthLogoutEvent` (router guard otomatis redirect ke login)

---

## 🔄 Alur Sesi (Resumable)

### First Launch (No Sesi)
```
App Start
  └─ FirebaseInitializer.ensureInitialized()
  └─ ServiceLocator.setupServiceLocator()
  └─ AuthBloc created + emit AuthSessionRequestedEvent
  └─ AuthBloc.getCurrentUser() → null (Firebase tidak ada sesi)
  └─ Router: unauthenticated → /login
```

### Register
```
LoginScreen "Create an account"
  └─ navigate /register
  └─ RegisterScreen submit
  └─ AuthRegisterEvent(name, email, password, role='participant')
  └─ Firebase Auth.createUserWithEmailAndPassword()
  └─ Firestore users/{uid}.set({name, email, role})
  └─ BLoC emit AuthSuccess(user)
  └─ Router: authenticated + onAuthRoute → /main
```

### Login
```
LoginScreen submit
  └─ AuthLoginEvent(email, password)
  └─ Firebase Auth.signInWithEmailAndPassword()
  └─ Firestore users/{uid}.get() → load role
  └─ BLoC emit AuthSuccess(user with role)
  └─ Router: /main
  └─ MainScreen rebuild dengan accountRole
  └─ HomeScreen: role == 'participant' (default) atau 'instructor' (jika Firestore diubah manual)
```

### App Restart (Sesi Persisten)
```
App Start
  └─ AuthSessionRequestedEvent
  └─ AuthBloc.getCurrentUser()
  └─ Firebase Auth.currentUser → uid
  └─ Firestore users/{uid}.get() → ambil data + role
  └─ BLoC emit AuthSuccess(user with role)
  └─ Router: authenticated → /main langsung
  └─ Tidak perlu login lagi
```

### Logout
```
ProfileScreen logout button
  └─ AuthLogoutEvent
  └─ Firebase Auth.signOut()
  └─ BLoC emit AuthLoggedOut
  └─ Router: unauthenticated + not onAuthRoute → /login
```

---

## 🔐 Security (Temporary)

### Development
- Firestore rules: test mode (open)
- Firebase Auth: standard email/password
- Fallback: mock auth jika offline

### Before Production
1. Implement proper token-based auth (integrate ke website backend)
2. Tighten Firestore rules (check `request.auth` + `role` field)
3. Swap `AuthRepositoryImpl` ke backend endpoint, bukan Firebase
4. Hapus fallback mock auth

---

## 🚀 Migration Path ke Backend Website

### Saat Backend Website Ready

1. **Ganti AuthRepositoryImpl**:
   ```dart
   // Dari Firebase Auth signInWithEmailAndPassword
   // Ke: await dio.post('/api/auth/login', data: {...})
   ```

2. **Ganti Firestore read**:
   ```dart
   // Dari: firestore.collection('users').doc(uid).get()
   // Ke: await dio.get('/api/user/profile', options: headers)
   ```

3. **Token management**:
   - Save JWT token dari backend ke local storage
   - Attach token ke semua API request

4. **Role model**: tetap sama (UserEntity.role)
   - Backend akan return role dalam response

**Keuntungan arsitektur ini**:
- Repository layer tetap abstrak (interface AuthRepository tidak berubah)
- UI + BLoC tidak butuh perubahan
- Hanya swap data layer (AuthRepositoryImpl)

---

## ⚠️ Known Limitations (Phase 1)

1. **Instructor account creation**: Manual via Firestore Console atau admin endpoint
   - Nanti bisa di-unlock via website backend admin panel
2. **Course/Lesson data**: Masih dummy (belum sync dari Firestore)
   - Phase 2 akan add Firestore sync
3. **Offline mode**: Fallback ke mock, bukan local Firestore cache
   - Bisa ditambah nanti dengan Firestore offline persistence

---

## 📊 Phase 2 Preview

Setelah Phase 1 validated:

1. **Instructor UI**:
   - CourseListScreen: tombol "Add Course" (instructor only)
   - CourseDetailScreen: tombol "Edit Course", "Edit Lesson" (instructor only)
   - LessonDetailScreen: edit content form (instructor only)

2. **Firestore Sync**:
   - Listen ke `courses` collection → update participant view real-time
   - Listen ke `lessons` collection → sync instructor edits

3. **Role-based permissions**:
   - `role == 'instructor'` → tampilkan edit buttons
   - `role == 'participant'` → read-only

---

## 🧪 Testing Checklist

- [ ] Firebase project created + google-services.json added
- [ ] App runs without "No Firebase App" error
- [ ] Register screen works → user created in Firebase Auth + Firestore
- [ ] Login works → session restored
- [ ] App restart preserves login
- [ ] Logout works → redirects to /login
- [ ] Participant role shows default home (no banner)
- [ ] Instructor role (manual Firestore edit) shows "Mode Instruktur" banner
- [ ] Profile shows role badge correctly
- [ ] Offline/Firebase unavailable → fallback mock auth works

---

## 📚 File Index

| File | Role | Status |
|------|------|--------|
| `pubspec.yaml` | Dependencies | ✅ Updated |
| `lib/main.dart` | Bootstrap | ✅ Updated |
| `lib/src/core/services/firebase_initializer.dart` | Service | ✅ New |
| `lib/src/features/authentication/domain/entities/user_entity.dart` | Model | ✅ Updated |
| `lib/src/features/authentication/data/models/user.dart` | Model | ✅ Updated |
| `lib/src/features/authentication/data/mappers/user_mapper.dart` | Mapper | ✅ Updated |
| `lib/src/features/authentication/domain/repositories/auth_repository.dart` | Interface | ✅ Updated |
| `lib/src/features/authentication/data/repositories/auth_repository_impl.dart` | Implementation | ✅ Updated |
| `lib/src/features/authentication/domain/usecases/auth_usecase.dart` | UseCase | ✅ Updated |
| `lib/src/features/authentication/presentation/bloc/auth/auth_event.dart` | BLoC | ✅ Updated |
| `lib/src/features/authentication/presentation/bloc/auth/auth_bloc.dart` | BLoC | ✅ Updated |
| `lib/src/features/authentication/presentation/screens/login_screen.dart` | UI | ✅ Updated |
| `lib/src/features/authentication/presentation/screens/register_screen.dart` | UI | ✅ New |
| `lib/src/core/routes/app_router.dart` | Navigation | ✅ Updated |
| `lib/src/features/main/presentation/screens/main_screen.dart` | Shell | ✅ Updated |
| `lib/src/features/home/presentation/screens/home_screen.dart` | UI | ✅ Updated |
| `lib/src/features/authentication/presentation/screens/profile_screen.dart` | UI | ✅ Updated |
| `lib/src/core/di/modules/auth_module.dart` | DI | ✅ Updated |

---

## 📞 Questions?

Lihat `FIREBASE_AUTH_SETUP.md` untuk setup guide.
