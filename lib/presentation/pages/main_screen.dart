import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:banking_app_challenge/core/theme/app_colors.dart';
import 'home_page.dart';
import 'my_accounts_page.dart';
import 'transactions_page.dart';
import 'profile_page.dart';
import 'package:banking_app_challenge/core/network/api_client.dart';
import '../../data/datasources/account_remote_datasource.dart';
import '../../data/datasources/transaction_remote_datasource.dart';
import '../../data/repositories/account_repository_impl.dart';
import '../../data/repositories/transaction_repository_impl.dart';
import '../bloc/account/account_bloc.dart';
import '../bloc/account/account_event.dart';
import '../bloc/account/account_state.dart';
import '../bloc/transaction/transaction_bloc.dart';
import '../bloc/transaction/transaction_event.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_state.dart';

//todo:use shell route for bottom navigation instead of maintaining state here (need to refactor auth flow to use go router first)
class MainScreen extends StatefulWidget {
  final ApiClient apiClient;

  const MainScreen({
    super.key,
    required this.apiClient,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}
//todo: refactor to use go router shell route for bottom navigation
class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  late final List<Widget> _pages;
  late AccountBloc _accountBloc;
  late TransactionBloc _transactionBloc;
  late TransactionBloc _homeTransactionBloc; // Separate bloc for home page
  late TransactionBloc _transactionsPageBloc; // Separate bloc for transactions page

  @override
  void initState() {
    super.initState();
    _pages = [
      HomeView(
        apiClient: widget.apiClient,
        onTabChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
      const MyAccountsPage(),
      const TransactionsPage(),
      const ProfilePage(),
    ];

    // Initialize BLoCs
    _accountBloc = AccountBloc(
      accountRepository: AccountRepositoryImpl(
        remoteDataSource: AccountRemoteDataSourceImpl(
          apiClient: widget.apiClient,
        ),
      ),
    );

    _transactionBloc = TransactionBloc(
      transactionRepository: TransactionRepositoryImpl(
        remoteDataSource: TransactionRemoteDataSourceImpl(
          apiClient: widget.apiClient,
        ),
      ),
    );

    // Create separate transaction bloc for home page
    _homeTransactionBloc = TransactionBloc(
      transactionRepository: TransactionRepositoryImpl(
        remoteDataSource: TransactionRemoteDataSourceImpl(
          apiClient: widget.apiClient,
        ),
      ),
    );

    // Create separate transaction bloc for transactions page
    _transactionsPageBloc = TransactionBloc(
      transactionRepository: TransactionRepositoryImpl(
        remoteDataSource: TransactionRemoteDataSourceImpl(
          apiClient: widget.apiClient,
        ),
      ),
    );

    // Load accounts after widget is built to ensure auth context is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Check if user is authenticated and load accounts
      final authState = context.read<AuthBloc>().state;
      if (authState is AuthAuthenticated) {
        print('🔄 User authenticated on app start, loading accounts...');
        _accountBloc.add(const LoadAccounts());
      }

      // Listen to auth state changes
      context.read<AuthBloc>().stream.listen((authState) {
        if (authState is AuthAuthenticated) {
          print('🔄 Auth state changed to authenticated, reloading accounts...');
          // Add a small delay to ensure token is properly set
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              _accountBloc.add(const LoadAccounts());
            }
          });
        }
      });

      // Listen to account state changes to load transactions for all accounts
      _accountBloc.stream.listen((accountState) {
        if (accountState is AccountLoaded && accountState.accounts.isNotEmpty) {
          final accountIds = accountState.accounts.map((a) => a.id).toList();
          // Load transactions for the transactions page bloc
          _transactionsPageBloc.add(LoadAllAccountsTransactions(accountIds: accountIds));
        }
      });
    });
  }

  @override
  void dispose() {
    _accountBloc.close();
    _transactionBloc.close();
    _homeTransactionBloc.close();
    _transactionsPageBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(
          value: _accountBloc,
        ),
        BlocProvider.value(
          value: _transactionBloc,
        ),
      ],
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: [
            // Home page with its own transaction bloc
            BlocProvider.value(
              value: _homeTransactionBloc,
              child: _pages[0],
            ),
            // My Accounts page uses the shared transaction bloc
            _pages[1],
            // Transactions page with its own transaction bloc
            BlocProvider.value(
              value: _transactionsPageBloc,
              child: _pages[2],
            ),
            // Profile page
            _pages[3],
          ],
        ),
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: Colors.grey[400],
            selectedFontSize: 12,
            unselectedFontSize: 12,
            elevation: 0,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.credit_card_outlined),
                activeIcon: Icon(Icons.credit_card),
                label: 'Cards',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.receipt_outlined),
                activeIcon: Icon(Icons.receipt),
                label: 'Transactions',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
