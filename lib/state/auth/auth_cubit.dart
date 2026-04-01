import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_project/domain/models/local_user.dart';
import 'package:my_project/services/auth_store.dart';
import 'package:my_project/state/auth/auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._authStore) : super(AuthState.idle);

  final AuthStore _authStore;

  Future<void> loadUser() async {
    emit(state.copyWith(status: AuthStatus.loading));
    final user = await _authStore.getUser();
    if (user == null) {
      emit(state.copyWith(status: AuthStatus.unauthenticated));
      return;
    }
    emit(
      state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
      ),
    );
  }

  Future<void> login(String email, String password) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      final isValid = await _authStore.validateLogin(email, password);
      if (!isValid) {
        emit(
          state.copyWith(
            status: AuthStatus.error,
            message: 'Incorrect email or password.',
          ),
        );
        return;
      }
      await _authStore.setLoggedIn(true);
      final user = await _authStore.getUser();
      emit(
        state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: AuthStatus.error,
          message: 'Failed to sign in.',
        ),
      );
    }
  }

  Future<void> register(LocalUser user) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      await _authStore.saveUser(user);
      await _authStore.setLoggedIn(true);
      emit(
        state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: AuthStatus.error,
          message: error.toString(),
        ),
      );
    }
  }

  Future<void> updateProfile(LocalUser user) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      await _authStore.saveUser(user);
      emit(
        state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: AuthStatus.error,
          message: 'Failed to update profile.',
        ),
      );
    }
  }

  Future<void> logout() async {
    await _authStore.setLoggedIn(false);
    emit(state.copyWith(status: AuthStatus.unauthenticated, user: null));
  }

  Future<void> deleteProfile() async {
    await _authStore.clearUser();
    emit(state.copyWith(status: AuthStatus.unauthenticated, user: null));
  }
}
