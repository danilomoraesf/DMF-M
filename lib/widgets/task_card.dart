import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../models/user_preferences.dart';
import '../providers/task_provider.dart';
import '../providers/preferences_provider.dart';
import 'checklist_widget.dart';
import 'friendly_snackbar.dart';
import 'pomodoro_timer.dart';

class TaskCard extends StatelessWidget {
  final Task task;

  const TaskCard({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<TaskProvider>();
    final prefs = context.watch<PreferencesProvider>().preferences;
    final complexity = prefs.complexityLevel;
    final focusMode = prefs.focusMode;
    final theme = Theme.of(context);

    if (complexity == ComplexityLevel.simple || focusMode) {
      return _buildSimple(context, provider, theme, focusMode: focusMode);
    }

    return Card(
      child: ExpansionTile(
        title: Text(task.title, style: theme.textTheme.titleMedium),
        subtitle: task.description != null && task.description!.isNotEmpty
            ? Text(
                task.description!,
                style: theme.textTheme.bodySmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              )
            : null,
        trailing: _buildPopupMenu(context, provider),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                if (complexity == ComplexityLevel.detailed) ...[
                  PomodoroTimerWidget(
                    pomodoro: task.pomodoro,
                    onUpdate: (p) => provider.updatePomodoro(task.id, p),
                  ),
                  const Divider(height: 24),
                ],
                ChecklistWidget(
                  items: task.checklist,
                  onAdd: (text) =>
                      provider.addChecklistItem(task.id, text),
                  onToggle: (itemId) =>
                      provider.toggleChecklistItem(task.id, itemId),
                  onRemove: (itemId) =>
                      provider.removeChecklistItem(task.id, itemId),
                ),
                const SizedBox(height: 8),
                _buildMoveButtons(context, provider, complexity),
                if (complexity == ComplexityLevel.detailed) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Criada em ${_formatDate(task.createdAt)}',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
                const SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimple(
      BuildContext context, TaskProvider provider, ThemeData theme,
      {bool focusMode = false}) {
    return Card(
      elevation: focusMode ? 0 : null,
      color: focusMode
          ? theme.colorScheme.surface
          : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Text(
                task.title,
                style: focusMode
                    ? theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w400,
                      )
                    : theme.textTheme.titleMedium,
              ),
            ),
            if (task.status != TaskStatus.todo)
              IconButton(
                onPressed: () {
                  provider.moveTask(task.id, TaskStatus.todo);
                  _showMoveSnack(context, 'A Fazer');
                },
                icon: const Icon(Icons.arrow_back),
                tooltip: 'A Fazer',
                iconSize: 20,
              ),
            if (task.status != TaskStatus.inProgress)
              IconButton(
                onPressed: () {
                  provider.moveTask(task.id, TaskStatus.inProgress);
                  _showMoveSnack(context, 'Em Progresso');
                },
                icon: const Icon(Icons.play_arrow),
                tooltip: 'Em Progresso',
                iconSize: 20,
              ),
            if (task.status != TaskStatus.done)
              IconButton(
                onPressed: () {
                  provider.moveTask(task.id, TaskStatus.done);
                  _showMoveSnack(context, 'Concluído');
                },
                icon: const Icon(Icons.check_circle),
                tooltip: 'Concluído',
                iconSize: 20,
              ),
            IconButton(
              onPressed: () => _showEditDialog(context, provider, true),
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Editar',
              iconSize: 20,
            ),
            IconButton(
              onPressed: () => _confirmDelete(context, provider),
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              tooltip: 'Excluir',
              iconSize: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoveButtons(
      BuildContext context, TaskProvider provider, ComplexityLevel complexity) {
    final buttons = <Widget>[];

    if (task.status != TaskStatus.todo) {
      buttons.add(
        OutlinedButton.icon(
          onPressed: () {
            provider.moveTask(task.id, TaskStatus.todo);
            _showMoveSnack(context, 'A Fazer');
          },
          icon: const Icon(Icons.arrow_back, size: 16),
          label: const Text('A Fazer'),
        ),
      );
    }
    if (task.status != TaskStatus.inProgress) {
      buttons.add(
        FilledButton.icon(
          onPressed: () {
            provider.moveTask(task.id, TaskStatus.inProgress);
            _showMoveSnack(context, 'Em Progresso');
          },
          icon: const Icon(Icons.play_arrow, size: 16),
          label: const Text('Em Progresso'),
        ),
      );
    }
    if (task.status != TaskStatus.done) {
      buttons.add(
        FilledButton.tonalIcon(
          onPressed: () {
            provider.moveTask(task.id, TaskStatus.done);
            _showMoveSnack(context, 'Concluído');
          },
          icon: const Icon(Icons.check, size: 16),
          label: const Text('Concluído'),
        ),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: buttons,
    );
  }

  void _showMoveSnack(BuildContext context, String destino) {
    showFriendlySnackBar(
      context,
      message: 'Tarefa movida para "$destino".',
      icon: Icons.swap_horiz,
    );
  }

  String _formatDate(String iso) {
    final dt = DateTime.tryParse(iso);
    if (dt == null) return iso;
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildPopupMenu(BuildContext context, TaskProvider provider) {
    final isSimple = context.read<PreferencesProvider>().preferences.complexityLevel ==
        ComplexityLevel.simple;
    return PopupMenuButton<String>(
      onSelected: (value) {
        if (value == 'edit') {
          _showEditDialog(context, provider, isSimple);
        } else if (value == 'delete') {
          _confirmDelete(context, provider);
        }
      },
      itemBuilder: (_) => [
        const PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit, size: 20),
              SizedBox(width: 8),
              Text('Editar'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete, color: Colors.red, size: 20),
              SizedBox(width: 8),
              Text('Excluir'),
            ],
          ),
        ),
      ],
    );
  }

  void _showEditDialog(BuildContext context, TaskProvider provider, bool isSimple) {
    final titleCtrl = TextEditingController(text: task.title);
    final descCtrl = TextEditingController(text: task.description ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Editar Tarefa'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(
                labelText: 'Título',
              ),
              autofocus: true,
            ),
            if (!isSimple) ...[
              const SizedBox(height: 12),
              TextField(
                controller: descCtrl,
                decoration: const InputDecoration(
                  labelText: 'Descrição (opcional)',
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
              final title = titleCtrl.text.trim();
              if (title.isEmpty) {
                showFriendlySnackBar(
                  context,
                  message: 'O título não pode ficar vazio.',
                  isError: true,
                );
                return;
              }
              final desc = descCtrl.text.trim().isEmpty ? null : descCtrl.text.trim();
              provider.updateTask(task.id, title, desc);
              Navigator.pop(ctx);
              showFriendlySnackBar(
                context,
                message: 'Tarefa atualizada!',
                isSuccess: true,
              );
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, TaskProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.warning_amber_rounded,
            color: Colors.orange, size: 40),
        title: const Text('Tem certeza?'),
        content: Text(
          'A tarefa "${task.title}" será removida permanentemente.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Manter tarefa'),
          ),
          FilledButton(
            onPressed: () {
              provider.deleteTask(task.id);
              Navigator.pop(ctx);
              showFriendlySnackBar(
                context,
                message: 'Tarefa removida.',
                icon: Icons.delete_outline,
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Sim, excluir'),
          ),
        ],
      ),
    );
  }
}
