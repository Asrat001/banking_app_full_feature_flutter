import 'package:equatable/equatable.dart';

abstract class TransactionEvent extends Equatable {
  const TransactionEvent();

  @override
  List<Object> get props => [];
}

class LoadTransactions extends TransactionEvent {
  final int accountId;
  final int page;

  const LoadTransactions({
    required this.accountId,
    this.page = 0,
  });

  @override
  List<Object> get props => [accountId, page];
}

class LoadMoreTransactions extends TransactionEvent {
  final int accountId;

  const LoadMoreTransactions({required this.accountId});

  @override
  List<Object> get props => [accountId];
}

class LoadAllAccountsTransactions extends TransactionEvent {
  final List<int> accountIds;

  const LoadAllAccountsTransactions({required this.accountIds});

  @override
  List<Object> get props => [accountIds];
}