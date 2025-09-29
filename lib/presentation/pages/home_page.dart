import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../../core/network/api_client.dart';
import '../../domain/entities/account.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/entities/transaction_enums.dart';
import '../bloc/account/account_bloc.dart';
import '../bloc/account/account_event.dart';
import '../bloc/account/account_state.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_state.dart';
import '../bloc/transaction/transaction_bloc.dart';
import '../bloc/transaction/transaction_event.dart';
import '../bloc/transaction/transaction_state.dart';
import '../widgets/account_card.dart';
import '../widgets/account_header.dart';
import '../widgets/create_account_dialog.dart';
import '../widgets/quick_action_card.dart';
import '../widgets/row_label.dart';
import '../widgets/transaction_card.dart';
import 'fund_transfer_page.dart';
import 'bill_payment_page.dart';
import 'transaction_detail_page.dart';

class HomePage extends StatelessWidget {
  final ApiClient apiClient;
  final Function(int)? onTabChanged;

  const HomePage({super.key, required this.apiClient, this.onTabChanged});

  @override
  Widget build(BuildContext context) {
    return HomeView(apiClient: apiClient, onTabChanged: onTabChanged);
  }
}

class HomeView extends StatefulWidget {
  final ApiClient apiClient;
  final Function(int)? onTabChanged;

  const HomeView({super.key, required this.apiClient, this.onTabChanged});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final ScrollController _scrollController = ScrollController();
  bool _hasLoadedInitialTransactions = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    // Check current account state and load transactions for all accounts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final accountState = context.read<AccountBloc>().state;
      if (accountState is AccountLoaded &&
          accountState.accounts.isNotEmpty &&
          !_hasLoadedInitialTransactions) {
        // Get all account IDs
        final accountIds = accountState.accounts.map((a) => a.id).toList();
        // Load transactions from all accounts
        context.read<TransactionBloc>().add(
              LoadAllAccountsTransactions(accountIds: accountIds),
            );
        _hasLoadedInitialTransactions = true;
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<AccountBloc>().add(LoadMoreAccounts());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }


  @override
  Widget build(BuildContext context) {
    return BlocListener<AccountBloc, AccountState>(
      listener: (context, state) {
        // When accounts are loaded, reload transactions from all accounts
        if (state is AccountLoaded && state.accounts.isNotEmpty) {
          final accountIds = state.accounts.map((a) => a.id).toList();
          context.read<TransactionBloc>().add(
                LoadAllAccountsTransactions(accountIds: accountIds),
              );
        }
      },
      child: Scaffold(
        body: Column(
          children: [
            // Dark grey header background
            AccountHeader(onTabChanged: () {
              if (widget.onTabChanged != null) {
                widget.onTabChanged!(3); // Navigate to Profile tab
              }
            }),

            Expanded(
              child: Transform.translate(
                offset: const Offset(0, -30),
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(35),
                      topRight: Radius.circular(35),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(
                      top: 30,
                    ),
                    child: Column(children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          QuickActionCard(icon: "assets/transfer_bold.svg", label: 'Transfer', onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => MultiBlocProvider(
                                  providers: [
                                    BlocProvider.value(
                                      value: context.read<AccountBloc>(),
                                    ),
                                    BlocProvider.value(
                                      value: context.read<TransactionBloc>(),
                                    ),
                                  ],
                                  child: FundTransferPage(
                                    apiClient: widget.apiClient,
                                  ),
                                ),
                              ),
                            )),
                          QuickActionCard(icon: "assets/doc_bold.svg", label: 'Bills', onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => MultiBlocProvider(
                                  providers: [
                                    BlocProvider.value(
                                      value: context.read<AccountBloc>(),
                                    ),
                                    BlocProvider.value(
                                      value: context.read<TransactionBloc>(),
                                    ),
                                  ],
                                  child: BillPaymentPage(
                                    apiClient: widget.apiClient,
                                  ),
                                ),
                              ),
                            )),
                          QuickActionCard(icon: "assets/phone_icon.svg", label: 'Recharge', onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Recharge coming soon')),
                              );
                            }),
                          QuickActionCard(icon: "assets/more_icon.svg", label: 'More', onTap: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                builder: (dialogContext){
                                  return CreateAccountDialog(
                                    apiClient: widget.apiClient,
                                    onAccountCreated: () {
                                      context
                                          .read<AccountBloc>()
                                          .add(const LoadAccounts());
                                    },
                                  );
                                }
                              );
                            }),
                        ],
                      ),
                      const SizedBox(height: 18),
                      // My Accounts Section
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            RowLabel(
                                onClick: () {
                                  if (widget.onTabChanged != null) {
                                    widget.onTabChanged!(1);
                                  } else {
                                    // Fallback for when callback is not provided
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content:
                                            Text('Navigation not available'),
                                        duration: Duration(seconds: 2),
                                      ),
                                    );
                                  }
                                },
                                title: "My Accounts"),
                            const SizedBox(height: 8),
                            // Account Cards
                            BlocBuilder<AccountBloc, AccountState>(
                              builder: (context, state) {
                                if (state is AccountLoading) {
                                  return const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(20),
                                      child: SpinKitCircle(
                                        color: Color(0xFF4A5568),
                                        size: 40,
                                      ),
                                    ),
                                  );
                                }

                                if (state is AccountError) {
                                  return Center(
                                    child: Text(
                                      state.message,
                                      style: const TextStyle(color: Colors.red),
                                    ),
                                  );
                                }

                                if (state is AccountLoaded) {
                                  if (state.accounts.isEmpty) {
                                    return _buildEmptyState();
                                  }

                                  return Container(
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(15),
                                        border: Border.all(
                                          color: Colors.grey,
                                        )),
                                    child: Column(
                                      children:
                                          state.accounts.take(2).map((account) {
                                        return AccountCard(
                                            account: account,
                                            isLast:
                                                account == state.accounts[1]);
                                      }).toList(),
                                    ),
                                  );
                                }

                                return _buildEmptyState();
                              },
                            ),

                            const SizedBox(height: 8),
                            // Recent Transactions Section
                            RowLabel(
                              title: "Recent Transactions",
                              onClick: () {
                                if (widget.onTabChanged != null) {
                                  widget.onTabChanged!(2);
                                }
                              },
                            ),
                            const SizedBox(height: 15),

                            // Transaction List
                            BlocBuilder<TransactionBloc, TransactionState>(
                              builder: (context, transactionState) {
                                if (transactionState is TransactionLoading) {
                                  return Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(15),
                                      border: Border.all(color: Colors.grey),
                                    ),
                                    padding: const EdgeInsets.all(40),
                                    child: const Center(
                                      child: SpinKitCircle(
                                        color: Color(0xFF4A5568),
                                        size: 30,
                                      ),
                                    ),
                                  );
                                }

                                if (transactionState is TransactionError) {
                                  // Show empty state instead of error for better UX
                                  return Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(15),
                                      border: Border.all(color: Colors.grey),
                                    ),
                                    padding: const EdgeInsets.all(40),
                                    child: Center(
                                      child: Column(
                                        children: [
                                          Icon(
                                            Icons.receipt_outlined,
                                            size: 40,
                                            color: Colors.grey[400],
                                          ),
                                          const SizedBox(height: 10),
                                          Text(
                                            'No recent transactions',
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }
                            // todo: we only show the two most recent transactions , but it's to use listview builder for better performance on lower end devices
                                if (transactionState is TransactionLoaded) {
                                  final recentTransactions = transactionState
                                      .transactions
                                      .take(2)
                                      .toList();

                                  if (recentTransactions.isEmpty) {
                                    return Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(15),
                                        border: Border.all(color: Colors.grey),
                                      ),
                                      padding: const EdgeInsets.all(40),
                                      child: Center(
                                        child: Column(
                                          children: [
                                            Icon(
                                              Icons.receipt_outlined,
                                              size: 40,
                                              color: Colors.grey[400],
                                            ),
                                            const SizedBox(height: 10),
                                            Text(
                                              'No recent transactions',
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }

                                  return Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(15),
                                      border: Border.all(color: Colors.grey),
                                    ),
                                    child: Column(
                                      children: [
                                        for (int i = 0;
                                            i < recentTransactions.length;
                                            i++) ...[
                                          TransactionCard(
                                            transaction: recentTransactions[i],
                                          ),
                                          if (i < recentTransactions.length - 1)
                                            const Divider(height: 2),
                                        ],
                                      ],
                                    ),
                                  );
                                }

                                return Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(15),
                                    border: Border.all(color: Colors.grey),
                                  ),
                                  padding: const EdgeInsets.all(40),
                                  child: Center(
                                    child: Text(
                                      'No transactions available',
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ]),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }




  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            size: 60,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 15),
          Text(
            'No accounts found',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}

