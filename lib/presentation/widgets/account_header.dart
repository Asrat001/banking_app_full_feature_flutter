import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/account/account_bloc.dart';
import '../bloc/account/account_state.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_state.dart';

class AccountHeader extends StatelessWidget {
  const AccountHeader({super.key, required this.onTabChanged});

  final VoidCallback onTabChanged;

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning!';
    } else if (hour < 17) {
      return 'Good Afternoon!';
    } else {
      return 'Good Evening!';
    }
  }


  @override
  Widget build(BuildContext context) {
    return             Container(
      width: double.infinity,
      color: const Color(0xFF4A5568),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 60),
      child: SafeArea(
        child: Column(
          children: [
            // User greeting and profile
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getGreeting(),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, authState) {
                        String displayName = 'User';

                        if (authState is AuthAuthenticated) {
                          final user = authState.user;
                          if (user.firstName.isNotEmpty &&
                              user.lastName.isNotEmpty) {
                            displayName =
                            '${user.firstName} ${user.lastName}';
                          } else if (user.username.isNotEmpty) {
                            displayName = user.username;
                          }
                        }
                        return Text(
                          displayName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                    ),
                  ],
                ),
                GestureDetector(
                  onTap:onTabChanged,
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        "assets/profile_pic.png",
                        width: 30,
                        height: 30,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            // Balance display
            BlocBuilder<AccountBloc, AccountState>(
              builder: (context, state) {
                double totalBalance = 0.0;
                if (state is AccountLoaded &&
                    state.accounts.isNotEmpty) {
                  totalBalance = state.accounts.fold<double>(
                      0, (sum, account) => sum + account.balance);
                }
                return Column(
                  children: [
                    Text(
                      'ETB ${totalBalance.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Available Balance',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
