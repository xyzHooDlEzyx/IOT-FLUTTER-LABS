class UserValidator {
  static String? validateFullName(String value) {
    if (value.isEmpty) {
      return 'Full name is required.';
    }
    final hasDigit = RegExp(r'\d').hasMatch(value);
    if (hasDigit) {
      return 'Name should not contain digits.';
    }
    return null;
  }

  static String? validateEmail(String value) {
    if (value.isEmpty) {
      return 'Email is required.';
    }
    final trimmed = value.trim();
    if (!trimmed.contains('@') || !trimmed.contains('.')) {
      return 'Enter a valid email.';
    }
    return null;
  }

  static String? validatePassword(String value) {
    if (value.isEmpty) {
      return 'Password is required.';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters.';
    }
    return null;
  }

  static String? validateCompany(String value) {
    if (value.isEmpty) {
      return 'Company is required.';
    }
    return null;
  }
}
