import 'package:equatable/equatable.dart';
import '../../../domain/entities/account.dart';

abstract class AccountState extends Equatable {
  const AccountState();

  @override
  List<Object> get props => [];
}

class AccountInitial extends AccountState {}

class AccountLoading extends AccountState {}

class AccountLoaded extends AccountState {
  final List<Account> accounts;
  final bool hasReachedEnd;
  final int currentPage;

  const AccountLoaded({
    required this.accounts,
    this.hasReachedEnd = false,
    this.currentPage = 0,
  });

  AccountLoaded copyWith({
    List<Account>? accounts,
    bool? hasReachedEnd,
    int? currentPage,
  }) {
    return AccountLoaded(
      accounts: accounts ?? this.accounts,
      hasReachedEnd: hasReachedEnd ?? this.hasReachedEnd,
      currentPage: currentPage ?? this.currentPage,
    );
  }

  @override
  List<Object> get props => [accounts, hasReachedEnd, currentPage];
}

class AccountError extends AccountState {
  final String message;

  const AccountError({required this.message});

  @override
  List<Object> get props => [message];
}

class TransferInProgress extends AccountState {}

class TransferSuccess extends AccountState {}

class TransferFailure extends AccountState {
  final String message;

  const TransferFailure({required this.message});

  @override
  List<Object> get props => [message];
}