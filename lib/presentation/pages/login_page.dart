import 'package:banking_app_challenge/core/utils/message_utils.dart';
import 'package:banking_app_challenge/presentation/widgets/app_button.dart';
import 'package:banking_app_challenge/presentation/widgets/app_lable.dart';
import 'package:banking_app_challenge/presentation/widgets/app_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:banking_app_challenge/presentation/bloc/auth/auth_bloc.dart';
import 'package:banking_app_challenge/presentation/bloc/auth/auth_event.dart';
import 'package:banking_app_challenge/presentation/bloc/auth/auth_state.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  void _login() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
        LoginRequested(
          username: _usernameController.text.trim(),
          password: _passwordController.text,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            context.go('/dashboard');
          } else if (state is AuthError) {
            MessageUtils.showMessage(
              context: context,
              title: state.message,
              error: true,
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return IgnorePointer(
            ignoring: false,
            child: Column(
              children: [
                // Header
                Container(
                  height: 200,
                  width: double.infinity,
                  color: const Color(0xFF4A5568),
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          Text('Welcome',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500)),
                          const SizedBox(height: 8),
                          Text('Login here',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ),

                // Form
                Expanded(
                  child: Transform.translate(
                    offset: const Offset(0, -30),
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                        BorderRadius.vertical(top: Radius.circular(35)),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: SingleChildScrollView(
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              const SizedBox(height: 40),
                              Container(
                                height: 60,
                                width: 60,
                                padding: const EdgeInsets.all(16),
                                decoration: const BoxDecoration(
                                  color: Color(0xFFDBE3F8),
                                  borderRadius: BorderRadius.all(Radius.circular(45))

                                ),
                                child: const Center(
                                  child: Icon(Icons.login_rounded,

                                      color: Color(0xFF4A5568), size: 30),
                                ),
                              ),
                              const SizedBox(height: 60),
                              const AppLabel('Username',align: TextAlign.start,),
                              const SizedBox(height: 10),
                              AppTextField(
                                controller: _usernameController,
                                hint: 'please enter your username',
                                validator: (v) => v == null || v.isEmpty
                                    ? 'Enter username'
                                    : null,
                                suffixIcon: Icons.account_circle_outlined,
                              ),
                              const SizedBox(height: 30),
                              const AppLabel('Password',align: TextAlign.start,),
                              const SizedBox(height: 10),
                              AppTextField(
                                controller: _passwordController,
                                hint: 'please enter your password',
                                obscureText: _obscurePassword,
                                validator: (v) {
                                  if (v == null || v.isEmpty) {
                                    return 'Enter password';
                                  }
                                  if (v.length < 6) {
                                    return 'Password must be 6+ chars';
                                  }
                                  return null;
                                },
                                suffixIcon: _obscurePassword
                                    ? Icons.lock_outline
                                    : Icons.lock_open_outlined,
                                onSuffixTap: () => setState(() {
                                  _obscurePassword = !_obscurePassword;
                                }),
                              ),
                              const SizedBox(height: 50),

                              AppButton(
                                label: 'Login',
                                loading: isLoading,
                                onPressed: _login,
                              ),

                              const SizedBox(height: 50),

                              // Register link
                              Column(
                                children: [
                                  Text("don't have an account?",
                                      style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 14)),
                                  const SizedBox(height: 5),
                                  GestureDetector(
                                    onTap: () => context.go('/register'),
                                    child: const Text(
                                      'register',
                                      style: TextStyle(
                                        color: Color(0xFF4A5568),
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
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
        },
      ),
    );
  }
}
