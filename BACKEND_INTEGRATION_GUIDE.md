# Backend Integration Guide - LMS Mobile App

**Tujuan**: Menjelaskan step-by-step cara integrate API backend ke lms_mobile_app

---

## 📌 Konsep Utama

Arsitektur sudah didesain agar **MUDAH switch dari dummy data ke API**. Tidak perlu refactor UI/BLoC/Domain!

### Yang Berubah
- **HANYA `data/datasources/` yang diupdate**
- Repository tetap sama
- UseCase tetap sama
- BLoC tetap sama
- UI tetap sama

---

## 🔄 Step-by-Step Integration

### STEP 1: Update `network_module.dart`

Saat ini ada placeholder untuk Dio. Update untuk production:

```dart
class NetworkModule {
  static Future<void> register() async {
    // Inject Dio client yang sudah siap pakai
    _setupDioClient();
  }

  static void _setupDioClient() {
    final config = FlavorConfig.instance;
    
    final baseOptions = BaseOptions(
      baseUrl: config.apiBaseUrl,  // misal: 'https://api.lms.com'
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    );

    final dio = Dio(baseOptions);

    // Add logging interceptor
    if (config.enableLogging) {
      dio.interceptors.add(LoggingInterceptor());
    }

    // TODO: Add auth interceptor untuk bearer token
    // dio.interceptors.add(AuthInterceptor());

    // Register ke service locator (jika menggunakan GetIt)
    // getIt.registerSingleton<Dio>(dio);
  }
}
```

### STEP 2: Update Course Remote DataSource

Replace dummy data dengan API calls:

**File**: `lib/src/features/courses/data/datasources/course_remote_data_source_impl.dart`

```dart
import 'package:dio/dio.dart';
import '../models/course.dart';
import 'course_remote_data_source.dart';

class CourseRemoteDataSourceImpl implements CourseRemoteDataSource {
  final Dio _dio;

  CourseRemoteDataSourceImpl(this._dio);

  @override
  Future<List<Course>> getCourses() async {
    try {
      final response = await _dio.get('/api/courses');
      
      // Assume backend return: { "data": [ {...}, {...} ] }
      final data = response.data as Map<String, dynamic>;
      final coursesList = data['data'] as List;
      
      return coursesList
          .map((json) => Course.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      // Handle Dio errors dengan error mapping
      throw _mapDioError(e);
    }
  }

  @override
  Future<Course?> getCourseById(String id) async {
    try {
      final response = await _dio.get('/api/courses/$id');
      final data = response.data as Map<String, dynamic>;
      return Course.fromJson(data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return null;
      }
      throw _mapDioError(e);
    }
  }

  @override
  Future<List<Course>> searchCourses(String query) async {
    try {
      final response = await _dio.get(
        '/api/courses/search',
        queryParameters: {'q': query},
      );
      
      final data = response.data as Map<String, dynamic>;
      final coursesList = data['data'] as List;
      
      return coursesList
          .map((json) => Course.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  @override
  Future<void> toggleSaveCourse(String courseId) async {
    try {
      await _dio.post('/api/courses/$courseId/save/toggle');
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  @override
  Future<List<Course>> getSavedCourses() async {
    try {
      final response = await _dio.get('/api/courses/saved');
      
      final data = response.data as Map<String, dynamic>;
      final coursesList = data['data'] as List;
      
      return coursesList
          .map((json) => Course.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  // Helper untuk map Dio error ke AppException
  Exception _mapDioError(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout) {
      return Exception('Connection timeout');
    } else if (error.type == DioExceptionType.receiveTimeout) {
      return Exception('Receive timeout');
    } else if (error.response?.statusCode == 401) {
      return Exception('Unauthorized - please login again');
    } else if (error.response?.statusCode == 403) {
      return Exception('Forbidden - access denied');
    } else if (error.response?.statusCode == 404) {
      return Exception('Not found');
    } else if (error.response?.statusCode == 500) {
      return Exception('Server error - please try again later');
    }
    return Exception('Unknown error: ${error.message}');
  }
}
```

### STEP 3: Update Lessons & Others (Sama Pattern)

**File**: `lib/src/features/lessons/data/datasources/lesson_remote_data_source_impl.dart`

```dart
class LessonRemoteDataSourceImpl implements LessonRemoteDataSource {
  final Dio _dio;

  LessonRemoteDataSourceImpl(this._dio);

  @override
  Future<bool> isLessonCompleted(String lessonId) async {
    try {
      final response = await _dio.get('/api/lessons/$lessonId/status');
      final data = response.data as Map<String, dynamic>;
      return data['isCompleted'] as bool;
    } on DioException {
      // Fallback ke local jika error
      return false;
    }
  }

  @override
  Future<void> markLessonComplete(String lessonId) async {
    try {
      await _dio.post('/api/lessons/$lessonId/complete');
    } on DioException catch (e) {
      // Biarkan repository handle, bisa retry nanti
      rethrow;
    }
  }

  // ... implement methods lainnya dengan pattern yang sama
}
```

### STEP 4: Update DI Injection

**File**: `lib/src/core/di/modules/course_module.dart`

```dart
class CourseModule {
  static void register() {
    // Ambil Dio dari DI (sudah di-register di NetworkModule)
    // Dengan GetIt:
    // final dio = getIt<Dio>();

    // Atau inject langsung:
    final dio = Dio(BaseOptions(baseUrl: 'https://api.lms.com'));

    // Data Sources
    CourseLocalDataSource localDataSource = CourseLocalDataSourceImpl();
    CourseRemoteDataSource remoteDataSource = CourseRemoteDataSourceImpl(dio);

    // Repository dengan Dio client
    CourseRepository courseRepository = CourseRepositoryImpl(
      localDataSource: localDataSource,
      remoteDataSource: remoteDataSource,
    );

    // Rest tetap sama...
  }
}
```

---

## 🔐 Auth Integration (Important!)

### Tambah Bearer Token ke Dio

**File**: `lib/src/core/network/auth_interceptor.dart`

```dart
import 'package:dio/dio.dart';
import 'package:lms_mobile_app/src/core/utils/local_storage.dart';

class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Ambil token dari local storage
    final token = LocalStorage.getAuthToken();
    
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    
    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Jika 401, berarti token expired
    if (err.response?.statusCode == 401) {
      // TODO: Trigger logout / refresh token
      // eventBus.fire(LogoutEvent());
    }
    
    super.onError(err, handler);
  }
}
```

### Register di NetworkModule

```dart
void _setupDioClient() {
  final dio = Dio(baseOptions);
  
  // Add interceptors
  dio.interceptors.add(LoggingInterceptor());
  dio.interceptors.add(AuthInterceptor());
  
  // Register ke getIt jika pakai GetIt
}
```

---

## 🧪 Testing Steps

### 1. **Manual Test dengan Postman/Insomnia**

Pastikan API endpoints working:
```
GET /api/courses
GET /api/courses/:id
GET /api/courses/search?q=...
POST /api/courses/:id/save/toggle
GET /api/courses/saved
```

### 2. **Update API Base URL di FlavorConfig**

**File**: `lib/src/core/config/flavor_config.dart`

```dart
class DevelopmentFlavorConfig {
  // Change from dummy:
  static const String apiBaseUrl = 'https://api.dev.lms.com';
  
  // For production:
  // static const String apiBaseUrl = 'https://api.lms.com';
}
```

### 3. **Run App & Test Flow**

1. Login dengan credentials dari backend
2. Tekan tombol "Get Courses" → akan hit `/api/courses`
3. Search course → akan hit `/api/courses/search`
4. Save course → akan hit `/api/courses/:id/save/toggle`
5. Offline mode → fallback ke local cache otomatis

---

## 🚨 Error Handling Checklist

- [ ] Network timeout → show "Connection timeout" to user
- [ ] 401 Unauthorized → trigger logout + redirect to login
- [ ] 403 Forbidden → show "Access denied" message
- [ ] 404 Not Found → graceful handling
- [ ] 500 Server Error → show "Server error, try again later"
- [ ] No internet → fallback to local cache

---

## 📊 Example API Response Format

```json
// GET /api/courses
{
  "success": true,
  "message": "Courses retrieved successfully",
  "data": [
    {
      "id": "1",
      "title": "Accounting",
      "description": "Learn accounting basics",
      "instructor": "Pak Bayu",
      "color": "#A29BFE",
      "icon": "📊",
      "chaptersCount": 4,
      "duration": "8 hours",
      "sections": [
        {
          "id": "1-s1",
          "courseId": "1",
          "sectionNumber": 1,
          "title": "Introduction",
          "lessons": [
            {
              "id": "1-1-1",
              "courseId": "1",
              "title": "What is Accounting?",
              "content": "...",
              "duration": "20 min",
              "type": "video"
            }
          ]
        }
      ]
    }
  ]
}

// POST /api/courses/:id/complete (untuk lessons)
{
  "success": true,
  "message": "Lesson marked as complete"
}
```

---

## 📝 Checklist sebelum go Live

- [ ] Semua API endpoints sudah tested
- [ ] Error handling proper
- [ ] Auth token handling correct
- [ ] Offline cache working
- [ ] Token refresh implemented
- [ ] Logging disable di production
- [ ] Build APK/IPA untuk testing device
- [ ] Load testing (berapa banyak courses dapat handle?)
- [ ] Security review (no hardcoded secrets)

---

## 🎯 Troubleshooting

### API returns 401 terus-menerus
- Check: Bearer token format di AuthInterceptor
- Check: Token expiry time di backend
- Check: Refresh token logic implemented

### Courses tidak load tapi offline cache ada
- Check: Repository fallback logic bekerja?
- Check: Local datasource punya data?

### Timeout terus
- Increase timeout di DioClient (DEFAULT 30s)
- Check: API server latency

### Serialization error (fromJson error)
- Ensure model's fromJson match API response format
- Use `json_serializable` package untuk auto-generate

---

## 📚 Resources

- Dio docs: https://pub.dev/packages/dio
- GoRouter docs: https://pub.dev/packages/go_router
- BLoC pattern: https://bloclibrary.dev
- Clean Architecture: https://resocoder.com/flutter-clean-architecture

---

**Created by**: GitHub Copilot  
**Date**: 11 Mei 2026  
**Status**: Ready untuk backend integration
