import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my_project/domain/validators/user_validator.dart';
import 'package:my_project/routes/app_routes.dart';
import 'package:my_project/state/auth/auth_cubit.dart';
import 'package:my_project/state/auth/auth_state.dart';
import 'package:my_project/widgets/app_card.dart';
import 'package:my_project/widgets/app_shell.dart';
import 'package:my_project/widgets/app_text_field.dart';
import 'package:my_project/widgets/primary_button.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    final emailError = UserValidator.validateEmail(email);
    if (emailError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(emailError)),
      );
      return;
    }

    if (password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter your email and password.')),
      );
      return;
    }

    context.read<AuthCubit>().login(email, password);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listenWhen: (previous, current) =>
          previous.status != current.status,
      listener: (context, state) {
        if (state.status == AuthStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message ?? 'Failed to sign in.'),
            ),
          );
          return;
        }
        if (state.status == AuthStatus.authenticated) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.home,
            (route) => false,
          );
        }
      },
      child: AppShell(
        title: 'Welcome back',
        subtitle: 'Access your IoT control room',
        child: AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppTextField(
                label: 'Email',
                hint: 'name@domain.com',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                onSubmitted: (_) {
                  FocusScope.of(context).nextFocus();
                },
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Password',
                hint: '********',
                controller: _passwordController,
                obscureText: true,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _handleLogin(),
              ),
              const SizedBox(height: 20),
              PrimaryButton(
                label: 'Sign in',
                onPressed: _handleLogin,
              ),
              const SizedBox(height: 12),
              GhostButton(
                label: 'Create an account',
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.register);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
