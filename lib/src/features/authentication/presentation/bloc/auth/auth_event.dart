import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
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
  final String role;

  const AuthRegisterEvent({
    required this.name,
    required this.email,
    required this.password,
    required this.role,
  });

  @override
  List<Object?> get props => [name, email, password, role];
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
