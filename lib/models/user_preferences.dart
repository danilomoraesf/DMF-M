enum ComplexityLevel { simple, normal, detailed }

enum ThemeMode { calm, highContrast, darkFocus, minimal }

enum SpacingLevel { normal, wide }

enum FontScale { small, medium, large }

class UserPreferences {
  ComplexityLevel complexityLevel;
  bool focusMode;
  ThemeMode themeMode;
  SpacingLevel spacingLevel;
  FontScale fontScale;

  UserPreferences({
    this.complexityLevel = ComplexityLevel.normal,
    this.focusMode = false,
    this.themeMode = ThemeMode.calm,
    this.spacingLevel = SpacingLevel.normal,
    this.fontScale = FontScale.medium,
  });

  Map<String, dynamic> toJson() => {
        'complexityLevel': complexityLevel.index,
        'focusMode': focusMode,
        'themeMode': themeMode.index,
        'spacingLevel': spacingLevel.index,
        'fontScale': fontScale.index,
      };

  factory UserPreferences.fromJson(Map<String, dynamic> json) =>
      UserPreferences(
        complexityLevel:
            ComplexityLevel.values[json['complexityLevel'] ?? 1],
        focusMode: json['focusMode'] ?? false,
        themeMode: ThemeMode.values[json['themeMode'] ?? 0],
        spacingLevel: SpacingLevel.values[json['spacingLevel'] ?? 0],
        fontScale: FontScale.values[json['fontScale'] ?? 1],
      );
}
