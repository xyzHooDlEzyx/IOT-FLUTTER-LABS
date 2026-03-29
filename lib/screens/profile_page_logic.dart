part of 'profile_page.dart';

mixin _ProfilePageLogic on State<ProfilePage> {
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
}
