import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';
import '../models/user_preferences.dart';
import '../models/user_profile.dart';

class StorageService {
  static const _tasksKey = 'tasks';
  static const _preferencesKey = 'preferences';
  static const _profileKey = 'profile';

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Tasks
  Future<List<Task>> loadTasks() async {
    final data = _prefs.getString(_tasksKey);
    if (data == null) return [];
    final list = jsonDecode(data) as List;
    return list.map((e) => Task.fromJson(e)).toList();
  }

  Future<void> saveTasks(List<Task> tasks) async {
    final data = jsonEncode(tasks.map((e) => e.toJson()).toList());
    await _prefs.setString(_tasksKey, data);
  }

  // Preferences
  Future<UserPreferences> loadPreferences() async {
    final data = _prefs.getString(_preferencesKey);
    if (data == null) return UserPreferences();
    return UserPreferences.fromJson(jsonDecode(data));
  }

  Future<void> savePreferences(UserPreferences preferences) async {
    await _prefs.setString(_preferencesKey, jsonEncode(preferences.toJson()));
  }

  // Profile
  Future<UserProfile> loadProfile() async {
    final data = _prefs.getString(_profileKey);
    if (data == null) return UserProfile();
    return UserProfile.fromJson(jsonDecode(data));
  }

  Future<void> saveProfile(UserProfile profile) async {
    await _prefs.setString(_profileKey, jsonEncode(profile.toJson()));
  }
}
