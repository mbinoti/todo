import 'package:app_todo/features/tasks/models/auth_user.dart';

/// Auth contract used by the view models.
abstract class AuthRepository {
  Stream<AuthUser?> authStateChanges();

  AuthUser? get currentUser;

  Future<AuthUser> signIn({
    required String email,
    required String password,
  });

  Future<AuthUser> signUp({
    required String name,
    required String email,
    required String password,
  });

  Future<void> sendEmailVerification();

  Future<AuthUser?> reloadCurrentUser();

  Future<void> signOut();
}

/// Normalized auth failure used outside the auth provider.
class AuthFailure implements Exception {
  const AuthFailure(this.code, [this.message]);

  final String code;
  final String? message;
}
