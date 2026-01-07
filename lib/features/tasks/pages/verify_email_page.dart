import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:app_todo/features/tasks/view_model/auth_model.dart';

class VerifyEmailPage extends StatelessWidget {
  const VerifyEmailPage({super.key});

  static const Color _accentGreen = Color(0xFF21B66E);
  static const Color _titleColor = Color(0xFF1D1E20);
  static const Color _mutedColor = Color(0xFF8C9097);
  static const Color _backgroundColor = Color(0xFFF6F7F8);

  @override
  Widget build(BuildContext context) {
    final isIOS = defaultTargetPlatform == TargetPlatform.iOS;
    final body = _VerifyEmailBody(isIOS: isIOS);
    if (isIOS) {
      return CupertinoPageScaffold(
        backgroundColor: _backgroundColor,
        child: body,
      );
    }
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: body,
    );
  }
}

class _VerifyEmailBody extends StatelessWidget {
  const _VerifyEmailBody({required this.isIOS});

  final bool isIOS;

  static const Color _accentGreen = VerifyEmailPage._accentGreen;
  static const Color _titleColor = VerifyEmailPage._titleColor;
  static const Color _mutedColor = VerifyEmailPage._mutedColor;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthModel>();
    final email = auth.currentUser?.email ?? '';
    final errorMessage = auth.errorMessage;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 24),
            const Icon(CupertinoIcons.mail, size: 64, color: _accentGreen),
            const SizedBox(height: 24),
            const Text(
              'Verifique seu email',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: _titleColor,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Enviamos um link de verificação para $email.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: _mutedColor),
            ),
            if (errorMessage != null) ...[
              const SizedBox(height: 16),
              Text(
                errorMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.redAccent),
              ),
            ],
            const Spacer(),
            _buildPrimaryButton(
              context,
              label: 'Já verifiquei',
              onPressed: auth.isBusy ? null : () => _refresh(context),
            ),
            const SizedBox(height: 12),
            _buildSecondaryButton(
              context,
              label: 'Reenviar email',
              onPressed: auth.isBusy ? null : () => _resend(context),
            ),
            const SizedBox(height: 12),
            _buildTextButton(
              context,
              label: 'Sair',
              onPressed: auth.isBusy ? null : () => auth.signOut(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrimaryButton(
    BuildContext context, {
    required String label,
    required VoidCallback? onPressed,
  }) {
    if (isIOS) {
      return SizedBox(
        height: 54,
        child: CupertinoButton(
          padding: EdgeInsets.zero,
          borderRadius: BorderRadius.circular(28),
          color: _accentGreen,
          onPressed: onPressed,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      );
    }
    return SizedBox(
      height: 54,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: _accentGreen,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildSecondaryButton(
    BuildContext context, {
    required String label,
    required VoidCallback? onPressed,
  }) {
    if (isIOS) {
      return SizedBox(
        height: 54,
        child: CupertinoButton(
          padding: EdgeInsets.zero,
          borderRadius: BorderRadius.circular(28),
          color: Colors.white,
          onPressed: onPressed,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: _accentGreen,
            ),
          ),
        ),
      );
    }
    return SizedBox(
      height: 54,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          foregroundColor: _accentGreen,
          side: const BorderSide(color: _accentGreen, width: 1.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildTextButton(
    BuildContext context, {
    required String label,
    required VoidCallback? onPressed,
  }) {
    if (isIOS) {
      return CupertinoButton(
        padding: EdgeInsets.zero,
        minimumSize: Size.zero,
        onPressed: onPressed,
        child: Text(
          label,
          style: const TextStyle(
            color: _mutedColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        foregroundColor: _mutedColor,
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
    );
  }

  Future<void> _refresh(BuildContext context) async {
    final auth = context.read<AuthModel>();
    await auth.refreshCurrentUser();
    if (!auth.isEmailVerified) {
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        const SnackBar(content: Text('Email ainda não verificado.')),
      );
    }
  }

  Future<void> _resend(BuildContext context) async {
    final auth = context.read<AuthModel>();
    await auth.sendEmailVerification();
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      const SnackBar(content: Text('Email de verificação enviado.')),
    );
  }
}
