import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:banking_app_challenge/core/utils/message_utils.dart';
import 'package:banking_app_challenge/presentation/widgets/app_button.dart';
import 'package:banking_app_challenge/presentation/widgets/app_text_field.dart';
import 'package:banking_app_challenge/presentation/widgets/app_lable.dart';
import 'package:banking_app_challenge/presentation/bloc/auth/auth_bloc.dart';
import 'package:banking_app_challenge/presentation/bloc/auth/auth_event.dart';
import 'package:banking_app_challenge/presentation/bloc/auth/auth_state.dart';
import '../../core/utils/validation_utils.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailController = TextEditingController();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _register() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
        RegisterRequested(
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          username: _usernameController.text.trim(),
          password: _passwordController.text,
          phoneNumber: _phoneController.text.trim(),
          email: _emailController.text.trim(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            MessageUtils.showMessage(
              context: context,
              title: state.message,
              error: false,
            );
            Future.delayed(const Duration(seconds: 2), () {
              if (context.mounted) context.go('/login');
            });
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
            ignoring: isLoading,
            child: Column(
              children: [
                // Reusable header (could be extracted if reused again)
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
                                fontWeight: FontWeight.w500,
                              )),
                          const SizedBox(height: 8),
                          Text('Register',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              )),
                        ],
                      ),
                    ),
                  ),
                ),

                // Form container
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
                              const AppLabel('First Name', align: TextAlign.start,),
                              const SizedBox(height: 10),
                              AppTextField(
                                controller: _firstNameController,
                                hint: 'please specify your first name',
                                validator:ValidationUtils.validateName
                              ),
                              const SizedBox(height: 20),

                              const AppLabel('Last Name',align: TextAlign.start),
                              const SizedBox(height: 10),
                              AppTextField(
                                controller: _lastNameController,
                                hint: 'please specify your last name',
                                validator: ValidationUtils.validateName
                              ),
                              const SizedBox(height: 20),

                              const AppLabel('Username',align: TextAlign.start),
                              const SizedBox(height: 10),
                              AppTextField(
                                controller: _usernameController,
                                hint: 'please enter new username',
                                validator:ValidationUtils.validateUsername
                              ),
                              const SizedBox(height: 20),

                              const AppLabel('Phone Number',align: TextAlign.start),
                              const SizedBox(height: 10),
                              AppTextField(
                                controller: _phoneController,
                                hint: 'enter a valid phone number',
                                keyboardType: TextInputType.phone,
                                validator:ValidationUtils.validateEthiopianPhone
                              ),
                              const SizedBox(height: 20),

                              const AppLabel('Password',align: TextAlign.start),
                              const SizedBox(height: 10),
                              AppTextField(
                                controller: _passwordController,
                                hint: 'please create new password',
                                errorMaxLines: 3,
                                obscureText: _obscurePassword,
                                suffixIcon: _obscurePassword
                                    ? Icons.lock_outline
                                    : Icons.lock_open_outlined,
                                onSuffixTap: () => setState(() {
                                  _obscurePassword = !_obscurePassword;
                                }),
                                validator:ValidationUtils.validateStrongPassword
                              ),

                              const SizedBox(height: 60),

                              AppButton(
                                label: 'Register',
                                onPressed: _register,
                                loading: isLoading,
                              ),

                              const SizedBox(height: 20),

                              // Login link
                              Column(
                                children: [
                                  Text("already have an account??",
                                      style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 14)),
                                  const SizedBox(height: 5),
                                  GestureDetector(
                                    onTap: () => context.go('/login'),
                                    child: const Text(
                                      'login',
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
