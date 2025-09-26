import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'core/network/api_client.dart';
import 'data/datasources/auth_remote_datasource.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'presentation/bloc/auth/auth_bloc.dart';
import 'presentation/bloc/auth/auth_event.dart';
import 'core/theme/app_theme.dart';
import 'core/routes/app_routes.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final _secureStorage = const FlutterSecureStorage();
  final _apiClient = ApiClient();
  final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();


  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (context) => AuthRepositoryImpl(
        remoteDataSource: AuthRemoteDataSourceImpl(apiClient: _apiClient),
        secureStorage: _secureStorage,
      ),
      child: BlocProvider(
        create: (context) {
          final authBloc = AuthBloc(
            authRepository: context.read<AuthRepositoryImpl>(),
          )..add(CheckAuthStatus());
          authNotifier.setAuthBloc(authBloc);

          ApiClient.onTokenExpired = () {

            // Show snackbar
            rootScaffoldMessengerKey.currentState?.showSnackBar(
              const SnackBar(
                content: Text('Session expired. Please login again.'),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 3),
              ),
            );

            authBloc.add(LogoutRequested());
          };

          return authBloc;
        },
        child: MaterialApp.router(
          title: 'Banking App Challenge',
          debugShowCheckedModeBanner: false,
          theme: appTheme,
          routerConfig: createRouter(_apiClient),
          scaffoldMessengerKey: rootScaffoldMessengerKey,
        ),
      ),
    );
  }
}
