import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:my_project/data/repositories/auth_repository.dart';
import 'package:my_project/data/repositories/local_auth_repository.dart';
import 'package:my_project/data/storage/token_storage.dart';
import 'package:my_project/domain/models/local_user.dart';

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository({
    required FirebaseAuth auth,
    required FirebaseFirestore firestore,
    required LocalAuthRepository local,
    required TokenStorage tokenStorage,
  })  : _auth = auth,
        _firestore = firestore,
        _local = local,
        _tokenStorage = tokenStorage;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final LocalAuthRepository _local;
  final TokenStorage _tokenStorage;
  @override
  Future<void> saveUser(LocalUser user) async {
    final current = _auth.currentUser;
    final firebaseUser = current ??
        await _auth
            .createUserWithEmailAndPassword(
              email: user.email,
              password: user.password,
            )
            .then((value) => value.user);
    if (firebaseUser == null) {
      return;
    }

    await _firestore.collection('users').doc(firebaseUser.uid).set({
      'fullName': user.fullName,
      'email': user.email,
      'company': user.company,
    });
    await _local.saveUser(user);
    await _cacheToken(firebaseUser);
  }
  @override
  Future<LocalUser?> getUser() async {
    final cached = await _local.getUser();
    if (cached != null) {
      return cached;
    }

    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) {
      return null;
    }

    final snapshot =
        await _firestore.collection('users').doc(firebaseUser.uid).get();
    final data = snapshot.data();
    if (data == null) {
      return null;
    }

    final fullName = data['fullName'];
    final email = data['email'];
    final company = data['company'];
    if (fullName is! String || email is! String || company is! String) {
      return null;
    }

    final user = LocalUser(
      fullName: fullName,
      email: email,
      password: '',
      company: company,
    );
    await _local.saveUser(user);
    await _cacheToken(firebaseUser);
    return user;
  }
  @override
  Future<void> setLoggedIn(bool value) async {
    await _local.setLoggedIn(value);
    if (!value) {
      await _auth.signOut();
      await _tokenStorage.clearToken();
    }
  }
  @override
  Future<bool> isLoggedIn() async {
    if (await _local.isLoggedIn()) {
      return true;
    }
    return _auth.currentUser != null;
  }
  @override
  Future<bool> validateLogin(String email, String password) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final firebaseUser = result.user;
      if (firebaseUser == null) {
        return false;
      }

      final snapshot =
          await _firestore.collection('users').doc(firebaseUser.uid).get();
      final data = snapshot.data();
      if (data == null) {
        return false;
      }

      final fullName = data['fullName'];
      final company = data['company'];
      if (fullName is! String || company is! String) {
        return false;
      }

      final user = LocalUser(
        fullName: fullName,
        email: email,
        password: password,
        company: company,
      );
      await _local.saveUser(user);
      await _cacheToken(firebaseUser);
      return true;
    } on FirebaseAuthException {
      return false;
    }
  }
  @override
  Future<void> clearUser() async {
    await _auth.signOut();
    await _tokenStorage.clearToken();
    await _local.clearUser();
  }
  Future<void> _cacheToken(User firebaseUser) async {
    final token = await firebaseUser.getIdToken();
    if (token == null || token.isEmpty) {
      return;
    }
    await _tokenStorage.saveToken(token);
  }
}
