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

  String? accessToken;
  String? refreshToken;

  print('🔵 Testing Banking API Endpoints\n');
  print('=' * 50);

  // Test 1: Login
  print('\n1️⃣  Testing Login...');
  try {
    final loginResponse = await dio.post(
      '/api/auth/login',
      data: {
        'username': 'asreqw',
        'passwordHash': 'Aa@12345',
      },
    );

    accessToken = loginResponse.data['accessToken'];
    refreshToken = loginResponse.data['refreshToken'];

    print('✅ Login successful!');
    print('   User: ${loginResponse.data['username']}');
    print('   UserID: ${loginResponse.data['userId']}');
    print('   Token: ${accessToken?.substring(0, 30)}...');
  } catch (e) {
    print('❌ Login failed: $e');
    return;
  }

  // Add auth header for protected endpoints
  dio.options.headers['Authorization'] = 'Bearer $accessToken';

  // Test 2: Get Accounts
  print('\n2️⃣  Testing Get Accounts...');
  try {
    final accountsResponse = await dio.get(
      '/api/accounts',
      queryParameters: {
        'page': 0,
        'size': 10,
      },
    );

    print('✅ Accounts retrieved!');
    final accounts = accountsResponse.data['content'] ?? [];
    print('   Total accounts: ${accounts.length}');

    if (accounts.isNotEmpty) {
      for (var account in accounts) {
        print('   📊 Account: ${account['accountNumber']} - Balance: ${account['balance']} (${account['accountType']})');
      }

      // Test 3: Get Transactions for first account
      final firstAccountId = accounts[0]['accountNumber'];
      print('\n3️⃣  Testing Get Transactions for account $firstAccountId...');
      try {
        final transactionsResponse = await dio.get(
          '/api/transactions/$firstAccountId',
          queryParameters: {
            'page': 0,
            'size': 5,
          },
        );

        print('✅ Transactions retrieved!');
        final transactions = transactionsResponse.data['content'] ?? [];
        print('   Total transactions: ${transactions.length}');

        for (var tx in transactions.take(3)) {
          print('   💸 ${tx['direction']} - Amount: ${tx['amount']} - ${tx['description'] ?? 'No description'}');
        }
      } catch (e) {
        print('❌ Get transactions failed: $e');
      }
    } else {
      print('   ⚠️  No accounts found. Creating one...');

      // Test 4: Create Account
      print('\n4️⃣  Testing Create Account...');
      try {
        final createAccountResponse = await dio.post(
          '/api/accounts',
          data: {
            'accountType': 'SAVINGS',
            'initialDeposit': 1000.0,
          },
        );

        print('✅ Account created!');
        print('   Account Number: ${createAccountResponse.data['accountNumber']}');
        print('   Type: ${createAccountResponse.data['accountType']}');
        print('   Balance: ${createAccountResponse.data['balance']}');
      } catch (e) {
        print('❌ Create account failed: $e');
      }
    }
  } catch (e) {
    if (e is DioException) {
      print('❌ Get accounts failed: ${e.response?.statusCode}');
      print('   Error: ${e.response?.data}');
    } else {
      print('❌ Get accounts failed: $e');
    }
  }

  // Test 5: Refresh Token
  print('\n5️⃣  Testing Token Refresh...');
  try {
    // Remove auth header for refresh
    dio.options.headers.remove('Authorization');

    final refreshResponse = await dio.post(
      '/api/auth/refresh-token',
      data: {
        'refreshToken': refreshToken,
      },
    );

    print('✅ Token refreshed!');
    print('   New access token: ${refreshResponse.data['accessToken']?.substring(0, 30)}...');
  } catch (e) {
    if (e is DioException) {
      print('❌ Token refresh failed: ${e.response?.statusCode}');
      print('   Error: ${e.response?.data}');
    } else {
      print('❌ Token refresh failed: $e');
    }
  }

  print('\n' + '=' * 50);
  print('🏁 Testing complete!\n');
}