// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_spinkit/flutter_spinkit.dart';
// import 'package:banking_app_challenge/core/network/api_client.dart';
// import 'package:banking_app_challenge/data/datasources/transaction_remote_datasource.dart';
// import 'package:banking_app_challenge/data/repositories/transaction_repository_impl.dart';
// import 'package:banking_app_challenge/domain/entities/account.dart';
// import 'package:banking_app_challenge/domain/entities/transaction.dart';
// import 'package:banking_app_challenge/domain/entities/transaction_enums.dart';
// import 'package:banking_app_challenge/presentation/bloc/transaction/transaction_bloc.dart';
// import 'package:banking_app_challenge/presentation/bloc/transaction/transaction_event.dart';
// import 'package:banking_app_challenge/presentation/bloc/transaction/transaction_state.dart';

// class TransactionHistoryPage extends StatefulWidget {
//   final Account account;
//   final ApiClient apiClient;

//   const TransactionHistoryPage({
//     super.key,
//     required this.account,
//     required this.apiClient,
//   });

//   @override
//   State<TransactionHistoryPage> createState() => _TransactionHistoryPageState();
// }

// class _TransactionHistoryPageState extends State<TransactionHistoryPage> {
//   final ScrollController _scrollController = ScrollController();

//   @override
//   void initState() {
//     super.initState();
//     _scrollController.addListener(_onScroll);
//   }

//   @override
//   void dispose() {
//     _scrollController.dispose();
//     super.dispose();
//   }

//   void _onScroll() {
//     if (_isBottom) {
//       context.read<TransactionBloc>().add(
//             LoadMoreTransactions(accountId: widget.account.id),
//           );
//     }
//   }

//   bool get _isBottom {
//     if (!_scrollController.hasClients) return false;
//     final maxScroll = _scrollController.position.maxScrollExtent;
//     final currentScroll = _scrollController.offset;
//     return currentScroll >= (maxScroll * 0.9);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (context) => TransactionBloc(
//         transactionRepository: TransactionRepositoryImpl(
//           remoteDataSource: TransactionRemoteDataSourceImpl(
//             apiClient: widget.apiClient,
//           ),
//         ),
//       )..add(LoadTransactions(accountId: widget.account.id)),
//       child: Scaffold(
//         appBar: AppBar(
//           title: const Text('Transaction History'),
//           backgroundColor: Colors.blue.shade700,
//           foregroundColor: Colors.white,
//           elevation: 0,
//         ),
//         body: Column(
//           children: [
//             // Account Info Card
//             Container(
//               width: double.infinity,
//               decoration: BoxDecoration(
//                 color: Colors.blue.shade700,
//                 borderRadius: const BorderRadius.only(
//                   bottomLeft: Radius.circular(30),
//                   bottomRight: Radius.circular(30),
//                 ),
//               ),
//               padding: const EdgeInsets.all(20),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 12,
//                       vertical: 6,
//                     ),
//                     decoration: BoxDecoration(
//                       color: Colors.white.withValues(alpha: 0.2),
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                     child: Text(
//                       widget.account.accountType.toUpperCase(),
//                       style: const TextStyle(
//                         color: Colors.white,
//                         fontSize: 12,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 12),
//                   Text(
//                     widget.account.accountNumber,
//                     style: const TextStyle(
//                       color: Colors.white70,
//                       fontSize: 14,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     'ETB${widget.account.balance.toStringAsFixed(2)}',
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 32,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const Text(
//                     'Current Balance',
//                     style: TextStyle(
//                       color: Colors.white70,
//                       fontSize: 14,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 20),

//             // Transaction List
//             Expanded(
//               child: BlocBuilder<TransactionBloc, TransactionState>(
//                 builder: (context, state) {
//                   if (state is TransactionLoading) {
//                     return const Center(
//                       child: SpinKitCircle(
//                         color: Colors.blue,
//                         size: 50,
//                       ),
//                     );
//                   }

//                   if (state is TransactionError) {
//                     return Center(
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           const Icon(
//                             Icons.error_outline,
//                             color: Colors.red,
//                             size: 60,
//                           ),
//                           const SizedBox(height: 16),
//                           Text(
//                             state.message,
//                             style: const TextStyle(fontSize: 16),
//                             textAlign: TextAlign.center,
//                           ),
//                           const SizedBox(height: 16),
//                           ElevatedButton(
//                             onPressed: () {
//                               context.read<TransactionBloc>().add(
//                                     LoadTransactions(
//                                       accountId: widget.account.id,
//                                     ),
//                                   );
//                             },
//                             child: const Text('Retry'),
//                           ),
//                         ],
//                       ),
//                     );
//                   }

//                   if (state is TransactionLoaded) {
//                     if (state.transactions.isEmpty) {
//                       return const Center(
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Icon(
//                               Icons.receipt_long_outlined,
//                               size: 80,
//                               color: Colors.grey,
//                             ),
//                             SizedBox(height: 16),
//                             Text(
//                               'No transactions yet',
//                               style: TextStyle(
//                                 fontSize: 18,
//                                 color: Colors.grey,
//                               ),
//                             ),
//                             SizedBox(height: 8),
//                             Text(
//                               'Your transaction history will appear here',
//                               style: TextStyle(
//                                 fontSize: 14,
//                                 color: Colors.grey,
//                               ),
//                             ),
//                           ],
//                         ),
//                       );
//                     }

//                     return RefreshIndicator(
//                       onRefresh: () async {
//                         context.read<TransactionBloc>().add(
//                               LoadTransactions(
//                                 accountId: widget.account.id,
//                               ),
//                             );
//                       },
//                       child: ListView.builder(
//                         controller: _scrollController,
//                         padding: const EdgeInsets.symmetric(horizontal: 20),
//                         itemCount: state.hasReachedEnd
//                             ? state.transactions.length
//                             : state.transactions.length + 1,
//                         itemBuilder: (context, index) {
//                           if (index >= state.transactions.length) {
//                             return const Padding(
//                               padding: EdgeInsets.symmetric(vertical: 20),
//                               child: Center(
//                                 child: SpinKitThreeBounce(
//                                   color: Colors.blue,
//                                   size: 30,
//                                 ),
//                               ),
//                             );
//                           }
//                           return _buildTransactionItem(
//                               state.transactions[index]);
//                         },
//                       ),
//                     );
//                   }

//                   return const SizedBox.shrink();
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildTransactionItem(Transaction transaction) {
//     final isCredit = transaction.direction == TransactionDirection.CREDIT;

//     return Card(
//       margin: const EdgeInsets.only(bottom: 12),
//       elevation: 2,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Row(
//           children: [
//             // Transaction Type Icon

//             Container(
//               width: 48,
//               height: 48,
//               decoration: BoxDecoration(
//                 color: isCredit ? Colors.green.shade100 : Colors.red.shade100,
//                 borderRadius: BorderRadius.circular(24),
//               ),
//               child: Icon(
//                 isCredit ? Icons.arrow_downward : Icons.arrow_upward,
//                 color: isCredit ? Colors.green.shade700 : Colors.red.shade700,
//                 size: 24,
//               ),
//             ),
//             const SizedBox(width: 16),

//             // Transaction Details
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     transaction.description.isNotEmpty
//                         ? transaction.description
//                         : (isCredit ? 'Credit' : 'Debit'),
//                     style: const TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w500,
//                     ),
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     _formatDate(transaction.date),
//                     style: TextStyle(
//                       fontSize: 12,
//                       color: Colors.grey.shade600,
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             // Amount
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.end,
//               children: [
//                 Text(
//                   '${isCredit ? '+' : '-'}ETB${transaction.amount.toStringAsFixed(2)}',
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                     color:
//                         isCredit ? Colors.green.shade700 : Colors.red.shade700,
//                   ),
//                 ),
//                 if (transaction.balanceAfter != null)
//                   Text(
//                     'Balance: ETB${transaction.balanceAfter!.toStringAsFixed(2)}',
//                     style: TextStyle(
//                       fontSize: 11,
//                       color: Colors.grey.shade600,
//                     ),
//                   ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   String _formatDate(DateTime date) {
//     final now = DateTime.now();
//     final difference = now.difference(date);

//     if (difference.inDays == 0) {
//       if (difference.inHours == 0) {
//         if (difference.inMinutes == 0) {
//           return 'Just now';
//         }
//         return '${difference.inMinutes} min ago';
//       }
//       return '${difference.inHours} hours ago';
//     } else if (difference.inDays == 1) {
//       return 'Yesterday';
//     } else if (difference.inDays < 7) {
//       return '${difference.inDays} days ago';
//     } else {
//       return '${date.day}/${date.month}/${date.year}';
//     }
//   }
// }
