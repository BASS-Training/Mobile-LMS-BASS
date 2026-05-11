import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/auth_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final LogoutUseCase logoutUseCase;

  AuthBloc({
    required this.loginUseCase,
    required this.logoutUseCase,
  }) : super(const AuthInitial()) {
    on<AuthLoginEvent>(_onLogin);
    on<AuthLogoutEvent>(_onLogout);
    on<AuthClearErrorEvent>(_onClearError);
  }

  Future<void> _onLogin(AuthLoginEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    final user = await loginUseCase(event.email, event.password);

    if (user != null) {
      emit(AuthSuccess(user: user));
    } else {
      emit(const AuthFailure(
        message: 'Login failed. Please check your credentials.',
      ));
    }
  }

  Future<void> _onLogout(AuthLogoutEvent event, Emitter<AuthState> emit) async {
    await logoutUseCase();
    emit(const AuthLoggedOut());
  }

  Future<void> _onClearError(
      AuthClearErrorEvent event, Emitter<AuthState> emit) async {
    if (state is AuthFailure) {
      emit(const AuthInitial());
    }
  }
}
