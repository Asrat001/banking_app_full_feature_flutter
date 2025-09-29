import 'package:banking_app_challenge/presentation/widgets/app_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../core/network/api_client.dart';
import '../../data/datasources/account_remote_datasource.dart';
import '../../data/repositories/account_repository_impl.dart';
import '../../domain/entities/account.dart';
import '../bloc/account/account_bloc.dart';
import '../bloc/account/account_event.dart';
import '../bloc/account/account_state.dart';
import '../bloc/transaction/transaction_bloc.dart';
import '../bloc/transaction/transaction_event.dart';

class FundTransferPage extends StatefulWidget {
  final ApiClient apiClient;

  const FundTransferPage({
    super.key,
    required this.apiClient,
  });

  @override
  State<FundTransferPage> createState() => _FundTransferPageState();
}

class _FundTransferPageState extends State<FundTransferPage> {
  final _formKey = GlobalKey<FormState>();
  final _toAccountController = TextEditingController();
  final _amountController = TextEditingController();



  List<Account> _accounts = [];
  Account? _selectedFromAccount;
  String? _selectedRecipient;
  String _selectedPurpose = 'Education';
  bool _isLoading = false;
  int _currentAccountIndex = 0;
  final PageController _pageController = PageController();

  // Mock recipients data with account numbers
  final List<Map<String, String>> _recentRecipients = [
    {'name': 'Aliya', 'image': '👤', 'accountNumber': '1089514452'},
    {'name': 'Calira', 'image': '👤', 'accountNumber': '2345678901'},
    {'name': 'Bob', 'image': '👤', 'accountNumber': '3456789012'},
    {'name': 'Samy', 'image': '👤', 'accountNumber': '4567890123'},
    {'name': 'Sara', 'image': '👤', 'accountNumber': '5678901234'},
  ];

  final List<String> _purposes = [
    'Education',
    'Healthcare',
    'Shopping',
    'Bills',
    'Entertainment',
    'Travel',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _loadAccounts();
    _amountController.text = '0.00';
  }
//todo: handle pagination if user has many accounts
// todo:refactor to use account bloc to load accounts instead of direct repository call
  Future<void> _loadAccounts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final repository = AccountRepositoryImpl(
        remoteDataSource: AccountRemoteDataSourceImpl(
          apiClient: widget.apiClient,
        ),
      );

      final result = await repository.getAccounts(page: 0, size: 100);

      result.fold(
        (failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to load accounts: ${failure.message}'),
              backgroundColor: Colors.red,
            ),
          );
        },
        (accounts) {
          setState(() {
            _accounts = accounts;
            if (accounts.isNotEmpty) {
              _selectedFromAccount = accounts.first;
            }
          });
        },
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _toAccountController.dispose();
    _amountController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  //todo: refactor to use bloc event instead of direct repository call
  void _handleTransfer() {
    if (_formKey.currentState!.validate()) {
      if (_selectedFromAccount == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a source account'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      String toAccount = _toAccountController.text.trim();
      if (toAccount.isEmpty && _selectedRecipient != null) {
        // Get account number from selected recipient
        final recipient = _recentRecipients.firstWhere(
          (r) => r['name'] == _selectedRecipient,
        );
        toAccount = recipient['accountNumber']!;
      }

      if (toAccount.isEmpty && _selectedRecipient == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a recipient or add account number'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      context.read<AccountBloc>().add(
            TransferFunds(
              fromAccountNumber: _selectedFromAccount!.accountNumber,
              toAccountNumber: toAccount,
              amount: double.parse(_amountController.text.replaceAll(',', '')),
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Transfer',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocListener<AccountBloc, AccountState>(
        listener: (context, state) {
          if (state is TransferInProgress) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => Dialog(
                backgroundColor: Colors.transparent,
                elevation: 0,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: SpinKitCircle(
                      color: Color(0xFF4A5568),
                      size: 50,
                    ),
                  ),
                ),
              ),
            );
          } else if (state is TransferSuccess) {
            Navigator.pop(context); // Close loading dialog

            // Refresh accounts and transactions
            context.read<AccountBloc>().add(const LoadAccounts());
            if (_selectedFromAccount != null) {
              context.read<TransactionBloc>().add(
                    LoadTransactions(accountId: _selectedFromAccount!.id),
                  );
            }

            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                title: const Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green),
                    SizedBox(width: 8),
                    Text('Transfer Successful'),
                  ],
                ),
                content: const Text(
                    'Your funds have been transferred successfully.'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context); // Close success dialog
                      Navigator.pop(context); // Go back to dashboard
                    },
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          } else if (state is TransferFailure) {
            Navigator.pop(context); // Close loading dialog if open
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Transfer failed: ${state.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // From Section
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'From',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Account Cards
                            if (_isLoading)
                              Container(
                                height: 100,
                                alignment: Alignment.center,
                                child: const SpinKitThreeBounce(
                                  color: Color(0xFF4A5568),
                                  size: 30,
                                ),
                              )
                            else if (_accounts.isNotEmpty) ...[
                              SizedBox(
                                height: 100,
                                child: PageView.builder(
                                  controller: _pageController,
                                  onPageChanged: (index) {
                                    setState(() {
                                      _currentAccountIndex = index;
                                      _selectedFromAccount = _accounts[index];
                                    });
                                  },
                                  itemCount: _accounts.length,
                                  itemBuilder: (context, index) {
                                    final account = _accounts[index];
                                    return Container(
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 4),
                                      padding: const EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            const Color.fromARGB(
                                                    255, 59, 69, 118)
                                                .withValues(alpha: 0.8),
                                            const Color(0xFFA7B5E8)
                                                .withValues(alpha: 0.8),
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Text(
                                            'Account',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            account.accountNumber,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600,
                                              letterSpacing: 1,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 12),

                              // Page Indicators
                              if (_accounts.length > 1)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(
                                    _accounts.length,
                                    (index) => Container(
                                      width: 8,
                                      height: 8,
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 4),
                                      decoration: BoxDecoration(
                                        color: _currentAccountIndex == index
                                            ? const Color(0xFF4A5568)
                                            : const Color(0xFFD0D0D0),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                                ),
                            ],

                            const SizedBox(height: 30),

                            // To Section
                            const Text(
                              'To',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],
                        ),
                      ),

                      // Recipients
                      SizedBox(
                        height: 90,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.only(left: 20),
                          children: [
                            // Add New Recipient
                            GestureDetector(
                              onTap: () {
                                // Show modal bottom sheet to add new recipient
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(20),
                                    ),
                                  ),
                                  builder: (context) => Padding(
                                    padding: EdgeInsets.only(
                                      bottom: MediaQuery.of(context)
                                          .viewInsets
                                          .bottom,
                                      left: 20,
                                      right: 20,
                                      top: 20,
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            const Text(
                                              'Add Recipient',
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const Spacer(),
                                            IconButton(
                                              onPressed: () =>
                                                  Navigator.pop(context),
                                              icon: const Icon(Icons.close),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 20),
                                        AppTextField(
                                          controller: _toAccountController,
                                          keyboardType: TextInputType.number,
                                          textInputFormatter: [    FilteringTextInputFormatter
                                              .digitsOnly,],
                                          hint: 'Enter account number',
                                        ),
                                        const SizedBox(height: 20),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: OutlinedButton(
                                                onPressed: () =>
                                                    Navigator.pop(context),
                                                style: OutlinedButton.styleFrom(
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 12),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                ),
                                                child: const Text('Cancel'),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: ElevatedButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                  setState(() {
                                                    _selectedRecipient =
                                                        null; // Clear selected recipient when adding manual account
                                                  });
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      const Color(0xFF4A5568),
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 12),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                ),
                                                child: const Text(
                                                  'Add',
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 20),
                                      ],
                                    ),
                                  ),
                                );
                              },
                              child: Column(
                                children: [
                                  Container(
                                    width: 60,
                                    height: 60,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFE8ECFF),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.add,
                                      color: Color(0xFF4A5568),
                                      size: 28,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    '',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Recent Recipients
                            ..._recentRecipients.asMap().entries.map((entry) {
                              final index = entry.key;
                              final recipient = entry.value;
                              final isLast =
                                  index == _recentRecipients.length - 1;

                              return Padding(
                                padding: EdgeInsets.only(
                                  right: isLast
                                      ? 20
                                      : 16, // Add extra padding for last item
                                ),
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedRecipient = recipient['name'];
                                      _toAccountController.clear();
                                    });
                                  },
                                  child: Column(
                                    children: [
                                      Container(
                                        width: 60,
                                        height: 60,
                                        decoration: BoxDecoration(
                                          color: _selectedRecipient ==
                                                  recipient['name']
                                              ? const Color(0xFF4A5568)
                                                  .withValues(alpha: 0.2)
                                              : const Color(0xFFF5F5F5),
                                          shape: BoxShape.circle,
                                          border: _selectedRecipient ==
                                                  recipient['name']
                                              ? Border.all(
                                                  color:
                                                      const Color(0xFF4A5568),
                                                  width: 2)
                                              : null,
                                        ),
                                        child: Center(
                                          child: Text(
                                            recipient['image']!,
                                            style:
                                                const TextStyle(fontSize: 24),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        recipient['name']!,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: _selectedRecipient ==
                                                  recipient['name']
                                              ? const Color(0xFF4A5568)
                                              : Colors.black54,
                                          fontWeight: _selectedRecipient ==
                                                  recipient['name']
                                              ? FontWeight.w600
                                              : FontWeight.normal,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),

                      // Amount Section
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Amount',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),

                            const SizedBox(height: 12),
                            AppTextField(
                              controller: _amountController,
                              prefixText: "ETB",
                              hint: '0.00',
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              textInputFormatter: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'^\d+\.?\d{0,2}'),
                                ),
                              ],
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter an amount';
                                }
                                final amount = double.tryParse(value);
                                if (amount == null || amount <= 0) {
                                  return 'Please enter a valid amount';
                                }
                                if (_selectedFromAccount != null &&
                                    amount > _selectedFromAccount!.balance) {
                                  return 'Insufficient balance';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 30),

                            // Purpose Section
                            const Text(
                              'Purpose',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: Colors.grey.shade300,
                                    width: 1,
                                  ),
                                ),
                              ),
                              child: DropdownButton<String>(
                                value: _selectedPurpose,
                                isExpanded: true,
                                underline: const SizedBox(),
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                                icon: const Icon(Icons.keyboard_arrow_down),
                                items: _purposes.map((purpose) {
                                  return DropdownMenuItem<String>(
                                    value: purpose,
                                    child: Text(purpose),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedPurpose = value!;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Send Button
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _handleTransfer,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4A5568),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Send',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
