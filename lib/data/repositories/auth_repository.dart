import 'package:my_project/domain/models/local_user.dart';

abstract class AuthRepository {
  Future<void> saveUser(LocalUser user);
  Future<LocalUser?> getUser();
  Future<void> setLoggedIn(bool value);
  Future<bool> isLoggedIn();
  Future<bool> validateLogin(String email, String password);
  Future<void> clearUser();
}
