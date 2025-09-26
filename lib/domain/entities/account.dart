import 'package:equatable/equatable.dart';

class Account extends Equatable {
  final int id;
  final String accountNumber;
  final String accountType;
  final double balance;
  final int userId;

  const Account({
    required this.id,
    required this.accountNumber,
    required this.accountType,
    required this.balance,
    required this.userId,
  });

  @override
  List<Object> get props => [
        id,
        accountNumber,
        accountType,
        balance,
        userId,
      ];
}