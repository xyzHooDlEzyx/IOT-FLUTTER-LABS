class LocalUser {
  const LocalUser({
    required this.fullName,
    required this.email,
    required this.password,
    required this.company,
  });

  final String fullName;
  final String email;
  final String password;
  final String company;

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'email': email,
      'password': password,
      'company': company,
    };
  }

  LocalUser copyWith({
    String? fullName,
    String? email,
    String? password,
    String? company,
  }) {
    return LocalUser(
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      password: password ?? this.password,
      company: company ?? this.company,
    );
  }

  static LocalUser? fromJson(Map<String, dynamic> json) {
    final fullName = json['fullName'];
    final email = json['email'];
    final password = json['password'];
    final company = json['company'];
    if (fullName is! String ||
        email is! String ||
        password is! String ||
        company is! String) {
      return null;
    }

    return LocalUser(
      fullName: fullName,
      email: email,
      password: password,
      company: company,
    );
  }
}
