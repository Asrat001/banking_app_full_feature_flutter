import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../datasources/transaction_remote_datasource.dart';
import '../models/page_transaction_response.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionRemoteDataSource remoteDataSource;

  TransactionRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Transaction>>> getTransactions({
    required String accountId,
    int page = 0,
    int size = 10,
  }) async {
    try {
      final transactionModels = await remoteDataSource.getTransactions(
        accountId: accountId,
        page: page,
        size: size,
      );

      final transactions = transactionModels
          .map((model) => Transaction(
                id: model.id,
                accountId: model.accountId,
                amount: model.amount,
                type: model.type,
                direction: model.direction,
                description: model.description ?? '',
                timestamp: model.timestamp,
                date: model.timestamp,
                balanceAfter: model.balanceAfter,
                toAccount: model.toAccount,
                fromAccount: model.fromAccount,
                relatedAccount: model.relatedAccount,
              ))
          .toList();

      return Right(transactions);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return const Left(ServerFailure('Failed to fetch transactions'));
    }
  }

  @override
  Future<Either<Failure, PageTransactionResponse>> getTransactionHistory({
    required int accountId,
    int page = 0,
    int size = 20,
  }) async {
    try {
      final pageResponse = await remoteDataSource.getTransactionHistory(
        accountId: accountId,
        page: page,
        size: size,
      );

      return Right(pageResponse);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return const Left(ServerFailure('Failed to fetch transaction history'));
    }
  }
}
