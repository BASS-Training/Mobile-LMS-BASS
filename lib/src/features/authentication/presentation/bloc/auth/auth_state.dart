import 'package:equatable/equatable.dart';
import '../../../domain/entities/user_entity.dart';

abstract class AuthState extends Equatable {
  const AuthState();
}

class AuthInitial extends AuthState {
  const AuthInitial();

  @override
  List<Object?> get props => [];
}

class AuthLoading extends AuthState {
  const AuthLoading();

  @override
  List<Object?> get props => [];
}

class AuthSuccess extends AuthState {
  final UserEntity user;

  const AuthSuccess({required this.user});

  @override
  List<Object?> get props => [user];
}

class AuthRegisterSuccess extends AuthState {
  final UserEntity user;

  const AuthRegisterSuccess({required this.user});

  @override
  List<Object?> get props => [user];
}

class AuthFailure extends AuthState {
  final String message;

  const AuthFailure({required this.message});

  @override
  List<Object?> get props => [message];
}

class AuthLoggedOut extends AuthState {
  const AuthLoggedOut();

  @override
  List<Object?> get props => [];
}
