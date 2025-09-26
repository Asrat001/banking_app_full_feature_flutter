import '../../core/network/api_client.dart';
import '../../core/constants/api_constants.dart';
import '../models/transaction_model.dart';
import '../models/page_transaction_response.dart';

abstract class TransactionRemoteDataSource {
  Future<List<TransactionModel>> getTransactions({
    required String accountId,
    int page = 0,
    int size = 10,
  });

  Future<PageTransactionResponse> getTransactionHistory({
    required int accountId,
    int page = 0,
    int size = 20,
  });
}

class TransactionRemoteDataSourceImpl implements TransactionRemoteDataSource {
  final ApiClient apiClient;

  TransactionRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<TransactionModel>> getTransactions({
    required String accountId,
    int page = 0,
    int size = 10,
  }) async {
    final response = await apiClient.get(
      '${ApiConstants.transactionsEndpoint}/$accountId',
      queryParameters: {
        'page': page,
        'size': size,
      },
    );

    final List<dynamic> data = response.data['content'] ?? response.data;
    return data.map((json) => TransactionModel.fromJson(json)).toList();
  }

  @override
  Future<PageTransactionResponse> getTransactionHistory({
    required int accountId,
    int page = 0,
    int size = 20,
  }) async {
    final response = await apiClient.get(
      '${ApiConstants.transactionsEndpoint}/$accountId',
      queryParameters: {
        'page': page,
        'size': size,
      },
    );

    return PageTransactionResponse.fromJson(response.data);
  }
}