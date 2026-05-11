# 🏗️ LMS Mobile App - Clean Architecture Diagram

## Data Flow Architecture

```
┌──────────────────────────────────────────────────────────────────┐
│                    PRESENTATION LAYER                            │
│  (UI, BLoC, Screens, Widgets)                                   │
│                                                                  │
│  Screens → emit Events to BLoC                                  │
│  BLoCs → receive States from domain logic                       │
│  depend on: Domain entities & repositories only                 │
└──────────────────────────────────────────────────────────────────┘
                            ↓
┌──────────────────────────────────────────────────────────────────┐
│                      DOMAIN LAYER                                │
│  (Entities, Repositories, UseCases)                             │
│                                                                  │
│  Pure business logic, no Flutter imports                        │
│  Defines contracts via abstract classes                         │
│  Returns Either<Failure, T> for error handling                 │
│  depend on: Nothing (most independent)                          │
└──────────────────────────────────────────────────────────────────┘
                            ↓
┌──────────────────────────────────────────────────────────────────┐
│                      DATA LAYER                                  │
│  (Models, Mappers, Repositories, DataSources)                  │
│                                                                  │
│  Implements domain contracts                                    │
│  Maps Model (from API) → Entity (domain)                       │
│  Handles API calls & local storage                              │
│  depend on: Domain layer                                        │
└──────────────────────────────────────────────────────────────────┘
                            ↓
┌──────────────────────────────────────────────────────────────────┐
│                      CORE LAYER                                  │
│  (Infrastructure, Utilities)                                    │
│                                                                  │
│  DI, Error handling, Networking, Storage, Config, Utils         │
│  Used by all other layers                                       │
│  depend on: Nothing (lowest level)                              │
└──────────────────────────────────────────────────────────────────┘
```

---

## Folder Structure

```
📦 lms_mobile_app/lib/
├── 📂 src/
│   ├── 📂 core/                          ← Infrastructure
│   │   ├── config/
│   │   │   └── app_config.dart           Flavor (dev, staging, prod)
│   │   ├── constants/
│   │   │   ├── app_strings.dart          All text/labels
│   │   │   ├── app_routes.dart           Route paths
│   │   │   ├── app_images.dart           Asset paths
│   │   │   └── app_sizes.dart            Sizing constants
│   │   ├── di/                           Dependency Injection
│   │   │   ├── modules/
│   │   │   │   ├── auth_module.dart      ✅ DONE
│   │   │   │   ├── courses_module.dart   🚀 TODO
│   │   │   │   ├── lessons_module.dart   🚀 TODO
│   │   │   │   ├── certificates_module.dart 🚀 TODO
│   │   │   │   └── profile_module.dart   🚀 TODO
│   │   │   └── injector.dart             Main DI orchestrator
│   │   ├── error/
│   │   │   ├── failures.dart             Error abstractions
│   │   │   └── app_exception.dart        Exception classes
│   │   ├── network/                      🚀 API setup
│   │   ├── routes/
│   │   │   └── app_router.dart           Route generation
│   │   ├── storage/                      🚀 Storage abstraction
│   │   └── utils/
│   │       ├── validators.dart           Form validators
│   │       ├── date_formatter.dart       Date/time formatting
│   │       ├── currency_formatter.dart   Currency formatting
│   │       └── app_logger.dart           Logging utility
│   │
│   ├── 📂 shared/                        ← Reusable across features
│   │   └── styles/
│   │       ├── app_colors.dart           Color palette
│   │       ├── app_typography.dart       Text styles
│   │       ├── app_theme.dart            Material theme
│   │       └── styles.dart               Barrel export
│   │
│   ├── 📂 features/                      ← Feature modules
│   │   ├── 📂 authentication/
│   │   │   ├── data/
│   │   │   │   ├── datasources/
│   │   │   │   │   └── auth_remote_data_source.dart ✅
│   │   │   │   ├── dtos/                 (optional)
│   │   │   │   ├── mappers/
│   │   │   │   │   └── user_mapper.dart  ✅
│   │   │   │   ├── models/
│   │   │   │   │   └── user_model.dart   ✅
│   │   │   │   └── repositories/
│   │   │   │       └── auth_repository_impl.dart ✅
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   │   └── user_session_entity.dart ✅
│   │   │   │   ├── repositories/
│   │   │   │   │   └── auth_repository.dart ✅
│   │   │   │   ├── usecases/
│   │   │   │   │   └── auth_usecases.dart ✅
│   │   │   │   └── value_objects/
│   │   │   │       └── auth_token.dart   ✅
│   │   │   └── presentation/             🚀 TODO
│   │   │       ├── bloc/                 Need AuthBloc
│   │   │       ├── screens/              Need LoginScreen
│   │   │       └── widgets/              Need login_form, etc
│   │   │
│   │   ├── 📂 courses/                   🚀 TODO (same pattern)
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   └── presentation/
│   │   │
│   │   ├── 📂 lessons/                   🚀 TODO (same pattern)
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   └── presentation/
│   │   │
│   │   ├── 📂 certificates/              🚀 TODO (same pattern)
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   └── presentation/
│   │   │
│   │   └── 📂 profile/                   🚀 TODO (same pattern)
│   │       ├── data/
│   │       ├── domain/
│   │       └── presentation/
│   │
│   └── app.dart                          Root widget ✅
│
├── main.dart                             Entry point 🚀 TODO: Update
│
└── pubspec.yaml                          Dependencies
```

---

## Dependency Diagram

```
PRESENTATION LAYER
├── AuthBloc
│   ├── depends on: LoginUseCase, LogoutUseCase, GetCurrentUserUseCase
│   └── emits: AuthState (initial, loading, authenticated, error)
│
├── CourseBloc
│   └── depends on: Get/Search/ToggleSave/RefreshCoursesUseCase
│
└── LessonBloc
    └── depends on: IsLessonCompleted, ToggleLessonCompletion, etc...

         ↓ inject via DI
         
DOMAIN LAYER
├── UseCases
│   └── depend on: Repositories (interfaces)
│
└── Repositories (interfaces)
    └── AuthRepository, CourseRepository, LessonRepository, ...

         ↓ implement
         
DATA LAYER
├── Repository Implementations
│   └── depend on: DataSources, Mappers
│
├── DataSources
│   └── Remote (API) + Local (Storage)
│
└── Mappers
    └── Convert: DataModel ↔ DomainEntity

         ↓ use
         
CORE LAYER
├── DI (GetIt)
├── Error (Failures, Exceptions)
├── Network (Dio, Interceptors)
├── Storage (Hive, SharedPreferences)
├── Utils (Validators, Formatters, Logger)
└── Config (Flavors)
```

---

## Feature Module Pattern (Repeat for each feature)

```
┌─────────────────────────────────────────────────┐
│ FEATURE: Authentication                         │
├─────────────────────────────────────────────────┤
│                                                 │
│ DOMAIN (Pure Logic - No Flutter)                │
│ ├── entities/user_session_entity.dart          │
│ ├── repositories/auth_repository.dart          │
│ ├── usecases/auth_usecases.dart                │
│ │   ├── LoginUseCase                           │
│ │   ├── LogoutUseCase                          │
│ │   ├── GetCurrentUserUseCase                  │
│ │   └── IsLoggedInUseCase                      │
│ └── value_objects/auth_token.dart              │
│                                                 │
│ DATA (API/Storage Interaction)                  │
│ ├── models/user_model.dart                     │
│ ├── dtos/login_request_dto.dart (optional)     │
│ ├── mappers/user_mapper.dart                   │
│ ├── datasources/auth_remote_data_source.dart   │
│ └── repositories/auth_repository_impl.dart     │
│                                                 │
│ PRESENTATION (UI & State Management)            │
│ ├── bloc/{auth_bloc, auth_event, auth_state}  │
│ ├── screens/login_screen.dart                  │
│ └── widgets/login_form.dart                    │
│                                                 │
│ DI MODULE                                       │
│ └── core/di/modules/auth_module.dart           │
│     ├── registerDataSources()                  │
│     ├── registerRepositories()                 │
│     ├── registerUseCases()                     │
│     └── registerBLoCs()                        │
│                                                 │
└─────────────────────────────────────────────────┘
```

---

## Data Flow Example: Login

```
User taps Login button
        ↓
LoginScreen
        ↓
emit LoginEvent(email: "...", password: "...")
        ↓
AuthBloc receives event
        ↓
call LoginUseCase(email, password)
        ↓
UseCase calls AuthRepository.login()
        ↓
Repository calls AuthRemoteDataSource.login()
        ↓
DataSource makes HTTP request (Dio)
        ↓
Response received: UserModel
        ↓
UserMapper converts: UserModel → UserSessionEntity
        ↓
Repository returns: Either<Failure, UserSessionEntity>
        ↓
UseCase receives result
        ↓
UseCase returns: Either<Failure, UserSessionEntity>
        ↓
BLoC receives result
        ↓
if Right (success):
  emit AuthenticatedState(user)
elif Left (failure):
  emit AuthErrorState(message)
        ↓
Screen listens to state
        ↓
if AuthenticatedState:
  Navigate to Home
else if AuthErrorState:
  Show error message
```

---

## Import Examples (Old vs New)

### Before Refactoring 🚫
```dart
import 'package:lms_mobile_app/data/models/course.dart';
import 'package:lms_mobile_app/data/repositories/course_repository_impl.dart';
import 'package:lms_mobile_app/domain/entities/course_entity.dart';
import 'package:lms_mobile_app/domain/repositories/course_repository.dart';
import 'package:lms_mobile_app/domain/usecases/course_usecase.dart';
import 'package:lms_mobile_app/presentation/bloc/course/course_bloc.dart';
```

### After Refactoring ✅
```dart
// Domain
import 'package:lms_mobile_app/src/features/courses/domain/entities/course_entity.dart';
import 'package:lms_mobile_app/src/features/courses/domain/repositories/course_repository.dart';
import 'package:lms_mobile_app/src/features/courses/domain/usecases/get_courses_usecase.dart';

// Data
import 'package:lms_mobile_app/src/features/courses/data/models/course_model.dart';
import 'package:lms_mobile_app/src/features/courses/data/repositories/course_repository_impl.dart';

// Presentation
import 'package:lms_mobile_app/src/features/courses/presentation/bloc/course_bloc.dart';

// Core
import 'package:lms_mobile_app/src/core/error/failures.dart';
import 'package:lms_mobile_app/src/shared/styles/styles.dart';
```

---

## Key Metrics

| Aspect | Before | After |
|--------|--------|-------|
| **Features Grouped** | No (mixed layers) | ✅ Yes (feature-first) |
| **Code Reusability** | Low | ✅ High |
| **Layer Coupling** | High | ✅ Low |
| **DI Management** | 1 monolithic file | ✅ Per-feature modules |
| **Error Handling** | Exceptions | ✅ Either/Failure |
| **Testability** | Moderate | ✅ High |
| **Scalability** | Hard to add features | ✅ Easy (copy pattern) |
| **Team Collaboration** | Merge conflicts | ✅ Minimal conflicts |
| **Documentation** | Minimal | ✅ Comprehensive |

---

## Legend

- ✅ = Complete (ready to use)
- 🚀 = In development (follow pattern)
- 📋 = Planned (upcoming)
- 🚫 = Old structure (deprecated)

---

**Next**: Start with **REFACTORING_GUIDE.md** to understand patterns deeply.
