import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:app_todo/features/tasks/view_model/auth_model.dart';

class CreateAccountPage extends StatelessWidget {
  const CreateAccountPage({super.key});

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
    final body = _CreateAccountBody(isIOS: isIOS);
    if (isIOS) {
      return CupertinoPageScaffold(
        backgroundColor: _backgroundColor,
        navigationBar: const CupertinoNavigationBar(
          backgroundColor: _backgroundColor,
          middle: Text(
            'Criar Conta',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: _titleColor,
            ),
          ),
        ),
        child: body,
      );
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: _backgroundColor,
        foregroundColor: _titleColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Criar Conta',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: body,
    );
  }
}

class _CreateAccountBody extends StatefulWidget {
  const _CreateAccountBody({required this.isIOS});

  final bool isIOS;

  @override
  State<_CreateAccountBody> createState() => _CreateAccountBodyState();
}

class _CreateAccountBodyState extends State<_CreateAccountBody> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  static const Color _accentGreen = CreateAccountPage._accentGreen;
  static const Color _titleColor = CreateAccountPage._titleColor;
  static const Color _mutedColor = CreateAccountPage._mutedColor;
  static const Color _borderColor = CreateAccountPage._borderColor;
  static const Color _requiredColor = CreateAccountPage._requiredColor;
  static const Color _hintColor = CreateAccountPage._hintColor;

  bool get isIOS => widget.isIOS;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthModel>();
    return SafeArea(
      top: false,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: isIOS
                ? const BouncingScrollPhysics()
                : const ClampingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 8),
                  const Center(
                    child: Text(
                      'Preencha os dados para criar sua conta',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: _mutedColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  _buildFieldLabel('Nome completo'),
                  const SizedBox(height: 10),
                  _buildNameField(),
                  const SizedBox(height: 22),
                  _buildFieldLabel('Email'),
                  const SizedBox(height: 10),
                  _buildEmailField(),
                  const SizedBox(height: 22),
                  _buildFieldLabel('Senha'),
                  const SizedBox(height: 10),
                  _buildPasswordField(
                    controller: _passwordController,
                    placeholder: '••••••••',
                  ),
                  const SizedBox(height: 22),
                  _buildFieldLabel('Confirmar senha'),
                  const SizedBox(height: 10),
                  _buildPasswordField(
                    controller: _confirmPasswordController,
                    placeholder: '••••••••',
                  ),
                  const SizedBox(height: 30),
                  _buildSubmitButton(context, auth.isBusy),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNameField() {
    if (isIOS) {
      return _buildCupertinoField(
        controller: _nameController,
        placeholder: 'João Silva',
        textCapitalization: TextCapitalization.words,
      );
    }
    return TextField(
      controller: _nameController,
      textCapitalization: TextCapitalization.words,
      decoration: _inputDecoration('João Silva'),
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

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String placeholder,
  }) {
    if (isIOS) {
      return _buildCupertinoField(
        controller: controller,
        placeholder: placeholder,
        obscureText: true,
        suffix: const Padding(
          padding: EdgeInsets.only(right: 12),
          child: Icon(CupertinoIcons.eye, color: _mutedColor, size: 20),
        ),
      );
    }
    return TextField(
      controller: controller,
      obscureText: true,
      decoration: _inputDecoration(
        placeholder,
        suffixIcon: const Icon(
          Icons.visibility_outlined,
          color: _mutedColor,
        ),
      ),
    );
  }

  Widget _buildSubmitButton(BuildContext context, bool isBusy) {
    final onPressed = isBusy ? null : () => _handleSubmit(context);
    if (isIOS) {
      return SizedBox(
        height: 54,
        child: CupertinoButton(
          padding: EdgeInsets.zero,
          borderRadius: BorderRadius.circular(28),
          color: _accentGreen,
          onPressed: onPressed,
          child: const Text(
            'Criar conta',
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
          'Criar conta',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Future<void> _handleSubmit(BuildContext context) async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;
    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos.')),
      );
      return;
    }
    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('As senhas não coincidem.')),
      );
      return;
    }
    final auth = context.read<AuthModel>();
    final success = await auth.signUp(
      name: name,
      email: email,
      password: password,
    );
    if (!mounted) {
      return;
    }
    if (!success) {
      final message = auth.errorMessage ?? 'Não foi possível criar a conta.';
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Conta criada. Verifique seu email para continuar.'),
      ),
    );
    Navigator.of(context).maybePop();
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
    TextCapitalization textCapitalization = TextCapitalization.none,
    Widget? suffix,
  }) {
    return CupertinoTextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      textCapitalization: textCapitalization,
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
