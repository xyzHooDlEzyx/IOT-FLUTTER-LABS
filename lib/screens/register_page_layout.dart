part of 'register_page.dart';

mixin _RegisterPageLayout on _RegisterPageLogic {
  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listenWhen: (previous, current) =>
          previous.status != current.status,
      listener: (context, state) {
        if (state.status == AuthStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message ?? 'Failed to create account.'),
            ),
          );
          return;
        }
        if (state.status == AuthStatus.authenticated) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Account created.')),
          );
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.profile,
            (route) => false,
          );
        }
      },
      child: AppShell(
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
      ),
    );
  }
}
