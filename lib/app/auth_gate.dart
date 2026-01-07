import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import 'package:app_todo/features/tasks/pages/login_page.dart';
import 'package:app_todo/features/tasks/pages/splash_page.dart';
import 'package:app_todo/features/tasks/pages/tasks_page.dart';
import 'package:app_todo/features/tasks/pages/verify_email_page.dart';
import 'package:app_todo/features/tasks/view_model/auth_model.dart';

/// Displays the right entry screen based on authentication state.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthModel>();
    if (!auth.isReady) {
      return const SplashPage();
    }
    if (!auth.isLoggedIn) {
      return const LoginPage();
    }
    if (!auth.isEmailVerified) {
      return const VerifyEmailPage();
    }
    return const TasksPage();
  }
}
