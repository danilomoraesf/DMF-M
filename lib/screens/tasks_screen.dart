import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../models/user_preferences.dart';
import '../providers/task_provider.dart';
import '../providers/preferences_provider.dart';
import '../widgets/task_card.dart';
import '../widgets/friendly_snackbar.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer<PreferencesProvider>(
          builder: (context, prov, _) => Row(
            children: [
              const Text('MindEase'),
              if (prov.preferences.focusMode) ...[
                const SizedBox(width: 8),
                Icon(Icons.visibility_off,
                    size: 18,
                    color: Colors.white.withValues(alpha: 0.7)),
              ],
            ],
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'A Fazer'),
            Tab(text: 'Em Progresso'),
            Tab(text: 'Concluído'),
          ],
        ),
      ),
      body: Consumer<TaskProvider>(
        builder: (context, provider, _) {
          return TabBarView(
            controller: _tabController,
            children: [
              _buildTaskList(provider.todoTasks, 'Nenhuma tarefa a fazer'),
              _buildTaskList(
                  provider.inProgressTasks, 'Nenhuma tarefa em progresso'),
              _buildTaskList(provider.doneTasks, 'Nenhuma tarefa concluída'),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTaskDialog(context),
        tooltip: 'Nova tarefa',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTaskList(List<Task> tasks, String emptyMessage) {
    if (tasks.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.inbox,
                  size: 64,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.3)),
              const SizedBox(height: 16),
              Text(emptyMessage,
                  style: Theme.of(context).textTheme.bodyLarge),
            ],
          ),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 80),
      itemCount: tasks.length,
      itemBuilder: (_, i) => TaskCard(key: ValueKey(tasks[i].id), task: tasks[i]),
    );
  }

  void _showAddTaskDialog(BuildContext context) {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final isSimple = context.read<PreferencesProvider>().preferences
            .complexityLevel ==
        ComplexityLevel.simple;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nova Tarefa'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Título',
                hintText: 'Nome da tarefa',
              ),
              autofocus: true,
            ),
            if (!isSimple) ...[
              const SizedBox(height: 12),
              TextField(
                controller: descController,
                decoration: const InputDecoration(
                  labelText: 'Descrição (opcional)',
                  hintText: 'Detalhes da tarefa',
                ),
                maxLines: 3,
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              final title = titleController.text.trim();
              if (title.isEmpty) {
                showFriendlySnackBar(
                  context,
                  message: 'Dê um nome para sua tarefa antes de criar.',
                  isError: true,
                );
                return;
              }
              context.read<TaskProvider>().addTask(
                    title,
                    descController.text.trim().isEmpty
                        ? null
                        : descController.text.trim(),
                  );
              Navigator.pop(ctx);
              showFriendlySnackBar(
                context,
                message: 'Tarefa "$title" criada com sucesso!',
                isSuccess: true,
              );
            },
            child: const Text('Criar'),
          ),
        ],
      ),
    );
  }
}
