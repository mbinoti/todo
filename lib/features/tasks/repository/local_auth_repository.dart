import 'dart:async';

import 'package:app_todo/features/tasks/models/auth_user.dart';
import 'package:app_todo/features/tasks/repository/auth_repository.dart';

/// Simple in-memory auth implementation for local-only data.
class LocalAuthRepository implements AuthRepository {
  LocalAuthRepository();

  final StreamController<AuthUser?> _authController =
      StreamController<AuthUser?>.broadcast();
  final Map<String, _LocalAccount> _accountsByEmail = {};
  _LocalAccount? _currentAccount;
  int _counter = 0;

  @override
  Stream<AuthUser?> authStateChanges() {
    Future.microtask(() {
      if (_authController.isClosed) {
        return;
      }
      _authController.add(_currentAccount?.toAuthUser());
    });
    return _authController.stream;
  }

  @override
  AuthUser? get currentUser => _currentAccount?.toAuthUser();

  @override
  Future<AuthUser> signIn({
    required String email,
    required String password,
  }) async {
    final normalized = email.trim().toLowerCase();
    final account = _accountsByEmail[normalized];
    if (account == null) {
      throw const AuthFailure('user-not-found');
    }
    if (account.password != password) {
      throw const AuthFailure('wrong-password');
    }
    _currentAccount = account;
    _authController.add(account.toAuthUser());
    return account.toAuthUser();
  }

  @override
  Future<AuthUser> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    final normalized = email.trim().toLowerCase();
    if (!_isValidEmail(normalized)) {
      throw const AuthFailure('invalid-email');
    }
    if (password.length < 6) {
      throw const AuthFailure('weak-password');
    }
    if (_accountsByEmail.containsKey(normalized)) {
      throw const AuthFailure('email-already-in-use');
    }
    final uid = 'local_${++_counter}';
    final account = _LocalAccount(
      uid: uid,
      email: normalized,
      displayName: name.trim().isEmpty ? null : name.trim(),
      password: password,
      emailVerified: false,
    );
    account.verificationRequested = true;
    _accountsByEmail[normalized] = account;
    _currentAccount = account;
    _authController.add(account.toAuthUser());
    return account.toAuthUser();
  }

  @override
  Future<void> sendEmailVerification() async {
    final account = _currentAccount;
    if (account == null) {
      return;
    }
    account.verificationRequested = true;
  }

  @override
  Future<AuthUser?> reloadCurrentUser() async {
    final account = _currentAccount;
    if (account == null) {
      return null;
    }
    if (!account.emailVerified && account.verificationRequested) {
      account.emailVerified = true;
      _authController.add(account.toAuthUser());
    }
    return account.toAuthUser();
  }

  @override
  Future<void> signOut() async {
    _currentAccount = null;
    _authController.add(null);
  }

  bool _isValidEmail(String email) {
    return email.contains('@') && email.contains('.');
  }
}

class _LocalAccount {
  _LocalAccount({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.password,
    required this.emailVerified,
  });

  final String uid;
  final String email;
  final String? displayName;
  final String password;
  bool emailVerified;
  bool verificationRequested = false;

  AuthUser toAuthUser() {
    return AuthUser(
      uid: uid,
      email: email,
      displayName: displayName,
      emailVerified: emailVerified,
    );
  }
}
