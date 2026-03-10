import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/task_provider.dart';
import 'providers/preferences_provider.dart';
import 'providers/profile_provider.dart';
import 'services/storage_service.dart';
import 'theme/app_themes.dart';
import 'screens/tasks_screen.dart';
import 'screens/accessibility_screen.dart';
import 'screens/profile_screen.dart';
import 'widgets/friendly_snackbar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final storage = StorageService();
  await storage.init();

  final taskProvider = TaskProvider(storage);
  final prefsProvider = PreferencesProvider(storage);
  final profileProvider = ProfileProvider(storage);

  await Future.wait([
    taskProvider.loadTasks(),
    prefsProvider.loadPreferences(),
    profileProvider.loadProfile(),
  ]);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: taskProvider),
        ChangeNotifierProvider.value(value: prefsProvider),
        ChangeNotifierProvider.value(value: profileProvider),
      ],
      child: const DMFMobileApp(),
    ),
  );
}

class DMFMobileApp extends StatelessWidget {
  const DMFMobileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PreferencesProvider>(
      builder: (context, prefsProvider, _) {
        return MaterialApp(
          title: 'MindEase',
          debugShowCheckedModeBanner: false,
          theme: buildTheme(prefsProvider.preferences),
          home: const HomeScreen(),
        );
      },
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  Timer? _alertTimer;
  DateTime _lastAlertTime = DateTime.now();

  static const _screens = [
    TasksScreen(),
    AccessibilityScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _startAlertTimer();
  }

  @override
  void dispose() {
    _alertTimer?.cancel();
    super.dispose();
  }

  void _startAlertTimer() {
    _alertTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (!mounted) return;
      final prefs = context.read<PreferencesProvider>().preferences;
      if (!prefs.cognitiveAlerts.enabled) return;

      final elapsed = DateTime.now().difference(_lastAlertTime).inMinutes;
      if (elapsed >= prefs.cognitiveAlerts.intervalMinutes) {
        _lastAlertTime = DateTime.now();
        _showCognitiveAlert(elapsed);
      }
    });
  }

  void _showCognitiveAlert(int minutes) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.self_improvement, color: Colors.blue, size: 40),
        title: const Text('Hora de uma pausa!'),
        content: Text(
          'Você está estudando há $minutes minutos. '
          'Que tal se levantar, beber água ou descansar os olhos por alguns minutos?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Agora não'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              showFriendlySnackBar(
                context,
                message: 'Boa! Aproveite sua pausa.',
                icon: Icons.favorite,
                isSuccess: true,
              );
            },
            child: const Text('Vou pausar!'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.task_alt),
            label: 'Tarefas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.accessibility_new),
            label: 'Acessibilidade',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
