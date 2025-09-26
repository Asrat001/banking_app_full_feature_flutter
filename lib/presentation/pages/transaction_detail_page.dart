import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/entities/transaction_enums.dart';
import '../../domain/entities/account.dart';
import '../bloc/account/account_bloc.dart';
import '../bloc/account/account_state.dart';

class TransactionDetailPage extends StatelessWidget {
  final Transaction transaction;

  const TransactionDetailPage({
    super.key,
    required this.transaction,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Transaction Details',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Transaction Status Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: transaction.direction.isDebit
                      ? [AppColors.primary, AppColors.primaryDark]
                      : [AppColors.success, const Color(0xFF059669)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Icon(
                    _getTransactionIcon(),
                    color: Colors.white,
                    size: 50,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    transaction.direction.isDebit ? 'Sent' : 'Received',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${transaction.direction.isDebit ? '-' : '+'}ETB ${transaction.amount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Completed',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Transaction Information
            const Text(
              'Transaction Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),

            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  _buildDetailRow(
                      'Transaction Type', _getTransactionTypeName()),
                  _buildDivider(),
                  if (transaction.description.isNotEmpty) ...[
                    _buildDetailRow('Description', transaction.description),
                    _buildDivider(),
                  ],
                  if (transaction.relatedAccount != null) ...[
                    _buildDetailRow('To Account', transaction.relatedAccount!),
                    _buildDivider(),
                  ],
                  _buildDetailRow(
                      'Date & Time', _formatDateTime(transaction.timestamp)),
                  _buildDivider(),
                  _buildDetailRow('Transaction ID', transaction.id.toString()),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Payment Account Information
            const Text(
              'Payment Account',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),

            BlocBuilder<AccountBloc, AccountState>(
              builder: (context, state) {
                if (state is AccountLoaded) {
                  // Find the account used for this transaction
                  final account = state.accounts.firstWhere(
                    (acc) => acc.id == transaction.accountId,
                    orElse: () => const Account(
                      id: 0,
                      accountNumber: 'Unknown',
                      accountType: 'Unknown',
                      balance: 0.0,
                      userId: 0,
                    ),
                  );

                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      children: [
                        _buildAccountRow(account),
                        _buildDivider(),
                        _buildDetailRow('Available Balance',
                            'ETB ${account.balance.toStringAsFixed(2)}'),
                      ],
                    ),
                  );
                }
                return Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: const Text('Account information not available'),
                );
              },
            ),

            const SizedBox(height: 30),

            // Receipt Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Receipt download coming soon')),
                  );
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.download, color: AppColors.primary),
                    SizedBox(width: 8),
                    Text(
                      'Download Receipt',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getTransactionIcon() {
    switch (transaction.type) {
      case TransactionType.FUND_TRANSFER:
        return Icons.swap_horiz_outlined;
      case TransactionType.BILL_PAYMENT:
        return Icons.receipt_outlined;
      case TransactionType.ATM_WITHDRAWAL:
        return Icons.atm_outlined;
      case TransactionType.TELLER_DEPOSIT:
        return Icons.account_balance_outlined;
      case TransactionType.PURCHASE:
        return Icons.shopping_cart_outlined;
      case TransactionType.INTEREST_EARNED:
        return Icons.trending_up_outlined;
      default:
        return Icons.receipt_outlined;
    }
  }

  String _getTransactionTypeName() {
    switch (transaction.type) {
      case TransactionType.FUND_TRANSFER:
        return 'Fund Transfer';
      case TransactionType.BILL_PAYMENT:
        return 'Bill Payment';
      case TransactionType.ATM_WITHDRAWAL:
        return 'ATM Withdrawal';
      case TransactionType.TELLER_DEPOSIT:
        return 'Bank Deposit';
      case TransactionType.PURCHASE:
        return 'Purchase';
      case TransactionType.INTEREST_EARNED:
        return 'Interest Earned';
      default:
        return transaction.type.displayName;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];

    final day = dateTime.day.toString().padLeft(2, '0');
    final month = months[dateTime.month - 1];
    final year = dateTime.year;
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');

    return '$day $month $year at $hour:$minute';
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountRow(Account account) {
    final accountNumber = account.accountNumber.length >= 4
        ? '**** **** **** ${account.accountNumber.substring(account.accountNumber.length - 4)}'
        : account.accountNumber;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey),
            ),
            child: Icon(
              account.accountType.toLowerCase() == 'savings'
                  ? Icons.savings_outlined
                  : Icons.account_balance_wallet_outlined,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  account.accountType,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  accountNumber,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: Colors.grey[200],
    );
  }
}
