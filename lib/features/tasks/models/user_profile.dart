import 'package:app_todo/features/tasks/models/user_preferences.dart';

/// Domain model for the user profile stored locally.
class UserProfile {
  const UserProfile({
    required this.uid,
    required this.name,
    required this.email,
    required this.createdAt,
    required this.updatedAt,
    this.photoUrl,
    this.preferences = const UserPreferences(),
  });

  final String uid;
  final String name;
  final String email;
  final String? photoUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final UserPreferences preferences;

  UserProfile copyWith({
    String? name,
    String? email,
    String? photoUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    UserPreferences? preferences,
  }) {
    return UserProfile(
      uid: uid,
      name: name ?? this.name,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      preferences: preferences ?? this.preferences,
    );
  }

  Map<String, Object?> toFirestore() {
    return {
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'preferences': preferences.toFirestore(),
    };
  }

  static UserProfile fromFirestore(String uid, Map<String, Object?> data) {
    DateTime? parseDate(Object? value) {
      if (value == null) {
        return null;
      }
      if (value is DateTime) {
        return value;
      }
      if (value is int) {
        return DateTime.fromMillisecondsSinceEpoch(value);
      }
      if (value is String) {
        return DateTime.tryParse(value);
      }
      try {
        final dynamic dynamicValue = value;
        final dynamic resolved = dynamicValue.toDate();
        if (resolved is DateTime) {
          return resolved;
        }
      } catch (_) {
        return null;
      }
      return null;
    }

    final rawPreferences = data['preferences'];
    final preferencesData = rawPreferences is Map
        ? Map<String, Object?>.from(rawPreferences)
        : null;

    return UserProfile(
      uid: uid,
      name: data['name'] as String? ?? '',
      email: data['email'] as String? ?? '',
      photoUrl: data['photoUrl'] as String?,
      createdAt: parseDate(data['createdAt']) ?? DateTime.now(),
      updatedAt: parseDate(data['updatedAt']) ?? DateTime.now(),
      preferences: UserPreferences.fromFirestore(preferencesData),
    );
  }
}
