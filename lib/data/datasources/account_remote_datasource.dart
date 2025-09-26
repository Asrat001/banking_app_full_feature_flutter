import '../../core/network/api_client.dart';
import '../../core/constants/api_constants.dart';
import '../models/account_model.dart';
import '../models/create_account_request.dart';
import '../models/transfer_request.dart';
import '../models/transfer_response.dart';

abstract class AccountRemoteDataSource {
  Future<List<AccountModel>> getAccounts({int page = 0, int size = 10});
  Future<AccountModel> createAccount({
    required String accountType,
    required double initialBalance,
  });
  Future<void> transfer({
    required String fromAccountNumber,
    required String toAccountNumber,
    required double amount,
  });
}

class AccountRemoteDataSourceImpl implements AccountRemoteDataSource {
  final ApiClient apiClient;

  AccountRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<AccountModel>> getAccounts({int page = 0, int size = 10}) async {
    final response = await apiClient.get(
      ApiConstants.accountsEndpoint,
      queryParameters: {
        'page': page,
        'size': size,
      },
    );

    final List<dynamic> data = response.data['content'] ?? response.data;
    return data.map((json) => AccountModel.fromJson(json)).toList();
  }

  @override
  Future<AccountModel> createAccount({
    required String accountType,
    required double initialBalance,
  }) async {
    final request = CreateAccountRequest(
      accountType: accountType,
      initialBalance: initialBalance,
    );

    final response = await apiClient.post(
      ApiConstants.createAccountEndpoint,
      data: request.toJson(),
    );

    return AccountModel.fromJson(response.data);
  }

  @override
  Future<void> transfer({
    required String fromAccountNumber,
    required String toAccountNumber,
    required double amount,
  }) async {
    final request = TransferRequest(
      fromAccountNumber: fromAccountNumber,
      toAccountNumber: toAccountNumber,
      amount: amount,
    );

    final response = await apiClient.post(
      ApiConstants.transferEndpoint,
      data: request.toJson(),
    );

    // Parse the response to ensure it's valid
    TransferResponse.fromJson(response.data);
  }
}