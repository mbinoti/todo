import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'edit_profile_page.dart';
import 'profile_model.dart';

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
      photoPath: profile.photoPath,
      onEditProfile: () => _openEditProfile(context),
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
              initialPhotoPath: profile.photoPath,
            ),
          )
        : MaterialPageRoute<EditProfileResult>(
            builder: (_) => EditProfilePage(
              initialName: profile.name,
              initialEmail: profile.email,
              initialPhotoPath: profile.photoPath,
            ),
          );
    final result = await Navigator.of(context).push<EditProfileResult>(route);
    if (!mounted || result == null) {
      return;
    }
    await profile.update(
      name: result.name,
      email: result.email,
      photoPath: result.photoPath,
    );
  }
}

class _ProfileBody extends StatelessWidget {
  const _ProfileBody({
    required this.isIOS,
    required this.name,
    required this.email,
    required this.photoPath,
    required this.onEditProfile,
  });

  final bool isIOS;
  final String name;
  final String email;
  final String? photoPath;
  final VoidCallback onEditProfile;

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
      ),
      _ProfileAction(
        label: 'Sair',
        icon: isIOS ? CupertinoIcons.square_arrow_right : Icons.logout,
        color: _dangerColor,
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
    final imagePath = photoPath;
    final imageFile = imagePath == null || imagePath.isEmpty
        ? null
        : File(imagePath);
    final hasImage = imageFile != null && imageFile.existsSync();
    return Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        color: _accentGreen,
        shape: BoxShape.circle,
        image: hasImage
            ? DecorationImage(
                image: FileImage(imageFile!),
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
