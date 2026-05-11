# LMS Mobile App - Clean Architecture Migration Guide

**Status**: Phase 1, 2, 5 Complete ✅ | Phases 3, 4, 6-9 Pending

---

## 📌 Current State

### ✅ Completed
- [x] Core & Shared folder structure created
- [x] Error handling (AppException, Failures, ErrorHandler)
- [x] Shared styles (colors, typography, measures, theme)
- [x] Constants (endpoints, strings, routes, flavor config)
- [x] GoRouter setup ready
- [x] DI modules created (modular approach)
- [x] Reusable widgets (buttons, form fields, dialogs)
- [x] Extensions (string, datetime utilities)

### ⏳ Remaining Tasks

1. **Phase 3: Error Handling Integration** - Update repositories
2. **Phase 4: Routing** - Update main.dart with GoRouter
3. **Phase 6: Feature Extraction** - Move features to lib/src/features/
4. **Phase 7-9: Cleanup** - Update imports, test, delete old files

---

## 📂 File Movement Guide

### What's Already There (Old Path)
```
lib/
  main.dart
  config/
  data/
  domain/
  presentation/
  utils/
```

### Target Structure (New Path)
```
lib/
  main.dart (UPDATED)
  src/
    core/        ✅ CREATED
    shared/      ✅ CREATED
    features/    (TO BE MOVED)
```

### Step 1: Create Feature Folders
```bash
# Create these directories:
lib/src/features/authentication/
lib/src/features/courses/
lib/src/features/lessons/
lib/src/features/certificates/
lib/src/features/saved_courses/   # NEW: Extract from MainScreen
lib/src/features/profile/         # NEW: Extract from MainScreen
```

### Step 2: Move Existing Features
Move these folders to `lib/src/features/`:
- `lib/data/` → `lib/src/features/{feature}/data/`
- `lib/domain/` → `lib/src/features/{feature}/domain/`
- `lib/presentation/` → `lib/src/features/{feature}/presentation/`

**Organize by feature:**
```
lib/src/features/
  authentication/
    data/
      mappers/
        user_mapper.dart
      models/
        user.dart
      repositories/
        auth_repository_impl.dart
    domain/
      entities/
        user_entity.dart
      repositories/
        auth_repository.dart
      usecases/
        auth_usecase.dart
    presentation/
      bloc/
        auth_bloc.dart
        auth_event.dart
        auth_state.dart
      screens/
        login_screen.dart
```

### Step 3: Move Existing Config & Utils
- `lib/config/theme.dart` → DELETE (now in `lib/src/shared/styles/app_theme.dart`)
- `lib/utils/constants.dart` → REFACTOR content to `lib/src/core/config/constants/`
- `lib/utils/validators.dart` → MOVE to `lib/src/core/utils/validators.dart`

---

## 🔄 Import Updates Required

### Current (OLD) vs New (NEW) Imports

**OLD:**
```dart
import 'package:lms_mobile_app/config/theme.dart';
import 'package:lms_mobile_app/data/repositories/course_repository_impl.dart';
import 'package:lms_mobile_app/presentation/bloc/course/course_bloc.dart';
```

**NEW:**
```dart
import 'package:lms_mobile_app/src/shared/styles/app_theme.dart';
import 'package:lms_mobile_app/src/features/courses/data/repositories/course_repository_impl.dart';
import 'package:lms_mobile_app/src/features/courses/presentation/bloc/course_bloc.dart';
```

### Files That Need Import Updates (Batch Update)

1. **All presentation files** - update imports to:
   - `lib/src/shared/...` untuk theme, colors
   - `lib/src/features/...` untuk domain entities
   - `lib/src/core/error/...` untuk error handling

2. **All data repository files** - update imports to:
   - `lib/src/features/...` untuk domain repositories
   - `lib/src/core/error/...` untuk exceptions

3. **All usecase files** - update imports to:
   - `lib/src/features/...` untuk repositories

---

## 🔧 Implementation Checklist (Priority Order)

### Immediate (Critical for Compilation)
- [ ] **STEP 1**: Move folders to `lib/src/features/`
- [ ] **STEP 2**: Update all imports in moved files (batch find-replace)
- [ ] **STEP 3**: Update `lib/main.dart` to:
  ```dart
  import 'package:lms_mobile_app/src/core/di/injector.dart';
  import 'package:lms_mobile_app/src/core/routes/app_router.dart';
  import 'package:lms_mobile_app/src/shared/styles/app_theme.dart';
  
  // In main():
  final serviceLocator = ServiceLocator();
  await serviceLocator.setupServiceLocator();
  
  // In MaterialApp:
  theme: AppTheme.lightTheme,
  home: const LoginScreen(),  // or use GoRouter
  ```
- [ ] **STEP 4**: Delete old directories:
  - [ ] `lib/config/` (content moved to `lib/src/core/config/`)
  - [ ] `lib/data/` (content moved to `lib/src/features/*/data/`)
  - [ ] `lib/domain/` (content moved to `lib/src/features/*/domain/`)
  - [ ] `lib/presentation/` (content moved to `lib/src/features/*/presentation/`)
  - [ ] `lib/config/service_locator.dart` (replaced by `lib/src/core/di/injector.dart`)

### Phase 3: Error Handling Integration
- [ ] Update all data repositories to import from `lib/src/core/error/`
- [ ] Replace generic try-catch with proper error mapping:
  ```dart
  // Before:
  catch (e) {
    return [];
  }
  
  // After:
  catch (e) {
    throw ErrorHandler.mapExceptionToFailure(e);
  }
  ```

### Phase 4: GoRouter Integration
- [ ] Update `lib/src/core/routes/app_router.dart` with actual screen imports
- [ ] Replace MaterialApp named routes with GoRouter in `main.dart`
- [ ] Update all `Navigator.pushNamed()` to use GoRouter `context.go()` or `context.push()`

### Phase 6: Feature Extraction
- [ ] Extract `SavedCoursesScreen` from `MainScreen` → `features/saved_courses/`
- [ ] Extract `ProfileScreen` from `MainScreen` → `features/profile/`
- [ ] Update `MainScreen` to remove inline screens

### Phase 7-9: Final Cleanup
- [ ] Run `flutter pub get` to download go_router
- [ ] Run analysis: `dart analyze` - fix all import errors
- [ ] Test all navigation routes manually
- [ ] Test all BLoCs are receiving dependencies
- [ ] Delete old files once everything works

---

## 🚨 Common Issues & Solutions

### Issue 1: Import Not Found Error
**Problem:** `package:lms_mobile_app/data/repositories/...`
**Solution:** Find-replace all instances to new path:
```
FROM: package:lms_mobile_app/data/
TO:   package:lms_mobile_app/src/features/{feature}/data/
```

### Issue 2: ServiceLocator Not Found
**Problem:** Old `lib/config/service_locator.dart` doesn't exist
**Solution:** Update import in main.dart:
```dart
import 'package:lms_mobile_app/src/core/di/injector.dart';
```

### Issue 3: Theme Not Found
**Problem:** `lib/config/theme.dart` doesn't exist
**Solution:** Update imports to:
```dart
import 'package:lms_mobile_app/src/shared/styles/app_theme.dart';
import 'package:lms_mobile_app/src/shared/styles/app_colors.dart';
```

### Issue 4: GoRouter Not Recognized
**Problem:** `go_router` package not found
**Solution:** Run `flutter pub get` after pubspec.yaml update

---

## 📋 Import Find-Replace Patterns

Use your IDE's Find-Replace (Ctrl+H) with these patterns:

```
# Pattern 1: Data layer
FROM:   import 'package:lms_mobile_app/data/
TO:     import 'package:lms_mobile_app/src/features/authentication/data/

# Pattern 2: Domain layer
FROM:   import 'package:lms_mobile_app/domain/
TO:     import 'package:lms_mobile_app/src/features/authentication/domain/

# Pattern 3: Presentation layer
FROM:   import 'package:lms_mobile_app/presentation/
TO:     import 'package:lms_mobile_app/src/features/authentication/presentation/

# Pattern 4: Theme
FROM:   import 'package:lms_mobile_app/config/theme.dart';
TO:     import 'package:lms_mobile_app/src/shared/styles/app_theme.dart';

# Pattern 5: Config/ServiceLocator
FROM:   import 'package:lms_mobile_app/config/service_locator.dart';
TO:     import 'package:lms_mobile_app/src/core/di/injector.dart';

# Pattern 6: Colors
FROM:   import 'package:lms_mobile_app/config/theme.dart';
TO:     import 'package:lms_mobile_app/src/shared/styles/app_colors.dart';
```

**Repeat for each feature:**
- authentication
- courses
- lessons
- certificates

---

## ✅ Verification Checklist

After completing migration:
- [ ] All imports compile without errors
- [ ] ServiceLocator initializes successfully
- [ ] All BLoCs receive their dependencies
- [ ] MainScreen loads and displays all tabs
- [ ] Navigation to course detail works
- [ ] Navigation to lesson detail works
- [ ] Course save/unsave toggles work
- [ ] Lesson completion toggle works
- [ ] Bottom nav bar switches tabs correctly
- [ ] All screens render without errors
- [ ] No unused imports
- [ ] No old lib/config, lib/data, lib/domain, lib/presentation directories

---

## 🎯 Quick Start (If You Want to Just Execute)

1. **Copy this command** to move all directories:
   ```bash
   # Create feature directories
   mkdir -p lib/src/features/authentication lib/src/features/courses lib/src/features/lessons lib/src/features/certificates lib/src/features/saved_courses lib/src/features/profile
   
   # Move data/domain/presentation folders
   mv lib/data/* lib/src/features/
   mv lib/domain/* lib/src/features/
   mv lib/presentation/* lib/src/features/
   ```

2. **Organize by feature** (manual - drag files in IDE)

3. **Update imports** using Find-Replace in IDE

4. **Delete old directories:**
   ```bash
   rm -rf lib/config lib/data lib/domain lib/presentation
   ```

5. **Run analysis:**
   ```bash
   flutter pub get
   dart analyze
   ```

6. **Fix any remaining errors** and test manually

---

## 📝 Notes

- All new code follows Quanta HRIS architecture pattern
- Dummy data pattern is maintained (ready for real API)
- Error handling now centralized (AppException → Failure mapping)
- DI is now modular (easier to maintain)
- Widgets are reusable and consistent
- Ready for multi-language (i18n) via AppStrings
- Ready for flavor configuration (dev/staging/prod)

---

**Next Action**: Execute the checklist above step-by-step. Start with moving folders, then batch import updates.
