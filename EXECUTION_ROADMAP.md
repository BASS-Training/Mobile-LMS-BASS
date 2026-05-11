# 🚀 COMPREHENSIVE REFACTORING EXECUTION GUIDE

**Status**: Phase 2 Refactoring In Progress  
**Goal**: Migrate from mixed-structure to Quanta HRIS Clean Architecture  
**Estimated**: 14.5 hours systematic work

---

## ✅ ALREADY DONE (This Session)

### 1. Analysis & Documentation
- [x] COMPREHENSIVE_ANALYSIS.md - Deep issue analysis
- [x] Identified all issues & patterns
- [x] Created detailed refactoring plan

### 2. Reusable Widgets Created
- [x] `lib/src/shared/widgets/app_list_tile.dart` - Generic tile (replaces LessonTile, CertificateListTile)
- [x] `lib/src/shared/widgets/app_gradient_card.dart` - Generic card (replaces CourseCard)
- These can now replace 3 duplicate widget files = **save 400+ lines**

### 3. Modular DI Setup
- [x] `auth_module.dart` - ✅ Complete
- [x] `courses_module.dart` - ✅ Created with 5 use cases
- [x] `lessons_module.dart` - ✅ Created with 5 use cases
- [x] `certificates_module.dart` - Scaffold (needs implementation)
- [x] `profile_module.dart` - Scaffold (needs implementation)
- [x] Updated `injector.dart` - All modules registered

---

## 📋 DETAILED EXECUTION ROADMAP

### PHASE 1: MIGRATE COURSES FEATURE (2 hours)

#### Step 1.1: Create Courses Domain Files
Migrate dari old structure ke new:

```
OLD: lib/domain/entities/course_entity.dart (85 lines)
NEW: lib/src/features/courses/domain/entities/course_entity.dart
```

**Action**: 
- Copy file dari old location ke new location
- Update imports dalam file (if any)

**Files to migrate to `lib/src/features/courses/domain/`:**
```
✓ entities/course_entity.dart
✓ entities/course_section_entity.dart
✓ repositories/course_repository.dart
✓ value_objects/progress.dart
✓ usecases/ - SPLIT dari course_usecase.dart:
  ✓ get_courses_usecase.dart
  ✓ get_course_by_id_usecase.dart
  ✓ search_courses_usecase.dart
  ✓ toggle_save_course_usecase.dart
  ✓ get_saved_courses_usecase.dart
  ✓ refresh_courses_usecase.dart
```

**Time**: 30 minutes

#### Step 1.2: Create Courses Data Files
```
OLD: lib/data/models/course.dart
NEW: lib/src/features/courses/data/models/course.dart
```

**Files to migrate to `lib/src/features/courses/data/`:**
```
✓ models/course.dart
✓ models/course_section.dart
✓ mappers/course_mapper.dart
✓ mappers/lesson_mapper.dart (jika ada)
✓ datasources/course_remote_data_source.dart
✓ datasources/course_local_data_source.dart
✓ repositories/course_repository_impl.dart
```

**Additional**: Migrate `dummy_data.dart` → `datasources/dummy_course_data.dart`

**Time**: 30 minutes

#### Step 1.3: Update Imports in Courses Domain/Data
Find & replace dalam file yang sudah di-copy:
- `package:lms_mobile_app/data/` → `package:lms_mobile_app/src/features/courses/data/`
- `package:lms_mobile_app/domain/` → `package:lms_mobile_app/src/features/courses/domain/`

**Time**: 15 minutes

#### Step 1.4: Verify courses_module.dart
Make sure all imports in `courses_module.dart` point ke paths yang correct:
```dart
import 'package:lms_mobile_app/src/features/courses/data/datasources/...';
import 'package:lms_mobile_app/src/features/courses/domain/usecases/...';
```

**Time**: 10 minutes

---

### PHASE 2: MIGRATE LESSONS FEATURE (1.5 hours)

Same pattern sebagai courses:

#### Files to migrate:
```
Domain:
✓ entities/lesson_entity.dart
✓ entities/document_section_entity.dart
✓ repositories/lesson_repository.dart
✓ value_objects/lesson_type.dart
✓ usecases/ (split dari lesson_usecase.dart):
  ✓ is_lesson_completed_usecase.dart
  ✓ toggle_lesson_completion_usecase.dart
  ✓ mark_lesson_complete_usecase.dart
  ✓ mark_lesson_incomplete_usecase.dart
  ✓ refresh_lesson_completion_usecase.dart

Data:
✓ models/lesson.dart
✓ models/document_lesson_model.dart
✓ datasources/lesson_local_data_source.dart
✓ repositories/lesson_repository_impl.dart
```

**Time**: 1.5 hours

---

### PHASE 3: MIGRATE CERTIFICATES FEATURE (1 hour)

#### Files needed (may not exist yet, create if needed):
```
Domain:
- entities/certificate_entity.dart
- repositories/certificate_repository.dart

Data:
- models/certificate_model.dart
- repositories/certificate_repository_impl.dart

Create stub implementations
```

**Time**: 1 hour

---

### PHASE 4: MIGRATE PROFILE FEATURE (1 hour)

Similar dengan certificates.

**Time**: 1 hour

---

### PHASE 5: MIGRATE PRESENTATION LAYER (3 hours)

#### Step 5.1: Update Shared Widgets (1 hour)
- Delete old duplicate widgets once you confirm they're replaced by new generic ones
- Old files to replace:
  - `lib/presentation/widgets/lesson_tile.dart` → Use AppListTile
  - `lib/presentation/widgets/course_card.dart` → Use AppGradientCard
  - `lib/presentation/widgets/certificate_list_tile.dart` → Use AppListTile

#### Step 5.2: Migrate BLoCs (1 hour)
```
OLD: lib/presentation/bloc/course/
NEW: lib/src/features/courses/presentation/bloc/
```

**Files**:
- course_bloc.dart
- course_event.dart
- course_state.dart

Also migrate:
- `lib/presentation/bloc/lesson/` → `lib/src/features/lessons/presentation/bloc/`
- `lib/presentation/bloc/auth/` → `lib/src/features/authentication/presentation/bloc/`

#### Step 5.3: Migrate Screens (1 hour)
```
OLD: lib/presentation/screens/
NEW: lib/src/features/*/presentation/screens/

Migration:
✓ lib/presentation/screens/courses/ → lib/src/features/courses/presentation/screens/
✓ lib/presentation/screens/lessons/ → lib/src/features/lessons/presentation/screens/
✓ lib/presentation/screens/certificate/ → lib/src/features/certificates/presentation/screens/
✓ lib/presentation/screens/auth/ → lib/src/features/authentication/presentation/screens/
✓ lib/presentation/screens/main_screen.dart → lib/src/features/home/presentation/screens/
✓ lib/presentation/screens/home/ → lib/src/features/home/presentation/screens/
```

**Time**: 1 hour

---

### PHASE 6: IMPORT FIX & MAIN.DART UPDATE (1 hour)

#### Step 6.1: Update main.dart
```dart
// ❌ OLD
import 'package:lms_mobile_app/config/theme.dart';
import 'package:lms_mobile_app/config/service_locator.dart';
import 'package:lms_mobile_app/presentation/bloc/auth/auth_bloc.dart';

// ✅ NEW
import 'package:lms_mobile_app/src/app.dart';
import 'package:lms_mobile_app/src/core/di/injector.dart';
import 'package:lms_mobile_app/src/core/config/app_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Configure DI (VERY IMPORTANT!)
  configureDependencies();
  
  runApp(
    const LmsApp(
      appConfig: AppConfig.production(),
    ),
  );
}
```

**Time**: 15 minutes

#### Step 6.2: Find & Replace Imports
Use IDE Find & Replace untuk update imports di **all files**:

1. Replace semua:
   - `package:lms_mobile_app/config/` → `package:lms_mobile_app/src/core/`
   - `package:lms_mobile_app/utils/` → `package:lms_mobile_app/src/core/utils/`
   - `package:lms_mobile_app/data/` → `package:lms_mobile_app/src/features/`
   - `package:lms_mobile_app/domain/` → `package:lms_mobile_app/src/features/`
   - `package:lms_mobile_app/presentation/` → `package:lms_mobile_app/src/features/`

**Time**: 30 minutes

#### Step 6.3: Delete Old Folder Structure
Setelah semua di-migrate & imports di-update:
```bash
# Backup first!
# Then delete:
rm -rf lib/config/
rm -rf lib/data/
rm -rf lib/domain/
rm -rf lib/presentation/
rm -rf lib/utils/
```

**Time**: 5 minutes

---

### PHASE 7: VERIFICATION & TESTING (1.5 hours)

#### Step 7.1: Compilation Check
```bash
cd f:\Aplikasi Mobile Bass Training\lms_mobile_app
flutter clean
flutter pub get
dart analyze lib/src
```

**Expected**: 0 errors

**Time**: 15 minutes

#### Step 7.2: Fix Remaining Errors
If ada errors dari import yang terlewat, fix one by one.

**Time**: 30 minutes

#### Step 7.3: Run on Emulator
```bash
flutter run
```

Test flows:
- [ ] App launches without crash
- [ ] Login works
- [ ] Can browse courses
- [ ] Can view lessons
- [ ] Can mark lessons complete
- [ ] Can save courses
- [ ] Progress tracking works

**Time**: 30 minutes

---

## 🎯 PRIORITY & TIME BREAKDOWN

| Phase | Time | Priority |
|-------|------|----------|
| 1. Courses | 2h | 🔴 HIGH (largest feature) |
| 2. Lessons | 1.5h | 🔴 HIGH |
| 3. Certificates | 1h | 🟡 MEDIUM |
| 4. Profile | 1h | 🟡 MEDIUM |
| 5. Presentation | 3h | 🔴 HIGH |
| 6. Imports & main | 1h | 🔴 HIGH (critical) |
| 7. Testing | 1.5h | 🔴 HIGH (validation) |
| **TOTAL** | **14.5h** | - |

---

## ✅ DEFINITION OF DONE

Project complete when:

- [ ] ✅ No compilation errors (`dart analyze lib/src` returns 0 errors)
- [ ] ✅ All old `lib/` folders deleted (config, data, domain, presentation, utils)
- [ ] ✅ Only `lib/src/` & `lib/main.dart` exist
- [ ] ✅ All imports updated to new paths
- [ ] ✅ All 5 features have modular DI modules
- [ ] ✅ Reusable widgets used instead of duplicates
- [ ] ✅ App runs on emulator without crash
- [ ] ✅ Core flows tested (login, browse, mark complete, save)
- [ ] ✅ No TODO comments in critical code
- [ ] ✅ All feature-specific widgets in correct locations

---

## 🚨 CRITICAL CHECKLIST

Before you start each phase:

- [ ] Read COMPREHENSIVE_ANALYSIS.md
- [ ] Read Quanta HRIS ARCHITECTURE.md (dari attachment)
- [ ] Understand feature module structure
- [ ] Backup current code (git commit)

During each phase:
- [ ] Migrate domain files first (safe, no dependencies)
- [ ] Then migrate data files
- [ ] Then update imports
- [ ] Then update DI module
- [ ] Test compilation after each major step

---

## 🔧 HELPFUL COMMANDS

### Check compilation without running
```bash
dart analyze lib/src
```

### Find files with import errors
```bash
grep -r "package:lms_mobile_app/data/" lib/src
grep -r "package:lms_mobile_app/domain/" lib/src
grep -r "package:lms_mobile_app/presentation/" lib/src
```

### Count files in each feature
```bash
find lib/src/features/courses -name "*.dart" | wc -l
find lib/src/features/lessons -name "*.dart" | wc -l
```

---

## 📝 NOTES FOR EXECUTION

1. **Backup first**: This is large refactoring, make sure git is clean
2. **One feature at a time**: Don't try to do all at once
3. **Test after each feature**: Run `dart analyze` after each phase
4. **Keep main.dart simple**: It should just call configureDependencies() & runApp()
5. **Reusable widgets**: Always use generic widgets from shared/widgets/ first
6. **DI modules**: Make sure each feature module is complete before moving next
7. **Import paths**: Most common error, double-check all imports

---

## 🎓 PATTERN REMINDERS

### UseCase Split Pattern
❌ WRONG: 1 file dengan 6 usecases
```dart
class CourseUseCase { ... }
class SearchCourseUseCase { ... }
```

✅ RIGHT: 5 separate files
```
// get_courses_usecase.dart
class GetCoursesUseCase { ... }

// search_courses_usecase.dart
class SearchCoursesUseCase { ... }
```

### DI Module Pattern
```dart
void registerCoursesModule() {
  // 1. DataSources
  getIt.registerSingleton<CourseRemoteDataSource>(Impl());
  
  // 2. Repositories
  getIt.registerSingleton<CourseRepository>(Impl(dataSource: getIt()));
  
  // 3. UseCases
  getIt.registerSingleton(GetCoursesUseCase(getIt()));
  
  // 4. BLoCs
  getIt.registerSingleton(CourseBloc(
    getCoursesUseCase: getIt(),
  ));
}
```

### Widget Reuse Pattern
✅ Use `AppListTile` untuk semua tile-like widgets:
```dart
AppListTile(
  title: 'Lesson Name',
  subtitle: '30 min',
  leading: CircleIndicator(label: '1'),
  trailing: TrailingIcon(icon: Icons.check),
  onTap: () { ... },
)
```

---

## 🎯 NEXT ACTION RIGHT NOW

1. **Read** this entire execution guide carefully (20 min)
2. **Read** COMPREHENSIVE_ANALYSIS.md (15 min)  
3. **Read** attached Quanta HRIS ARCHITECTURE.md (15 min)
4. **Start Phase 1**: Migrate courses domain layer (first 30 min)
5. **Test**: Run `dart analyze lib/src` after Phase 1 completes
6. **Continue**: Phase by phase

---

**Good luck! You've got this! 🚀**

Last Updated: May 11, 2026
