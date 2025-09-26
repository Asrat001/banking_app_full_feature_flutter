import 'package:banking_app_challenge/presentation/widgets/transaction_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/entities/account.dart';
import '../bloc/account/account_bloc.dart';
import '../bloc/account/account_event.dart';
import '../bloc/account/account_state.dart';
import '../bloc/transaction/transaction_bloc.dart';
import '../bloc/transaction/transaction_event.dart';
import '../bloc/transaction/transaction_state.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/entities/transaction_enums.dart';
import 'transaction_detail_page.dart';

class MyAccountsPage extends StatefulWidget {


  const MyAccountsPage({super.key});

  @override
  State<MyAccountsPage> createState() => _MyAccountsPageState();
}

class _MyAccountsPageState extends State<MyAccountsPage> {
  int _currentCardIndex = 0;
  final PageController _pageController = PageController();
  bool _showTransactions = false; // false for Settings, true for Transactions



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:const Text(
          'My Accounts'),
      ),
      body: SafeArea(
        child: Column(
          children: [

            // Main Content
            Expanded(
              child: BlocBuilder<AccountBloc, AccountState>(
                builder: (context, state) {
                  if (state is AccountLoading) {
                    return const Center(
                      child: SpinKitCircle(
                        color: Color(0xFF7B8CDE),
                        size: 50,
                      ),
                    );
                  }

                  if (state is AccountError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 60,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Failed to load accounts',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () {
                              context
                                  .read<AccountBloc>()
                                  .add(const LoadAccounts());
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state is AccountLoaded) {
                    final accounts = state.accounts;

                    if (accounts.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.account_balance_wallet_outlined,
                              size: 60,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
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

                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          // Account Cards with PageView
                          SizedBox(
                            height: 165,
                            child: PageView.builder(
                              controller: _pageController,
                              onPageChanged: (index) {
                                setState(() {
                                  _currentCardIndex = index;
                                });
                                // Load transactions for the selected account using account ID
                                context.read<TransactionBloc>().add(
                                      LoadTransactions(
                                        accountId: accounts[index].id,
                                      ),
                                    );
                              },
                              itemCount: accounts.length,
                              itemBuilder: (context, index) {
                                final account = accounts[index];
                                return _buildAccountCard(account);
                              },
                            ),
                          ),

                          // Card Dots Indicator
                          if (accounts.length > 1) ...[
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                accounts.length,
                                (index) => Container(
                                  width: 8,
                                  height: 8,
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 4),
                                  decoration: BoxDecoration(
                                    color: _currentCardIndex == index
                                        ? const Color(0xFF7B8CDE)
                                        : Colors.grey[300],
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ),
                          ],

                          const SizedBox(height: 30),

                          // Recent Payment Card
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.grey)
                                ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Make a Payment',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                "\$200",
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Due: Feb 10, 2022',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFF6B7280),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Action Buttons
                          Row(
                            children: [
                              Expanded(
                                child: _buildActionButton(
                                  'Settings',
                                  !_showTransactions,
                                  onTap: () {
                                    setState(() {
                                      _showTransactions = false;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildActionButton(
                                  'Transactions',
                                  _showTransactions,
                                  onTap: () {
                                    setState(() {
                                      _showTransactions = true;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // Toggle Content - Settings or Transactions
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: _showTransactions
                                ? _buildTransactionsView(
                                    accounts[_currentCardIndex])
                                : _buildSettingsView(),
                          ),
                          const SizedBox(height: 30),
                        ],
                      ),
                    );
                  }

                  // Default empty state
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Widget _buildAccountCard(Account account) {
    // Get last 4 digits of account number
    final String last4Digits = account.accountNumber.length >= 4
        ? account.accountNumber.substring(account.accountNumber.length - 4)
        : account.accountNumber;

    // Format account number as **** **** **** XXXX
    final String formattedNumber = '**** **** **** $last4Digits';

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: account.accountType == 'SAVINGS'
              ? [const Color(0xFF5A6D9E), const Color(0xFFBECAF5)]
              : [const Color(0xFFBECAF5), const Color(0xFF5A6D9E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
               SvgPicture.asset("assets/visa.svg",
                  height: 18,
                  width: 28,
                  fit: BoxFit.contain
               )
              ],
            ),
            const SizedBox(height: 10,),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    formattedNumber,
                    style:  const TextStyle(
                      color:Color(0xff31326F),
                      fontSize: 20,
                      letterSpacing: 2,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Available Balance',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        '\$ ${account.balance.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${DateTime.now().month.toString().padLeft(2, '0')}/${DateTime.now().year.toString().substring(2)}',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String label, bool isPrimary,
      {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: isPrimary ? const Color(0xFFEEF2FF) : Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: Colors.grey,
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isPrimary
                  ? const Color.fromARGB(255, 47, 55, 94)
                  : const Color(0xFF6B7280),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOptionItem(String icon, String title) {
    return InkWell(
      onTap: () {

      },
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Row(
          children: [
            Container(
              height: 40,
              width: 40,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey)),
              child: SvgPicture.asset(
                icon,
                height: 22,
                width: 22,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.grey[600],
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      height: 2,
      thickness: 0.6,
      color: Colors.grey,
    );
  }

  Widget _buildSettingsView() {
    return Container(
      key: const ValueKey('settings'),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey),
      ),
      child: Column(
        children: [
          _buildOptionItem("assets/doc_icon.svg", 'View Statement'),
          _buildDivider(),
          _buildOptionItem("assets/pin_icon.svg", 'Change Pin'),
          _buildDivider(),
          _buildOptionItem("assets/remove_icon.svg", 'Remove Card'),
        ],
      ),
    );
  }

  Widget _buildTransactionsView(Account account) {
    return Container(
      key: const ValueKey('transactions'),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey),
      ),
      child: BlocBuilder<TransactionBloc, TransactionState>(
        builder: (context, state) {
          // Loading state
          if (state is TransactionLoading) {
            return const Padding(
              padding: EdgeInsets.all(40),
              child: Center(
                child: SpinKitCircle(
                  color: Color(0xFF4A5568),
                  size: 40,
                ),
              ),
            );
          }

          // Error state
          if (state is TransactionError) {
            return Padding(
              padding: const EdgeInsets.all(40),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.receipt_outlined,
                      size: 40,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Failed to load transactions',
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

          // Loaded state
          if (state is TransactionLoaded) {
            if (state.transactions.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(40),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.receipt_outlined,
                        size: 40,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'No transactions yet',
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

            // Take first 5 transactions to display
            final displayTransactions = state.transactions.take(5).toList();

            // Scrollable list of transactions
            return ListView.separated(
              shrinkWrap: true, // Important if inside another scrollable
              physics: const NeverScrollableScrollPhysics(), // Avoid scroll conflict
              itemCount: displayTransactions.length,
              itemBuilder: (context, index) {
                return TransactionCard(transaction: displayTransactions[index]);
              },
              separatorBuilder: (_, __) => const Divider(height: 2),
            );
          }

          // Fallback for unexpected state
          return const Center(
            child: Text('Something went wrong'),
          );
        },
      ),
    );
  }

  Widget _buildCompactTransactionItem(Transaction transaction) {
    IconData icon;
    String title;

    switch (transaction.type) {
      case TransactionType.FUND_TRANSFER:
        icon = Icons.swap_horiz;
        title = 'Fund Transfer';
        break;
      case TransactionType.BILL_PAYMENT:
        icon = Icons.receipt_outlined;
        title = 'Bill Payment';
        break;
      case TransactionType.ATM_WITHDRAWAL:
        icon = Icons.atm;
        title = 'ATM Withdrawal';
        break;
      case TransactionType.TELLER_DEPOSIT:
        icon = Icons.account_balance;
        title = 'Deposit';
        break;
      case TransactionType.PURCHASE:
        icon = Icons.shopping_cart_outlined;
        title = 'Purchase';
        break;
      case TransactionType.INTEREST_EARNED:
        icon = Icons.trending_up;
        title = 'Interest';
        break;
      default:
        icon = Icons.receipt_outlined;
        title = transaction.type.displayName;
    }

    if (transaction.description.isNotEmpty) {
      title = transaction.description;
    }

    final isDebit = transaction.direction.isDebit;
    final amountPrefix = isDebit ? '-' : '+';
    final amount = '$amountPrefix ETB ${transaction.amount.toStringAsFixed(2)}';

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MultiBlocProvider(
              providers: [
                BlocProvider.value(
                  value: context.read<AccountBloc>(),
                ),
              ],
              child: TransactionDetailPage(transaction: transaction),
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFF0F0F5)),
              ),
              child: Icon(
                icon,
                color: Colors.grey,
                size: 20,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF2D3748),
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                  if (transaction.relatedAccount != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      'To: ${transaction.relatedAccount}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Text(
              amount,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3748),
                // isDebit ? Colors.red : Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
