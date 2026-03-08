import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_preferences.dart' as prefs;
import '../providers/preferences_provider.dart';
import '../widgets/friendly_snackbar.dart';

class AccessibilityScreen extends StatelessWidget {
  const AccessibilityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Acessibilidade')),
      body: Consumer<PreferencesProvider>(
        builder: (context, provider, _) {
          final p = provider.preferences;
          final isSimple = p.complexityLevel == prefs.ComplexityLevel.simple;
          final isDetailed = p.complexityLevel == prefs.ComplexityLevel.detailed;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _sectionTitle(context, 'Tema'),
              _buildThemeSelector(context, provider, p),
              const SizedBox(height: 24),
              _sectionTitle(context, 'Complexidade da Interface'),
              _buildComplexitySelector(context, provider, p),
              _complexityHint(context, p.complexityLevel),
              const SizedBox(height: 24),
              _sectionTitle(context, 'Tamanho da Fonte'),
              _buildFontScaleSelector(context, provider, p),
              if (!isSimple) ...[
                const SizedBox(height: 24),
                _sectionTitle(context, 'Espaçamento'),
                _buildSpacingSelector(context, provider, p),
              ],
              if (!isSimple) ...[
                const SizedBox(height: 24),
                _sectionTitle(context, 'Opções'),
                SwitchListTile(
                  title: const Text('Animações'),
                  subtitle: const Text('Ativar ou desativar animações'),
                  value: p.animationsEnabled,
                  onChanged: (_) => provider.toggleAnimations(),
                ),
                SwitchListTile(
                  title: const Text('Modo Foco'),
                  subtitle:
                      const Text('Exibe apenas o título das tarefas, sem detalhes'),
                  value: p.focusMode,
                  onChanged: (_) {
                    provider.toggleFocusMode();
                    showFriendlySnackBar(
                      context,
                      message: !p.focusMode
                          ? 'Modo Foco ativado. Distrações reduzidas.'
                          : 'Modo Foco desativado.',
                      icon: !p.focusMode
                          ? Icons.visibility_off
                          : Icons.visibility,
                      isSuccess: true,
                    );
                  },
                ),
              ],
              if (isDetailed) ...[
                const SizedBox(height: 24),
                _sectionTitle(context, 'Alertas Cognitivos'),
                _buildCognitiveAlerts(context, provider, p),
              ],
              const SizedBox(height: 32),
              Center(
                child: OutlinedButton.icon(
                  onPressed: () => _confirmReset(context, provider),
                  icon: const Icon(Icons.restart_alt),
                  label: const Text('Resetar Preferências'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          );
        },
      ),
    );
  }

  Widget _complexityHint(BuildContext context, prefs.ComplexityLevel level) {
    final hints = {
      prefs.ComplexityLevel.simple:
          'Interface mínima: apenas título e ações rápidas por ícones.',
      prefs.ComplexityLevel.normal:
          'Interface padrão: título, descrição, checklist e botões de ação.',
      prefs.ComplexityLevel.detailed:
          'Interface completa: tudo visível, incluindo Pomodoro e datas.',
    };
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        hints[level]!,
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(title, style: Theme.of(context).textTheme.titleLarge),
    );
  }

  Widget _buildThemeSelector(
      BuildContext context, PreferencesProvider provider, prefs.UserPreferences p) {
    const labels = {
      prefs.ThemeMode.calm: 'Calm',
      prefs.ThemeMode.highContrast: 'Alto Contraste',
      prefs.ThemeMode.darkFocus: 'Dark Focus',
      prefs.ThemeMode.minimal: 'Minimal',
    };

    return SegmentedButton<prefs.ThemeMode>(
      segments: labels.entries
          .map((e) => ButtonSegment(value: e.key, label: Text(e.value)))
          .toList(),
      selected: {p.themeMode},
      onSelectionChanged: (s) => provider.setThemeMode(s.first),
    );
  }

  Widget _buildComplexitySelector(
      BuildContext context, PreferencesProvider provider, prefs.UserPreferences p) {
    const labels = {
      prefs.ComplexityLevel.simple: 'Simples',
      prefs.ComplexityLevel.normal: 'Normal',
      prefs.ComplexityLevel.detailed: 'Detalhado',
    };

    return SegmentedButton<prefs.ComplexityLevel>(
      segments: labels.entries
          .map((e) => ButtonSegment(value: e.key, label: Text(e.value)))
          .toList(),
      selected: {p.complexityLevel},
      onSelectionChanged: (s) => provider.setComplexityLevel(s.first),
    );
  }

  Widget _buildFontScaleSelector(
      BuildContext context, PreferencesProvider provider, prefs.UserPreferences p) {
    const labels = {
      prefs.FontScale.small: 'Pequeno',
      prefs.FontScale.medium: 'Médio',
      prefs.FontScale.large: 'Grande',
    };

    return SegmentedButton<prefs.FontScale>(
      segments: labels.entries
          .map((e) => ButtonSegment(value: e.key, label: Text(e.value)))
          .toList(),
      selected: {p.fontScale},
      onSelectionChanged: (s) => provider.setFontScale(s.first),
    );
  }

  Widget _buildSpacingSelector(
      BuildContext context, PreferencesProvider provider, prefs.UserPreferences p) {
    const labels = {
      prefs.SpacingLevel.normal: 'Normal',
      prefs.SpacingLevel.wide: 'Amplo',
    };

    return SegmentedButton<prefs.SpacingLevel>(
      segments: labels.entries
          .map((e) => ButtonSegment(value: e.key, label: Text(e.value)))
          .toList(),
      selected: {p.spacingLevel},
      onSelectionChanged: (s) => provider.setSpacingLevel(s.first),
    );
  }

  Widget _buildCognitiveAlerts(
      BuildContext context, PreferencesProvider provider, prefs.UserPreferences p) {
    return Column(
      children: [
        SwitchListTile(
          title: const Text('Ativar alertas'),
          subtitle: const Text('Lembretes periódicos de pausa'),
          value: p.cognitiveAlerts.enabled,
          onChanged: (val) =>
              provider.setCognitiveAlerts(val, p.cognitiveAlerts.intervalMinutes),
        ),
        if (p.cognitiveAlerts.enabled)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Text('Intervalo: '),
                SizedBox(
                  width: 80,
                  child: TextField(
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      isDense: true,
                      suffixText: 'min',
                    ),
                    controller: TextEditingController(
                      text: p.cognitiveAlerts.intervalMinutes.toString(),
                    ),
                    onSubmitted: (val) {
                      final minutes = int.tryParse(val);
                      if (minutes != null && minutes > 0) {
                        provider.setCognitiveAlerts(true, minutes);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  void _confirmReset(BuildContext context, PreferencesProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.restart_alt, color: Colors.orange, size: 40),
        title: const Text('Restaurar padrões?'),
        content: const Text(
            'Suas preferências de acessibilidade voltarão ao padrão. Você pode ajustá-las novamente depois.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Manter atuais'),
          ),
          FilledButton(
            onPressed: () {
              provider.resetPreferences();
              Navigator.pop(ctx);
              showFriendlySnackBar(
                context,
                message: 'Preferências restauradas ao padrão.',
                isSuccess: true,
              );
            },
            child: const Text('Sim, restaurar'),
          ),
        ],
      ),
    );
  }
}
