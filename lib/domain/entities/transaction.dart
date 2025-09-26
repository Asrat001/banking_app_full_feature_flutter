import 'package:equatable/equatable.dart';
import 'transaction_enums.dart';

class Transaction extends Equatable {
  final int id;
  final int accountId;
  final double amount;
  final TransactionType type;
  final TransactionDirection direction;
  final String description;
  final DateTime timestamp;
  final DateTime date;
  final String? relatedAccount;
  final double? balanceAfter;
  final String? toAccount;
  final String? fromAccount;

  const Transaction({
    required this.id,
    required this.accountId,
    required this.amount,
    required this.type,
    required this.direction,
    required this.description,
    required this.timestamp,
    required this.date,
    this.relatedAccount,
    this.balanceAfter,
    this.toAccount,
    this.fromAccount,
  });

  @override
  List<Object?> get props => [
        id,
        accountId,
        amount,
        type,
        direction,
        description,
        timestamp,
        date,
        relatedAccount,
        balanceAfter,
        toAccount,
        fromAccount,
      ];
}