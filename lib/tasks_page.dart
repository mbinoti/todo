import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'new_task_page.dart';
import 'profile_page.dart';
import 'task_details_page.dart';
import 'task_item.dart';

class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  static const Color _accentGreen = Color(0xFF21B66E);
  static const Color _titleColor = Color(0xFF1D1E20);
  static const Color _mutedColor = Color(0xFF8C9097);
  static const Color _sectionColor = Color(0xFF7D8188);
  static const Color _backgroundColor = Color(0xFFF6F7F8);
  static const Color _cardBorderColor = Color(0xFFE1E4E8);
  static const Color _pendingIconBorder = Color(0xFFD8DBE0);

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  late final List<TaskItem> _pendingTasks;
  late final List<TaskItem> _completedTasks;

  @override
  void initState() {
    super.initState();
    final baseDate = DateTime(2024, 12, 25, 16, 0);
    _pendingTasks = [
      TaskItem(
        title: 'Finalizar apresentação do projeto',
        subtitle:
            'Preparar slides e revisar conteúdo para a reunião de quinta-feira',
        completed: false,
        createdAt: baseDate,
      ),
      TaskItem(
        title: 'Comprar presentes de Natal',
        subtitle: 'Lista: livro para Maria, fone para João, jogo para Pedro',
        completed: false,
        createdAt: baseDate,
      ),
      TaskItem(
        title: 'Revisar código do app mobile',
        subtitle: 'Fazer code review do PR #142 e testar funcionalidades',
        completed: false,
        createdAt: baseDate,
      ),
    ];
    _completedTasks = [
      TaskItem(
        title: 'Academia — treino de pernas',
        completed: true,
        createdAt: baseDate,
      ),
      TaskItem(
        title: 'Agendar consulta médica',
        completed: true,
        createdAt: baseDate,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final isIOS = defaultTargetPlatform == TargetPlatform.iOS;
    if (isIOS) {
      return CupertinoPageScaffold(
        backgroundColor: TasksPage._backgroundColor,
        navigationBar: CupertinoNavigationBar(
          border: const Border(
            bottom: BorderSide(color: TasksPage._cardBorderColor, width: 0.6),
          ),
          backgroundColor: Colors.white,
          middle: const Text(
            'Minhas Tarefas',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: TasksPage._titleColor,
            ),
          ),
          trailing: CupertinoButton(
            padding: EdgeInsets.zero,
            minSize: 0,
            onPressed: () => _openProfile(context),
            child: const Icon(
              CupertinoIcons.line_horizontal_3,
              color: TasksPage._titleColor,
            ),
          ),
        ),
        child: _TasksBody(
          isIOS: true,
          pendingTasks: _pendingTasks,
          completedTasks: _completedTasks,
          onCreateTask: () => _openNewTask(context),
          onOpenDetails: _openDetails,
          onToggleComplete: _markCompleted,
        ),
      );
    }
    return Scaffold(
      backgroundColor: TasksPage._backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: TasksPage._titleColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text(
          'Minhas Tarefas',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            onPressed: () => _openProfile(context),
            icon: const Icon(Icons.menu),
          ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: TasksPage._cardBorderColor),
        ),
      ),
      body: _TasksBody(
        isIOS: false,
        pendingTasks: _pendingTasks,
        completedTasks: _completedTasks,
        onCreateTask: () => _openNewTask(context),
        onOpenDetails: _openDetails,
        onToggleComplete: _markCompleted,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openNewTask(context),
        backgroundColor: TasksPage._accentGreen,
        elevation: 6,
        child: const Icon(Icons.add, size: 30, color: Colors.white),
      ),
    );
  }

  void _openProfile(BuildContext context) {
    final isIOS = defaultTargetPlatform == TargetPlatform.iOS;
    final route = isIOS
        ? CupertinoPageRoute<void>(builder: (_) => const ProfilePage())
        : MaterialPageRoute<void>(builder: (_) => const ProfilePage());
    Navigator.of(context).push(route);
  }

  Future<void> _openDetails(int index) async {
    if (index >= _pendingTasks.length) {
      return;
    }
    final task = _pendingTasks[index];
    final isIOS = defaultTargetPlatform == TargetPlatform.iOS;
    final route = isIOS
        ? CupertinoPageRoute<TaskDetailsResult?>(
            builder: (_) => TaskDetailsPage(task: task),
          )
        : MaterialPageRoute<TaskDetailsResult?>(
            builder: (_) => TaskDetailsPage(task: task),
          );
    final result = await Navigator.of(context).push<TaskDetailsResult?>(route);
    if (!mounted || result == null) {
      return;
    }
    var taskIndex = index;
    if (taskIndex >= _pendingTasks.length ||
        !identical(_pendingTasks[taskIndex], task)) {
      taskIndex = _pendingTasks.indexWhere((item) => identical(item, task));
    }
    if (taskIndex == -1) {
      return;
    }
    if (result.action == TaskDetailsAction.deleted) {
      setState(() {
        if (taskIndex < _pendingTasks.length) {
          _pendingTasks.removeAt(taskIndex);
        }
      });
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        const SnackBar(content: Text('Tarefa excluída.')),
      );
      return;
    }
    if (result.action == TaskDetailsAction.updated && result.task != null) {
      setState(() {
        if (taskIndex < _pendingTasks.length) {
          _pendingTasks[taskIndex] = result.task!;
        }
      });
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        const SnackBar(content: Text('Tarefa atualizada.')),
      );
    }
  }

  void _markCompleted(int index) {
    setState(() {
      if (index >= _pendingTasks.length) {
        return;
      }
      final task = _pendingTasks.removeAt(index);
      _completedTasks.insert(0, task.copyWith(completed: true));
    });
  }

  Future<void> _openNewTask(BuildContext context) async {
    final isIOS = defaultTargetPlatform == TargetPlatform.iOS;
    final route = isIOS
        ? CupertinoPageRoute<TaskItem?>(builder: (_) => const NewTaskPage())
        : MaterialPageRoute<TaskItem?>(builder: (_) => const NewTaskPage());
    final newTask = await Navigator.of(context).push<TaskItem?>(route);
    if (newTask == null) {
      return;
    }
    setState(() {
      _pendingTasks.insert(0, newTask);
    });
  }
}

class _TasksBody extends StatelessWidget {
  const _TasksBody({
    required this.isIOS,
    required this.pendingTasks,
    required this.completedTasks,
    required this.onCreateTask,
    required this.onOpenDetails,
    required this.onToggleComplete,
  });

  final bool isIOS;
  final List<TaskItem> pendingTasks;
  final List<TaskItem> completedTasks;
  final VoidCallback onCreateTask;
  final ValueChanged<int> onOpenDetails;
  final ValueChanged<int> onToggleComplete;

  static const Color _accentGreen = TasksPage._accentGreen;
  static const Color _titleColor = TasksPage._titleColor;
  static const Color _mutedColor = TasksPage._mutedColor;
  static const Color _sectionColor = TasksPage._sectionColor;
  static const Color _cardBorderColor = TasksPage._cardBorderColor;
  static const Color _pendingIconBorder = TasksPage._pendingIconBorder;

  @override
  Widget build(BuildContext context) {
    final list = SingleChildScrollView(
      physics:
          isIOS ? const BouncingScrollPhysics() : const ClampingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pendentes (${pendingTasks.length})',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: _sectionColor,
            ),
          ),
          const SizedBox(height: 16),
          for (var i = 0; i < pendingTasks.length; i++)
            _buildCard(
              pendingTasks[i],
              onTap: () => onOpenDetails(i),
              onToggleComplete: () => onToggleComplete(i),
            ),
          const SizedBox(height: 24),
          Text(
            'Concluídas (${completedTasks.length})',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: _sectionColor,
            ),
          ),
          const SizedBox(height: 16),
          for (var i = 0; i < completedTasks.length; i++)
            _buildCard(completedTasks[i]),
        ],
      ),
    );

    if (!isIOS) {
      return list;
    }

    return Stack(
      children: [
        list,
        Positioned(
          right: 20,
          bottom: 24,
          child: _buildIosFab(),
        ),
      ],
    );
  }

  Widget _buildCard(
    TaskItem item, {
    VoidCallback? onTap,
    VoidCallback? onToggleComplete,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _cardBorderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatusIcon(item.completed, onToggleComplete),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: onTap,
              behavior: HitTestBehavior.opaque,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: item.completed ? _mutedColor : _titleColor,
                      decoration:
                          item.completed ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  if (item.subtitle != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      item.subtitle!,
                      style: const TextStyle(
                        fontSize: 15,
                        color: _mutedColor,
                        height: 1.3,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIcon(bool completed, VoidCallback? onToggleComplete) {
    if (completed) {
      final iconData = isIOS ? CupertinoIcons.check_mark : Icons.check;
      return Container(
        width: 28,
        height: 28,
        decoration: const BoxDecoration(
          color: _accentGreen,
          shape: BoxShape.circle,
        ),
        child: Icon(iconData, size: 18, color: Colors.white),
      );
    }
    return GestureDetector(
      onTap: onToggleComplete,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: _pendingIconBorder, width: 2),
        ),
      ),
    );
  }

  Widget _buildIosFab() {
    return Container(
      width: 62,
      height: 62,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.14),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        borderRadius: BorderRadius.circular(31),
        color: _accentGreen,
        onPressed: onCreateTask,
        child: const Icon(CupertinoIcons.add, size: 30, color: Colors.white),
      ),
    );
  }
}
