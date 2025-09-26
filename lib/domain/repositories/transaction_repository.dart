import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../data/models/page_transaction_response.dart';
import '../entities/transaction.dart';

abstract class TransactionRepository {
  Future<Either<Failure, List<Transaction>>> getTransactions({
    required String accountId,
    int page = 0,
    int size = 10,
  });

  Future<Either<Failure, PageTransactionResponse>> getTransactionHistory({
    required int accountId,
    int page = 0,
    int size = 20,
  });
}