import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'task_item.dart';

class NewTaskPage extends StatelessWidget {
  const NewTaskPage({super.key});

  static const Color _accentGreen = Color(0xFF21B66E);
  static const Color _titleColor = Color(0xFF1D1E20);
  static const Color _borderColor = Color(0xFFE1E4E8);
  static const Color _requiredColor = Color(0xFFE35D6A);
  static const Color _backgroundColor = Color(0xFFF6F7F8);
  static const Color _hintColor = Color(0xFFB6B9BE);
  static const Color _backCircleColor = Color(0xFFF0F1F3);

  @override
  Widget build(BuildContext context) {
    final isIOS = defaultTargetPlatform == TargetPlatform.iOS;
    final body = _NewTaskBody(isIOS: isIOS);
    if (isIOS) {
      return CupertinoPageScaffold(
        backgroundColor: _backgroundColor,
        navigationBar: CupertinoNavigationBar(
          backgroundColor: Colors.white,
          border: const Border(
            bottom: BorderSide(color: _borderColor, width: 0.8),
          ),
          leading: CupertinoButton(
            padding: EdgeInsets.zero,
            minSize: 0,
            onPressed: () => Navigator.of(context).maybePop(),
            child: Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: _backCircleColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                CupertinoIcons.back,
                color: _titleColor,
                size: 20,
              ),
            ),
          ),
          middle: const Text(
            'Nova Tarefa',
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
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: _titleColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: const Text(
          'Nova Tarefa',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
        ),
        leading: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => Navigator.of(context).maybePop(),
            child: Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: _backCircleColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back,
                color: _titleColor,
                size: 20,
              ),
            ),
          ),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: _borderColor),
        ),
      ),
      body: body,
    );
  }
}

class _NewTaskBody extends StatefulWidget {
  const _NewTaskBody({required this.isIOS});

  final bool isIOS;

  @override
  State<_NewTaskBody> createState() => _NewTaskBodyState();
}

class _NewTaskBodyState extends State<_NewTaskBody> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  static const Color _accentGreen = NewTaskPage._accentGreen;
  static const Color _titleColor = NewTaskPage._titleColor;
  static const Color _borderColor = NewTaskPage._borderColor;
  static const Color _requiredColor = NewTaskPage._requiredColor;
  static const Color _hintColor = NewTaskPage._hintColor;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildFieldLabel('Título', required: true),
            const SizedBox(height: 10),
            _buildTitleField(),
            const SizedBox(height: 22),
            _buildFieldLabel('Descrição'),
            const SizedBox(height: 10),
            _buildDescriptionField(),
            const SizedBox(height: 26),
            _buildActions(context),
          ],
        ),
      ),
    );
  }

  void _submit() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe o título da tarefa.')),
      );
      return;
    }
    final description = _descriptionController.text.trim();
    final task = TaskItem(
      title: title,
      subtitle: description.isEmpty ? null : description,
      completed: false,
      createdAt: DateTime.now(),
    );
    Navigator.of(context).pop(task);
  }

  Widget _buildTitleField() {
    if (widget.isIOS) {
      return _buildCupertinoField(
        controller: _titleController,
        placeholder: 'Digite o título da tarefa',
      );
    }
    return TextField(
      controller: _titleController,
      decoration: _inputDecoration('Digite o título da tarefa'),
    );
  }

  Widget _buildDescriptionField() {
    if (widget.isIOS) {
      return _buildCupertinoField(
        controller: _descriptionController,
        placeholder: 'Adicione uma descrição (opcional)',
        minLines: 5,
        maxLines: 6,
      );
    }
    return TextField(
      controller: _descriptionController,
      minLines: 5,
      maxLines: 6,
      decoration: _inputDecoration('Adicione uma descrição (opcional)'),
      keyboardType: TextInputType.multiline,
    );
  }

  Widget _buildActions(BuildContext context) {
    if (widget.isIOS) {
      return Row(
        children: [
          Expanded(
            child: _CupertinoOutlinedButton(
              label: 'Cancelar',
              onPressed: () => Navigator.of(context).maybePop(),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: CupertinoButton(
              padding: const EdgeInsets.symmetric(vertical: 16),
              borderRadius: BorderRadius.circular(28),
              color: _accentGreen,
              onPressed: _submit,
              child: const Text(
                'Criar',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      );
    }
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: const BorderSide(color: _borderColor, width: 1.2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              foregroundColor: _titleColor,
            ),
            onPressed: () => Navigator.of(context).maybePop(),
            child: const Text(
              'Cancelar',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _accentGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
            ),
            onPressed: _submit,
            child: const Text(
              'Criar',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFieldLabel(String label, {bool required = false}) {
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
        if (required) ...[
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
        borderSide: const BorderSide(color: _borderColor, width: 1.2),
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
    int minLines = 1,
    int maxLines = 1,
  }) {
    return CupertinoTextField(
      controller: controller,
      placeholder: placeholder,
      placeholderStyle: const TextStyle(color: _hintColor),
      minLines: minLines,
      maxLines: maxLines,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _borderColor, width: 1.2),
      ),
      style: const TextStyle(color: _titleColor),
    );
  }
}

class _CupertinoOutlinedButton extends StatelessWidget {
  const _CupertinoOutlinedButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  static const Color _titleColor = NewTaskPage._titleColor;
  static const Color _borderColor = NewTaskPage._borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: _borderColor, width: 1.2),
      ),
      child: CupertinoButton(
        padding: const EdgeInsets.symmetric(vertical: 16),
        borderRadius: BorderRadius.circular(28),
        onPressed: onPressed,
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: _titleColor,
          ),
        ),
      ),
    );
  }
}
