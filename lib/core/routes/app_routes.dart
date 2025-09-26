import 'dart:async';
import 'package:banking_app_challenge/core/routes/route_observers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../presentation/bloc/auth/auth_bloc.dart';
import '../../presentation/bloc/auth/auth_state.dart';
import '../../presentation/pages/login_page.dart';
import '../../presentation/pages/main_screen.dart';
import '../../presentation/pages/register_page.dart';
import '../../presentation/pages/splash_screen.dart';
import '../network/api_client.dart';


class AuthNotifier extends ChangeNotifier {
  AuthBloc? _authBloc;
  StreamSubscription? _authSubscription;

  void setAuthBloc(AuthBloc authBloc) {
    _authBloc = authBloc;
    _authSubscription?.cancel();
    _authSubscription = _authBloc!.stream.listen((_) {
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}

final authNotifier = AuthNotifier();

GoRouter createRouter(ApiClient apiClient) => GoRouter(
  initialLocation: '/splash',
  refreshListenable: authNotifier,
  observers: [StatusBarNavigatorObserver()],
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterPage(),
    ),
    GoRoute(
      path: '/dashboard',
      builder: (context, state) => MainScreen(apiClient: apiClient),
    ),
  ],
  redirect: (context, state) {
    final authState = context.read<AuthBloc>().state;
    final isLoggedIn = authState is AuthAuthenticated;
    final isAuthChecking = authState is AuthChecking || authState is AuthInitial;
    final isOnSplashPage = state.fullPath == '/splash';
    final isOnLoginPage = state.fullPath == '/login';
    final isOnRegisterPage = state.fullPath == '/register';

    if (isAuthChecking && !isOnSplashPage) return '/splash';
    if (!isAuthChecking) {
      if (!isLoggedIn && !isOnLoginPage && !isOnRegisterPage) return '/login';
      if (isLoggedIn && (isOnLoginPage || isOnRegisterPage || isOnSplashPage)) return '/dashboard';
    }
    return null;
  },
);
