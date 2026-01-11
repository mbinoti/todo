import 'dart:async';

import 'package:hive/hive.dart';

import 'package:app_todo/features/tasks/models/auth_user.dart';
import 'package:app_todo/features/tasks/repository/auth_repository.dart';

/// Local auth implementation backed by Hive for persistence.
class LocalAuthRepository implements AuthRepository {
  LocalAuthRepository(this._box) {
    _loadFromStorage();
  }

  final Box<dynamic> _box;
  static const String _accountsKey = 'accounts';
  static const String _currentUidKey = 'currentUid';

  final StreamController<AuthUser?> _authController =
      StreamController<AuthUser?>.broadcast();
  final Map<String, _LocalAccount> _accountsByEmail = {};
  final Map<String, _LocalAccount> _accountsById = {};
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
    await _persistState();
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
    _accountsById[uid] = account;
    _currentAccount = account;
    _authController.add(account.toAuthUser());
    await _persistState();
    return account.toAuthUser();
  }

  @override
  Future<void> sendEmailVerification() async {
    final account = _currentAccount;
    if (account == null) {
      return;
    }
    account.verificationRequested = true;
    await _persistState();
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
      await _persistState();
    }
    return account.toAuthUser();
  }

  @override
  Future<void> signOut() async {
    _currentAccount = null;
    _authController.add(null);
    await _persistState();
  }

  bool _isValidEmail(String email) {
    return email.contains('@') && email.contains('.');
  }

  void _loadFromStorage() {
    final storedAccounts = _box.get(_accountsKey);
    if (storedAccounts is List) {
      for (final raw in storedAccounts) {
        if (raw is Map) {
          final account = _LocalAccount.fromMap(raw);
          if (account.uid.isEmpty || account.email.isEmpty) {
            continue;
          }
          _accountsByEmail[account.email] = account;
          _accountsById[account.uid] = account;
          _counter = _maxCounter(_counter, account.uid);
        }
      }
    }
    final currentUid = _box.get(_currentUidKey);
    if (currentUid is String) {
      _currentAccount = _accountsById[currentUid];
    }
  }

  int _maxCounter(int current, String uid) {
    const prefix = 'local_';
    if (!uid.startsWith(prefix)) {
      return current;
    }
    final value = int.tryParse(uid.substring(prefix.length));
    if (value == null) {
      return current;
    }
    return value > current ? value : current;
  }

  Future<void> _persistState() {
    final accounts = _accountsById.values
        .map((account) => account.toMap())
        .toList(growable: false);
    return Future.wait([
      _box.put(_accountsKey, accounts),
      _box.put(_currentUidKey, _currentAccount?.uid),
    ]);
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

  Map<String, Object?> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'password': password,
      'emailVerified': emailVerified,
      'verificationRequested': verificationRequested,
    };
  }

  static _LocalAccount fromMap(Map<dynamic, dynamic> data) {
    return _LocalAccount(
      uid: data['uid'] as String? ?? '',
      email: (data['email'] as String? ?? '').trim().toLowerCase(),
      displayName: data['displayName'] as String?,
      password: data['password'] as String? ?? '',
      emailVerified: data['emailVerified'] as bool? ?? false,
    )..verificationRequested =
        data['verificationRequested'] as bool? ?? false;
  }
}
