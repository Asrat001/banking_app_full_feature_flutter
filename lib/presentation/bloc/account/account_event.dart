import 'package:equatable/equatable.dart';

abstract class AccountEvent extends Equatable {
  const AccountEvent();

  @override
  List<Object> get props => [];
}

class LoadAccounts extends AccountEvent {
  final int page;

  const LoadAccounts({this.page = 0});

  @override
  List<Object> get props => [page];
}

class LoadMoreAccounts extends AccountEvent {}

class TransferFunds extends AccountEvent {
  final String fromAccountNumber;
  final String toAccountNumber;
  final double amount;

  const TransferFunds({
    required this.fromAccountNumber,
    required this.toAccountNumber,
    required this.amount,
  });

  @override
  List<Object> get props => [fromAccountNumber, toAccountNumber, amount];
}