// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_spinkit/flutter_spinkit.dart';
// import 'package:go_router/go_router.dart';

// import '../../core/network/api_client.dart';
// import '../../data/datasources/account_remote_datasource.dart';
// import '../../data/repositories/account_repository_impl.dart';
// import '../../domain/entities/account.dart';
// import '../bloc/account/account_bloc.dart';
// import '../bloc/account/account_event.dart';
// import '../bloc/account/account_state.dart';
// import '../widgets/create_account_dialog.dart';
// import 'fund_transfer_page.dart';
// import 'transaction_history_page.dart';
// import 'bill_payment_page.dart';

// class HomePage extends StatelessWidget {
//   final ApiClient apiClient;

//   const HomePage({super.key, required this.apiClient});

//   @override
//   Widget build(BuildContext context) {
//     return MultiBlocProvider(
//       providers: [
//         BlocProvider(
//           create: (context) => AccountBloc(
//             accountRepository: AccountRepositoryImpl(
//               remoteDataSource: AccountRemoteDataSourceImpl(
//                 apiClient: apiClient,
//               ),
//             ),
//           )..add(const LoadAccounts()),
//         ),
//       ],
//       child: HomeView(apiClient: apiClient),
//     );
//   }
// }

// class HomeView extends StatefulWidget {
//   final ApiClient apiClient;

//   const HomeView({super.key, required this.apiClient});

//   @override
//   State<HomeView> createState() => _HomeViewState();
// }

// class _HomeViewState extends State<HomeView> {
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
//       context.read<AccountBloc>().add(LoadMoreAccounts());
//     }
//   }

//   bool get _isBottom {
//     if (!_scrollController.hasClients) return false;
//     final maxScroll = _scrollController.position.maxScrollExtent;
//     final currentScroll = _scrollController.offset;
//     return currentScroll >= (maxScroll * 0.9);
//   }

//   String _getGreeting() {
//     final hour = DateTime.now().hour;
//     if (hour < 12) {
//       return 'Good Morning!';
//     } else if (hour < 17) {
//       return 'Good Afternoon!';
//     } else {
//       return 'Good Evening!';
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       // backgroundColor: const Color(0xFFF5F7FA),
//       body: Column(
//         children: [
//           // Dark grey header background
//           Container(
//             width: double.infinity,
//             decoration: const BoxDecoration(
//               color: Color(0xFF4A5568),
//               // borderRadius: BorderRadius.only(
//               //   bottomLeft: Radius.circular(30),
//               //   bottomRight: Radius.circular(30),
//               // ),
//             ),
//             padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
//             child: Column(
//               children: [
//                 // User greeting and profile
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           _getGreeting(),
//                           style: const TextStyle(
//                             color: Colors.white70,
//                             fontSize: 14,
//                           ),
//                         ),
//                         const SizedBox(height: 4),
//                         const Text(
//                           'Jane Doe',
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontSize: 20,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ],
//                     ),
//                     Container(
//                       width: 50,
//                       height: 50,
//                       decoration: BoxDecoration(
//                         shape: BoxShape.circle,
//                         color: Colors.white,
//                         border: Border.all(color: Colors.white, width: 2),
//                       ),
//                       child: const ClipOval(
//                         child: Icon(
//                           Icons.person,
//                           color: Color(0xFF4A5568),
//                           size: 30,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 30),
//                 // Balance display
//                 BlocBuilder<AccountBloc, AccountState>(
//                   builder: (context, state) {
//                     double totalBalance = 8640.00; // Default for demo
//                     if (state is AccountLoaded && state.accounts.isNotEmpty) {
//                       totalBalance = state.accounts.fold<double>(
//                           0, (sum, account) => sum + account.balance);
//                     }
//                     return Column(
//                       children: [
//                         Text(
//                           'ETB ${totalBalance.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
//                           style: const TextStyle(
//                             color: Colors.white,
//                             fontSize: 32,
//                             fontWeight: FontWeight.bold,
//                             letterSpacing: 1.2,
//                           ),
//                         ),
//                         const SizedBox(height: 4),
//                         const Text(
//                           'Available Balance',
//                           style: TextStyle(
//                             color: Colors.white70,
//                             fontSize: 14,
//                           ),
//                         ),
//                       ],
//                     );
//                   },
//                 ),
//               ],
//             ),
//           ),

//           // Quick Actions
//           Transform.translate(
//             offset: const Offset(0, -25),
//             child: Container(
//               margin: const EdgeInsets.symmetric(horizontal: 20),
//               padding: const EdgeInsets.symmetric(vertical: 15),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(20),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withValues(alpha: 0.1),
//                     blurRadius: 20,
//                     offset: const Offset(0, 10),
//                   ),
//                 ],
//               ),
//             ),
//           ),

//           Expanded(
//             child: Transform.translate(
//               offset: const Offset(0, -30),
//               child: Container(
//                 width: double.infinity,
//                 decoration: const BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.only(
//                     topLeft: Radius.circular(35),
//                     topRight: Radius.circular(35),
//                   ),
//                 ),
//                 child: SingleChildScrollView(
//                   padding: const EdgeInsets.only(
//                     left: 20,
//                     top: 80,
//                     right: 20,
//                   ),
//                   child: Column(
//                     children: [
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceAround,
//                         children: [
//                           _buildQuickAction(
//                             icon: Icons.swap_horiz,
//                             label: 'Transfer',
//                             onTap: () => Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (context) => FundTransferPage(
//                                   apiClient: widget.apiClient,
//                                 ),
//                               ),
//                             ),
//                           ),
//                           _buildQuickAction(
//                             icon: Icons.receipt_long,
//                             label: 'Bills',
//                             onTap: () => Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (context) => BillPaymentPage(
//                                   apiClient: widget.apiClient,
//                                 ),
//                               ),
//                             ),
//                           ),
//                           _buildQuickAction(
//                             icon: Icons.phone_android,
//                             label: 'Recharge',
//                             onTap: () {
//                               ScaffoldMessenger.of(context).showSnackBar(
//                                 const SnackBar(
//                                     content: Text('Recharge coming soon')),
//                               );
//                             },
//                           ),
//                           _buildQuickAction(
//                             icon: Icons.more_horiz,
//                             label: 'More',
//                             onTap: () {
//                               showDialog(
//                                 context: context,
//                                 builder: (dialogContext) => CreateAccountDialog(
//                                   onAccountCreated: () {
//                                     context
//                                         .read<AccountBloc>()
//                                         .add(const LoadAccounts());
//                                   },
//                                 ),
//                               );
//                             },
//                           ),
//                         ],
//                       ),
//                       Expanded(
//                         child: ListView(
//                           controller: _scrollController,
//                           padding: const EdgeInsets.symmetric(horizontal: 20),
//                           children: [
//                             // My Accounts Section
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 const Text(
//                                   'My Accounts',
//                                   style: TextStyle(
//                                     fontSize: 18,
//                                     fontWeight: FontWeight.bold,
//                                     color: Color(0xFF2D3748),
//                                   ),
//                                 ),
//                                 TextButton(
//                                   onPressed: () {},
//                                   child: const Text(
//                                     'View All',
//                                     style: TextStyle(
//                                       color: Color(0xFF4A5568),
//                                       fontSize: 14,
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             const SizedBox(height: 10),

//                             // Account Cards
//                             BlocBuilder<AccountBloc, AccountState>(
//                               builder: (context, state) {
//                                 if (state is AccountLoading) {
//                                   return const Center(
//                                     child: Padding(
//                                       padding: EdgeInsets.all(20),
//                                       child: SpinKitCircle(
//                                         color: Color(0xFF4A5568),
//                                         size: 40,
//                                       ),
//                                     ),
//                                   );
//                                 }

//                                 if (state is AccountError) {
//                                   return Center(
//                                     child: Text(
//                                       state.message,
//                                       style: const TextStyle(color: Colors.red),
//                                     ),
//                                   );
//                                 }

//                                 if (state is AccountLoaded) {
//                                   if (state.accounts.isEmpty) {
//                                     return _buildEmptyState();
//                                   }

//                                   return Column(
//                                     children: state.accounts.map((account) {
//                                       return _buildAccountCard(account);
//                                     }).toList(),
//                                   );
//                                 }

//                                 return _buildDemoAccounts();
//                               },
//                             ),

//                             const SizedBox(height: 25),

//                             // Recent Transactions Section
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 const Text(
//                                   'Recent Transactions',
//                                   style: TextStyle(
//                                     fontSize: 18,
//                                     fontWeight: FontWeight.bold,
//                                     color: Color(0xFF2D3748),
//                                   ),
//                                 ),
//                                 TextButton(
//                                   onPressed: () {},
//                                   child: const Text(
//                                     'View All',
//                                     style: TextStyle(
//                                       color: Color(0xFF4A5568),
//                                       fontSize: 14,
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             const SizedBox(height: 10),

//                             // Transaction List
//                             Container(
//                               padding: const EdgeInsets.all(15),
//                               decoration: BoxDecoration(
//                                 color: Colors.white,
//                                 borderRadius: BorderRadius.circular(15),
//                                 boxShadow: [
//                                   BoxShadow(
//                                     color: Colors.black.withValues(alpha: 0.05),
//                                     blurRadius: 10,
//                                     offset: const Offset(0, 5),
//                                   ),
//                                 ],
//                               ),
//                               child: Column(
//                                 children: [
//                                   _buildTransactionItem(
//                                     icon: Icons.shopping_cart,
//                                     title: 'Grocery',
//                                     amount: '-ETB400',
//                                     isDebit: true,
//                                   ),
//                                   const Divider(height: 30),
//                                   _buildTransactionItem(
//                                     icon: Icons.receipt,
//                                     title: 'IESCO Bill',
//                                     amount: '-ETB120',
//                                     isDebit: true,
//                                   ),
//                                 ],
//                               ),
//                             ),
//                             const SizedBox(height: 20),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildQuickAction({
//     required IconData icon,
//     required String label,
//     required VoidCallback onTap,
//   }) {
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(12),
//       child: Column(
//         children: [
//           Container(
//             width: 50,
//             height: 50,
//             decoration: const BoxDecoration(
//               shape: BoxShape.circle,
//               color: Color(0xFFE8EAF6),
//             ),
//             child: Icon(icon, color: const Color(0xFF4A5568)),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             label,
//             style: const TextStyle(
//               fontSize: 12,
//               color: Color(0xFF2D3748),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildAccountCard(Account account) {
//     IconData iconData = account.accountType.toLowerCase() == 'savings'
//         ? Icons.savings
//         : Icons.account_balance_wallet;

//     return Container(
//       margin: const EdgeInsets.only(bottom: 15),
//       padding: const EdgeInsets.all(15),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(15),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 10,
//             offset: const Offset(0, 5),
//           ),
//         ],
//       ),
//       child: InkWell(
//         onTap: () => Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => TransactionHistoryPage(
//               account: account,
//               apiClient: widget.apiClient,
//             ),
//           ),
//         ),
//         child: Row(
//           children: [
//             Container(
//               width: 45,
//               height: 45,
//               decoration: BoxDecoration(
//                 color: const Color(0xFFE8EAF6),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Icon(iconData, color: const Color(0xFF4A5568)),
//             ),
//             const SizedBox(width: 15),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     account.accountType,
//                     style: const TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                       color: Color(0xFF2D3748),
//                     ),
//                   ),
//                   Text(
//                     '(${account.accountNumber.substring(0, 4)}***${account.accountNumber.substring(account.accountNumber.length - 3)})',
//                     style: TextStyle(
//                       fontSize: 12,
//                       color: Colors.grey[600],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.end,
//               children: [
//                 Text(
//                   'ETB ${account.balance.toStringAsFixed(2)}',
//                   style: const TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                     color: Color(0xFF2D3748),
//                   ),
//                 ),
//                 Text(
//                   'last updated ${DateTime.now().month}/${DateTime.now().day}',
//                   style: TextStyle(
//                     fontSize: 10,
//                     color: Colors.grey[600],
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildDemoAccounts() {
//     return Column(
//       children: [
//         _buildAccountCard(Account(
//           id: '1',
//           accountNumber: '1000***648',
//           accountType: 'Saving',
//           balance: 2200,
//           userId: '1',
//           createdAt: DateTime.now(),
//           updatedAt: DateTime.now(),
//         )),
//         _buildAccountCard(Account(
//           id: '2',
//           accountNumber: '1000***493',
//           accountType: 'Checking',
//           balance: 650,
//           userId: '1',
//           createdAt: DateTime.now(),
//           updatedAt: DateTime.now(),
//         )),
//       ],
//     );
//   }

//   Widget _buildTransactionItem({
//     required IconData icon,
//     required String title,
//     required String amount,
//     required bool isDebit,
//   }) {
//     return Row(
//       children: [
//         Container(
//           width: 40,
//           height: 40,
//           decoration: BoxDecoration(
//             color: const Color(0xFFF0F0F5),
//             borderRadius: BorderRadius.circular(10),
//           ),
//           child: Icon(
//             icon,
//             color: const Color(0xFF4A5568),
//             size: 20,
//           ),
//         ),
//         const SizedBox(width: 15),
//         Expanded(
//           child: Text(
//             title,
//             style: const TextStyle(
//               fontSize: 15,
//               fontWeight: FontWeight.w500,
//               color: Color(0xFF2D3748),
//             ),
//           ),
//         ),
//         Text(
//           amount,
//           style: TextStyle(
//             fontSize: 15,
//             fontWeight: FontWeight.bold,
//             color: isDebit ? Colors.red : Colors.green,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildEmptyState() {
//     return Container(
//       padding: const EdgeInsets.all(40),
//       child: Column(
//         children: [
//           Icon(
//             Icons.account_balance_wallet_outlined,
//             size: 60,
//             color: Colors.grey[400],
//           ),
//           const SizedBox(height: 15),
//           Text(
//             'No accounts found',
//             style: TextStyle(
//               fontSize: 16,
//               color: Colors.grey[600],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
