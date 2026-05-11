# 🔍 COMPREHENSIVE REFACTORING ANALYSIS - LMS Mobile App

**Date**: May 11, 2026  
**Status**: Deep Analysis Complete | Ready for Systematic Refactoring  
**Priority**: CRITICAL - Mixed architecture needs consolidation

---

## 📊 CRITICAL ISSUES FOUND

### 🚨 Issue #1: TWO PARALLEL STRUCTURES (CRITICAL)
Project punya **2 folder structure yang bercampur**:
- ❌ Old: `lib/config/`, `lib/data/`, `lib/domain/`, `lib/presentation/`, `lib/utils/`
- ✅ New: `lib/src/` (partially implemented)
- **Impact**: Confusing, import errors, duplicate code, difficult maintenance

### 🚨 Issue #2: MONOLITHIC DI SETUP (service_locator.dart)
```dart
class ServiceLocator {
  // Semua registrations manual di 1 file
  // ~150+ lines untuk setup
}
```
- ❌ Not scalable
- ❌ Merge conflicts likely
- ❌ Doesn't match Quanta HRIS pattern (modular DI)

### 🚨 Issue #3: MAIN.DART OUTDATED
```dart
import 'package:lms_mobile_app/config/theme.dart';      // ❌ Old path
import 'package:lms_mobile_app/presentation/bloc/...';  // ❌ Old path
```
- Imports masih mereferensi old structure
- Tidak bisa compile dengan new lib/src structure

### 🚨 Issue #4: DUPLICATE WIDGETS (Code Duplication)
Ditemukan widget yang similar atau bisa di-reuse:
- `LessonTile` (159 lines) - Tile untuk lesson
- `LessonDrawer` (200+ lines) - Drawer untuk lesson navigation
- `CourseCard` (169 lines) - Card untuk course
- `CertificateListTile` (80 lines) - Tile untuk certificate

**Potential Issues**:
- `LessonTile` & `CertificateListTile` punya similar structure → bisa di-buat generic `ListTile` widget
- `CourseCard` & `LessonTile` punya gradient + header pattern yang mirip
- Multiple progress indicators bisa di-consolidate

### 🚨 Issue #5: LARGE FILES (>150 lines)

| File | Lines | Status |
|------|-------|--------|
| `dummy_data.dart` | 200+ | Too large, bisa di-split |
| `lesson_drawer.dart` | 200+ | Complex drawer logic bisa di-extract |
| `course_card.dart` | 169 | Besar, tapi acceptable |
| `lesson_tile.dart` | 159 | Besar, tapi acceptable |

**Recommended**: Split large files, extract custom painters/helpers

### 🚨 Issue #6: OLD ENTITY/MODEL FILES NOT MIGRATED
Old files masih exist:
- `lib/data/models/course.dart` (95 lines)
- `lib/data/models/lesson.dart` (65 lines)
- `lib/data/models/course_section.dart` (unknown)
- `lib/domain/entities/course_entity.dart` (85 lines) - needs migration
- `lib/domain/usecases/course_usecase.dart` (76 lines) - needs split

**Action**: Migrate dan clean up old files

### 🚨 Issue #7: INCOMPLETE FEATURE MODULES
Auth module ada, tapi:
- ❌ Courses module - not created
- ❌ Lessons module - not created
- ❌ Certificates module - not created
- ❌ Profile module - not created

### 🚨 Issue #8: BLoC ERRORS (Found in Analysis)
Blocks ada di old path, belum ada di new lib/src structure:
- `lib/presentation/bloc/auth/auth_bloc.dart` - needs migration
- `lib/presentation/bloc/course/course_bloc.dart` - needs migration
- `lib/presentation/bloc/lesson/lesson_bloc.dart` - needs migration

---

## 📋 DETAILED ACTION PLAN

### PHASE 1: INVENTORY & CLEANUP (2 hours)

#### Task 1.1: List all files to migrate
```
lib/ (old structure - TO MIGRATE)
├── config/
│   ├── service_locator.dart → lib/src/core/di/
│   └── theme.dart → lib/src/shared/styles/
├── data/
│   ├── models/ → lib/src/features/*/data/models/
│   ├── repositories/ → lib/src/features/*/data/repositories/
│   ├── sources/ → lib/src/features/*/data/datasources/
│   └── mappers/ → lib/src/features/*/data/mappers/
├── domain/
│   ├── entities/ → lib/src/features/*/domain/entities/
│   ├── repositories/ → lib/src/features/*/domain/repositories/
│   └── usecases/ → lib/src/features/*/domain/usecases/
├── presentation/
│   ├── bloc/ → lib/src/features/*/presentation/bloc/
│   ├── screens/ → lib/src/features/*/presentation/screens/
│   └── widgets/ → lib/src/shared/widgets/ (reusable) or lib/src/features/*/presentation/widgets/
└── utils/
    └── constants.dart → lib/src/core/constants/
```

#### Task 1.2: Identify reusable widgets
- [ ] `ListTile` generic widget (from LessonTile, CertificateListTile)
- [ ] `GradientCard` widget (from CourseCard)
- [ ] `ProgressBar` widget (already done)
- [ ] `AppDialog` widget (core shared)

#### Task 1.3: Split large files
- [ ] `dummy_data.dart` → split by course
- [ ] `lesson_drawer.dart` → extract logic to controller
- [ ] `app_router.dart` → if becomes too large

### PHASE 2: CREATE MODULAR DI MODULES (2 hours)

#### Task 2.1: Create courses_module.dart
```dart
void registerCoursesModule() {
  // DataSources
  getIt.registerSingleton<CourseRemoteDataSource>(...);
  getIt.registerSingleton<CourseLocalDataSource>(...);
  
  // Repositories
  getIt.registerSingleton<CourseRepository>(...);
  
  // UseCases (5 files)
  getIt.registerSingleton(GetCoursesUseCase(...));
  getIt.registerSingleton(SearchCoursesUseCase(...));
  getIt.registerSingleton(ToggleSaveCourseUseCase(...));
  getIt.registerSingleton(GetSavedCoursesUseCase(...));
  getIt.registerSingleton(RefreshCoursesUseCase(...));
  
  // BLoC
  getIt.registerSingleton(CourseBloc(...));
}
```

#### Task 2.2: Create lessons_module.dart
Similar pattern untuk lessons

#### Task 2.3: Create certificates_module.dart
#### Task 2.4: Create profile_module.dart

### PHASE 3: MIGRATE ALL DOMAIN LAYER (2 hours)

#### Task 3.1: Migrate course domain
- Move `domain/entities/course_entity.dart` → `src/features/courses/domain/entities/`
- Move `domain/entities/course_section_entity.dart` → `src/features/courses/domain/entities/`
- Move `domain/repositories/course_repository.dart` → `src/features/courses/domain/repositories/`
- Split `domain/usecases/course_usecase.dart` into 5 separate files

#### Task 3.2: Migrate lesson domain
- Move `domain/entities/lesson_entity.dart`
- Move `domain/value_objects/` (Progress, LessonType, etc.)

#### Task 3.3: Migrate certificate & profile domain

### PHASE 4: MIGRATE ALL DATA LAYER (2 hours)

#### Task 4.1: Migrate course data
- Move models → `src/features/courses/data/models/`
- Move mappers → `src/features/courses/data/mappers/`
- Move datasources → `src/features/courses/data/datasources/`
- Move repositories impl → `src/features/courses/data/repositories/`

#### Task 4.2: Migrate lesson data
#### Task 4.3: Migrate certificate & profile data

### PHASE 5: MIGRATE PRESENTATION LAYER (3 hours)

#### Task 5.1: Consolidate & create reusable widgets
Create `lib/src/shared/widgets/`:
```dart
// Generic reusable widgets
- generic_list_tile.dart (replaces LessonTile, CertificateListTile)
- gradient_card.dart (from CourseCard)
- progress_bar.dart (already exists)
- app_dialog.dart
- app_button.dart
- app_text_field.dart
```

#### Task 5.2: Move feature-specific widgets
Each feature punya `presentation/widgets/`:
```
src/features/courses/presentation/widgets/
├── course_filter_dropdown.dart
├── course_sort_button.dart
└── ...
```

#### Task 5.3: Migrate BLoCs
- Move `presentation/bloc/auth/` → `src/features/authentication/presentation/bloc/`
- Move `presentation/bloc/course/` → `src/features/courses/presentation/bloc/`
- Move `presentation/bloc/lesson/` → `src/features/lessons/presentation/bloc/`

#### Task 5.4: Migrate Screens
- Move `presentation/screens/` to respective features

### PHASE 6: FIX IMPORTS & DELETE OLD CODE (2 hours)

#### Task 6.1: Update main.dart
```dart
import 'package:lms_mobile_app/src/app.dart';
import 'package:lms_mobile_app/src/core/di/injector.dart';
import 'package:lms_mobile_app/src/core/config/app_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Configure DI
  configureDependencies();
  
  // Run app
  runApp(
    const LmsApp(
      appConfig: AppConfig.production(),
    ),
  );
}
```

#### Task 6.2: Update pubspec.yaml dependencies
- Add GetIt (already done?)
- Add dartz
- Verify all dependencies

#### Task 6.3: Find & replace imports
Use IDE find-replace for:
- `package:lms_mobile_app/config/` → `package:lms_mobile_app/src/core/`
- `package:lms_mobile_app/data/` → `package:lms_mobile_app/src/features/X/data/`
- `package:lms_mobile_app/domain/` → `package:lms_mobile_app/src/features/X/domain/`
- `package:lms_mobile_app/presentation/` → `package:lms_mobile_app/src/features/X/presentation/`

#### Task 6.4: Delete old folders
```
lib/config/ ← DELETE (migrated to src/core)
lib/data/ ← DELETE (migrated to src/features)
lib/domain/ ← DELETE (migrated to src/features)
lib/presentation/ ← DELETE (migrated to src/features)
lib/utils/ ← DELETE (migrated to src/core/utils)
```

### PHASE 7: VALIDATION & TESTING (1.5 hours)

#### Task 7.1: Check compilation
```bash
flutter pub get
dart analyze lib/src
```

#### Task 7.2: Fix remaining import errors
#### Task 7.3: Run app on emulator
#### Task 7.4: Test core flows
- Authentication
- Course browsing
- Lesson viewing
- Progress tracking

---

## 🎯 KEY REFACTORING PATTERNS TO FOLLOW

### Pattern 1: Feature Module Structure
```
features/<feature>/
├── data/
│   ├── datasources/<feature>_*.dart (interface + impl)
│   ├── dtos/ (if needed)
│   ├── mappers/<feature>_mapper.dart
│   ├── models/<feature>_model.dart
│   └── repositories/<feature>_repository_impl.dart
├── domain/
│   ├── entities/<feature>_entity.dart
│   ├── repositories/<feature>_repository.dart (interface)
│   ├── usecases/
│   │   ├── <action>_<feature>_usecase.dart (individual files!)
│   │   └── ...
│   └── value_objects/<value_object>.dart
└── presentation/
    ├── bloc/<feature>_bloc.dart, event, state
    ├── screens/<feature>_screen.dart
    └── widgets/<feature>_specific_widget.dart
```

### Pattern 2: DI Module Template
```dart
void register<Feature>Module() {
  // 1. DataSources (interfaces first)
  getIt.registerSingleton<DataSource>(DataSourceImpl());
  
  // 2. Repositories
  getIt.registerSingleton<Repository>(
    RepositoryImpl(dataSource: getIt()),
  );
  
  // 3. UseCases
  getIt.registerSingleton(UseCase1(getIt()));
  getIt.registerSingleton(UseCase2(getIt()));
  
  // 4. BLoCs
  getIt.registerSingleton(FeatureBloc(
    useCase1: getIt(),
    useCase2: getIt(),
  ));
}
```

### Pattern 3: Error Handling
ALL features MUST use Either<Failure, T>:
```dart
// ❌ OLD
Future<List<CourseEntity>> getCourses() async {
  try {
    return await repository.getCourses();
  } catch (e) {
    return [];
  }
}

// ✅ NEW
Future<Either<Failure, List<CourseEntity>>> getCourses() async {
  try {
    final courses = await repository.getCourses();
    return Right(courses);
  } on ServerException {
    return Left(ServerFailure(message: 'Server error'));
  } catch (e) {
    return Left(UnknownFailure(message: e.toString()));
  }
}
```

### Pattern 4: Reusable Widgets (lib/src/shared/widgets/)
```dart
// ✅ Generic ListTile yang reusable
class AppListTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback onTap;
  final Color? backgroundColor;
  final bool showBorder;
  
  // Bisa dipakai untuk lesson, certificate, profile, dll
}
```

### Pattern 5: Naming Conventions (from Quanta HRIS)
- **UseCase**: `<Action><Feature>UseCase`
  - ✅ `GetCoursesUseCase`, `SearchCoursesUseCase`, `ToggleSaveCourseUseCase`
- **Repository Interface**: `<Feature>Repository`
- **Repository Impl**: `<Feature>RepositoryImpl`
- **DataSource Interface**: `<Feature>RemoteDataSource`, `<Feature>LocalDataSource`
- **Model**: suffix `Model` atau `Dto`
- **Entity**: suffix `Entity`
- **Value Object**: `<ValueName>` (e.g., `Progress`, `AuthToken`, `LessonType`)

---

## 📐 PRIORITY ORDER (DO THIS SEQUENCE)

1. **FIRST**: Complete auth_module.dart with working pattern
2. **SECOND**: Consolidate widgets → lib/src/shared/widgets/
3. **THIRD**: Migrate courses (largest feature) → courses_module.dart
4. **FOURTH**: Migrate lessons → lessons_module.dart
5. **FIFTH**: Migrate certificates & profile
6. **SIXTH**: Fix main.dart & delete old lib/
7. **SEVENTH**: Test & validate

---

## ⚠️ COMMON MISTAKES TO AVOID

| Mistake | ❌ Wrong | ✅ Right |
|---------|---------|---------|
| **Import path** | `lib/data/models/` | `lib/src/features/X/data/models/` |
| **UseCase file split** | 1 file with 5 classes | 5 separate files |
| **Widget reuse** | Copy-paste same widget | Use parameters + extract generic |
| **DI registration** | Everything in injector.dart | Separate module per feature |
| **Error handling** | Throw exceptions | Return Either<Failure, T> |
| **Data ↔ Domain** | Import models in entities | Use mappers only in data layer |

---

## 📊 ESTIMATED TIME

| Phase | Time | Status |
|-------|------|--------|
| 1. Inventory | 2h | TODO |
| 2. Modular DI | 2h | TODO |
| 3. Domain Migration | 2h | TODO |
| 4. Data Migration | 2h | TODO |
| 5. Presentation | 3h | TODO |
| 6. Imports & Cleanup | 2h | TODO |
| 7. Testing | 1.5h | TODO |
| **TOTAL** | **14.5 hours** | **Ready** |

---

## ✅ DEFINITION OF DONE

Project is complete when:
- ✅ Zero compilation errors (`dart analyze lib/src`)
- ✅ All imports use new lib/src paths
- ✅ Old lib/ folders deleted
- ✅ All features have modular DI modules
- ✅ All widgets in shared/widgets/ (reusable) or feature/presentation/widgets/ (specific)
- ✅ All features follow clean architecture pattern
- ✅ App runs on emulator without errors
- ✅ Core flows work (auth, courses, lessons, progress)

---

**Next Action**: Start with Task 1.1 - List all files and create migration map
