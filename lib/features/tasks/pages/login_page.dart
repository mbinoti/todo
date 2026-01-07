import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:app_todo/features/tasks/pages/create_account_page.dart';
import 'package:app_todo/features/tasks/view_model/auth_model.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  static const Color _accentGreen = Color(0xFF21B66E);
  static const Color _titleColor = Color(0xFF1D1E20);
  static const Color _mutedColor = Color(0xFF8C9097);
  static const Color _borderColor = Color(0xFFE1E4E8);
  static const Color _requiredColor = Color(0xFFE35D6A);
  static const Color _backgroundColor = Color(0xFFF6F7F8);
  static const Color _hintColor = Color(0xFFB6B9BE);

  @override
  Widget build(BuildContext context) {
    final isIOS = defaultTargetPlatform == TargetPlatform.iOS;
    if (isIOS) {
      return CupertinoPageScaffold(
        backgroundColor: _backgroundColor,
        child: const _LoginBody(isIOS: true),
      );
    }
    return Scaffold(body: _LoginBody(isIOS: isIOS));
  }
}

class _LoginBody extends StatefulWidget {
  const _LoginBody({required this.isIOS});

  final bool isIOS;

  @override
  State<_LoginBody> createState() => _LoginBodyState();
}

class _LoginBodyState extends State<_LoginBody> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  static const Color _accentGreen = LoginPage._accentGreen;
  static const Color _titleColor = LoginPage._titleColor;
  static const Color _mutedColor = LoginPage._mutedColor;
  static const Color _borderColor = LoginPage._borderColor;
  static const Color _requiredColor = LoginPage._requiredColor;
  static const Color _hintColor = LoginPage._hintColor;

  bool get isIOS => widget.isIOS;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthModel>();
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: isIOS
                ? const BouncingScrollPhysics()
                : const ClampingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 18),
                  Center(child: _buildLogo()),
                  const SizedBox(height: 18),
                  const Center(
                    child: Text(
                      'TaskFlow',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: _titleColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Center(
                    child: Text(
                      'Bem-vindo de volta',
                      style: TextStyle(fontSize: 16, color: _mutedColor),
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildFieldLabel('Email'),
                  const SizedBox(height: 10),
                  _buildEmailField(),
                  const SizedBox(height: 22),
                  _buildFieldLabel('Senha'),
                  const SizedBox(height: 10),
                  _buildPasswordField(),
                  const SizedBox(height: 14),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: _buildForgotPasswordAction(context),
                  ),
                  const SizedBox(height: 24),
                  _buildLoginButton(context, auth.isBusy),
                  const SizedBox(height: 26),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Não tem uma conta? ',
                        style: TextStyle(color: _mutedColor),
                      ),
                      _buildCreateAccountAction(context),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLogo() {
    final iconData = isIOS
        ? CupertinoIcons.check_mark
        : Icons.check_box_outlined;
    return Container(
      width: 92,
      height: 92,
      decoration: BoxDecoration(
        color: _accentGreen,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Center(child: Icon(iconData, size: 44, color: Colors.white)),
    );
  }

  Widget _buildEmailField() {
    if (isIOS) {
      return _buildCupertinoField(
        controller: _emailController,
        placeholder: 'seu@email.com',
        keyboardType: TextInputType.emailAddress,
      );
    }
    return TextField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: _inputDecoration('seu@email.com'),
    );
  }

  Widget _buildPasswordField() {
    if (isIOS) {
      return _buildCupertinoField(
        controller: _passwordController,
        placeholder: '••••••••',
        obscureText: true,
        suffix: const Padding(
          padding: EdgeInsets.only(right: 12),
          child: Icon(CupertinoIcons.eye, color: _mutedColor, size: 20),
        ),
      );
    }
    return TextField(
      controller: _passwordController,
      obscureText: true,
      decoration: _inputDecoration(
        '••••••••',
        suffixIcon: const Icon(Icons.visibility_outlined, color: _mutedColor),
      ),
    );
  }

  Widget _buildLoginButton(BuildContext context, bool isBusy) {
    final onPressed = isBusy ? null : () => _handleLogin(context);
    if (isIOS) {
      return SizedBox(
        height: 54,
        child: CupertinoButton(
          padding: EdgeInsets.zero,
          borderRadius: BorderRadius.circular(28),
          color: _accentGreen,
          onPressed: onPressed,
          child: const Text(
            'Entrar',
            style: TextStyle(
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
        child: const Text(
          'Entrar',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Future<void> _handleLogin(BuildContext context) async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe email e senha.')),
      );
      return;
    }
    final auth = context.read<AuthModel>();
    final success = await auth.signIn(email: email, password: password);
    if (!success && mounted) {
      final message = auth.errorMessage ?? 'Não foi possível entrar.';
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    }
  }

  void _showForgotPasswordMessage(BuildContext context) {
    const message = 'Funcionalidade em desenvolvimento.';
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text(message)));
  }

  Widget _buildForgotPasswordAction(BuildContext context) {
    if (isIOS) {
      return CupertinoButton(
        padding: EdgeInsets.zero,
        minimumSize: Size.zero,
        onPressed: () => _showForgotPasswordMessage(context),
        child: const Text(
          'Esqueci minha senha',
          style: TextStyle(color: _accentGreen, fontWeight: FontWeight.w600),
        ),
      );
    }
    return TextButton(
      onPressed: () => _showForgotPasswordMessage(context),
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        foregroundColor: _accentGreen,
      ),
      child: const Text(
        'Esqueci minha senha',
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }

  void _openCreateAccount(BuildContext context) {
    final route = isIOS
        ? CupertinoPageRoute<void>(builder: (_) => const CreateAccountPage())
        : MaterialPageRoute<void>(builder: (_) => const CreateAccountPage());
    Navigator.of(context).push(route);
  }

  Widget _buildCreateAccountAction(BuildContext context) {
    if (isIOS) {
      return CupertinoButton(
        padding: EdgeInsets.zero,
        minSize: 0,
        onPressed: () => _openCreateAccount(context),
        child: const Text(
          'Criar conta',
          style: TextStyle(color: _accentGreen, fontWeight: FontWeight.w600),
        ),
      );
    }
    return TextButton(
      onPressed: () => _openCreateAccount(context),
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        foregroundColor: _accentGreen,
      ),
      child: const Text(
        'Criar conta',
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: _titleColor,
          ),
        ),
        const SizedBox(width: 4),
        const Text(
          '*',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: _requiredColor,
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String hintText, {Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: _hintColor),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: _borderColor, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: _accentGreen, width: 1.2),
      ),
      suffixIcon: suffixIcon == null
          ? null
          : Padding(
              padding: const EdgeInsets.only(right: 8),
              child: suffixIcon,
            ),
    );
  }

  Widget _buildCupertinoField({
    required TextEditingController controller,
    required String placeholder,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffix,
  }) {
    return CupertinoTextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      placeholder: placeholder,
      placeholderStyle: const TextStyle(color: _hintColor),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor, width: 1),
      ),
      suffix: suffix,
      suffixMode: suffix == null
          ? OverlayVisibilityMode.never
          : OverlayVisibilityMode.always,
    );
  }
}
