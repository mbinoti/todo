/// Preferences stored under the user profile document.
class UserPreferences {
  const UserPreferences({
    this.notificationsEnabled = true,
    this.darkMode = false,
    this.language = 'pt-BR',
  });

  final bool notificationsEnabled;
  final bool darkMode;
  final String language;

  UserPreferences copyWith({
    bool? notificationsEnabled,
    bool? darkMode,
    String? language,
  }) {
    return UserPreferences(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      darkMode: darkMode ?? this.darkMode,
      language: language ?? this.language,
    );
  }

  Map<String, Object?> toFirestore() {
    return {
      'notificationsEnabled': notificationsEnabled,
      'darkMode': darkMode,
      'language': language,
    };
  }

  static UserPreferences fromFirestore(Map<String, Object?>? data) {
    if (data == null) {
      return const UserPreferences();
    }
    return UserPreferences(
      notificationsEnabled: data['notificationsEnabled'] as bool? ?? true,
      darkMode: data['darkMode'] as bool? ?? false,
      language: data['language'] as String? ?? 'pt-BR',
    );
  }
}
