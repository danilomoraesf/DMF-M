import 'package:flutter/foundation.dart';
import '../models/task.dart';
import '../services/storage_service.dart';

class TaskProvider extends ChangeNotifier {
  final StorageService _storage;
  List<Task> _tasks = [];

  TaskProvider(this._storage);

  List<Task> get tasks => _tasks;
  List<Task> get todoTasks =>
      _tasks.where((t) => t.status == TaskStatus.todo).toList();
  List<Task> get inProgressTasks =>
      _tasks.where((t) => t.status == TaskStatus.inProgress).toList();
  List<Task> get doneTasks =>
      _tasks.where((t) => t.status == TaskStatus.done).toList();

  Future<void> loadTasks() async {
    _tasks = await _storage.loadTasks();
    notifyListeners();
  }

  Future<void> _save() async {
    await _storage.saveTasks(_tasks);
    notifyListeners();
  }

  Future<void> addTask(String title, String? description) async {
    _tasks.add(Task(title: title, description: description));
    await _save();
  }

  Future<void> updateTask(String id, String title, String? description) async {
    final task = _tasks.firstWhere((t) => t.id == id);
    task.title = title;
    task.description = description;
    task.updatedAt = DateTime.now().toIso8601String();
    await _save();
  }

  Future<void> deleteTask(String id) async {
    _tasks.removeWhere((t) => t.id == id);
    await _save();
  }

  Future<void> moveTask(String id, TaskStatus newStatus) async {
    final task = _tasks.firstWhere((t) => t.id == id);
    task.status = newStatus;
    task.updatedAt = DateTime.now().toIso8601String();
    await _save();
  }

  // Checklist
  Future<void> addChecklistItem(String taskId, String text) async {
    final task = _tasks.firstWhere((t) => t.id == taskId);
    task.checklist.add(ChecklistItem(text: text));
    task.updatedAt = DateTime.now().toIso8601String();
    await _save();
  }

  Future<void> toggleChecklistItem(String taskId, String itemId) async {
    final task = _tasks.firstWhere((t) => t.id == taskId);
    final item = task.checklist.firstWhere((i) => i.id == itemId);
    item.completed = !item.completed;
    task.updatedAt = DateTime.now().toIso8601String();
    await _save();
  }

  Future<void> removeChecklistItem(String taskId, String itemId) async {
    final task = _tasks.firstWhere((t) => t.id == taskId);
    task.checklist.removeWhere((i) => i.id == itemId);
    task.updatedAt = DateTime.now().toIso8601String();
    await _save();
  }

  // Pomodoro
  void updatePomodoro(String taskId, PomodoroSession pomodoro) {
    final task = _tasks.firstWhere((t) => t.id == taskId);
    task.pomodoro = pomodoro;
    _storage.saveTasks(_tasks);
    notifyListeners();
  }
}
