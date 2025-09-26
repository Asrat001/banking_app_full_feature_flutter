import 'package:dartz/dartz.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final FlutterSecureStorage secureStorage;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.secureStorage,
  });

  @override
  Future<Either<Failure, User>> login(String username, String password) async {
    try {
      final authResponse = await remoteDataSource.login(username, password);

      // Store tokens securely
      await secureStorage.write(
          key: 'access_token', value: authResponse.accessToken);
      await secureStorage.write(
          key: 'refresh_token', value: authResponse.refreshToken);

      // Store user info
      if (authResponse.userId != null) {
        await secureStorage.write(
            key: 'user_id', value: authResponse.userId.toString());
      }
      if (authResponse.username != null) {
        await secureStorage.write(
            key: 'username', value: authResponse.username);
      }

      // Get complete user data including stored profile information
      final getCurrentUserResult = await getCurrentUser();
      return getCurrentUserResult.fold(
        (failure) {
          // If getCurrentUser fails, create basic user with available data
          final user = User(
            id: authResponse.userId?.toString() ?? '',
            username: authResponse.username ?? username,
            firstName: '', // API doesn't return these in login response
            lastName: '',
            email: '',
            phoneNumber: '',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
          return Right(user);
        },
        (user) => Right(user), // Return the complete user data from getCurrentUser
      );
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure('Authentication failed: $e'));
    }
  }

  @override
  Future<Either<Failure, User>> register(Map<String, dynamic> userData) async {
    try {
      print('🔄 AuthRepository: Starting registration with data: $userData');
      final authResponse = await remoteDataSource.register(userData);
      print('✅ AuthRepository: Got response from remote datasource');

      // Store tokens securely (if available - registration might not return tokens)
      if (authResponse.accessToken != null) {
        await secureStorage.write(
            key: 'access_token', value: authResponse.accessToken);
      }
      if (authResponse.refreshToken != null) {
        await secureStorage.write(
            key: 'refresh_token', value: authResponse.refreshToken);
      }

      // Store user info
      if (authResponse.userId != null) {
        await secureStorage.write(
            key: 'user_id', value: authResponse.userId.toString());
      }
      if (authResponse.username != null) {
        await secureStorage.write(key: 'username', value: authResponse.username);
      }
      if (authResponse.initialAccountNumber != null) {
        await secureStorage.write(
            key: 'initial_account', value: authResponse.initialAccountNumber);
      }

      // Store additional user profile data
      if (userData['firstName'] != null) {
        await secureStorage.write(key: 'first_name', value: userData['firstName']);
      }
      if (userData['lastName'] != null) {
        await secureStorage.write(key: 'last_name', value: userData['lastName']);
      }
      if (userData['email'] != null) {
        await secureStorage.write(key: 'email', value: userData['email']);
      }
      if (userData['phoneNumber'] != null) {
        await secureStorage.write(key: 'phone_number', value: userData['phoneNumber']);
      }

      // Create user entity from response and request data
      final user = User(
        id: authResponse.userId?.toString() ?? '',
        username: authResponse.username ?? userData['username'] ?? '',
        firstName: userData['firstName'] ?? '',
        lastName: userData['lastName'] ?? '',
        email: userData['email'] ?? '',
        phoneNumber: userData['phoneNumber'] ?? '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      return Right(user);
    } on Failure catch (failure) {
      print('❌ AuthRepository: Caught Failure: ${failure.message} (${failure.runtimeType})');
      return Left(failure);
    } catch (e, stackTrace) {
      print('❌ AuthRepository: Caught unexpected exception: $e');
      print('❌ Stack trace: $stackTrace');
      return Left(ServerFailure('Registration failed: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await remoteDataSource.logout();

      // Clear all stored user data
      await secureStorage.delete(key: 'access_token');
      await secureStorage.delete(key: 'refresh_token');
      await secureStorage.delete(key: 'user_id');
      await secureStorage.delete(key: 'username');
      await secureStorage.delete(key: 'first_name');
      await secureStorage.delete(key: 'last_name');
      await secureStorage.delete(key: 'email');
      await secureStorage.delete(key: 'phone_number');
      await secureStorage.delete(key: 'initial_account');

      return const Right(null);
    } catch (e) {
      return const Left(ServerFailure('Logout failed'));
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    try {
      final accessToken = await secureStorage.read(key: 'access_token');
      return accessToken != null;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<Either<Failure, User>> getCurrentUser() async {
    try {
      final accessToken = await secureStorage.read(key: 'access_token');
      if (accessToken == null) {
        return const Left(AuthFailure('No access token found'));
      }

      // Get stored user data
      final userId = await secureStorage.read(key: 'user_id');
      final username = await secureStorage.read(key: 'username');
      final firstName = await secureStorage.read(key: 'first_name') ?? '';
      final lastName = await secureStorage.read(key: 'last_name') ?? '';
      final email = await secureStorage.read(key: 'email') ?? '';
      final phoneNumber = await secureStorage.read(key: 'phone_number') ?? '';

      if (userId == null || username == null) {
        return const Left(AuthFailure('Incomplete user data'));
      }

      final user = User(
        id: userId,
        username: username,
        firstName: firstName,
        lastName: lastName,
        email: email,
        phoneNumber: phoneNumber,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      return Right(user);
    } catch (e) {
      return const Left(ServerFailure('Failed to get current user'));
    }
  }
}
