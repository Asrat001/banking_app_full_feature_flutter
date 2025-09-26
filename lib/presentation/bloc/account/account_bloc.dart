import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/account_repository.dart';
import 'account_event.dart';
import 'account_state.dart';

class AccountBloc extends Bloc<AccountEvent, AccountState> {
  final AccountRepository accountRepository;
  static const int _pageSize = 10;

  AccountBloc({required this.accountRepository}) : super(AccountInitial()) {
    on<LoadAccounts>(_onLoadAccounts);
    on<LoadMoreAccounts>(_onLoadMoreAccounts);
    on<TransferFunds>(_onTransferFunds);
  }

  Future<void> _onLoadAccounts(
    LoadAccounts event,
    Emitter<AccountState> emit,
  ) async {
    print('🔵 AccountBloc: Starting LoadAccounts event, page=${event.page}');
    emit(AccountLoading());

    final result = await accountRepository.getAccounts(
      page: event.page,
      size: _pageSize,
    );

    result.fold(
      (failure) {
        print('🔴 AccountBloc: LoadAccounts failed with error: ${failure.message}');
        emit(AccountError(message: failure.message));
      },
      (accounts) {
        print('🟢 AccountBloc: LoadAccounts successful, loaded ${accounts.length} accounts');
        emit(AccountLoaded(
          accounts: accounts,
          hasReachedEnd: accounts.length < _pageSize,
          currentPage: event.page,
        ));
      },
    );
  }

  Future<void> _onLoadMoreAccounts(
    LoadMoreAccounts event,
    Emitter<AccountState> emit,
  ) async {
    if (state is AccountLoaded) {
      final currentState = state as AccountLoaded;

      if (!currentState.hasReachedEnd) {
        final nextPage = currentState.currentPage + 1;
        final result = await accountRepository.getAccounts(
          page: nextPage,
          size: _pageSize,
        );

        result.fold(
          (failure) => emit(AccountError(message: failure.message)),
          (newAccounts) => emit(currentState.copyWith(
            accounts: [...currentState.accounts, ...newAccounts],
            hasReachedEnd: newAccounts.length < _pageSize,
            currentPage: nextPage,
          )),
        );
      }
    }
  }

  Future<void> _onTransferFunds(
    TransferFunds event,
    Emitter<AccountState> emit,
  ) async {
    final previousState = state;
    emit(TransferInProgress());

    final result = await accountRepository.transfer(
      fromAccountNumber: event.fromAccountNumber,
      toAccountNumber: event.toAccountNumber,
      amount: event.amount,
    );

    result.fold(
      (failure) {
        emit(TransferFailure(message: failure.message));
        emit(previousState); // Return to previous state
      },
      (_) {
        emit(TransferSuccess());
        // Reload accounts to update balances
        add(const LoadAccounts());
      },
    );
  }
}