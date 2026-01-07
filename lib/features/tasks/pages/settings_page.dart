import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:app_todo/features/tasks/view_model/profile_model.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  static const Color _accentGreen = Color(0xFF21B66E);
  static const Color _titleColor = Color(0xFF1D1E20);
  static const Color _mutedColor = Color(0xFF8C9097);
  static const Color _sectionColor = Color(0xFF7D8188);
  static const Color _dividerColor = Color(0xFFE1E4E8);
  static const Color _cardBorderColor = Color(0xFFE1E4E8);
  static const Color _iconColor = Color(0xFF6F7380);

  @override
  Widget build(BuildContext context) {
    final isIOS = defaultTargetPlatform == TargetPlatform.iOS;
    final profile = context.watch<ProfileModel>();
    final body = _SettingsBody(
      isIOS: isIOS,
      notificationsEnabled: profile.preferences.notificationsEnabled,
      language: profile.preferences.language,
      onNotificationsChanged: (value) {
        profile.updatePreferences(notificationsEnabled: value);
      },
    );
    if (isIOS) {
      return CupertinoPageScaffold(
        backgroundColor: Colors.white,
        navigationBar: CupertinoNavigationBar(
          backgroundColor: Colors.white,
          border: const Border(
            bottom: BorderSide(
              color: SettingsPage._dividerColor,
              width: 0.6,
            ),
          ),
          leading: CupertinoButton(
            padding: EdgeInsets.zero,
            minSize: 0,
            onPressed: () => Navigator.of(context).maybePop(),
            child: const Icon(
              CupertinoIcons.back,
              color: SettingsPage._titleColor,
              size: 26,
            ),
          ),
          middle: const Text(
            'Configurações',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: SettingsPage._titleColor,
            ),
          ),
        ),
        child: body,
      );
    }
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: SettingsPage._titleColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: const Text(
          'Configurações',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: SettingsPage._dividerColor),
        ),
      ),
      body: body,
    );
  }
}

class _SettingsBody extends StatelessWidget {
  const _SettingsBody({
    required this.isIOS,
    required this.notificationsEnabled,
    required this.language,
    required this.onNotificationsChanged,
  });

  final bool isIOS;
  final bool notificationsEnabled;
  final String language;
  final ValueChanged<bool> onNotificationsChanged;

  static const Color _accentGreen = SettingsPage._accentGreen;
  static const Color _titleColor = SettingsPage._titleColor;
  static const Color _mutedColor = SettingsPage._mutedColor;
  static const Color _sectionColor = SettingsPage._sectionColor;
  static const Color _dividerColor = SettingsPage._dividerColor;
  static const Color _cardBorderColor = SettingsPage._cardBorderColor;
  static const Color _iconColor = SettingsPage._iconColor;

  static const double _rowHorizontalPadding = 18;
  static const double _rowVerticalPadding = 16;
  static const double _iconSize = 26;
  static const double _iconSpacing = 16;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        physics: isIOS
            ? const BouncingScrollPhysics()
            : const ClampingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSectionTitle('Preferências'),
            const SizedBox(height: 16),
            _buildCard(
              children: [
                _buildSettingsRow(
                  icon: isIOS
                      ? CupertinoIcons.bell
                      : Icons.notifications_none_outlined,
                  title: 'Notificações',
                  subtitle: 'Receber alertas de tarefas',
                  trailing: _buildSwitch(
                    value: notificationsEnabled,
                    onChanged: onNotificationsChanged,
                  ),
                ),
                _buildDivider(),
                _buildSettingsRow(
                  icon: isIOS
                      ? CupertinoIcons.moon
                      : Icons.nightlight_outlined,
                  title: 'Modo Escuro',
                  subtitle: 'Em desenvolvimento',
                  trailing: _buildSwitch(value: false, onChanged: null),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('Geral'),
            const SizedBox(height: 16),
            _buildCard(
              children: [
                _buildSettingsRow(
                  icon:
                      isIOS ? CupertinoIcons.globe : Icons.language_outlined,
                  title: 'Idioma',
                  subtitle: language,
                ),
                _buildDivider(),
                _buildSettingsRow(
                  icon: isIOS
                      ? CupertinoIcons.shield
                      : Icons.shield_outlined,
                  title: 'Privacidade',
                  subtitle: 'Gerenciar seus dados',
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('Suporte'),
            const SizedBox(height: 16),
            _buildCard(
              children: [
                _buildSettingsRow(
                  icon: isIOS
                      ? CupertinoIcons.question_circle
                      : Icons.help_outline,
                  title: 'Central de Ajuda',
                  subtitle: 'Perguntas frequentes',
                ),
                _buildDivider(),
                _buildSettingsRow(
                  icon: isIOS
                      ? CupertinoIcons.info_circle
                      : Icons.info_outline,
                  title: 'Sobre o App',
                  subtitle: 'Versão 1.0.0',
                ),
              ],
            ),
            const SizedBox(height: 28),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: _sectionColor,
      ),
    );
  }

  Widget _buildCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _cardBorderColor),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSettingsRow({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: _rowHorizontalPadding,
        vertical: _rowVerticalPadding,
      ),
      child: Row(
        children: [
          Icon(icon, color: _iconColor, size: _iconSize),
          const SizedBox(width: _iconSpacing),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: _titleColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: _mutedColor,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  Widget _buildDivider() {
    final indent = _rowHorizontalPadding + _iconSize + _iconSpacing;
    return Padding(
      padding: EdgeInsets.only(left: indent, right: _rowHorizontalPadding),
      child: const Divider(height: 1, color: _dividerColor),
    );
  }

  Widget _buildSwitch({
    required bool value,
    ValueChanged<bool>? onChanged,
  }) {
    if (isIOS) {
      return CupertinoSwitch(
        value: value,
        activeColor: _accentGreen,
        onChanged: onChanged,
      );
    }
    return Switch(
      value: value,
      onChanged: onChanged,
      activeColor: _accentGreen,
      activeTrackColor: _accentGreen.withOpacity(0.55),
      inactiveThumbColor: Colors.white,
      inactiveTrackColor: const Color(0xFFD3D6DB),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: const [
        Text(
          'TaskFlow v1.0.0',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: _sectionColor,
          ),
        ),
        SizedBox(height: 6),
        Text(
          '© 2024 Todos os direitos reservados',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: _mutedColor,
          ),
        ),
      ],
    );
  }
}
