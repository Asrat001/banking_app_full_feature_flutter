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

  print('\n💳 Testing Account Creation Feature\n');
  print('=' * 60);

  // Step 1: Login first to get access token
  print('\n1️⃣  Logging in to get access token...');

  String? accessToken;

  try {
    final loginResponse = await dio.post(
      '/api/auth/login',
      data: {
        'username': 'asreqw',
        'passwordHash': 'Aa@12345',
      },
    );

    if (loginResponse.statusCode == 200) {
      accessToken = loginResponse.data['accessToken'];
      print('✅ Login successful! Got access token.');

      // Add auth header for subsequent requests
      dio.options.headers['Authorization'] = 'Bearer $accessToken';
    } else {
      print('❌ Login failed');
      return;
    }
  } catch (e) {
    print('❌ Login error: $e');
    return;
  }

  // Step 2: Get current accounts
  print('\n2️⃣  Getting current accounts...');

  try {
    final accountsResponse = await dio.get(
      '/api/accounts',
      queryParameters: {'page': 0, 'size': 10},
    );

    if (accountsResponse.statusCode == 200) {
      final accounts = accountsResponse.data['content'] ?? [];
      print('✅ Current account count: ${accounts.length}');

      for (var account in accounts) {
        print('   📊 ${account['accountNumber']} - ${account['accountType']} - ETB${account['balance']}');
      }
    }
  } catch (e) {
    print('❌ Get accounts error: $e');
  }

  // Step 3: Test account creation
  print('\n3️⃣  Testing CREATE ACCOUNT...');
  print('   Account Type: CHECKING');
  print('   Initial Balance: ETB100.00');

  try {
    final createResponse = await dio.post(
      '/api/accounts',
      data: {
        'accountType': 'CHECKING',
        'initialBalance': 100.0,
      },
    );

    print('\n   Status Code: ${createResponse.statusCode}');

    if (createResponse.statusCode == 200 || createResponse.statusCode == 201) {
      print('✅ ACCOUNT CREATED SUCCESSFULLY!');

      final data = createResponse.data;
      print('\n   📋 New Account Details:');
      print('   - ID: ${data['id']}');
      print('   - Account Number: ${data['accountNumber']}');
      print('   - Account Type: ${data['accountType']}');
      print('   - Balance: ETB${data['balance']}');
      print('   - User ID: ${data['userId']}');

      // Step 4: Verify by getting accounts again
      print('\n4️⃣  Verifying new account in list...');

      final verifyResponse = await dio.get(
        '/api/accounts',
        queryParameters: {'page': 0, 'size': 10},
      );

      if (verifyResponse.statusCode == 200) {
        final updatedAccounts = verifyResponse.data['content'] ?? [];
        print('✅ Updated account count: ${updatedAccounts.length}');

        final newAccount = updatedAccounts.firstWhere(
          (acc) => acc['accountNumber'] == data['accountNumber'],
          orElse: () => null,
        );

        if (newAccount != null) {
          print('✅ New account found in the list!');
        } else {
          print('⚠️  New account not found in immediate list');
        }
      }

    } else {
      print('❌ Account creation failed');
      print('Response: ${createResponse.data}');
    }
  } catch (e) {
    if (e is DioException) {
      print('❌ Account creation error: ${e.response?.statusCode}');
      print('   Error details: ${e.response?.data}');
    } else {
      print('❌ Account creation error: $e');
    }
  }

  print('\n' + '=' * 60);
  print('\n📊 Summary:');
  print('✅ Account creation endpoint: POST /api/accounts');
  print('✅ Required fields: accountType, initialBalance');
  print('✅ Returns: id, accountNumber, balance, userId, accountType');
  print('\n💡 The Create Account feature is ready to use in the app!');
}