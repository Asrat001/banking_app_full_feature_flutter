import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class LoginRequested extends AuthEvent {
  final String username;
  final String password;

  const LoginRequested({
    required this.username,
    required this.password,
  });

  @override
  List<Object> get props => [username, password];
}

class RegisterRequested extends AuthEvent {
  final String username;
  final String password;
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;

  const RegisterRequested({
    required this.username,
    required this.password,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
  });

  @override
  List<Object> get props => [
        username,
        password,
        firstName,
        lastName,
        email,
        phoneNumber,
      ];
}

class LogoutRequested extends AuthEvent {}

class CheckAuthStatus extends AuthEvent {}