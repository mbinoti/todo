import 'package:firebase_auth/firebase_auth.dart';

import 'package:app_todo/features/tasks/models/auth_user.dart';
import 'package:app_todo/features/tasks/repository/auth_repository.dart';

/// Firebase-backed implementation of AuthRepository.
class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository(this._auth);

  final FirebaseAuth _auth;

  @override
  Stream<AuthUser?> authStateChanges() {
    return _auth.authStateChanges().map(_mapUser);
  }

  @override
  AuthUser? get currentUser => _mapUser(_auth.currentUser);

  @override
  Future<AuthUser> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        throw const AuthFailure('user-not-found');
      }
      return _mapUser(user)!;
    } on FirebaseAuthException catch (error) {
      throw AuthFailure(error.code, error.message);
    }
  }

  @override
  Future<AuthUser> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        throw const AuthFailure('user-not-found');
      }
      await user.updateDisplayName(name);
      await user.sendEmailVerification();
      await user.reload();
      return _mapUser(_auth.currentUser)!;
    } on FirebaseAuthException catch (error) {
      throw AuthFailure(error.code, error.message);
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    final user = _auth.currentUser;
    if (user == null) {
      return;
    }
    await user.sendEmailVerification();
  }

  @override
  Future<AuthUser?> reloadCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) {
      return null;
    }
    await user.reload();
    return _mapUser(_auth.currentUser);
  }

  @override
  Future<void> signOut() {
    return _auth.signOut();
  }

  AuthUser? _mapUser(User? user) {
    if (user == null) {
      return null;
    }
    return AuthUser(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
      emailVerified: user.emailVerified,
    );
  }
}
