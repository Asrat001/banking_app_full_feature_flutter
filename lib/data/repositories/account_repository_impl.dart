import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/account.dart';
import '../../domain/repositories/account_repository.dart';
import '../datasources/account_remote_datasource.dart';

class AccountRepositoryImpl implements AccountRepository {
  final AccountRemoteDataSource remoteDataSource;

  AccountRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Account>>> getAccounts({
    int page = 0,
    int size = 10,
  }) async {
    try {
      print('🔵 AccountRepository: Starting getAccounts call with page=$page, size=$size');
      final accountModels = await remoteDataSource.getAccounts(
        page: page,
        size: size,
      );

      print('🟢 AccountRepository: Received ${accountModels.length} account models');
      final accounts = accountModels
          .map((model) => Account(
                id: model.id,
                accountNumber: model.accountNumber,
                accountType: model.accountType,
                balance: model.balance,
                userId: model.userId,
              ))
          .toList();

      print('🟢 AccountRepository: Successfully converted to ${accounts.length} account entities');
      return Right(accounts);
    } on Failure catch (failure) {
      print('🔴 AccountRepository: Failure occurred: ${failure.message}');
      return Left(failure);
    } catch (e) {
      print('🔴 AccountRepository: Exception occurred: $e');
      return const Left(ServerFailure('Failed to fetch accounts'));
    }
  }

  @override
  Future<Either<Failure, void>> transfer({
    required String fromAccountNumber,
    required String toAccountNumber,
    required double amount,
  }) async {
    try {
      print('🔵 AccountRepository: Starting transfer');
      print('  From: $fromAccountNumber');
      print('  To: $toAccountNumber');
      print('  Amount: $amount');

      if (amount <= 0) {
        print('🔴 AccountRepository: Invalid amount: $amount');
        return const Left(ValidationFailure('Amount must be greater than 0'));
      }

      if (fromAccountNumber.isEmpty) {
        print('🔴 AccountRepository: Empty fromAccountNumber');
        return const Left(ValidationFailure('From account number is required'));
      }

      if (toAccountNumber.isEmpty) {
        print('🔴 AccountRepository: Empty toAccountNumber');
        return const Left(ValidationFailure('To account number is required'));
      }

      await remoteDataSource.transfer(
        fromAccountNumber: fromAccountNumber,
        toAccountNumber: toAccountNumber,
        amount: amount,
      );

      print('🟢 AccountRepository: Transfer completed successfully');
      return const Right(null);
    } on Failure catch (failure) {
      print('🔴 AccountRepository: Transfer failed with Failure: ${failure.message}');
      return Left(failure);
    } catch (e) {
      print('🔴 AccountRepository: Transfer failed with Exception: $e');
      return const Left(ServerFailure('Transfer failed'));
    }
  }
}