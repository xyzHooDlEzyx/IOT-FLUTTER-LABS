import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:my_project/data/repositories/auth_repository.dart';
import 'package:my_project/data/repositories/firebase_auth_repository.dart';
import 'package:my_project/data/repositories/local_auth_repository.dart';
import 'package:my_project/data/storage/shared_prefs_storage.dart';
import 'package:my_project/data/storage/token_storage.dart';
import 'package:my_project/domain/models/local_user.dart';

class AuthStore {
  AuthStore(this._repository);

  static final AuthStore instance = AuthStore(
    FirebaseAuthRepository(
      auth: FirebaseAuth.instance,
      firestore: FirebaseFirestore.instanceFor(
        app: Firebase.app(),
        databaseId: 'data-db-mob',
      ),
      local: LocalAuthRepository(SharedPrefsStorage()),
      tokenStorage: TokenStorage(const FlutterSecureStorage()),
    ),
  );

  final AuthRepository _repository;

  Future<void> saveUser(LocalUser user) async {
    await _repository.saveUser(user);
  }

  Future<LocalUser?> getUser() async {
    return _repository.getUser();
  }

  Future<void> setLoggedIn(bool value) async {
    await _repository.setLoggedIn(value);
  }

  Future<bool> isLoggedIn() async {
    return _repository.isLoggedIn();
  }

  Future<bool> validateLogin(String email, String password) async {
    return _repository.validateLogin(email, password);
  }

  Future<void> clearUser() async {
    await _repository.clearUser();
  }
}
