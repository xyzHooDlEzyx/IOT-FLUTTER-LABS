import 'package:flutter/material.dart';

import 'package:my_project/domain/models/local_user.dart';
import 'package:my_project/domain/validators/user_validator.dart';
import 'package:my_project/routes/app_routes.dart';
import 'package:my_project/services/auth_store.dart';
import 'package:my_project/widgets/app_card.dart';
import 'package:my_project/widgets/app_shell.dart';
import 'package:my_project/widgets/app_text_field.dart';
import 'package:my_project/widgets/icon_action_button.dart';
import 'package:my_project/widgets/info_row.dart';
import 'package:my_project/widgets/primary_button.dart';
import 'package:my_project/widgets/section_title.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _companyController = TextEditingController();

  LocalUser? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _companyController.dispose();
    super.dispose();
  }

  Future<void> _loadUser() async {
    final user = await AuthStore.instance.getUser();
    if (!mounted) {
      return;
    }
    _user = user;
    _fullNameController.text = user?.fullName ?? '';
    _emailController.text = user?.email ?? '';
    _companyController.text = user?.company ?? '';
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _saveProfile() async {
    if (_user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No profile loaded yet.')),
      );
      return;
    }

    final fullName = _fullNameController.text.trim();
    final email = _emailController.text.trim();
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

    final companyError = UserValidator.validateCompany(company);
    if (companyError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(companyError)),
      );
      return;
    }

    final updated = _user!.copyWith(
      fullName: fullName,
      email: email,
      company: company,
    );

    await AuthStore.instance.saveUser(updated);
    if (!mounted) {
      return;
    }
    setState(() {
      _user = updated;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated.')),
    );
  }

  Future<void> _logout() async {
    await AuthStore.instance.setLoggedIn(false);
    if (!mounted) {
      return;
    }
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login,
      (route) => false,
    );
  }

  Future<void> _deleteProfile() async {
    await AuthStore.instance.clearUser();
    if (!mounted) {
      return;
    }
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _user;

    return AppShell(
      title: 'Profile',
      subtitle: 'Your workspace identity',
      leading: IconActionButton(
        tooltip: 'Back to dashboard',
        icon: Icons.chevron_left,
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.home);
        },
      ),
      headerSpacing: 12,
      subtitleSpacing: 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 28,
                      child: Icon(Icons.person),
                    ),
                    const SizedBox(width: 16),
                    if (_isLoading)
                      Text(
                        'Loading profile...',
                        style: Theme.of(context).textTheme.bodyMedium,
                      )
                    else
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.fullName ?? 'Unknown user',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          Text(
                            user?.company ?? 'Company not set',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                InfoRow(
                  label: 'Email',
                  value: user?.email ?? '- -',
                ),
                const SizedBox(height: 8),
                const InfoRow(label: 'Role', value: 'IoT Operator'),
                const SizedBox(height: 8),
                const InfoRow(label: 'Region', value: 'Central Hub'),
              ],
            ),
          ),
          const SizedBox(height: 24),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionTitle(title: 'Edit profile'),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Full name',
                  controller: _fullNameController,
                  keyboardType: TextInputType.name,
                ),
                const SizedBox(height: 12),
                AppTextField(
                  label: 'Email',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 12),
                AppTextField(
                  label: 'Company',
                  controller: _companyController,
                  keyboardType: TextInputType.text,
                ),
                const SizedBox(height: 16),
                PrimaryButton(
                  label: 'Save changes',
                  onPressed: _saveProfile,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          GhostButton(
            label: 'Log out',
            onPressed: _logout,
          ),
          const SizedBox(height: 8),
          GhostButton(
            label: 'Delete profile data',
            onPressed: _deleteProfile,
          ),
        ],
      ),
    );
  }
}
