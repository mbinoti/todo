import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:app_todo/features/tasks/models/auth_user.dart';
import 'package:app_todo/features/tasks/models/user_preferences.dart';
import 'package:app_todo/features/tasks/models/user_profile.dart';
import 'package:app_todo/features/tasks/repository/auth_repository.dart';
import 'package:app_todo/features/tasks/repository/user_repository.dart';

/// Handles authentication state and user onboarding.
class AuthModel extends ChangeNotifier {
  AuthModel({
    required AuthRepository authRepository,
    required UserRepository userRepository,
  })  : _authRepository = authRepository,
        _userRepository = userRepository {
    _authSubscription =
        _authRepository.authStateChanges().listen(_handleAuthChanged);
  }

  final AuthRepository _authRepository;
  final UserRepository _userRepository;
  StreamSubscription<AuthUser?>? _authSubscription;

  AuthUser? _currentUser;
  bool _isReady = false;
  bool _isBusy = false;
  String? _errorMessage;

  AuthUser? get currentUser => _currentUser;
  bool get isReady => _isReady;
  bool get isBusy => _isBusy;
  bool get isLoggedIn => _currentUser != null;
  bool get isEmailVerified => _currentUser?.emailVerified ?? false;
  String? get errorMessage => _errorMessage;

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _setBusy(true);
    _errorMessage = null;
    try {
      final user = await _authRepository.signIn(
        email: email,
        password: password,
      );
      await _userRepository.ensureProfile(
        uid: user.uid,
        email: user.email ?? email,
        name: user.displayName,
      );
      return true;
    } catch (error) {
      _errorMessage = _mapAuthError(error);
      return false;
    } finally {
      _setBusy(false);
    }
  }

  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    _setBusy(true);
    _errorMessage = null;
    try {
      final user = await _authRepository.signUp(
        name: name,
        email: email,
        password: password,
      );
      final profile = UserProfile(
        uid: user.uid,
        name: name,
        email: email,
        photoUrl: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        preferences: const UserPreferences(),
      );
      await _userRepository.createProfile(profile);
      return true;
    } catch (error) {
      _errorMessage = _mapAuthError(error);
      return false;
    } finally {
      _setBusy(false);
    }
  }

  Future<void> sendEmailVerification() async {
    await _authRepository.sendEmailVerification();
  }

  Future<void> refreshCurrentUser() async {
    final user = await _authRepository.reloadCurrentUser();
    _handleAuthChanged(user);
  }

  Future<void> signOut() async {
    _setBusy(true);
    _errorMessage = null;
    try {
      await _authRepository.signOut();
    } catch (error) {
      _errorMessage = _mapAuthError(error);
    } finally {
      _setBusy(false);
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _handleAuthChanged(AuthUser? user) {
    _currentUser = user;
    _isReady = true;
    notifyListeners();
  }

  void _setBusy(bool value) {
    if (_isBusy == value) {
      return;
    }
    _isBusy = value;
    notifyListeners();
  }

  String _mapAuthError(Object error) {
    if (error is AuthFailure) {
      switch (error.code) {
        case 'invalid-email':
          return 'Email inválido.';
        case 'user-disabled':
          return 'Usuário desativado.';
        case 'user-not-found':
          return 'Usuário não encontrado.';
        case 'wrong-password':
          return 'Senha incorreta.';
        case 'email-already-in-use':
          return 'Email já está em uso.';
        case 'weak-password':
          return 'Senha muito fraca.';
        case 'too-many-requests':
          return 'Muitas tentativas. Tente novamente mais tarde.';
        case 'network-request-failed':
          return 'Falha de rede. Verifique sua conexão.';
        default:
          return error.message ?? 'Falha ao autenticar.';
      }
    }
    return 'Não foi possível autenticar. Tente novamente.';
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
