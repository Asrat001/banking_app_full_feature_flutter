import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/account.dart';

abstract class AccountRepository {
  Future<Either<Failure, List<Account>>> getAccounts({int page = 0, int size = 10});
  Future<Either<Failure, void>> transfer({
    required String fromAccountNumber,
    required String toAccountNumber,
    required double amount,
  });
}