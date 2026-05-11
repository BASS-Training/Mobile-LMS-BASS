import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
}

class AuthLoginEvent extends AuthEvent {
  final String email;
  final String password;

  const AuthLoginEvent({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
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
