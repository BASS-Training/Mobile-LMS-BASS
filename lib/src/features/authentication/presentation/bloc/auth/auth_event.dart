import 'package:equatable/equatable.dart';

import '../../../domain/entities/user_entity.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
}

/// Replace the currently-authenticated user in global state (e.g. after the
/// user edits their profile). Keeps the session signed in.
class AuthUserUpdatedEvent extends AuthEvent {
  final UserEntity user;

  const AuthUserUpdatedEvent(this.user);

  @override
  List<Object?> get props => [user];
}

class AuthLoginEvent extends AuthEvent {
  final String email;
  final String password;

  const AuthLoginEvent({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class AuthRegisterEvent extends AuthEvent {
  final String name;
  final String email;
  final String password;
  final String classInterest;
  final String dateOfBirth;
  final String gender;
  final String institutionName;
  final String occupation;

  const AuthRegisterEvent({
    required this.name,
    required this.email,
    required this.password,
    required this.classInterest,
    required this.dateOfBirth,
    required this.gender,
    required this.institutionName,
    required this.occupation,
  });

  @override
  List<Object?> get props => [
    name,
    email,
    password,
    classInterest,
    dateOfBirth,
    gender,
    institutionName,
    occupation,
  ];
}

class AuthSessionRequestedEvent extends AuthEvent {
  const AuthSessionRequestedEvent();

  @override
  List<Object?> get props => [];
}

class AuthLogoutEvent extends AuthEvent {
  const AuthLogoutEvent();

  @override
  List<Object?> get props => [];
}

class AuthClearErrorEvent extends AuthEvent {
  const AuthClearErrorEvent();

  @override
  List<Object?> get props => [];
}
