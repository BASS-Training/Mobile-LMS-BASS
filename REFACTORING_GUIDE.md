# 📚 REFACTORING GUIDE - LMS Mobile App

Panduan lengkap refactoring LMS Mobile App ke Clean Architecture seperti Quanta HRIS.

## 🏗️ Struktur Baru (Clean Architecture)

```
lib/
  main.dart                          # Entry point
  src/
    app.dart                         # Root widget
    core/                            # Infrastructure & cross-cutting concerns
      config/
        app_config.dart              # Flavor configuration (dev, staging, prod)
      constants/
        app_strings.dart             # Semua string/text constants
        app_routes.dart              # Route paths
        app_images.dart              # Image/asset paths
        app_sizes.dart               # Sizing constants
      di/
        modules/                     # DI modules per feature (TODO)
          core_module.dart
          auth_module.dart
          courses_module.dart
          lessons_module.dart
          certificates_module.dart
          profile_module.dart
        injector.dart                # Main DI orchestrator
      error/
        failures.dart                # Error abstraction (ServerFailure, UnauthorizedFailure, etc.)
        app_exception.dart           # Exception classes
      network/
        api_client.dart              # (TODO) Dio client configuration
        api_response_model.dart      # (TODO) Common response model
      routes/
        app_router.dart              # Route generation & navigation helpers
      storage/
        session_storage_repository.dart    # (TODO) Session storage interface
        session_storage_repository_impl.dart # (TODO) Implementation
      utils/
        validators.dart              # Form validators
        date_formatter.dart          # Date/time formatting
        currency_formatter.dart      # Currency formatting
        app_logger.dart              # Logging utility
        extensions/                  # (TODO) Dart extensions
          string_extension.dart
          datetime_extension.dart

    shared/                          # Reusable components across features
      styles/
        app_colors.dart              # Color palette
        app_typography.dart          # Text styles
        app_theme.dart               # Material theme
        styles.dart                  # Export barrel
      widgets/                       # (TODO) Reusable UI widgets
        app_text_field.dart
        app_button.dart
        primary_button.dart
      dialogs/                       # (TODO) Reusable dialogs
        app_dialog.dart
        loading_dialog.dart
      states/                        # (TODO) Common state classes
        view_state.dart

    features/                        # Feature modules
      authentication/
        data/
          datasources/
            auth_remote_data_source.dart      # Interface
            auth_remote_data_source_impl.dart # Implementation
          dtos/
            login_request_dto.dart
            login_response_dto.dart
          mappers/
            auth_mapper.dart
          repositories/
            auth_repository_impl.dart
        domain/
          entities/
            user_session_entity.dart
          repositories/
            auth_repository.dart              # Interface
          usecases/
            login_usecase.dart
            logout_usecase.dart
          value_objects/
            auth_token.dart
        presentation/
          bloc/
            auth_bloc.dart
            auth_event.dart
            auth_state.dart
          screens/
            login_screen.dart
          widgets/
            login_form.dart

      courses/                       # Same pattern as authentication
        data/
          datasources/
          dtos/
          mappers/
          models/
          repositories/
        domain/
          entities/
          repositories/
          usecases/
          value_objects/
        presentation/
          bloc/
          screens/
          widgets/

      lessons/                       # Same pattern
        ...

      certificates/                  # Same pattern
        ...

      profile/                       # Same pattern
        ...
```

## 🎯 Key Principles

### 1. **Dependency Rule**
```
┌─────────────────────────────────────────┐
│         PRESENTATION LAYER              │
│  (UI, BLoC, Screens, Widgets)          │
└─────────────────────────────────────────┘
                    ↓ depends on
┌─────────────────────────────────────────┐
│           DOMAIN LAYER                  │
│  (Entities, Repositories, UseCases)    │
└─────────────────────────────────────────┘
                    ↓ depends on
┌─────────────────────────────────────────┐
│            DATA LAYER                   │
│  (DataSources, Models, Mappers, Repos) │
└─────────────────────────────────────────┘
                    ↓ depends on
┌─────────────────────────────────────────┐
│      CORE (cross-cutting concerns)      │
│  (Network, Storage, DI, Utils, Config) │
└─────────────────────────────────────────┘
```

**Aturan Penting:**
- `Presentation` boleh depend ke `Domain`
- `Data` implement kontrak dari `Domain`
- `Domain` TIDAK boleh depend ke `Data` atau Flutter UI
- `Core` dipakai oleh semua layer

### 2. **Data Flow (Unidirectional)**
```
UI Event → BLoC → UseCase → Repository (interface)
         ↓
   Repository (impl) → DataSource → API/Local Storage
         ↓
   Mapping (Model → Entity) → BLoC → State
         ↓
   UI Render
```

### 3. **Naming Convention**

| Artifact | Pattern | Example |
|----------|---------|---------|
| Repository Interface | `<Feature>Repository` | `AuthRepository` |
| Repository Implementation | `<Feature>RepositoryImpl` | `AuthRepositoryImpl` |
| Remote DataSource Interface | `<Feature>RemoteDataSource` | `AuthRemoteDataSource` |
| Remote DataSource Impl | `<Feature>RemoteDataSourceImpl` | `AuthRemoteDataSourceImpl` |
| UseCase | `<Action><Feature>UseCase` | `LoginUseCase`, `GetCoursesUseCase` |
| BLoC | `<Feature>Bloc` | `AuthBloc` |
| Event | `<Feature>Event` | `AuthEvent` |
| State | `<Feature>State` | `AuthState` |
| Entity | `<Feature>Entity` | `UserSessionEntity` |
| Model | `<Feature>Model` atau `<Feature>Dto` | `LoginResponseModel` |
| Failure | `<Type>Failure` | `ServerFailure`, `NetworkFailure` |

## 📝 How to Add a New Feature

### Step 1: Create Feature Structure
```bash
# Automatic via folder creation
lib/src/features/<feature_name>/
  data/
    datasources/
    dtos/
    mappers/
    models/
    repositories/
  domain/
    entities/
    repositories/
    usecases/
    value_objects/
  presentation/
    bloc/
    screens/
    widgets/
```

### Step 2: Domain Layer (Business Logic)
Mulai dari domain karena itu adalah core business logic.

```dart
// domain/entities/course_entity.dart
class CourseEntity {
  final String id;
  final String title;
  final String description;
  
  CourseEntity({
    required this.id,
    required this.title,
    required this.description,
  });
}

// domain/repositories/course_repository.dart
abstract class CourseRepository {
  Future<Either<Failure, List<CourseEntity>>> getCourses();
  Future<Either<Failure, CourseEntity>> getCourseById(String id);
}

// domain/usecases/get_courses_usecase.dart
class GetCoursesUseCase {
  final CourseRepository repository;
  
  GetCoursesUseCase(this.repository);
  
  Future<Either<Failure, List<CourseEntity>>> call() {
    return repository.getCourses();
  }
}
```

### Step 3: Data Layer (API/Storage)
Implement repository interface dan handle data mapping.

```dart
// data/models/course_model.dart
@freezed
class CourseModel with _$CourseModel {
  const factory CourseModel({
    required String id,
    required String title,
    required String description,
  }) = _CourseModel;

  factory CourseModel.fromJson(Map<String, dynamic> json) =>
      _$CourseModelFromJson(json);
}

// data/dtos/course_response_dto.dart
class CourseResponseDto {
  final List<CourseModel> courses;
  
  CourseResponseDto({required this.courses});
  
  factory CourseResponseDto.fromJson(Map<String, dynamic> json) {
    return CourseResponseDto(
      courses: (json['data'] as List)
          .map((c) => CourseModel.fromJson(c))
          .toList(),
    );
  }
}

// data/mappers/course_mapper.dart
class CourseMapper {
  static CourseEntity toEntity(CourseModel model) {
    return CourseEntity(
      id: model.id,
      title: model.title,
      description: model.description,
    );
  }
}

// data/datasources/course_remote_data_source.dart
abstract class CourseRemoteDataSource {
  Future<CourseResponseDto> getCourses();
}

class CourseRemoteDataSourceImpl implements CourseRemoteDataSource {
  final DioClient dioClient;
  
  CourseRemoteDataSourceImpl(this.dioClient);
  
  @override
  Future<CourseResponseDto> getCourses() async {
    final response = await dioClient.get('/courses');
    return CourseResponseDto.fromJson(response);
  }
}

// data/repositories/course_repository_impl.dart
class CourseRepositoryImpl implements CourseRepository {
  final CourseRemoteDataSource remoteDataSource;
  
  CourseRepositoryImpl({required this.remoteDataSource});
  
  @override
  Future<Either<Failure, List<CourseEntity>>> getCourses() async {
    try {
      final dto = await remoteDataSource.getCourses();
      final entities = dto.courses.map(CourseMapper.toEntity).toList();
      return Right(entities);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException {
      return Left(NetworkFailure());
    }
  }
}
```

### Step 4: Presentation Layer (UI & State Management)
```dart
// presentation/bloc/course_event.dart
abstract class CourseEvent extends Equatable {}

class GetCoursesEvent extends CourseEvent {
  @override
  List<Object?> get props => [];
}

// presentation/bloc/course_state.dart
abstract class CourseState extends Equatable {}

class CourseInitial extends CourseState {
  @override
  List<Object?> get props => [];
}

class CourseLoading extends CourseState {
  @override
  List<Object?> get props => [];
}

class CourseLoaded extends CourseState {
  final List<CourseEntity> courses;
  
  CourseLoaded(this.courses);
  
  @override
  List<Object?> get props => [courses];
}

class CourseError extends CourseState {
  final String message;
  
  CourseError(this.message);
  
  @override
  List<Object?> get props => [message];
}

// presentation/bloc/course_bloc.dart
class CourseBloc extends Bloc<CourseEvent, CourseState> {
  final GetCoursesUseCase getCoursesUseCase;
  
  CourseBloc({required this.getCoursesUseCase}) : super(CourseInitial()) {
    on<GetCoursesEvent>(_onGetCourses);
  }
  
  Future<void> _onGetCourses(
    GetCoursesEvent event,
    Emitter<CourseState> emit,
  ) async {
    emit(CourseLoading());
    
    final result = await getCoursesUseCase();
    result.fold(
      (failure) => emit(CourseError(failure.message)),
      (courses) => emit(CourseLoaded(courses)),
    );
  }
}

// presentation/screens/course_list_screen.dart
class CourseListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Courses')),
      body: BlocBuilder<CourseBloc, CourseState>(
        builder: (context, state) {
          if (state is CourseLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (state is CourseError) {
            return Center(child: Text(state.message));
          }
          
          if (state is CourseLoaded) {
            return ListView.builder(
              itemCount: state.courses.length,
              itemBuilder: (context, index) {
                final course = state.courses[index];
                return ListTile(
                  title: Text(course.title),
                  subtitle: Text(course.description),
                );
              },
            );
          }
          
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
```

## 🔧 Error Handling Pattern

Semua errors di-map ke `Failure` di domain layer:

```dart
// core/error/failures.dart
abstract class Failure {
  final String message;
  Failure({required this.message});
}

class ServerFailure extends Failure {
  ServerFailure({required String message}) : super(message: message);
}

class NetworkFailure extends Failure {
  NetworkFailure() : super(message: 'Network error');
}

class UnauthorizedFailure extends Failure {
  UnauthorizedFailure() : super(message: 'Unauthorized');
}

// data/repositories/course_repository_impl.dart
@override
Future<Either<Failure, List<CourseEntity>>> getCourses() async {
  try {
    final dto = await remoteDataSource.getCourses();
    return Right(dto.courses.map(CourseMapper.toEntity).toList());
  } on ServerException catch (e) {
    return Left(ServerFailure(message: e.message));
  } on UnauthorizedException {
    return Left(UnauthorizedFailure());
  } on NetworkException {
    return Left(NetworkFailure());
  } catch (e) {
    return Left(UnknownFailure(message: e.toString()));
  }
}
```

## 🔌 Dependency Injection (DI)

Gunakan GetIt untuk DI. Split per feature module:

```dart
// core/di/modules/auth_module.dart
void registerAuthModule() {
  // DataSources
  getIt.registerSingleton<AuthRemoteDataSource>(
    AuthRemoteDataSourceImpl(getIt()),
  );
  
  // Repositories
  getIt.registerSingleton<AuthRepository>(
    AuthRepositoryImpl(remoteDataSource: getIt()),
  );
  
  // UseCases
  getIt.registerSingleton(
    LoginUseCase(getIt()),
  );
  
  // BLoCs
  getIt.registerSingleton(
    AuthBloc(loginUseCase: getIt()),
  );
}

// core/di/modules/courses_module.dart
void registerCoursesModule() {
  // Same pattern...
}

// core/di/injector.dart
final getIt = GetIt.instance;

void configureDependencies() {
  registerCoreModule();
  registerNetworkModule();
  registerAuthModule();
  registerCoursesModule();
  registerLessonsModule();
  registerCertificatesModule();
  registerProfileModule();
}

// main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Setup DI
  configureDependencies();
  
  runApp(
    LmsApp(
      appConfig: AppConfig.production(),
    ),
  );
}
```

## 📊 State Management with BLoC

Pola umum untuk BLoC:

```dart
// Event (input dari UI)
abstract class CourseEvent extends Equatable {}

// State (output ke UI)
abstract class CourseState extends Equatable {}

// BLoC (business logic)
class CourseBloc extends Bloc<CourseEvent, CourseState> {
  CourseBloc() : super(CourseInitial()) {
    on<GetCoursesEvent>(_onGetCourses);
  }
  
  Future<void> _onGetCourses(GetCoursesEvent event, Emitter emit) async {
    emit(CourseLoading());
    // business logic
    emit(CourseLoaded(...));
  }
}
```

## 🧪 Testing Structure

```
test/
  features/
    authentication/
      data/
        repositories/
          auth_repository_test.dart
        datasources/
          auth_remote_data_source_test.dart
      domain/
        usecases/
          login_usecase_test.dart
      presentation/
        bloc/
          auth_bloc_test.dart
    courses/
      ...
```

## ✅ Checklist untuk Setiap Feature

- [ ] Domain layer lengkap (entities, repositories, usecases)
- [ ] Error handling (custom exceptions, failures)
- [ ] Data layer lengkap (datasources, dtos, mappers, repositories)
- [ ] Presentation layer (blocs, events, states, screens, widgets)
- [ ] DI registration di modules
- [ ] Routes di app_routes.dart
- [ ] Screens di app_router.dart
- [ ] Unit tests untuk critical business logic
- [ ] Integration tests untuk flow

## 📚 References

- **Architecture**: Clean Architecture oleh Robert C. Martin
- **State Management**: BLoC pattern documentation
- **Package**: GetIt untuk DI, dartz untuk Either/Result

---

**Terakhir diupdate**: May 11, 2026
