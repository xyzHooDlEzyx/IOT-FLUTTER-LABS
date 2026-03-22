import 'package:flutter/material.dart';

import 'package:my_project/domain/models/local_user.dart';
import 'package:my_project/domain/validators/user_validator.dart';
import 'package:my_project/routes/app_routes.dart';
import 'package:my_project/services/auth_store.dart';
import 'package:my_project/widgets/app_card.dart';
import 'package:my_project/widgets/app_shell.dart';
import 'package:my_project/widgets/app_text_field.dart';
import 'package:my_project/widgets/primary_button.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _fullNameController =
      TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController =
      TextEditingController();
  final TextEditingController _companyController = TextEditingController();

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _companyController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    final fullName = _fullNameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final company = _companyController.text.trim();

    final fullNameError = UserValidator.validateFullName(fullName);
    if (fullNameError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(fullNameError)),
      );
      return;
    }

    final emailError = UserValidator.validateEmail(email);
    if (emailError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(emailError)),
      );
      return;
    }

    final passwordError = UserValidator.validatePassword(password);
    if (passwordError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(passwordError)),
      );
      return;
    }

    final companyError = UserValidator.validateCompany(company);
    if (companyError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(companyError)),
      );
      return;
    }

    final user = LocalUser(
      fullName: fullName,
      email: email,
      password: password,
      company: company,
    );
    await AuthStore.instance.saveUser(user);
    await AuthStore.instance.setLoggedIn(true);

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Account saved locally.')),
    );
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.profile,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: 'Create account',
      subtitle: 'Set up your smart space in minutes',
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppTextField(
              label: 'Full name',
              hint: 'Alex Rivera',
              controller: _fullNameController,
              keyboardType: TextInputType.name,
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Email',
              hint: 'name@domain.com',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Password',
              hint: 'Create a password',
              controller: _passwordController,
              obscureText: true,
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Company',
              hint: 'Urban Lab',
              controller: _companyController,
              keyboardType: TextInputType.text,
            ),
            const SizedBox(height: 20),
            PrimaryButton(
              label: 'Create profile',
              onPressed: _handleRegister,
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
