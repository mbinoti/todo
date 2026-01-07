import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:app_todo/features/tasks/models/user_preferences.dart';

/// Domain model for the user profile stored in Firestore.
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
    DateTime resolveDate(Object? value) {
      if (value is DateTime) {
        return value;
      }
      if (value is Timestamp) {
        return value.toDate();
      }
      return DateTime.now();
    }

    return UserProfile(
      uid: uid,
      name: data['name'] as String? ?? '',
      email: data['email'] as String? ?? '',
      photoUrl: data['photoUrl'] as String?,
      createdAt: resolveDate(data['createdAt']),
      updatedAt: resolveDate(data['updatedAt']),
      preferences: UserPreferences.fromFirestore(
        data['preferences'] as Map<String, Object?>?,
      ),
    );
  }
}
