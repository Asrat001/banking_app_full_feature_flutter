// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_spinkit/flutter_spinkit.dart';
// import '../../core/network/api_client.dart';
// import '../../core/theme/app_colors.dart';
// import '../../domain/entities/account.dart';
// import '../bloc/account/account_bloc.dart';
// import '../bloc/account/account_event.dart';
// import '../bloc/account/account_state.dart';
// import '../bloc/transaction/transaction_bloc.dart';
// import '../bloc/transaction/transaction_event.dart';
// import '../bloc/transaction/transaction_state.dart';
// import '../../domain/entities/transaction.dart';
// import '../../domain/entities/transaction_enums.dart';

// class MyAccountsPage extends StatefulWidget {
//   final ApiClient apiClient;

//   const MyAccountsPage({super.key, required this.apiClient});

//   @override
//   State<MyAccountsPage> createState() => _MyAccountsPageState();
// }

// class _MyAccountsPageState extends State<MyAccountsPage> {
//   int _currentCardIndex = 0;
//   final PageController _pageController = PageController();
//   bool _showTransactions = false; // false for Settings, true for Transactions

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       // backgroundColor: const Color(0xFFF8F9FA),
//       body: SafeArea(
//         child: Column(
//           children: [
//             // Custom App Bar
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
//               color: Colors.white,
//               child: const Text(
//                 'My Accounts',
//                 style: TextStyle(
//                   color: AppColors.textPrimary,
//                   fontSize: 22,
//                   fontWeight: FontWeight.w600,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//             ),
//             // Main Content
//             Expanded(
//               child: BlocBuilder<AccountBloc, AccountState>(
//                 builder: (context, state) {
//                   if (state is AccountLoading) {
//                     return const Center(
//                       child: SpinKitCircle(
//                         color: Color(0xFF7B8CDE),
//                         size: 50,
//                       ),
//                     );
//                   }

//                   if (state is AccountError) {
//                     return Center(
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Icon(
//                             Icons.error_outline,
//                             size: 60,
//                             color: Colors.grey[400],
//                           ),
//                           const SizedBox(height: 16),
//                           Text(
//                             'Failed to load accounts',
//                             style: TextStyle(
//                               fontSize: 16,
//                               color: Colors.grey[600],
//                             ),
//                           ),
//                           const SizedBox(height: 8),
//                           ElevatedButton(
//                             onPressed: () {
//                               context
//                                   .read<AccountBloc>()
//                                   .add(const LoadAccounts());
//                             },
//                             child: const Text('Retry'),
//                           ),
//                         ],
//                       ),
//                     );
//                   }

//                   if (state is AccountLoaded) {
//                     final accounts = state.accounts;

//                     if (accounts.isEmpty) {
//                       return Center(
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Icon(
//                               Icons.account_balance_wallet_outlined,
//                               size: 60,
//                               color: Colors.grey[400],
//                             ),
//                             const SizedBox(height: 16),
//                             Text(
//                               'No accounts found',
//                               style: TextStyle(
//                                 fontSize: 16,
//                                 color: Colors.grey[600],
//                               ),
//                             ),
//                           ],
//                         ),
//                       );
//                     }

//                     return SingleChildScrollView(
//                       padding: const EdgeInsets.all(20),
//                       child: Column(
//                         children: [
//                           // Account Cards with PageView
//                           SizedBox(
//                             height: 200,
//                             child: PageView.builder(
//                               controller: _pageController,
//                               onPageChanged: (index) {
//                                 setState(() {
//                                   _currentCardIndex = index;
//                                 });
//                                 // Load transactions for the selected account using account ID
//                                 context.read<TransactionBloc>().add(
//                                       LoadTransactions(
//                                         accountId: accounts[index].id,
//                                       ),
//                                     );
//                               },
//                               itemCount: accounts.length,
//                               itemBuilder: (context, index) {
//                                 final account = accounts[index];
//                                 return _buildAccountCard(account);
//                               },
//                             ),
//                           ),

//                           // Card Dots Indicator
//                           if (accounts.length > 1) ...[
//                             const SizedBox(height: 20),
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: List.generate(
//                                 accounts.length,
//                                 (index) => Container(
//                                   width: 8,
//                                   height: 8,
//                                   margin:
//                                       const EdgeInsets.symmetric(horizontal: 4),
//                                   decoration: BoxDecoration(
//                                     color: _currentCardIndex == index
//                                         ? const Color(0xFF7B8CDE)
//                                         : Colors.grey[300],
//                                     shape: BoxShape.circle,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ],

//                           const SizedBox(height: 30),

//                           // Recent Payment Card
//                           Container(
//                             padding: const EdgeInsets.all(20),
//                             decoration: BoxDecoration(
//                                 color: Colors.white,
//                                 borderRadius: BorderRadius.circular(16),
//                                 border: Border.all(color: Colors.grey)
//                                 // boxShadow: [
//                                 //   BoxShadow(
//                                 //     color: Colors.black.withValues(alpha: 0.04),
//                                 //     blurRadius: 10,
//                                 //     offset: const Offset(0, 2),
//                                 //   ),
//                                 // ],
//                                 ),
//                             child: const Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 Text(
//                                   'Make a Payment',
//                                   style: TextStyle(
//                                     fontSize: 16,
//                                     fontWeight: FontWeight.w600,
//                                     color: AppColors.textPrimary,
//                                   ),
//                                 ),
//                                 Column(
//                                   crossAxisAlignment: CrossAxisAlignment.end,
//                                   children: [
//                                     Text(
//                                       'ETB220',
//                                       style: TextStyle(
//                                         fontSize: 20,
//                                         fontWeight: FontWeight.bold,
//                                         color: AppColors.textPrimary,
//                                       ),
//                                     ),
//                                     SizedBox(height: 4),
//                                     Text(
//                                       'Due: Feb 10, 2022',
//                                       style: TextStyle(
//                                         fontSize: 13,
//                                         color: Color(0xFF6B7280),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ],
//                             ),
//                           ),

//                           const SizedBox(height: 20),

//                           // Action Buttons
//                           Row(
//                             children: [
//                               Expanded(
//                                 child: _buildActionButton(
//                                   'Settings',
//                                   !_showTransactions,
//                                   onTap: () {
//                                     setState(() {
//                                       _showTransactions = false;
//                                     });
//                                   },
//                                 ),
//                               ),
//                               const SizedBox(width: 12),
//                               Expanded(
//                                 child: _buildActionButton(
//                                   'Transactions',
//                                   _showTransactions,
//                                   onTap: () {
//                                     setState(() {
//                                       _showTransactions = true;
//                                     });
//                                   },
//                                 ),
//                               ),
//                             ],
//                           ),

//                           const SizedBox(height: 20),

//                           // Toggle Content - Settings or Transactions
//                           AnimatedSwitcher(
//                             duration: const Duration(milliseconds: 300),
//                             child: _showTransactions
//                                 ? _buildTransactionsView(
//                                     accounts[_currentCardIndex])
//                                 : _buildSettingsView(),
//                           ),
//                           const SizedBox(height: 30),
//                         ],
//                       ),
//                     );
//                   }

//                   // Default empty state
//                   return const SizedBox.shrink();
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _pageController.dispose();
//     super.dispose();
//   }

//   Widget _buildAccountCard(Account account) {
//     // Get last 4 digits of account number
//     final String last4Digits = account.accountNumber.length >= 4
//         ? account.accountNumber.substring(account.accountNumber.length - 4)
//         : account.accountNumber;

//     // Format account number as **** **** **** XXXX
//     final String formattedNumber = '**** **** **** $last4Digits';

//     // Determine card type based on account type
//     final String cardType =
//         account.accountType == 'SAVINGS' ? 'SAVINGS' : 'CHECKING';

//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 8),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: account.accountType == 'SAVINGS'
//               ? [const Color(0xFF4A5568), const Color(0xFF7B8CDE)]
//               : [const Color(0xFF2D3748), const Color(0xFF4A5568)],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: const Color(0xFF7B8CDE).withValues(alpha: 0.3),
//             blurRadius: 20,
//             offset: const Offset(0, 10),
//           ),
//         ],
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(24),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             const Row(
//               mainAxisAlignment: MainAxisAlignment.end,
//               children: [
//                 // Text(
//                 //   cardType,
//                 //   style: TextStyle(
//                 //     color: Colors.white.withValues(alpha: 0.9),
//                 //     fontSize: 12,
//                 //     fontWeight: FontWeight.w500,
//                 //     letterSpacing: 1,
//                 //   ),
//                 // ),
//                 Text(
//                   'VISA',
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 24,
//                     fontWeight: FontWeight.bold,
//                     letterSpacing: 1,
//                   ),
//                 ),
//               ],
//             ),
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   formattedNumber,
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 20,
//                     letterSpacing: 2,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'Available Balance',
//                           style: TextStyle(
//                             color: Colors.white.withValues(alpha: 0.8),
//                             fontSize: 12,
//                           ),
//                         ),
//                         const SizedBox(height: 4),
//                         Text(
//                           'ETB ${account.balance.toStringAsFixed(2)}',
//                           style: const TextStyle(
//                             color: Colors.white,
//                             fontSize: 22,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ],
//                     ),
//                     Text(
//                       '${DateTime.now().month.toString().padLeft(2, '0')}/${DateTime.now().year.toString().substring(2)}',
//                       style: TextStyle(
//                         color: Colors.white.withValues(alpha: 0.9),
//                         fontSize: 14,
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildActionButton(String label, bool isPrimary,
//       {VoidCallback? onTap}) {
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(30),
//       child: Container(
//         height: 48,
//         decoration: BoxDecoration(
//           color: isPrimary ? const Color(0xFFEEF2FF) : Colors.white,
//           borderRadius: BorderRadius.circular(30),
//           border: Border.all(
//             color: Colors.grey,
//             width: 1,
//           ),
//         ),
//         child: Center(
//           child: Text(
//             label,
//             style: TextStyle(
//               color: isPrimary
//                   ? const Color.fromARGB(255, 47, 55, 94)
//                   : const Color(0xFF6B7280),
//               fontSize: 14,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildOptionItem(IconData icon, String title) {
//     return InkWell(
//       onTap: () {},
//       borderRadius: BorderRadius.circular(12),
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
//         child: Row(
//           children: [
//             Container(
//               padding: const EdgeInsets.all(10),
//               decoration: const BoxDecoration(
//                   color: Color(0xFFF3F4F6), shape: BoxShape.circle),
//               child: Icon(
//                 icon,
//                 color: const Color(0xFF6B7280),
//                 size: 22,
//               ),
//             ),
//             const SizedBox(width: 16),
//             Expanded(
//               child: Text(
//                 title,
//                 style: const TextStyle(
//                   fontSize: 15,
//                   fontWeight: FontWeight.w500,
//                   color: AppColors.textPrimary,
//                 ),
//               ),
//             ),
//             Icon(
//               Icons.chevron_right,
//               color: Colors.grey[400],
//               size: 22,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildDivider() {
//     return const Divider(
//       height: 2,
//       thickness: 0.5,
//       color: Color(0xFFE5E7EB),
//       // indent: 72,
//       // endIndent: 20,
//     );
//   }

//   void _showTransactionsBottomSheet(BuildContext context, Account account) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (context) => Container(
//         height: MediaQuery.of(context).size.height * 0.75,
//         decoration: const BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.only(
//             topLeft: Radius.circular(20),
//             topRight: Radius.circular(20),
//           ),
//         ),
//         child: Column(
//           children: [
//             // Handle bar
//             Container(
//               margin: const EdgeInsets.only(top: 10),
//               width: 40,
//               height: 4,
//               decoration: BoxDecoration(
//                 color: Colors.grey[300],
//                 borderRadius: BorderRadius.circular(2),
//               ),
//             ),
//             // Header
//             Padding(
//               padding: const EdgeInsets.all(20),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Text(
//                         'Transaction History',
//                         style: TextStyle(
//                           fontSize: 20,
//                           fontWeight: FontWeight.bold,
//                           color: Color(0xFF2D3748),
//                         ),
//                       ),
//                       Text(
//                         account.accountType,
//                         style: TextStyle(
//                           fontSize: 14,
//                           color: Colors.grey[600],
//                         ),
//                       ),
//                     ],
//                   ),
//                   IconButton(
//                     icon: const Icon(Icons.close),
//                     onPressed: () => Navigator.pop(context),
//                   ),
//                 ],
//               ),
//             ),
//             const Divider(height: 1),
//             // Transactions list
//             Expanded(
//               child: BlocBuilder<TransactionBloc, TransactionState>(
//                 builder: (context, state) {
//                   if (state is TransactionLoading) {
//                     return const Center(
//                       child: SpinKitCircle(
//                         color: Color(0xFF4A5568),
//                         size: 40,
//                       ),
//                     );
//                   }

//                   if (state is TransactionError) {
//                     return Center(
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Icon(
//                             Icons.receipt_outlined,
//                             size: 60,
//                             color: Colors.grey[400],
//                           ),
//                           const SizedBox(height: 10),
//                           Text(
//                             'No transactions available',
//                             style: TextStyle(
//                               color: Colors.grey[600],
//                               fontSize: 16,
//                             ),
//                           ),
//                         ],
//                       ),
//                     );
//                   }

//                   if (state is TransactionLoaded) {
//                     if (state.transactions.isEmpty) {
//                       return Center(
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Icon(
//                               Icons.receipt_outlined,
//                               size: 60,
//                               color: Colors.grey[400],
//                             ),
//                             const SizedBox(height: 10),
//                             Text(
//                               'No transactions yet',
//                               style: TextStyle(
//                                 color: Colors.grey[600],
//                                 fontSize: 16,
//                               ),
//                             ),
//                           ],
//                         ),
//                       );
//                     }

//                     return ListView.separated(
//                       padding: const EdgeInsets.all(20),
//                       itemCount: state.transactions.length,
//                       separatorBuilder: (context, index) => const Divider(),
//                       itemBuilder: (context, index) {
//                         final transaction = state.transactions[index];
//                         return _buildTransactionItem(transaction);
//                       },
//                     );
//                   }

//                   return const SizedBox();
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildTransactionItem(Transaction transaction) {
//     IconData icon;
//     String title;

//     switch (transaction.type) {
//       case TransactionType.FUND_TRANSFER:
//         icon = Icons.swap_horiz;
//         title = 'Fund Transfer';
//         break;
//       case TransactionType.BILL_PAYMENT:
//         icon = Icons.receipt_outlined;
//         title = 'Bill Payment';
//         break;
//       case TransactionType.ATM_WITHDRAWAL:
//         icon = Icons.atm;
//         title = 'ATM Withdrawal';
//         break;
//       case TransactionType.TELLER_DEPOSIT:
//         icon = Icons.account_balance;
//         title = 'Deposit';
//         break;
//       case TransactionType.PURCHASE:
//         icon = Icons.shopping_cart_outlined;
//         title = 'Purchase';
//         break;
//       case TransactionType.INTEREST_EARNED:
//         icon = Icons.trending_up;
//         title = 'Interest';
//         break;
//       default:
//         icon = Icons.receipt_outlined;
//         title = transaction.type.displayName;
//     }

//     if (transaction.description.isNotEmpty) {
//       title = transaction.description;
//     }

//     final isDebit = transaction.direction.isDebit;
//     final amountPrefix = isDebit ? '-' : '+';
//     final amount = '$amountPrefix ETB ${transaction.amount.toStringAsFixed(2)}';

//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8),
//       child: Row(
//         children: [
//           Container(
//             width: 45,
//             height: 45,
//             decoration: const BoxDecoration(
//               color: Color(0xFFF3F4F6),
//               shape: BoxShape.circle,
//             ),
//             child: Icon(
//               icon,
//               color: const Color(0xFF6B7280),
//               size: 22,
//             ),
//           ),
//           const SizedBox(width: 15),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   title,
//                   style: const TextStyle(
//                     fontSize: 15,
//                     fontWeight: FontWeight.w500,
//                     color: Color(0xFF2D3748),
//                   ),
//                 ),
//                 if (transaction.relatedAccount != null) ...[
//                   const SizedBox(height: 2),
//                   Text(
//                     'To: ${transaction.relatedAccount}',
//                     style: TextStyle(
//                       fontSize: 12,
//                       color: Colors.grey[600],
//                     ),
//                   ),
//                 ],
//                 Text(
//                   _formatDate(transaction.timestamp),
//                   style: TextStyle(
//                     fontSize: 12,
//                     color: Colors.grey[500],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Text(
//             amount,
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.bold,
//               color: isDebit ? Colors.red : Colors.green,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   String _formatDate(DateTime date) {
//     final now = DateTime.now();
//     final difference = now.difference(date);

//     if (difference.inDays == 0) {
//       return 'Today';
//     } else if (difference.inDays == 1) {
//       return 'Yesterday';
//     } else if (difference.inDays < 7) {
//       return '${difference.inDays} days ago';
//     } else {
//       return '${date.day}/${date.month}/${date.year}';
//     }
//   }
// }
