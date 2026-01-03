import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

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

class _CreateAccountBody extends StatelessWidget {
  const _CreateAccountBody({required this.isIOS});

  final bool isIOS;

  static const Color _accentGreen = CreateAccountPage._accentGreen;
  static const Color _titleColor = CreateAccountPage._titleColor;
  static const Color _mutedColor = CreateAccountPage._mutedColor;
  static const Color _borderColor = CreateAccountPage._borderColor;
  static const Color _requiredColor = CreateAccountPage._requiredColor;
  static const Color _hintColor = CreateAccountPage._hintColor;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics:
                isIOS ? const BouncingScrollPhysics() : const ClampingScrollPhysics(),
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
                  _buildPasswordField(placeholder: '••••••••'),
                  const SizedBox(height: 22),
                  _buildFieldLabel('Confirmar senha'),
                  const SizedBox(height: 10),
                  _buildPasswordField(placeholder: '••••••••'),
                  const SizedBox(height: 30),
                  _buildSubmitButton(),
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
        placeholder: 'João Silva',
        textCapitalization: TextCapitalization.words,
      );
    }
    return TextField(
      textCapitalization: TextCapitalization.words,
      decoration: _inputDecoration('João Silva'),
    );
  }

  Widget _buildEmailField() {
    if (isIOS) {
      return _buildCupertinoField(
        placeholder: 'seu@email.com',
        keyboardType: TextInputType.emailAddress,
      );
    }
    return TextField(
      keyboardType: TextInputType.emailAddress,
      decoration: _inputDecoration('seu@email.com'),
    );
  }

  Widget _buildPasswordField({required String placeholder}) {
    if (isIOS) {
      return _buildCupertinoField(
        placeholder: placeholder,
        obscureText: true,
        suffix: const Padding(
          padding: EdgeInsets.only(right: 12),
          child: Icon(CupertinoIcons.eye, color: _mutedColor, size: 20),
        ),
      );
    }
    return TextField(
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

  Widget _buildSubmitButton() {
    if (isIOS) {
      return SizedBox(
        height: 54,
        child: CupertinoButton(
          padding: EdgeInsets.zero,
          borderRadius: BorderRadius.circular(28),
          color: _accentGreen,
          onPressed: () {},
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
        onPressed: () {},
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
    required String placeholder,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
    bool obscureText = false,
    Widget? suffix,
  }) {
    return CupertinoTextField(
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
