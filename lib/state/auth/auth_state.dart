import 'package:my_project/domain/models/local_user.dart';

enum AuthStatus {
  idle,
  loading,
  authenticated,
  unauthenticated,
  error,
}

class AuthState {
  const AuthState({
    required this.status,
    this.user,
    this.message,
  });

  static const Object _unset = Object();

  final AuthStatus status;
  final LocalUser? user;
  final String? message;

  bool get isLoading => status == AuthStatus.loading;

  AuthState copyWith({
    AuthStatus? status,
    Object? user = _unset,
    String? message,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user == _unset ? this.user : user as LocalUser?,
      message: message,
    );
  }

  static const AuthState idle = AuthState(
    status: AuthStatus.idle,
  );
}
