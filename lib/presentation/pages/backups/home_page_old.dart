// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_spinkit/flutter_spinkit.dart';
// import '../../core/network/api_client.dart';
// import '../../core/theme/app_colors.dart';
// import '../../data/datasources/account_remote_datasource.dart';
// import '../../data/repositories/account_repository_impl.dart';
// import '../../domain/entities/account.dart';
// import '../bloc/account/account_bloc.dart';
// import '../bloc/account/account_event.dart';
// import '../bloc/account/account_state.dart';
// import 'fund_transfer_page.dart';

// class HomePage extends StatelessWidget {
//   final ApiClient apiClient;

//   const HomePage({super.key, required this.apiClient});

//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (context) => AccountBloc(
//         accountRepository: AccountRepositoryImpl(
//           remoteDataSource: AccountRemoteDataSourceImpl(
//             apiClient: apiClient,
//           ),
//         ),
//       )..add(const LoadAccounts()),
//       child: const HomeView(),
//     );
//   }
// }

// class HomeView extends StatefulWidget {
//   const HomeView({super.key});

//   @override
//   State<HomeView> createState() => _HomeViewState();
// }

// class _HomeViewState extends State<HomeView> {
//   final ApiClient _apiClient = ApiClient();
//   String _greeting = '';

//   @override
//   void initState() {
//     super.initState();
//     _setGreeting();
//   }

//   void _setGreeting() {
//     final hour = DateTime.now().hour;
//     if (hour < 12) {
//       _greeting = 'Good Morning!';
//     } else if (hour < 18) {
//       _greeting = 'Good Afternoon!';
//     } else {
//       _greeting = 'Good Evening!';
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF5F5F5),
//       body: SafeArea(
//         child: Column(
//           children: [
//             // Header Section
//             Container(
//               padding: const EdgeInsets.all(20),
//               decoration: const BoxDecoration(
//                 color: AppColors.primary,
//                 borderRadius: BorderRadius.only(
//                   bottomLeft: Radius.circular(30),
//                   bottomRight: Radius.circular(30),
//                 ),
//               ),
//               child: Column(
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             _greeting,
//                             style: const TextStyle(
//                               color: Colors.white70,
//                               fontSize: 14,
//                             ),
//                           ),
//                           const SizedBox(height: 4),
//                           const Text(
//                             'Jane Doe',
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 20,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ],
//                       ),
//                       CircleAvatar(
//                         radius: 25,
//                         backgroundColor: Colors.white,
//                         child: Icon(
//                           Icons.person,
//                           color: AppColors.primary,
//                           size: 30,
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 30),
//                   BlocBuilder<AccountBloc, AccountState>(
//                     builder: (context, state) {
//                       double totalBalance = 0;
//                       if (state is AccountLoaded) {
//                         totalBalance = state.accounts.fold(
//                           0,
//                           (sum, account) => sum + account.balance,
//                         );
//                       }
//                       return Column(
//                         children: [
//                           Text(
//                             'ETB ${totalBalance.toStringAsFixed(2)}',
//                             style: const TextStyle(
//                               color: Colors.white,
//                               fontSize: 32,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           const SizedBox(height: 4),
//                           const Text(
//                             'Available Balance',
//                             style: TextStyle(
//                               color: Colors.white70,
//                               fontSize: 14,
//                             ),
//                           ),
//                         ],
//                       );
//                     },
//                   ),
//                 ],
//               ),
//             ),

//             // Quick Actions
//             Container(
//               margin: const EdgeInsets.all(20),
//               padding: const EdgeInsets.all(20),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(20),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withValues(alpha: 0.05),
//                     blurRadius: 10,
//                     offset: const Offset(0, 5),
//                   ),
//                 ],
//               ),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceAround,
//                 children: [
//                   _buildQuickAction(
//                     context,
//                     Icons.swap_horiz,
//                     'Transfer',
//                     () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => FundTransferPage(
//                             apiClient: _apiClient,
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                   _buildQuickAction(
//                     context,
//                     Icons.receipt_long,
//                     'Bills',
//                     () {},
//                   ),
//                   _buildQuickAction(
//                     context,
//                     Icons.phone_android,
//                     'Recharge',
//                     () {},
//                   ),
//                   _buildQuickAction(
//                     context,
//                     Icons.more_horiz,
//                     'More',
//                     () {},
//                   ),
//                 ],
//               ),
//             ),

//             // Accounts and Transactions
//             Expanded(
//               child: SingleChildScrollView(
//                 padding: const EdgeInsets.symmetric(horizontal: 20),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // My Accounts Section
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         const Text(
//                           'My Accounts',
//                           style: TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                             color: AppColors.textPrimary,
//                           ),
//                         ),
//                         TextButton(
//                           onPressed: () {},
//                           child: const Text(
//                             'View All',
//                             style: TextStyle(
//                               color: AppColors.primary,
//                               fontSize: 14,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 10),
//                     BlocBuilder<AccountBloc, AccountState>(
//                       builder: (context, state) {
//                         if (state is AccountLoading) {
//                           return const Center(
//                             child: SpinKitCircle(
//                               color: AppColors.primary,
//                               size: 40,
//                             ),
//                           );
//                         }
//                         if (state is AccountLoaded) {
//                           return Column(
//                             children: state.accounts
//                                 .take(2)
//                                 .map((account) => _buildAccountCard(account))
//                                 .toList(),
//                           );
//                         }
//                         return const SizedBox();
//                       },
//                     ),

//                     const SizedBox(height: 20),

//                     // Recent Transactions Section
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         const Text(
//                           'Recent Transactions',
//                           style: TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                             color: AppColors.textPrimary,
//                           ),
//                         ),
//                         TextButton(
//                           onPressed: () {},
//                           child: const Text(
//                             'View All',
//                             style: TextStyle(
//                               color: AppColors.primary,
//                               fontSize: 14,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 10),
//                     Container(
//                       padding: const EdgeInsets.all(15),
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(15),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black.withValues(alpha: 0.05),
//                             blurRadius: 10,
//                             offset: const Offset(0, 5),
//                           ),
//                         ],
//                       ),
//                       child: Column(
//                         children: [
//                           _buildTransactionItem(
//                             Icons.shopping_cart,
//                             'Grocery',
//                             '-ETB400',
//                             false,
//                           ),
//                           const Divider(height: 30),
//                           _buildTransactionItem(
//                             Icons.receipt,
//                             'IESCO Bill',
//                             '-ETB120',
//                             false,
//                           ),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(height: 20),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildQuickAction(
//     BuildContext context,
//     IconData icon,
//     String label,
//     VoidCallback onTap,
//   ) {
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(12),
//       child: Container(
//         padding: const EdgeInsets.all(12),
//         child: Column(
//           children: [
//             Container(
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: const Color(0xFFE8EAF6),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Icon(
//                 icon,
//                 color: AppColors.primary,
//                 size: 24,
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               label,
//               style: TextStyle(
//                 fontSize: 12,
//                 color: Colors.grey[700],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildAccountCard(Account account) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 15),
//       padding: const EdgeInsets.all(15),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(15),
//         border: Border.all(
//           color: Colors.grey[300]!,
//           width: 1,
//         ),
//       ),
//       child: Row(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(10),
//             decoration: BoxDecoration(
//               color: const Color(0xFFE8EAF6),
//               borderRadius: BorderRadius.circular(10),
//             ),
//             child: Icon(
//               account.accountType.toLowerCase() == 'saving'
//                   ? Icons.savings_outlined
//                   : Icons.account_balance_wallet_outlined,
//               color: AppColors.primary,
//               size: 24,
//             ),
//           ),
//           const SizedBox(width: 15),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   account.accountType,
//                   style: const TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w600,
//                     color: AppColors.textPrimary,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   '(${account.accountNumber})',
//                   style: TextStyle(
//                     fontSize: 12,
//                     color: Colors.grey[600],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.end,
//             children: [
//               Text(
//                 'ETB ${account.balance.toStringAsFixed(0)}',
//                 style: const TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                   color: AppColors.textPrimary,
//                 ),
//               ),
//               const SizedBox(height: 4),
//               Text(
//                 'last updated 01/24',
//                 style: TextStyle(
//                   fontSize: 10,
//                   color: Colors.grey[500],
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildTransactionItem(
//     IconData icon,
//     String title,
//     String amount,
//     bool isIncome,
//   ) {
//     return Row(
//       children: [
//         Container(
//           padding: const EdgeInsets.all(10),
//           decoration: BoxDecoration(
//             color: const Color(0xFFE8EAF6),
//             borderRadius: BorderRadius.circular(10),
//           ),
//           child: Icon(
//             icon,
//             color: AppColors.primary,
//             size: 20,
//           ),
//         ),
//         const SizedBox(width: 15),
//         Expanded(
//           child: Text(
//             title,
//             style: const TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.w500,
//               color: AppColors.textPrimary,
//             ),
//           ),
//         ),
//         Text(
//           amount,
//           style: TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.w600,
//             color: isIncome ? Colors.green : AppColors.textPrimary,
//           ),
//         ),
//       ],
//     );
//   }
// }
