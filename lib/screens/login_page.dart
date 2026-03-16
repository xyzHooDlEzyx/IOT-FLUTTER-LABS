import 'package:flutter/material.dart';
import 'package:my_project/routes/app_routes.dart';
import 'package:my_project/widgets/app_card.dart';
import 'package:my_project/widgets/app_shell.dart';
import 'package:my_project/widgets/app_text_field.dart';
import 'package:my_project/widgets/primary_button.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: 'Welcome back',
      subtitle: 'Access your IoT control room',
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AppTextField(
              label: 'Email',
              hint: 'name@domain.com',
            ),
            const SizedBox(height: 16),
            const AppTextField(
              label: 'Password',
              hint: '********',
              obscureText: true,
            ),
            const SizedBox(height: 20),
            PrimaryButton(
              label: 'Sign in',
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.home);
              },
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
    );
  }
}
