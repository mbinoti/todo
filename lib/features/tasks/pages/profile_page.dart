import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:app_todo/features/tasks/pages/edit_profile_page.dart';
import 'package:app_todo/features/tasks/pages/settings_page.dart';
import 'package:app_todo/features/tasks/view_model/auth_model.dart';
import 'package:app_todo/features/tasks/view_model/profile_model.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  static const Color _accentGreen = Color(0xFF21B66E);
  static const Color _titleColor = Color(0xFF1D1E20);
  static const Color _mutedColor = Color(0xFF8C9097);
  static const Color _dividerColor = Color(0xFFE1E4E8);
  static const Color _dangerColor = Color(0xFFE35D6A);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    final isIOS = defaultTargetPlatform == TargetPlatform.iOS;
    final profile = context.watch<ProfileModel>();
    final body = _ProfileBody(
      isIOS: isIOS,
      name: profile.name,
      email: profile.email,
      photoUrl: profile.photoUrl,
      onEditProfile: () => _openEditProfile(context),
      onOpenSettings: () => _openSettings(context),
      onSignOut: () => context.read<AuthModel>().signOut(),
    );
    if (isIOS) {
      return CupertinoPageScaffold(
        backgroundColor: Colors.white,
        navigationBar: CupertinoNavigationBar(
          backgroundColor: Colors.white,
          border: const Border(
            bottom: BorderSide(color: ProfilePage._dividerColor, width: 0.6),
          ),
          leading: CupertinoButton(
            padding: EdgeInsets.zero,
            minSize: 0,
            onPressed: () => Navigator.of(context).maybePop(),
            child: const Icon(
              CupertinoIcons.back,
              color: ProfilePage._titleColor,
              size: 26,
            ),
          ),
          middle: const Text(
            'Perfil',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: ProfilePage._titleColor,
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
        foregroundColor: ProfilePage._titleColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: const Text(
          'Perfil',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: ProfilePage._dividerColor),
        ),
      ),
      body: body,
    );
  }

  Future<void> _openEditProfile(BuildContext context) async {
    final isIOS = defaultTargetPlatform == TargetPlatform.iOS;
    final profile = context.read<ProfileModel>();
    final route = isIOS
        ? CupertinoPageRoute<EditProfileResult>(
            builder: (_) => EditProfilePage(
              initialName: profile.name,
              initialEmail: profile.email,
              initialPhotoUrl: profile.photoUrl,
            ),
          )
        : MaterialPageRoute<EditProfileResult>(
            builder: (_) => EditProfilePage(
              initialName: profile.name,
              initialEmail: profile.email,
              initialPhotoUrl: profile.photoUrl,
            ),
          );
    final result = await Navigator.of(context).push<EditProfileResult>(route);
    if (!mounted || result == null) {
      return;
    }
    await profile.updateProfile(
      name: result.name,
      email: result.email,
      photoFile: result.photoFile,
    );
  }

  void _openSettings(BuildContext context) {
    final isIOS = defaultTargetPlatform == TargetPlatform.iOS;
    final route = isIOS
        ? CupertinoPageRoute<void>(builder: (_) => const SettingsPage())
        : MaterialPageRoute<void>(builder: (_) => const SettingsPage());
    Navigator.of(context).push(route);
  }
}

class _ProfileBody extends StatelessWidget {
  const _ProfileBody({
    required this.isIOS,
    required this.name,
    required this.email,
    required this.photoUrl,
    required this.onEditProfile,
    required this.onOpenSettings,
    required this.onSignOut,
  });

  final bool isIOS;
  final String name;
  final String email;
  final String? photoUrl;
  final VoidCallback onEditProfile;
  final VoidCallback onOpenSettings;
  final VoidCallback onSignOut;

  static const Color _accentGreen = ProfilePage._accentGreen;
  static const Color _titleColor = ProfilePage._titleColor;
  static const Color _mutedColor = ProfilePage._mutedColor;
  static const Color _dangerColor = ProfilePage._dangerColor;

  @override
  Widget build(BuildContext context) {
    final items = [
      _ProfileAction(
        label: 'Editar perfil',
        icon: isIOS ? CupertinoIcons.person : Icons.person_outline,
        color: _titleColor,
        onTap: onEditProfile,
      ),
      _ProfileAction(
        label: 'Configurações',
        icon: isIOS ? CupertinoIcons.gear : Icons.settings_outlined,
        color: _titleColor,
        onTap: onOpenSettings,
      ),
      _ProfileAction(
        label: 'Sair',
        icon: isIOS ? CupertinoIcons.square_arrow_right : Icons.logout,
        color: _dangerColor,
        onTap: onSignOut,
      ),
    ];

    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),
            Center(child: _buildAvatar()),
            const SizedBox(height: 16),
            Center(
              child: Text(
                name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: _titleColor,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Center(
              child: Text(
                email,
                style: const TextStyle(
                  fontSize: 16,
                  color: _mutedColor,
                ),
              ),
            ),
            const SizedBox(height: 32),
            for (var i = 0; i < items.length; i++) ...[
              _buildActionRow(items[i]),
              if (i != items.length - 1) const SizedBox(height: 28),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    final initial = _initialForName(name);
    final imageProvider = _resolveAvatarImage(photoUrl);
    final hasImage = imageProvider != null;
    return Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        color: _accentGreen,
        shape: BoxShape.circle,
        image: hasImage
            ? DecorationImage(
                image: imageProvider!,
                fit: BoxFit.cover,
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: hasImage
          ? null
          : Center(
              child: Text(
                initial,
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
    );
  }

  ImageProvider? _resolveAvatarImage(String? url) {
    final trimmed = url?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return null;
    }
    final uri = Uri.tryParse(trimmed);
    if (uri != null && (uri.scheme == 'http' || uri.scheme == 'https')) {
      return NetworkImage(trimmed);
    }
    final file = uri != null && uri.scheme == 'file'
        ? File.fromUri(uri)
        : File(trimmed);
    if (file.existsSync()) {
      return FileImage(file);
    }
    return NetworkImage(trimmed);
  }

  Widget _buildActionRow(_ProfileAction item) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: item.onTap,
      child: Row(
        children: [
          Icon(item.icon, color: item.color, size: 26),
          const SizedBox(width: 16),
          Text(
            item.label,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: item.color,
            ),
          ),
        ],
      ),
    );
  }

  String _initialForName(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return 'S';
    }
    return trimmed.substring(0, 1).toUpperCase();
  }
}

class _ProfileAction {
  const _ProfileAction({
    required this.label,
    required this.icon,
    required this.color,
    this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
}
