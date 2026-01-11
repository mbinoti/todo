import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class EditProfileResult {
  const EditProfileResult({
    required this.name,
    required this.email,
    this.photoFile,
  });

  final String name;
  final String email;
  final File? photoFile;
}

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({
    super.key,
    required this.initialName,
    required this.initialEmail,
    this.initialPhotoUrl,
  });

  final String initialName;
  final String initialEmail;
  final String? initialPhotoUrl;

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  static const Color _accentGreen = Color(0xFF21B66E);
  static const Color _titleColor = Color(0xFF1D1E20);
  static const Color _mutedColor = Color(0xFF8C9097);
  static const Color _dividerColor = Color(0xFFE1E4E8);
  static const Color _requiredColor = Color(0xFFE35D6A);
  static const Color _borderColor = Color(0xFFE1E4E8);
  static const Color _hintColor = Color(0xFFB6B9BE);
  static const Color _tipBackground = Color(0xFFF0F1F3);
  static const Color _tipTextColor = Color(0xFF7D8188);
  static const Color _tipIconColor = Color(0xFFF5C04E);

  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  File? _selectedImage;
  String? _initialPhotoUrl;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _emailController = TextEditingController(text: widget.initialEmail);
    _nameController.addListener(_handleNameChanged);
    _initialPhotoUrl = widget.initialPhotoUrl?.trim();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isIOS = defaultTargetPlatform == TargetPlatform.iOS;
    final body = _EditProfileBody(
      isIOS: isIOS,
      nameController: _nameController,
      emailController: _emailController,
      selectedImage: _selectedImage,
      initialPhotoUrl: _initialPhotoUrl,
      onPickImage: _handlePickImage,
      onSave: _handleSave,
    );
    if (isIOS) {
      return CupertinoPageScaffold(
        backgroundColor: Colors.white,
        navigationBar: CupertinoNavigationBar(
          backgroundColor: Colors.white,
          border: const Border(
            bottom: BorderSide(color: _dividerColor, width: 0.6),
          ),
          leading: CupertinoButton(
            padding: EdgeInsets.zero,
            minSize: 0,
            onPressed: () => Navigator.of(context).maybePop(),
            child: const Icon(
              CupertinoIcons.back,
              color: _titleColor,
              size: 26,
            ),
          ),
          middle: const Text(
            'Editar Perfil',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: _titleColor,
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
        foregroundColor: _titleColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: const Text(
          'Editar Perfil',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: _dividerColor),
        ),
      ),
      body: body,
    );
  }

  void _handleSave() {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    Navigator.of(context).pop(
      EditProfileResult(
        name: name,
        email: email,
        photoFile: _selectedImage,
      ),
    );
  }

  void _handleNameChanged() {
    if (!mounted) {
      return;
    }
    setState(() {});
  }

  Future<void> _handlePickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );
    if (result == null || result.files.isEmpty) {
      return;
    }
    final path = result.files.single.path;
    if (path == null || path.isEmpty) {
      return;
    }
    if (!mounted) {
      return;
    }
    setState(() {
      _selectedImage = File(path);
    });
  }
}

class _EditProfileBody extends StatelessWidget {
  const _EditProfileBody({
    required this.isIOS,
    required this.nameController,
    required this.emailController,
    required this.selectedImage,
    required this.initialPhotoUrl,
    required this.onPickImage,
    required this.onSave,
  });

  final bool isIOS;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final File? selectedImage;
  final String? initialPhotoUrl;
  final VoidCallback onPickImage;
  final VoidCallback onSave;

  static const Color _accentGreen = _EditProfilePageState._accentGreen;
  static const Color _titleColor = _EditProfilePageState._titleColor;
  static const Color _mutedColor = _EditProfilePageState._mutedColor;
  static const Color _requiredColor = _EditProfilePageState._requiredColor;
  static const Color _borderColor = _EditProfilePageState._borderColor;
  static const Color _hintColor = _EditProfilePageState._hintColor;
  static const Color _tipBackground = _EditProfilePageState._tipBackground;
  static const Color _tipTextColor = _EditProfilePageState._tipTextColor;
  static const Color _tipIconColor = _EditProfilePageState._tipIconColor;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: isIOS
                ? const BouncingScrollPhysics()
                : const ClampingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildAvatar(),
                  const SizedBox(height: 12),
                  const Center(
                    child: Text(
                      'Toque para alterar a foto',
                      style: TextStyle(fontSize: 16, color: _mutedColor),
                    ),
                  ),
                  const SizedBox(height: 30),
                  _buildFieldLabel('Nome completo'),
                  const SizedBox(height: 10),
                  _buildNameField(),
                  const SizedBox(height: 22),
                  _buildFieldLabel('Email'),
                  const SizedBox(height: 10),
                  _buildEmailField(),
                  const SizedBox(height: 28),
                  _buildSaveButton(),
                  const SizedBox(height: 14),
                  _buildCancelButton(context),
                  const SizedBox(height: 24),
                  _buildTipBox(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAvatar() {
    final initial = _initialForName(nameController.text);
    final image = selectedImage;
    final imageUrl = initialPhotoUrl?.trim();
    final hasFileImage = image != null && image.existsSync();
    final localImageFile = !hasFileImage && imageUrl != null && imageUrl.isNotEmpty
        ? File(imageUrl)
        : null;
    final hasLocalImage =
        localImageFile != null && localImageFile.existsSync();
    final hasNetworkImage = !hasFileImage &&
        !hasLocalImage &&
        imageUrl != null &&
        imageUrl.isNotEmpty;
    final hasImage = hasFileImage || hasLocalImage || hasNetworkImage;
    return Center(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onPickImage,
        child: SizedBox(
          width: 132,
          height: 132,
          child: Stack(
            children: [
              Align(
                alignment: Alignment.center,
                child: Container(
                  width: 112,
                  height: 112,
                  decoration: BoxDecoration(
                    color: _accentGreen,
                    shape: BoxShape.circle,
                    image: hasFileImage
                        ? DecorationImage(
                            image: FileImage(image!),
                            fit: BoxFit.cover,
                          )
                        : hasLocalImage
                            ? DecorationImage(
                                image: FileImage(localImageFile!),
                                fit: BoxFit.cover,
                              )
                        : hasNetworkImage
                            ? DecorationImage(
                                image: NetworkImage(imageUrl!),
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
                ),
              ),
              Positioned(
                right: 12,
                bottom: 12,
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: _accentGreen, width: 2),
                  ),
                  child: Icon(
                    isIOS ? CupertinoIcons.person : Icons.person_outline,
                    color: _accentGreen,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNameField() {
    if (isIOS) {
      return _buildCupertinoField(
        controller: nameController,
        placeholder: 'Nome completo',
        textCapitalization: TextCapitalization.words,
      );
    }
    return TextField(
      controller: nameController,
      textCapitalization: TextCapitalization.words,
      decoration: _inputDecoration('Nome completo'),
    );
  }

  Widget _buildEmailField() {
    if (isIOS) {
      return _buildCupertinoField(
        controller: emailController,
        placeholder: 'Email',
        keyboardType: TextInputType.emailAddress,
      );
    }
    return TextField(
      controller: emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: _inputDecoration('Email'),
    );
  }

  Widget _buildSaveButton() {
    if (isIOS) {
      return SizedBox(
        height: 54,
        child: CupertinoButton(
          padding: EdgeInsets.zero,
          borderRadius: BorderRadius.circular(28),
          color: _accentGreen,
          onPressed: onSave,
          child: const Text(
            'Salvar Alterações',
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
        onPressed: onSave,
        child: const Text(
          'Salvar Alterações',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildCancelButton(BuildContext context) {
    if (isIOS) {
      return SizedBox(
        height: 54,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: _borderColor, width: 1),
          ),
          child: CupertinoButton(
            padding: EdgeInsets.zero,
            borderRadius: BorderRadius.circular(28),
            onPressed: () => Navigator.of(context).maybePop(),
            child: const Text(
              'Cancelar',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: _titleColor,
              ),
            ),
          ),
        ),
      );
    }
    return SizedBox(
      height: 54,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          foregroundColor: _titleColor,
          side: const BorderSide(color: _borderColor, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        onPressed: () => Navigator.of(context).maybePop(),
        child: const Text(
          'Cancelar',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildTipBox() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: _tipBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Icon(Icons.lightbulb_outline, color: _tipIconColor, size: 22),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Dica: Mantenha seus dados atualizados para melhor experiência no app.',
              style: TextStyle(
                fontSize: 14,
                color: _tipTextColor,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: _titleColor,
          ),
        ),
        const SizedBox(width: 4),
        const Text(
          '*',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: _requiredColor,
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: _hintColor),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: _borderColor, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: _accentGreen, width: 1.2),
      ),
    );
  }

  Widget _buildCupertinoField({
    required TextEditingController controller,
    required String placeholder,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return CupertinoTextField(
      controller: controller,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      placeholder: placeholder,
      placeholderStyle: const TextStyle(color: _hintColor),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _borderColor, width: 1),
      ),
    );
  }

  String _initialForName(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return 'U';
    }
    return trimmed.substring(0, 1).toUpperCase();
  }
}
