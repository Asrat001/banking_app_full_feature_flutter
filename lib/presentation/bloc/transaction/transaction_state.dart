import 'package:equatable/equatable.dart';
import '../../../domain/entities/transaction.dart';

abstract class TransactionState extends Equatable {
  const TransactionState();

  @override
  List<Object> get props => [];
}

class TransactionInitial extends TransactionState {}

class TransactionLoading extends TransactionState {}

class TransactionLoaded extends TransactionState {
  final List<Transaction> transactions;
  final bool hasReachedEnd;
  final int currentPage;

  const TransactionLoaded({
    required this.transactions,
    this.hasReachedEnd = false,
    this.currentPage = 0,
  });

  TransactionLoaded copyWith({
    List<Transaction>? transactions,
    bool? hasReachedEnd,
    int? currentPage,
  }) {
    return TransactionLoaded(
      transactions: transactions ?? this.transactions,
      hasReachedEnd: hasReachedEnd ?? this.hasReachedEnd,
      currentPage: currentPage ?? this.currentPage,
    );
  }

  @override
  List<Object> get props => [transactions, hasReachedEnd, currentPage];
}

class TransactionError extends TransactionState {
  final String message;

  const TransactionError({required this.message});

  @override
  List<Object> get props => [message];
}