part of 'profile_page.dart';

mixin _ProfilePageLogic on State<ProfilePage> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _companyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      context.read<AuthCubit>().loadUser();
    });
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _companyController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    final user = context.read<AuthCubit>().state.user;
    if (user == null) {
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

    final updated = user.copyWith(
      fullName: fullName,
      email: email,
      company: company,
    );
    context.read<AuthCubit>().updateProfile(updated);
  }

  Future<void> _logout() async {
    await context.read<AuthCubit>().logout();
  }

  Future<void> _deleteProfile() async {
    await context.read<AuthCubit>().deleteProfile();
  }
}
