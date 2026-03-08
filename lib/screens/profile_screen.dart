import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../models/user_preferences.dart';
import '../models/user_profile.dart';
import '../providers/preferences_provider.dart';
import '../providers/profile_provider.dart';
import '../widgets/friendly_snackbar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController _nameCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _routineCtrl;
  late TextEditingController _needsCtrl;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
    _emailCtrl = TextEditingController();
    _routineCtrl = TextEditingController();
    _needsCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _routineCtrl.dispose();
    _needsCtrl.dispose();
    super.dispose();
  }

  void _initControllers(UserProfile profile) {
    if (_initialized) return;
    _nameCtrl.text = profile.name;
    _emailCtrl.text = profile.email ?? '';
    _routineCtrl.text = profile.studyRoutine ?? '';
    _needsCtrl.text = profile.specificNeeds ?? '';
    _initialized = true;
  }

  void _saveProfile() {
    if (_nameCtrl.text.trim().isEmpty) {
      showFriendlySnackBar(
        context,
        message: 'Preencha seu nome para salvar o perfil.',
        isError: true,
      );
      return;
    }
    context.read<ProfileProvider>().updateProfile(
          name: _nameCtrl.text.trim(),
          email: _emailCtrl.text.trim().isEmpty
              ? null
              : _emailCtrl.text.trim(),
          studyRoutine: _routineCtrl.text.trim().isEmpty
              ? null
              : _routineCtrl.text.trim(),
          specificNeeds: _needsCtrl.text.trim().isEmpty
              ? null
              : _needsCtrl.text.trim(),
        );
    showFriendlySnackBar(
      context,
      message: 'Perfil salvo com sucesso!',
      isSuccess: true,
    );
  }

  void _exportData() {
    final profile = context.read<ProfileProvider>().profile;
    final preferences = context.read<PreferencesProvider>().preferences;
    final data = const JsonEncoder.withIndent('  ').convert({
      'profile': profile.toJson(),
      'preferences': preferences.toJson(),
    });

    Clipboard.setData(ClipboardData(text: data));
    showFriendlySnackBar(
      context,
      message: 'Dados copiados para a área de transferência! Cole em um arquivo .json para salvar.',
      isSuccess: true,
      duration: const Duration(seconds: 5),
    );
  }

  Future<void> _importData() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: kIsWeb ? FileType.any : FileType.custom,
        allowedExtensions: kIsWeb ? null : ['json'],
        withData: true,
      );
      if (result == null || result.files.isEmpty) return;

      final file = result.files.single;
      if (file.bytes == null) {
        if (mounted) {
          showFriendlySnackBar(
            context,
            message: 'Não foi possível ler o arquivo selecionado.',
            isError: true,
          );
        }
        return;
      }

      final content = utf8.decode(file.bytes!);

      late final Map<String, dynamic> data;
      try {
        data = jsonDecode(content) as Map<String, dynamic>;
      } catch (_) {
        if (mounted) {
          showFriendlySnackBar(
            context,
            message: 'O arquivo selecionado não é um JSON válido.',
            isError: true,
          );
        }
        return;
      }

      if (!data.containsKey('profile') && !data.containsKey('preferences')) {
        if (mounted) {
          showFriendlySnackBar(
            context,
            message: 'O arquivo não contém dados de perfil ou preferências.',
            isError: true,
          );
        }
        return;
      }

      if (!mounted) return;

      if (data.containsKey('profile')) {
        final profile = UserProfile.fromJson(data['profile']);
        context.read<ProfileProvider>().importProfile(profile);
        _initialized = false;
        setState(() {
          _initControllers(profile);
          _initialized = true;
        });
      }

      if (data.containsKey('preferences')) {
        final prefs = UserPreferences.fromJson(data['preferences']);
        context.read<PreferencesProvider>().importPreferences(prefs);
      }

      if (mounted) {
        showFriendlySnackBar(
          context,
          message: 'Dados importados com sucesso!',
          isSuccess: true,
        );
      }
    } catch (e) {
      if (mounted) {
        showFriendlySnackBar(
          context,
          message: 'Não foi possível importar o arquivo. Tente novamente.',
          isError: true,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: Consumer<ProfileProvider>(
        builder: (context, provider, _) {
          _initControllers(provider.profile);
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor:
                    Theme.of(context).colorScheme.primary,
                child: Text(
                  _nameCtrl.text.isNotEmpty
                      ? _nameCtrl.text[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    fontSize: 32,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nome',
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _emailCtrl,
                decoration: const InputDecoration(
                  labelText: 'E-mail',
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _routineCtrl,
                decoration: const InputDecoration(
                  labelText: 'Rotina de Estudo',
                  prefixIcon: Icon(Icons.schedule),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _needsCtrl,
                decoration: const InputDecoration(
                  labelText: 'Necessidades Específicas',
                  prefixIcon: Icon(Icons.accessibility_new),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _saveProfile,
                icon: const Icon(Icons.save),
                label: const Text('Salvar Perfil'),
              ),
              const SizedBox(height: 32),
              Text('Dados',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _exportData,
                      icon: const Icon(Icons.upload),
                      label: const Text('Exportar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _importData,
                      icon: const Icon(Icons.download),
                      label: const Text('Importar'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          );
        },
      ),
    );
  }
}
