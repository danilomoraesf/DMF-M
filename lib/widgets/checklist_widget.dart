import 'package:flutter/material.dart';
import '../models/task.dart';
import 'friendly_snackbar.dart';

class ChecklistWidget extends StatefulWidget {
  final List<ChecklistItem> items;
  final ValueChanged<String> onAdd;
  final ValueChanged<String> onToggle;
  final ValueChanged<String> onRemove;

  const ChecklistWidget({
    super.key,
    required this.items,
    required this.onAdd,
    required this.onToggle,
    required this.onRemove,
  });

  @override
  State<ChecklistWidget> createState() => _ChecklistWidgetState();
}

class _ChecklistWidgetState extends State<ChecklistWidget> {
  final _controller = TextEditingController();

  void _addItem() {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      showFriendlySnackBar(
        context,
        message: 'Digite o texto do item antes de adicionar.',
        isError: true,
      );
      return;
    }
    widget.onAdd(text);
    _controller.clear();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Checklist', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  hintText: 'Novo item...',
                  isDense: true,
                ),
                onSubmitted: (_) => _addItem(),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: _addItem,
              icon: const Icon(Icons.add_circle),
              tooltip: 'Adicionar item',
            ),
          ],
        ),
        const SizedBox(height: 4),
        ...widget.items.map(
          (item) => ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: Checkbox(
              value: item.completed,
              onChanged: (_) => widget.onToggle(item.id),
            ),
            title: Text(
              item.text,
              style: TextStyle(
                decoration:
                    item.completed ? TextDecoration.lineThrough : null,
              ),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.close, size: 18),
              onPressed: () => widget.onRemove(item.id),
              tooltip: 'Remover',
            ),
          ),
        ),
      ],
    );
  }
}
