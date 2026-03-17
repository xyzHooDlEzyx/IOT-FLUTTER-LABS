import 'package:flutter/material.dart';
import 'package:my_project/routes/app_routes.dart';
import 'package:my_project/widgets/app_card.dart';
import 'package:my_project/widgets/app_shell.dart';
import 'package:my_project/widgets/app_text_field.dart';
import 'package:my_project/widgets/primary_button.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: 'Create account',
      subtitle: 'Set up your smart space in minutes',
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AppTextField(
              label: 'Full name',
              hint: 'Alex Rivera',
            ),
            const SizedBox(height: 16),
            const AppTextField(
              label: 'Email',
              hint: 'name@domain.com',
            ),
            const SizedBox(height: 16),
            const AppTextField(
              label: 'Password',
              hint: 'Create a password',
              obscureText: true,
            ),
            const SizedBox(height: 16),
            const AppTextField(
              label: 'Company',
              hint: 'Urban Lab',
            ),
            const SizedBox(height: 20),
            PrimaryButton(
              label: 'Create profile',
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.profile);
              },
            ),
            const SizedBox(height: 12),
            GhostButton(
              label: 'Back to sign in',
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
