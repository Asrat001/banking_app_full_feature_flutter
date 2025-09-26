import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> login(String username, String password);
  Future<Either<Failure, User>> register(Map<String, dynamic> userData);
  Future<Either<Failure, void>> logout();
  Future<bool> isLoggedIn();
  Future<Either<Failure, User>> getCurrentUser();
}
