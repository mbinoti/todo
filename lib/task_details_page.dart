import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'task_item.dart';

enum TaskDetailsAction { updated, deleted }

class TaskDetailsResult {
  const TaskDetailsResult.updated(this.task) : action = TaskDetailsAction.updated;
  const TaskDetailsResult.deleted()
      : action = TaskDetailsAction.deleted,
        task = null;

  final TaskDetailsAction action;
  final TaskItem? task;
}

class TaskDetailsPage extends StatefulWidget {
  const TaskDetailsPage({super.key, required this.task});

  final TaskItem task;

  @override
  State<TaskDetailsPage> createState() => _TaskDetailsPageState();
}

class _TaskDetailsPageState extends State<TaskDetailsPage> {
  static const Color _accentGreen = Color(0xFF21B66E);
  static const Color _titleColor = Color(0xFF1D1E20);
  static const Color _mutedColor = Color(0xFF8C9097);
  static const Color _dividerColor = Color(0xFFE1E4E8);
  static const Color _dangerColor = Color(0xFFE35D6A);
  static const Color _pillColor = Color(0xFFE9EBEF);
  static const Color _backCircleColor = Color(0xFFF0F1F3);

  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final FocusNode _titleFocusNode;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _descriptionController =
        TextEditingController(text: widget.task.subtitle ?? '');
    _titleFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _titleFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isIOS = defaultTargetPlatform == TargetPlatform.iOS;
    final body = _buildBody(context, isIOS);
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
            'Detalhes',
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
          'Detalhes',
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
          child: Divider(height: 1, color: _dividerColor),
        ),
      ),
      body: body,
    );
  }

  Widget _buildBody(BuildContext context, bool isIOS) {
    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildStatusPill(),
            const SizedBox(height: 20),
            _isEditing ? _buildTitleField(isIOS) : _buildTitleText(),
            const SizedBox(height: 18),
            const Text(
              'Descrição',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: _mutedColor,
              ),
            ),
            const SizedBox(height: 8),
            _isEditing
                ? _buildDescriptionField(isIOS)
                : _buildDescriptionText(),
            const SizedBox(height: 24),
            const Text(
              'Criado em',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: _mutedColor,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _formatDate(widget.task.createdAt),
              style: const TextStyle(
                fontSize: 16,
                color: _titleColor,
              ),
            ),
            const SizedBox(height: 26),
            _buildEditButton(isIOS),
            const SizedBox(height: 14),
            _buildDeleteButton(isIOS),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusPill() {
    final label = widget.task.completed ? 'Concluída' : 'Pendente';
    final color = widget.task.completed ? _accentGreen : _pillColor;
    final textColor = widget.task.completed ? Colors.white : _mutedColor;
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
      ),
    );
  }

  Widget _buildTitleField(bool isIOS) {
    if (isIOS) {
      return CupertinoTextField(
        controller: _titleController,
        focusNode: _titleFocusNode,
        maxLines: 2,
        padding: EdgeInsets.zero,
        decoration: const BoxDecoration(color: Colors.transparent),
        style: const TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w700,
          color: _titleColor,
          height: 1.2,
        ),
      );
    }
    return TextField(
      controller: _titleController,
      focusNode: _titleFocusNode,
      maxLines: 2,
      decoration: const InputDecoration(
        border: InputBorder.none,
        isCollapsed: true,
        contentPadding: EdgeInsets.zero,
      ),
      style: const TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        color: _titleColor,
        height: 1.2,
      ),
    );
  }

  Widget _buildTitleText() {
    return Text(
      widget.task.title,
      style: const TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        color: _titleColor,
        height: 1.2,
      ),
    );
  }

  Widget _buildDescriptionField(bool isIOS) {
    if (isIOS) {
      return CupertinoTextField(
        controller: _descriptionController,
        minLines: 2,
        maxLines: null,
        padding: EdgeInsets.zero,
        decoration: const BoxDecoration(color: Colors.transparent),
        style: const TextStyle(
          fontSize: 16,
          color: _titleColor,
          height: 1.35,
        ),
      );
    }
    return TextField(
      controller: _descriptionController,
      maxLines: null,
      minLines: 2,
      decoration: const InputDecoration(
        border: InputBorder.none,
        isCollapsed: true,
        contentPadding: EdgeInsets.zero,
      ),
      style: const TextStyle(
        fontSize: 16,
        color: _titleColor,
        height: 1.35,
      ),
    );
  }

  Widget _buildDescriptionText() {
    return Text(
      widget.task.subtitle ?? '',
      style: const TextStyle(
        fontSize: 16,
        color: _titleColor,
        height: 1.35,
      ),
    );
  }

  Widget _buildEditButton(bool isIOS) {
    final icon = _isEditing
        ? (isIOS ? CupertinoIcons.check_mark : Icons.check)
        : (isIOS ? CupertinoIcons.pencil : Icons.edit_outlined);
    final label = _isEditing ? 'Salvar' : 'Editar';
    final onPressed = _isEditing ? _submitEdits : _startEditing;
    if (isIOS) {
      return CupertinoButton(
        padding: const EdgeInsets.symmetric(vertical: 16),
        borderRadius: BorderRadius.circular(28),
        color: _accentGreen,
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      );
    }
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: _accentGreen,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
      ),
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(
        label,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildDeleteButton(bool isIOS) {
    final icon = isIOS ? CupertinoIcons.trash : Icons.delete_outline;
    if (isIOS) {
      return CupertinoButton(
        padding: const EdgeInsets.symmetric(vertical: 16),
        borderRadius: BorderRadius.circular(28),
        color: _dangerColor,
        onPressed: _deleteTask,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: Colors.white),
            const SizedBox(width: 8),
            const Text(
              'Excluir',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      );
    }
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: _dangerColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
      ),
      onPressed: _deleteTask,
      icon: Icon(icon, size: 20),
      label: const Text(
        'Excluir',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }

  void _submitEdits() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      _showMessage('Informe o título da tarefa.');
      return;
    }
    final subtitle = _descriptionController.text.trim();
    final updated = widget.task.copyWith(
      title: title,
      subtitle: subtitle.isEmpty ? null : subtitle,
    );
    FocusScope.of(context).unfocus();
    Navigator.of(context).pop(TaskDetailsResult.updated(updated));
  }

  void _deleteTask() {
    FocusScope.of(context).unfocus();
    Navigator.of(context).pop(const TaskDetailsResult.deleted());
  }

  void _startEditing() {
    setState(() {
      _isEditing = true;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _titleFocusNode.requestFocus();
    });
  }

  void _showMessage(String message) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) {
      return;
    }
    messenger.showSnackBar(SnackBar(content: Text(message)));
  }

  String _formatDate(DateTime date) {
    const months = [
      'janeiro',
      'fevereiro',
      'março',
      'abril',
      'maio',
      'junho',
      'julho',
      'agosto',
      'setembro',
      'outubro',
      'novembro',
      'dezembro',
    ];
    final day = date.day.toString().padLeft(2, '0');
    final month = months[date.month - 1];
    final year = date.year.toString();
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$day de $month de $year às $hour:$minute';
  }
}
