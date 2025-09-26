import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:developer' as developer;
import 'package:banking_app_challenge/domain/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(AuthInitial()) {
    on<CheckAuthStatus>(_onCheckAuthStatus);
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<LogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatus event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthChecking());

    final result = await authRepository.getCurrentUser();
    result.fold(
      (failure) => emit(AuthUnauthenticated()),
      (user) => emit(AuthAuthenticated(user: user)),
    );
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    developer.log('🔐 LOGIN: Attempting login for user: ${event.username}');

    final result = await authRepository.login(event.username, event.password);

    result.fold(
      (failure) {
        developer.log('❌ LOGIN FAILED: ${failure.message}');
        emit(AuthError(message: failure.message));
      },
      (user) {
        developer.log('✅ LOGIN SUCCESS: User ${user.username} logged in');
        emit(AuthAuthenticated(user: user));
      },
    );
  }

  Future<void> _onRegisterRequested(
    RegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    // Auto-generate email based on first name and last name
    final generatedEmail = '${event.firstName.toLowerCase()}.${event.lastName.toLowerCase()}@example.com';

    final userData = {
      'username': event.username,
      'passwordHash': event.password,
      'firstName': event.firstName,
      'lastName': event.lastName,
      'email': event.email.isEmpty ? generatedEmail : event.email,
      'phoneNumber': event.phoneNumber,
    };

    developer.log('📝 REGISTER: Attempting registration');
    developer.log('User data: $userData');

    final result = await authRepository.register(userData);

    result.fold(
      (failure) {
        developer.log('❌ REGISTRATION FAILED: ${failure.message}');
        developer.log('❌ Failure type: ${failure.runtimeType}');
        emit(AuthError(message: failure.message));
      },
      (user) {
        developer
            .log('✅ REGISTRATION SUCCESS: User ${user.username} registered');
        // Don't authenticate after registration - user needs to login to get tokens
        emit(const AuthSuccess(message: 'Registration successful! Please login to continue.'));
      },
    );
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await authRepository.logout();
    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (_) => emit(AuthUnauthenticated()),
    );
  }
}
