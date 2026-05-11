# Clean Architecture Reference Guide - LMS Mobile App

Panduan lengkap untuk memahami dan menggunakan arsitektur Clean Architecture yang baru di LMS Mobile App.

---

## 🏗️ Architecture Overview

### Layers (Dependency Flow)

```
┌─────────────────────────────────────────────────────┐
│          PRESENTATION LAYER (UI)                    │
│  - Screens, Widgets, BLoCs, States, Events         │
│  • LocationInfo: lib/src/features/{feature}/        │
└──────────────────┬──────────────────────────────────┘
                   │
                   │ depends on
                   ▼
┌─────────────────────────────────────────────────────┐
│           DOMAIN LAYER (Business Logic)             │
│  - Entities, UseCases, Repository Interfaces       │
│  • Location: lib/src/features/{feature}/domain/    │
└──────────────────┬──────────────────────────────────┘
                   │
                   │ depends on
                   ▼
┌─────────────────────────────────────────────────────┐
│           DATA LAYER (Data Sources)                 │
│  - Models, Mappers, Repositories, DataSources      │
│  • Location: lib/src/features/{feature}/data/      │
└─────────────────────────────────────────────────────┘
                   │
                   │ uses
                   ▼
┌─────────────────────────────────────────────────────┐
│   CORE LAYER (Shared Infrastructure)                │
│  - DI, Error Handling, Network, Routes, Utils      │
│  • Location: lib/src/core/                         │
└─────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────┐
│     SHARED LAYER (Reusable UI Components)          │
│  - Common Widgets, Dialogs, Styles, States         │
│  • Location: lib/src/shared/                       │
└─────────────────────────────────────────────────────┘
```

---

## 📂 Folder Structure Explained

### lib/src/core/
**Tujuan**: Shared by all features, foundational infrastructure

```
core/
├── config/                    # Configuration
│   ├── constants/
│   │   ├── api_endpoints.dart    # API routes
│   │   ├── app_strings.dart      # UI strings (i18n ready)
│   │   └── app_routes.dart       # Navigation route names
│   └── flavor_config.dart        # Dev/Staging/Prod configuration
├── di/                        # Dependency Injection
│   ├── injector.dart          # Orchestrate all modules (entry point)
│   └── modules/
│       ├── core_module.dart       # Storage, router, config
│       ├── network_module.dart    # Dio client, interceptors
│       ├── auth_module.dart       # Auth dependencies
│       ├── course_module.dart     # Course dependencies
│       ├── lesson_module.dart     # Lesson dependencies
│       └── certificate_module.dart # Certificate dependencies
├── error/                     # Error Handling
│   ├── app_exception.dart     # App-wide exceptions
│   ├── failures.dart          # Domain-level failures
│   └── error_handler.dart     # Exception → Failure mapping
├── network/                   # Network/API
│   ├── api_client.dart        # Main Dio client
│   ├── api_response_model.dart # Unified API response
│   └── interceptors/
│       ├── auth_interceptor.dart
│       └── logging_interceptor.dart
├── routes/                    # Navigation
│   └── app_router.dart        # GoRouter configuration
└── utils/                     # Utilities
    ├── extensions/
    │   ├── string_extension.dart
    │   └── date_extension.dart
    ├── formatters/
    │   ├── currency_formatter.dart
    │   └── date_formatter.dart
    └── validators.dart        # Input validation
```

### lib/src/shared/
**Tujuan**: Reusable UI components & styles

```
shared/
├── styles/                    # Design system
│   ├── app_colors.dart        # Color palette
│   ├── app_typography.dart    # Text styles
│   ├── app_measures.dart      # Padding, spacing, sizes
│   └── app_theme.dart         # Complete theme
├── widgets/                   # Reusable components
│   ├── buttons.dart           # Button variants
│   ├── form_fields.dart       # Input fields
│   ├── bottom_nav_bar.dart
│   ├── progress_indicator.dart
│   ├── statistics_card.dart
│   ├── lesson_tile.dart
│   ├── course_card.dart
│   └── feature_card.dart
├── dialogs/                   # Dialog components
│   └── app_dialog.dart        # Reusable dialogs
└── states/                    # Shared state enums
    └── view_state.dart        # Loading, Success, Error states
```

### lib/src/features/
**Tujuan**: Feature-based modular structure

```
features/
├── authentication/            # Auth feature (complete)
│   ├── data/
│   │   ├── mappers/
│   │   │   └── user_mapper.dart
│   │   ├── models/
│   │   │   └── user.dart
│   │   ├── repositories/
│   │   │   └── auth_repository_impl.dart
│   │   └── sources/
│   │       └── auth_remote_data_source.dart
│   ├── domain/
│   │   ├── entities/
│   │   │   └── user_entity.dart
│   │   ├── repositories/
│   │   │   └── auth_repository.dart
│   │   ├── usecases/
│   │   │   └── auth_usecase.dart
│   │   └── value_objects/
│   │       └── auth_token.dart
│   └── presentation/
│       ├── bloc/
│       │   ├── auth_bloc.dart
│       │   ├── auth_event.dart
│       │   └── auth_state.dart
│       ├── screens/
│       │   └── login_screen.dart
│       └── widgets/
│           └── login_form.dart
├── courses/                   # Course feature
├── lessons/                   # Lesson feature
├── certificates/              # Certificate feature
├── saved_courses/             # NEW: Extracted from MainScreen
│   ├── data/
│   ├── domain/
│   └── presentation/
└── profile/                   # NEW: Extracted from MainScreen
    ├── data/
    ├── domain/
    └── presentation/
```

---

## 🔄 Data Flow (Architecture in Action)

### User Action → UI Response

```
1. USER INTERACTION
   └─ Tap button on screen

2. PRESENTATION LAYER
   ├─ Screen sends event to BLoC
   │  └─ LoginScreen → AuthBloc.add(AuthLoginEvent)
   │
   └─ BLoC receives event & emits loading state
      └─ emit(AuthLoading())

3. DOMAIN LAYER
   ├─ BLoC calls UseCase
   │  └─ AuthBloc → LoginUseCase(email, password)
   │
   └─ UseCase calls Repository interface (abstract)
      └─ LoginUseCase → AuthRepository.login()

4. DATA LAYER
   ├─ Repository implementation executes
   │  └─ AuthRepositoryImpl → LocalDataSource.login()
   │
   ├─ DataSource fetches data (API / Local Storage)
   │  └─ AuthRemoteDataSource → API call (or dummy)
   │
   └─ Data is mapped to Entity
      └─ DataSource returns User → Mapper.toDomain() → UserEntity

5. BACK UP THE CHAIN
   ├─ Repository returns UserEntity to UseCase
   ├─ UseCase returns UserEntity to BLoC
   │
   └─ BLoC emits success state with UserEntity
      └─ emit(AuthSuccess(user: userEntity))

6. PRESENTATION UPDATES
   └─ Screen listens to BLoC state via BlocBuilder
      └─ Render UI based on AuthSuccess state
      └─ Show user info, navigate to home
```

### Detailed Example: Get Courses

```dart
// 1. SCREEN triggers event
class CourseListScreen {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CourseBloc, CourseState>(
      builder: (context, state) {
        if (state is CourseLoading) return LoadingWidget();
        if (state is CourseLoaded) return CourseListWidget(state.courses);
        if (state is CourseFailure) return ErrorWidget(state.message);
      },
    );
  }

  @override
  void initState() {
    // Send event to BLoC
    context.read<CourseBloc>().add(const GetCoursesEvent());
  }
}

// 2. BLOC handles event
class CourseBloc extends Bloc<CourseEvent, CourseState> {
  Future<void> _onGetCourses(
    GetCoursesEvent event,
    Emitter<CourseState> emit,
  ) async {
    emit(const CourseLoading());
    
    try {
      // Call use case
      final courses = await getCoursesUseCase();
      emit(CourseLoaded(courses: courses));
    } catch (e) {
      emit(CourseFailure(message: 'Failed to load courses'));
    }
  }
}

// 3. USE CASE executes business logic
class GetCoursesUseCase {
  final CourseRepository repository;
  
  Future<List<CourseEntity>> call() async {
    return await repository.getCourses();
  }
}

// 4. REPOSITORY fetches data
class CourseRepositoryImpl implements CourseRepository {
  @override
  Future<List<CourseEntity>> getCourses() async {
    try {
      // Try remote first
      final remoteCourses = await remoteDataSource.getCourses();
      await localDataSource.saveCourses(remoteCourses);
      return _mapCoursesToEntities(remoteCourses);
    } catch (e) {
      // Fallback to local cache
      final localCourses = await localDataSource.getCourses();
      return _mapCoursesToEntities(localCourses);
    }
  }
}

// 5. DATA SOURCE retrieves data
class CourseRemoteDataSourceImpl implements CourseRemoteDataSource {
  @override
  Future<List<Course>> getCourses() async {
    // Return dummy data for now, later replace with real API call
    return dummyData.getCourses();
  }
}

// 6. MAPPER converts Model → Entity
class CourseMapper {
  static CourseEntity toDomain(Course model) {
    return CourseEntity(
      id: model.id,
      title: model.title,
      description: model.description,
      // ... map other fields
    );
  }
}
```

---

## 🛠️ Using the Architecture

### Adding a New Feature

**Step 1: Create Feature Folder**
```bash
lib/src/features/my_feature/
  ├── data/
  │   ├── datasources/
  │   ├── dtos/
  │   ├── mappers/
  │   ├── models/
  │   └── repositories/
  ├── domain/
  │   ├── entities/
  │   ├── repositories/
  │   ├── usecases/
  │   └── value_objects/
  └── presentation/
      ├── bloc/
      ├── screens/
      └── widgets/
```

**Step 2: Create Domain Layer First**
```dart
// domain/entities/my_entity.dart
class MyEntity extends Equatable {
  final String id;
  final String name;
  
  const MyEntity({required this.id, required this.name});
  
  @override
  List<Object> get props => [id, name];
}

// domain/repositories/my_repository.dart
abstract class MyRepository {
  Future<List<MyEntity>> getItems();
  Future<void> createItem(MyEntity item);
}

// domain/usecases/get_items_usecase.dart
class GetItemsUseCase {
  final MyRepository repository;
  GetItemsUseCase(this.repository);
  
  Future<List<MyEntity>> call() {
    return repository.getItems();
  }
}
```

**Step 3: Create Data Layer**
```dart
// data/models/my_model.dart
class MyModel {
  final String id;
  final String name;
  
  MyModel({required this.id, required this.name});
  
  factory MyModel.fromJson(Map<String, dynamic> json) {
    return MyModel(
      id: json['id'],
      name: json['name'],
    );
  }
}

// data/mappers/my_mapper.dart
class MyMapper {
  static MyEntity toDomain(MyModel model) {
    return MyEntity(id: model.id, name: model.name);
  }
}

// data/repositories/my_repository_impl.dart
class MyRepositoryImpl implements MyRepository {
  final MyRemoteDataSource remoteDataSource;
  final MyLocalDataSource localDataSource;
  
  @override
  Future<List<MyEntity>> getItems() async {
    try {
      final remoteItems = await remoteDataSource.getItems();
      await localDataSource.saveItems(remoteItems);
      return remoteItems.map((m) => MyMapper.toDomain(m)).toList();
    } catch (e) {
      final localItems = await localDataSource.getItems();
      return localItems.map((m) => MyMapper.toDomain(m)).toList();
    }
  }
}
```

**Step 4: Create Presentation Layer (BLoC)**
```dart
// presentation/bloc/my_bloc.dart
class MyBloc extends Bloc<MyEvent, MyState> {
  final GetItemsUseCase getItemsUseCase;
  
  MyBloc({required this.getItemsUseCase}) : super(const MyInitial()) {
    on<GetItemsEvent>(_onGetItems);
  }
  
  Future<void> _onGetItems(GetItemsEvent event, Emitter<MyState> emit) async {
    emit(const MyLoading());
    try {
      final items = await getItemsUseCase();
      emit(MyLoaded(items: items));
    } catch (e) {
      emit(const MyFailure(message: 'Failed to load items'));
    }
  }
}

// presentation/screens/my_screen.dart
class MyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MyBloc, MyState>(
      builder: (context, state) {
        if (state is MyLoading) return const LoadingWidget();
        if (state is MyLoaded) return MyListWidget(state.items);
        if (state is MyFailure) return ErrorWidget(state.message);
        return const SizedBox.shrink();
      },
    );
  }
  
  @override
  void initState() {
    context.read<MyBloc>().add(const GetItemsEvent());
    super.initState();
  }
}
```

**Step 5: Register in DI**
```dart
// core/di/modules/my_module.dart
class MyModule {
  static late MyBloc _myBloc;
  
  static void register() {
    MyRepository myRepository = MyRepositoryImpl(
      remoteDataSource: MyRemoteDataSourceImpl(),
      localDataSource: MyLocalDataSourceImpl(),
    );
    
    GetItemsUseCase getItemsUseCase = GetItemsUseCase(myRepository);
    
    _myBloc = MyBloc(getItemsUseCase: getItemsUseCase);
  }
  
  static MyBloc get myBloc => _myBloc;
}

// Then update core/di/injector.dart to call MyModule.register()
```

---

## 🚀 Key Benefits of This Architecture

| Aspek | Benefit |
|-------|---------|
| **Maintainability** | Clear separation of concerns, easy to understand |
| **Testability** | Each layer can be tested independently |
| **Scalability** | New features follow same pattern, no confusion |
| **Reusability** | Shared components & utilities available to all features |
| **Independence** | Features are isolated, can work in parallel |
| **Error Handling** | Centralized, consistent error mapping |
| **Backend Ready** | Dummy data pattern makes API integration seamless |

---

## 🔍 Troubleshooting

### Q: I added a BLoC but it's not receiving dependencies?
**A:** Make sure you registered it in the module and called `module.register()` in `injector.dart`

### Q: How do I add error handling?
**A:** Throw exceptions in data layer, map to failures in repository, handle in BLoC emit

### Q: How do I use constants?
**A:** Import from `lib/src/core/config/constants/` - all in one place

### Q: How do I create a new screen?
**A:** Create in `lib/src/features/{feature}/presentation/screens/`, create corresponding event/state in bloc

### Q: How do I navigate between screens?
**A:** Currently using named routes, soon: `context.go(AppRoutes.routeName, extra: data)`

---

## ✅ Checklist: Your Features Should Have

- ✅ Entity in `domain/entities/`
- ✅ Repository interface in `domain/repositories/`
- ✅ UseCase(s) in `domain/usecases/`
- ✅ Model in `data/models/`
- ✅ Mapper in `data/mappers/`
- ✅ DataSource(s) in `data/sources/`
- ✅ RepositoryImpl in `data/repositories/`
- ✅ BLoC/Event/State in `presentation/bloc/`
- ✅ Screen in `presentation/screens/`
- ✅ Module registered in `core/di/modules/`

---

**This architecture is production-ready and scales well. 🎯**
