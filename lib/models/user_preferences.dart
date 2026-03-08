enum ComplexityLevel { simple, normal, detailed }

enum ThemeMode { calm, highContrast, darkFocus, minimal }

enum SpacingLevel { normal, wide }

enum FontScale { small, medium, large }

class CognitiveAlertConfig {
  bool enabled;
  int intervalMinutes;

  CognitiveAlertConfig({
    this.enabled = false,
    this.intervalMinutes = 30,
  });

  Map<String, dynamic> toJson() => {
        'enabled': enabled,
        'intervalMinutes': intervalMinutes,
      };

  factory CognitiveAlertConfig.fromJson(Map<String, dynamic> json) =>
      CognitiveAlertConfig(
        enabled: json['enabled'] ?? false,
        intervalMinutes: json['intervalMinutes'] ?? 30,
      );
}

class UserPreferences {
  ComplexityLevel complexityLevel;
  bool focusMode;
  ThemeMode themeMode;
  SpacingLevel spacingLevel;
  FontScale fontScale;
  bool animationsEnabled;
  CognitiveAlertConfig cognitiveAlerts;

  UserPreferences({
    this.complexityLevel = ComplexityLevel.normal,
    this.focusMode = false,
    this.themeMode = ThemeMode.calm,
    this.spacingLevel = SpacingLevel.normal,
    this.fontScale = FontScale.medium,
    this.animationsEnabled = true,
    CognitiveAlertConfig? cognitiveAlerts,
  }) : cognitiveAlerts = cognitiveAlerts ?? CognitiveAlertConfig();

  Map<String, dynamic> toJson() => {
        'complexityLevel': complexityLevel.index,
        'focusMode': focusMode,
        'themeMode': themeMode.index,
        'spacingLevel': spacingLevel.index,
        'fontScale': fontScale.index,
        'animationsEnabled': animationsEnabled,
        'cognitiveAlerts': cognitiveAlerts.toJson(),
      };

  factory UserPreferences.fromJson(Map<String, dynamic> json) =>
      UserPreferences(
        complexityLevel:
            ComplexityLevel.values[json['complexityLevel'] ?? 1],
        focusMode: json['focusMode'] ?? false,
        themeMode: ThemeMode.values[json['themeMode'] ?? 0],
        spacingLevel: SpacingLevel.values[json['spacingLevel'] ?? 0],
        fontScale: FontScale.values[json['fontScale'] ?? 1],
        animationsEnabled: json['animationsEnabled'] ?? true,
        cognitiveAlerts: json['cognitiveAlerts'] != null
            ? CognitiveAlertConfig.fromJson(json['cognitiveAlerts'])
            : null,
      );
}
