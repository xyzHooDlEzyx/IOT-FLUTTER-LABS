part of 'register_page.dart';

mixin _RegisterPageLogic on State<RegisterPage> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
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
    context.read<AuthCubit>().register(user);
  }
}
