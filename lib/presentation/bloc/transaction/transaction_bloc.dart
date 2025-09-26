import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/transaction_repository.dart';
import '../../../domain/entities/transaction.dart';
import 'transaction_event.dart';
import 'transaction_state.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final TransactionRepository transactionRepository;
  static const int _pageSize = 20;

  TransactionBloc({required this.transactionRepository})
      : super(TransactionInitial()) {
    on<LoadTransactions>(_onLoadTransactions);
    on<LoadMoreTransactions>(_onLoadMoreTransactions);
    on<LoadAllAccountsTransactions>(_onLoadAllAccountsTransactions);
  }

  Future<void> _onLoadTransactions(
    LoadTransactions event,
    Emitter<TransactionState> emit,
  ) async {
    emit(TransactionLoading());

    print('🔄 Loading transactions for account ID: ${event.accountId}');

    final result = await transactionRepository.getTransactionHistory(
      accountId: event.accountId,
      page: event.page,
      size: _pageSize,
    );

    result.fold(
      (failure) {
        print('❌ Error loading transactions: ${failure.message}');
        emit(TransactionError(message: failure.message));
      },
      (pageResponse) {
        print('✅ Loaded ${pageResponse.content.length} transactions');
        final transactions = pageResponse.content
            .map((transactionResponse) => Transaction(
                  id: transactionResponse.id,
                  accountId: transactionResponse.accountId,
                  amount: transactionResponse.amount,
                  type: transactionResponse.type,
                  direction: transactionResponse.direction,
                  description: transactionResponse.description ?? '',
                  timestamp: transactionResponse.timestamp,
                  date: transactionResponse.timestamp,
                  relatedAccount: transactionResponse.relatedAccount,
                ))
            .toList();

        emit(TransactionLoaded(
          transactions: transactions,
          hasReachedEnd: pageResponse.last,
          currentPage: event.page,
        ));
      },
    );
  }

  Future<void> _onLoadMoreTransactions(
    LoadMoreTransactions event,
    Emitter<TransactionState> emit,
  ) async {
    if (state is TransactionLoaded) {
      final currentState = state as TransactionLoaded;

      if (!currentState.hasReachedEnd) {
        final nextPage = currentState.currentPage + 1;
        final result = await transactionRepository.getTransactionHistory(
          accountId: event.accountId,
          page: nextPage,
          size: _pageSize,
        );

        result.fold(
          (failure) => emit(TransactionError(message: failure.message)),
          (pageResponse) {
            final newTransactions = pageResponse.content
                .map((transactionResponse) => Transaction(
                      id: transactionResponse.id,
                      accountId: transactionResponse.accountId,
                      amount: transactionResponse.amount,
                      type: transactionResponse.type,
                      direction: transactionResponse.direction,
                      description: transactionResponse.description ?? '',
                      timestamp: transactionResponse.timestamp,
                      date: transactionResponse.timestamp,
                      relatedAccount: transactionResponse.relatedAccount,
                    ))
                .toList();

            emit(currentState.copyWith(
              transactions: [...currentState.transactions, ...newTransactions],
              hasReachedEnd: pageResponse.last,
              currentPage: nextPage,
            ));
          },
        );
      }
    }
  }

  Future<void> _onLoadAllAccountsTransactions(
    LoadAllAccountsTransactions event,
    Emitter<TransactionState> emit,
  ) async {
    emit(TransactionLoading());

    print('🔄 Loading transactions for all accounts: ${event.accountIds}');

    List<Transaction> allTransactions = [];

    // Load transactions for each account
    for (final accountId in event.accountIds) {
      print('🔄 Loading transactions for account ID: $accountId');

      final result = await transactionRepository.getTransactionHistory(
        accountId: accountId,
        page: 0,
        size: 10, // Limit to recent transactions for each account
      );

      result.fold(
        (failure) {
          print('❌ Error loading transactions for account $accountId: ${failure.message}');
          // Continue loading for other accounts even if one fails
        },
        (pageResponse) {
          print('✅ Loaded ${pageResponse.content.length} transactions for account $accountId');
          final transactions = pageResponse.content
              .map((transactionResponse) => Transaction(
                    id: transactionResponse.id,
                    accountId: transactionResponse.accountId,
                    amount: transactionResponse.amount,
                    type: transactionResponse.type,
                    direction: transactionResponse.direction,
                    description: transactionResponse.description ?? '',
                    timestamp: transactionResponse.timestamp,
                    date: transactionResponse.timestamp,
                    relatedAccount: transactionResponse.relatedAccount,
                  ))
              .toList();
          allTransactions.addAll(transactions);
        },
      );
    }

    // Sort all transactions by timestamp (most recent first)
    allTransactions.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    print('✅ Total loaded ${allTransactions.length} transactions from all accounts');

    emit(TransactionLoaded(
      transactions: allTransactions,
      hasReachedEnd: true, // For home page, we don't need pagination
      currentPage: 0,
    ));
  }
}