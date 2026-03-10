import 'package:flutter_test/flutter_test.dart';
import 'package:dmf_mobile/models/task.dart';
import 'package:dmf_mobile/models/user_preferences.dart';
import 'package:dmf_mobile/models/user_profile.dart';

void main() {
  group('Task', () {
    test('cria tarefa com valores padrão', () {
      final task = Task(title: 'Estudar Flutter');
      expect(task.title, 'Estudar Flutter');
      expect(task.status, TaskStatus.todo);
      expect(task.checklist, isEmpty);
      expect(task.pomodoro.workMinutes, 25);
    });

    test('serializa e deserializa corretamente', () {
      final task = Task(title: 'Teste', description: 'Desc');
      final json = task.toJson();
      final restored = Task.fromJson(json);
      expect(restored.title, 'Teste');
      expect(restored.description, 'Desc');
      expect(restored.id, task.id);
    });
  });

  group('ChecklistItem', () {
    test('cria item não completado por padrão', () {
      final item = ChecklistItem(text: 'Item 1');
      expect(item.completed, false);
    });
  });

  group('UserPreferences', () {
    test('valores padrão corretos', () {
      final prefs = UserPreferences();
      expect(prefs.themeMode, ThemeMode.calm);
      expect(prefs.complexityLevel, ComplexityLevel.normal);
      expect(prefs.fontScale, FontScale.medium);
    });

    test('serializa e deserializa corretamente', () {
      final prefs = UserPreferences(
        themeMode: ThemeMode.darkFocus,
        fontScale: FontScale.large,
      );
      final json = prefs.toJson();
      final restored = UserPreferences.fromJson(json);
      expect(restored.themeMode, ThemeMode.darkFocus);
      expect(restored.fontScale, FontScale.large);
    });
  });

  group('UserProfile', () {
    test('serializa e deserializa corretamente', () {
      final profile = UserProfile(name: 'João', email: 'joao@email.com');
      final json = profile.toJson();
      final restored = UserProfile.fromJson(json);
      expect(restored.name, 'João');
      expect(restored.email, 'joao@email.com');
    });
  });
}
