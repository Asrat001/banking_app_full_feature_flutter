import 'package:dio/dio.dart';

void main() async {
  final dio = Dio(
    BaseOptions(
      baseUrl: 'https://challenge-api.qena.dev',
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  // Test credentials
  const testUser = {
    'firstName': 'asre',
    'lastName': 'aser',
    'username': 'asreqw',
    'phoneNumber': '0975591723',
    'passwordHash': 'Aa@12345',
    'email': 'asreqw@example.com',
  };

  print('Testing Banking App API...\n');

  // Test 1: Register a new user
  print('1. Testing Registration...');
  try {
    final registerResponse = await dio.post(
      '/api/auth/register',
      data: testUser,
    );
    print('✅ Registration successful!');
    print('Response: ${registerResponse.data}\n');
  } catch (e) {
    if (e is DioException) {
      print('❌ Registration failed: ${e.response?.statusCode}');
      print('Error: ${e.response?.data}\n');
    } else {
      print('❌ Registration failed: $e\n');
    }
  }

  // Test 2: Login with the registered user
  print('2. Testing Login...');
  try {
    final loginResponse = await dio.post(
      '/api/auth/login',
      data: {
        'username': testUser['username'],
        'passwordHash': testUser['passwordHash'],
      },
    );
    print('✅ Login successful!');
    print('Response: ${loginResponse.data}');

    // Extract tokens
    final accessToken = loginResponse.data['accessToken'];
    final refreshToken = loginResponse.data['refreshToken'];

    if (accessToken != null) {
      print('\nAccess Token received: ${accessToken.substring(0, 20)}...');
      print('Refresh Token received: ${refreshToken != null ? 'Yes' : 'No'}');
    }
  } catch (e) {
    if (e is DioException) {
      print('❌ Login failed: ${e.response?.statusCode}');
      print('Error: ${e.response?.data}');
    } else {
      print('❌ Login failed: $e');
    }
  }
}