import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

import 'package:lms_mobile_app/src/core/services/firebase_initializer.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../mappers/user_mapper.dart';
import '../models/user.dart';

class AuthRepositoryImpl implements AuthRepository {
  static User? _fallbackCurrentUser;

  firebase_auth.FirebaseAuth get _firebaseAuth =>
      firebase_auth.FirebaseAuth.instance;
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  @override
  Future<UserEntity?> login(String email, String password) async {
    final cleanedEmail = email.trim();
    if (cleanedEmail.isEmpty ||
        password.isEmpty ||
        !_isValidEmail(cleanedEmail)) {
      return null;
    }

    final isFirebaseReady = await _ensureFirebaseReady();
    if (isFirebaseReady) {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: cleanedEmail,
        password: password,
      );
      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        return null;
      }

      final user = await _loadUserProfile(
        uid: firebaseUser.uid,
        email: firebaseUser.email ?? cleanedEmail,
        defaultName:
            firebaseUser.displayName ?? _fallbackDisplayName(cleanedEmail),
      );
      return UserMapper.toDomain(user);
    }

    final fallbackUser = _buildFallbackUser(
      email: cleanedEmail,
      name: _fallbackDisplayName(cleanedEmail),
    );
    _fallbackCurrentUser = fallbackUser;
    return UserMapper.toDomain(fallbackUser);
  }

  @override
  Future<UserEntity?> register(
    String name,
    String email,
    String password,
    String role,
  ) async {
    final cleanedName = name.trim();
    final cleanedEmail = email.trim();
    if (cleanedName.isEmpty || cleanedEmail.isEmpty || password.isEmpty) {
      return null;
    }

    final normalizedRole = _normalizeRole(role);
    final isFirebaseReady = await _ensureFirebaseReady();
    if (isFirebaseReady) {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: cleanedEmail,
        password: password,
      );
      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        return null;
      }

      await firebaseUser.updateDisplayName(cleanedName);
      final user = User(
        id: firebaseUser.uid,
        name: cleanedName,
        email: cleanedEmail,
        role: normalizedRole,
      );

      _saveUserProfileBestEffort(user);
      return UserMapper.toDomain(user);
    }

    final fallbackUser = User(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: cleanedName,
      email: cleanedEmail,
      role: normalizedRole,
    );
    _fallbackCurrentUser = fallbackUser;
    return UserMapper.toDomain(fallbackUser);
  }

  @override
  Future<void> logout() async {
    if (await _ensureFirebaseReady()) {
      await _firebaseAuth.signOut();
    }
    _fallbackCurrentUser = null;
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    if (await _ensureFirebaseReady()) {
      final firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser == null) {
        return null;
      }

      final user = await _loadUserProfile(
        uid: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        defaultName:
            firebaseUser.displayName ??
            _fallbackDisplayName(firebaseUser.email ?? ''),
      );
      return UserMapper.toDomain(user);
    }

    if (_fallbackCurrentUser == null) {
      return null;
    }

    return UserMapper.toDomain(_fallbackCurrentUser!);
  }

  @override
  Stream<UserEntity?> watchCurrentUser() async* {
    final isReady = await _ensureFirebaseReady();
    if (!isReady) {
      // Fallback: emit current fallback user if available, then close.
      if (_fallbackCurrentUser != null) {
        yield UserMapper.toDomain(_fallbackCurrentUser!);
      } else {
        yield null;
      }
      return;
    }

    await for (final firebaseUser in _firebaseAuth.authStateChanges()) {
      if (firebaseUser == null) {
        yield null;
        continue;
      }

      final docStream = _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .snapshots();
      await for (final doc in docStream) {
        if (doc.exists && doc.data() != null) {
          final data = doc.data()!;
          final storedName = data['name']?.toString().trim();
          final storedEmail = data['email']?.toString().trim();
          final user = User(
            id: firebaseUser.uid,
            name: storedName != null && storedName.isNotEmpty
                ? storedName
                : (firebaseUser.displayName ??
                      _fallbackDisplayName(firebaseUser.email ?? '')),
            email: storedEmail != null && storedEmail.isNotEmpty
                ? storedEmail
                : (firebaseUser.email ?? ''),
            role: _normalizeRole(data['role']?.toString()),
          );
          yield UserMapper.toDomain(user);
        } else {
          final fallback = User(
            id: firebaseUser.uid,
            name:
                firebaseUser.displayName ??
                _fallbackDisplayName(firebaseUser.email ?? ''),
            email: firebaseUser.email ?? '',
            role: 'participant',
          );
          // Best-effort create the profile document if missing.
          _firestore
              .collection('users')
              .doc(firebaseUser.uid)
              .set(fallback.toJson())
              .catchError((_) {});
          yield UserMapper.toDomain(fallback);
        }
      }
    }
  }

  bool _isValidEmail(String email) {
    final pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
    final regex = RegExp(pattern);
    return regex.hasMatch(email);
  }

  Future<bool> _ensureFirebaseReady() async {
    await FirebaseInitializer.ensureInitialized();
    return FirebaseInitializer.isInitialized;
  }

  Future<User> _loadUserProfile({
    required String uid,
    required String email,
    required String defaultName,
  }) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists && doc.data() != null) {
      final data = doc.data()!;
      final storedName = data['name']?.toString().trim();
      final storedEmail = data['email']?.toString().trim();
      return User(
        id: uid,
        name: storedName != null && storedName.isNotEmpty
            ? storedName
            : defaultName,
        email: storedEmail != null && storedEmail.isNotEmpty
            ? storedEmail
            : email,
        role: _normalizeRole(data['role']?.toString()),
      );
    }

    final fallback = User(
      id: uid,
      name: defaultName,
      email: email,
      role: 'participant',
    );
    await _firestore
        .collection('users')
        .doc(uid)
        .set(fallback.toJson())
        .timeout(const Duration(seconds: 8));
    return fallback;
  }

  User _buildFallbackUser({required String email, required String name}) {
    return User(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      email: email,
      role: 'participant',
    );
  }

  String _fallbackDisplayName(String email) {
    final localPart = email.split('@').first;
    if (localPart.isEmpty) {
      return 'User';
    }
    return localPart.replaceAll('.', ' ').replaceAll('_', ' ').trim();
  }

  String _normalizeRole(String? role) {
    final value = (role ?? 'participant').trim().toLowerCase();
    if (value == 'instructor') {
      return 'instructor';
    }
    return 'participant';
  }

  void _saveUserProfileBestEffort(User user) {
    _firestore
        .collection('users')
        .doc(user.id)
        .set(user.toJson())
        .timeout(const Duration(seconds: 8))
        .catchError((error) {
          // Keep auth success even if Firestore profile write fails.
          // The profile doc can be recreated on next login.
        });
  }
}
