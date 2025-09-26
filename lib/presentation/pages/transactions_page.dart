import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/network/api_client.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/entities/transaction_enums.dart';
import '../bloc/account/account_bloc.dart';
import '../bloc/transaction/transaction_bloc.dart';
import '../bloc/transaction/transaction_state.dart';
import '../widgets/transaction_card.dart';
import 'transaction_detail_page.dart';

class TransactionsPage extends StatefulWidget {

  const TransactionsPage({super.key});

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  String _selectedFilter = 'All';
  DateTimeRange? _selectedDateRange;
  String _dateRangeText = 'Recent';

  @override
  void initState() {
    super.initState();
    // Transactions are now loaded by the main screen's TransactionBloc
    // No need to load them here since we have a separate bloc instance
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Transactions',
        ),
      ),
      body: Column(
        children: [
          // Filter Section
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _dateRangeText,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        final DateTimeRange? result = await showDateRangePicker(
                          context: context,
                          firstDate: DateTime.now()
                              .subtract(const Duration(days: 365)),
                          lastDate: DateTime.now(),
                          currentDate: DateTime.now(),
                          saveText: 'APPLY',
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: const ColorScheme.light(
                                  primary: AppColors.primary,
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );

                        if (result != null) {
                          setState(() {
                            _selectedDateRange = result;
                            final days =
                                result.end.difference(result.start).inDays;
                            if (days == 0) {
                              _dateRangeText = 'Today';
                            } else if (days <= 7) {
                              _dateRangeText = 'Last ${days + 1} days';
                            } else if (days <= 30) {
                              _dateRangeText = 'Last month';
                            } else {
                              _dateRangeText =
                                  '${result.start.day}/${result.start.month} - ${result.end.day}/${result.end.month}';
                            }
                          });
                        }
                      },
                      child: Text(
                        _selectedDateRange == null
                            ? 'Select Time Range'
                            : 'Change',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize:MainAxisSize.max ,
                  spacing: 10.0,
                  children: [
                    Expanded(child: _buildFilterChip('All', _selectedFilter == 'All')),
                    _buildFilterChip('Income', _selectedFilter == 'Income',
                        Icons.arrow_circle_down_outlined, Colors.green),
                    _buildFilterChip('Expense', _selectedFilter == 'Expense',
                        Icons.arrow_circle_up_outlined, Colors.red),
                  ],
                ),
              ],
            ),
          ),

          // Transactions List
          Expanded(
            child: BlocBuilder<TransactionBloc, TransactionState>(
              builder: (context, state) {
                if (state is TransactionLoading) {
                  return const Center(
                    child: SpinKitCircle(
                      color: Color(0xFF4A5568),
                      size: 50,
                    ),
                  );
                }

                if (state is TransactionError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.receipt_outlined,
                          size: 60,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Failed to load transactions',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (state is TransactionLoaded) {
                  if (state.transactions.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.receipt_outlined,
                            size: 60,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No transactions yet',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  // Filter transactions
                  List<Transaction> filteredTransactions = state.transactions;

                  // Apply date range filter
                  if (_selectedDateRange != null) {
                    filteredTransactions =
                        filteredTransactions.where((transaction) {
                      final transactionDate = DateTime(
                        transaction.timestamp.year,
                        transaction.timestamp.month,
                        transaction.timestamp.day,
                      );
                      final startDate = DateTime(
                        _selectedDateRange!.start.year,
                        _selectedDateRange!.start.month,
                        _selectedDateRange!.start.day,
                      );
                      final endDate = DateTime(
                        _selectedDateRange!.end.year,
                        _selectedDateRange!.end.month,
                        _selectedDateRange!.end.day,
                      );
                      return transactionDate.isAtSameMomentAs(startDate) ||
                          transactionDate.isAtSameMomentAs(endDate) ||
                          (transactionDate.isAfter(startDate) &&
                              transactionDate.isBefore(endDate));
                    }).toList();
                  }

                  // Apply type filter
                  if (_selectedFilter == 'Income') {
                    filteredTransactions = filteredTransactions
                        .where((t) => t.direction.isCredit)
                        .toList();
                  } else if (_selectedFilter == 'Expense') {
                    filteredTransactions = filteredTransactions
                        .where((t) => t.direction.isDebit)
                        .toList();
                  }

                  // Show empty state if no transactions match filters
                  if (filteredTransactions.isEmpty) {
                    String emptyMessage = 'No transactions found';
                    if (_selectedFilter == 'Income') {
                      emptyMessage = 'No income transactions found';
                    } else if (_selectedFilter == 'Expense') {
                      emptyMessage = 'No expense transactions found';
                    }
                    if (_selectedDateRange != null) {
                      emptyMessage += ' for selected date range';
                    }

                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.receipt_outlined,
                            size: 60,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            emptyMessage,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _selectedFilter = 'All';
                                _selectedDateRange = null;
                                _dateRangeText = 'Recent';
                              });
                            },
                            child: const Text('Clear Filters'),
                          ),
                        ],
                      ),
                    );
                  }

                  // Group transactions by date
                  Map<String, List<Transaction>> groupedTransactions = {};
                  for (var transaction in filteredTransactions) {
                    String dateKey = _getDateKey(transaction.timestamp);
                    if (!groupedTransactions.containsKey(dateKey)) {
                      groupedTransactions[dateKey] = [];
                    }
                    groupedTransactions[dateKey]!.add(transaction);
                  }

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (var entry in groupedTransactions.entries) ...[
                          _buildDateSection(
                            entry.key,
                            entry.value
                                .map((t) => TransactionCard(transaction: t))
                                .toList(),
                          ),
                          if (entry.key != groupedTransactions.keys.last)
                            const SizedBox(height: 20),
                        ],
                      ],
                    ),
                  );
                }

                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected,
      [IconData? icon, Color? iconColor]) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE8EAF6) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: iconColor ?? AppColors.primary,
              ),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.primary : Colors.grey[600],
                fontSize: 14,
                overflow: TextOverflow.ellipsis,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSection(String date, List<Widget> transactions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          date,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: Colors.grey,
              width: 1,
            ),
          ),
          child: Column(
            children: [
              for (int i = 0; i < transactions.length; i++) ...[
                transactions[i],
                if (i < transactions.length - 1)
                  Divider(
                    height: 1,
                    thickness: 0.6,
                    color: Colors.grey[600],
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  String _getDateKey(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final transactionDate = DateTime(date.year, date.month, date.day);
    final difference = today.difference(transactionDate);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

}


