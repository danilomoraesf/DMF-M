import 'package:uuid/uuid.dart';

enum TaskStatus { todo, inProgress, done }

class ChecklistItem {
  final String id;
  String text;
  bool completed;

  ChecklistItem({
    String? id,
    required this.text,
    this.completed = false,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'completed': completed,
      };

  factory ChecklistItem.fromJson(Map<String, dynamic> json) => ChecklistItem(
        id: json['id'],
        text: json['text'],
        completed: json['completed'] ?? false,
      );
}

class PomodoroSession {
  String? startedAt;
  int elapsedSeconds;
  bool isRunning;
  int workMinutes;

  PomodoroSession({
    this.startedAt,
    this.elapsedSeconds = 0,
    this.isRunning = false,
    this.workMinutes = 25,
  });

  int get remainingSeconds => (workMinutes * 60) - elapsedSeconds;

  Map<String, dynamic> toJson() => {
        'startedAt': startedAt,
        'elapsedSeconds': elapsedSeconds,
        'isRunning': false, // nunca salvar como rodando
        'workMinutes': workMinutes,
      };

  factory PomodoroSession.fromJson(Map<String, dynamic> json) =>
      PomodoroSession(
        startedAt: json['startedAt'],
        elapsedSeconds: json['elapsedSeconds'] ?? 0,
        isRunning: false,
        workMinutes: json['workMinutes'] ?? 25,
      );
}

class Task {
  final String id;
  String title;
  String? description;
  TaskStatus status;
  List<ChecklistItem> checklist;
  PomodoroSession pomodoro;
  final String createdAt;
  String updatedAt;

  Task({
    String? id,
    required this.title,
    this.description,
    this.status = TaskStatus.todo,
    List<ChecklistItem>? checklist,
    PomodoroSession? pomodoro,
    String? createdAt,
    String? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        checklist = checklist ?? [],
        pomodoro = pomodoro ?? PomodoroSession(),
        createdAt = createdAt ?? DateTime.now().toIso8601String(),
        updatedAt = updatedAt ?? DateTime.now().toIso8601String();

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'status': status.index,
        'checklist': checklist.map((e) => e.toJson()).toList(),
        'pomodoro': pomodoro.toJson(),
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      };

  factory Task.fromJson(Map<String, dynamic> json) => Task(
        id: json['id'],
        title: json['title'],
        description: json['description'],
        status: TaskStatus.values[json['status'] ?? 0],
        checklist: (json['checklist'] as List?)
                ?.map((e) => ChecklistItem.fromJson(e))
                .toList() ??
            [],
        pomodoro: json['pomodoro'] != null
            ? PomodoroSession.fromJson(json['pomodoro'])
            : null,
        createdAt: json['createdAt'],
        updatedAt: json['updatedAt'],
      );
}
