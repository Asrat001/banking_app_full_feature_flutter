import 'package:banking_app_challenge/presentation/widgets/app_lable.dart';
import 'package:banking_app_challenge/presentation/widgets/app_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../core/network/api_client.dart';
import '../../core/constants/api_constants.dart';
import '../../data/datasources/account_remote_datasource.dart';
import '../../data/repositories/account_repository_impl.dart';
import '../../domain/entities/account.dart';
import '../widgets/bill_payment_app_bar.dart';

class BillPaymentPage extends StatefulWidget {
  final ApiClient apiClient;

  const BillPaymentPage({
    super.key,
    required this.apiClient,
  });

  @override
  State<BillPaymentPage> createState() => _BillPaymentPageState();
}

class _BillPaymentPageState extends State<BillPaymentPage> {
  final _formKey = GlobalKey<FormState>();
  final _accountController = TextEditingController();
  final _amountController = TextEditingController();

  String? _selectedBiller;
  List<Account> _accounts = [];
  Account? _selectedAccount;
  bool _isLoading = false;

  // Predefined billers
  final List<Map<String, dynamic>> _billers = [
    {
      'name': 'Electricity Company',
      'icon': Icons.electric_bolt,
      'color': Colors.orange
    },
    {'name': 'Water Company', 'icon': Icons.water_drop, 'color': Colors.blue},
    {'name': 'Internet Provider', 'icon': Icons.wifi, 'color': Colors.green},
    {
      'name': 'Gas Company',
      'icon': Icons.local_fire_department,
      'color': Colors.red
    },
    {'name': 'Telephone Company', 'icon': Icons.phone, 'color': Colors.green},
    {'name': 'Cable TV', 'icon': Icons.tv, 'color': Colors.teal},
  ];

  @override
  void initState() {
    super.initState();
    _loadAccounts();
  }

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
              _selectedAccount = accounts.first;
              _accountController.text = accounts.first.accountNumber;
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
    _accountController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _handlePayment() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedAccount == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select an account'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (_selectedBiller == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a biller'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          contentPadding: EdgeInsets.all(20),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SpinKitCircle(
                color: Color(0xFF4A5568),
                size: 50,
              ),
              SizedBox(height: 16),
              Text(
                'Processing payment...',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );

      try {
        final response = await widget.apiClient.post(
          ApiConstants.billPaymentEndpoint,
          data: {
            'accountNumber': _selectedAccount!.accountNumber,
            'biller': _selectedBiller,
            'amount': double.parse(_amountController.text),
          },
        ).timeout(const Duration(seconds: 10));


        // Close loading dialog
        if (mounted) Navigator.pop(context);

        // Show success dialog
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green),
                  SizedBox(width: 8),
                  Text('Payment Successful'),
                ],
              ),
              content: Text(
                  'Your payment of ETB ${_amountController.text} to $_selectedBiller has been processed successfully.',),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Close success dialog
                    Navigator.pop(context); // Go back to previous page
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      } catch (e) {
        // Close loading dialog if open
        if (mounted) Navigator.pop(context);
        String errorMessage = 'Payment failed: Unknown error';
        if (e.toString().contains('TimeoutException')) {
          errorMessage = 'Payment failed: Request timed out. Please try again.';
        } else if (e.toString().contains('404')) {
          errorMessage =
              'Payment failed: Bill payment service is not available.';
        } else {
          errorMessage = 'Payment failed: ${e.toString()}';
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BillPaymentAppBar(
        title: 'Bill Payment',
        subtitle: 'Pay your bills quickly and securely',
      ),
      body: Column(
        children: [
          // White container with form - overlapping the header
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
                    left: 20,
                    top: 40,
                    right: 20,
                    bottom: 20,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Biller Selection
                        const Text(
                          'Select Biller',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2D3748),
                          ),
                        ),
                        // const SizedBox(height: 10),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            childAspectRatio: 1.3,
                            crossAxisSpacing: 15,
                            mainAxisSpacing: 15,
                          ),
                          itemCount: _billers.length,
                          itemBuilder: (context, index) {
                            final biller = _billers[index];
                            final isSelected =
                                _selectedBiller == biller['name'];
                            return InkWell(
                              onTap: () {
                                setState(() {
                                  _selectedBiller = biller['name'];
                                });
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xFFE8EAF6)
                                      : Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected
                                        ? const Color(0xFF4A5568)
                                        : Colors.transparent,
                                    width: 2,
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      biller['icon'],
                                      color: isSelected
                                          ? const Color(0xFF4A5568)
                                          : biller['color'],
                                      size: 30,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      biller['name'],
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: isSelected
                                            ? const Color(0xFF4A5568)
                                            : Colors.grey.shade700,
                                        fontWeight: isSelected
                                            ? FontWeight.w600
                                            : FontWeight.normal,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 10),

                        // Account Selection
                        const AppLabel(
                          'From Account',
                          align: TextAlign.start,
                        ),
                        const SizedBox(height: 10),
                        _isLoading
                            ? const LinearProgressIndicator()
                            : Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: const Color(0xFFE5E7EB)),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: DropdownButtonFormField<Account>(
                                  value: _selectedAccount,
                                  isExpanded: true,
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 15,
                                      vertical: 12,
                                    ),
                                  ),
                                  items: _accounts.map((account) {
                                    return DropdownMenuItem<Account>(
                                      value: account,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              '${account.accountType} - ${account.accountNumber.substring(account.accountNumber.length - 4)}',
                                              style:
                                                  const TextStyle(fontSize: 14),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'ETB ${account.balance.toStringAsFixed(0)}',
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (Account? value) {
                                    setState(() {
                                      _selectedAccount = value;
                                      if (value != null) {
                                        _accountController.text =
                                            value.accountNumber;
                                      }
                                    });
                                  },
                                  validator: (value) {
                                    if (value == null) {
                                      return 'Please select an account';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                        const SizedBox(height: 25),

                        // Amount Field
                        const AppLabel(
                          "Amount",
                          align: TextAlign.start,
                        ),
                        const SizedBox(height: 10),
                        AppTextField(
                          controller: _amountController,
                          hint: "Enter amount",
                          keyboardType: const TextInputType.numberWithOptions(
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
                            if (amount < 0.01) {
                              return 'Minimum amount is 0.01';
                            }
                            if (_selectedAccount != null &&
                                amount > _selectedAccount!.balance) {
                              return 'Insufficient balance';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        // Available Balance Card
                        if (_selectedAccount != null)
                          Container(
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0F4F8),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Available Balance:',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF718096),
                                  ),
                                ),
                                Text(
                                  'ETB ${_selectedAccount!.balance.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2D3748),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 40),

                        // Pay Button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _handlePayment,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4A5568),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 2,
                            ),
                            child: const Text(
                              'Pay Bill',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
