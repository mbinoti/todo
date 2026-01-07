import 'dart:io';

import 'package:app_todo/features/tasks/models/user_preferences.dart';
import 'package:app_todo/features/tasks/models/user_profile.dart';

/// Contract for user profile persistence.
abstract class UserRepository {
  Stream<UserProfile?> watchProfile(String uid);

  Future<UserProfile?> fetchProfile(String uid);

  Future<UserProfile> createProfile(UserProfile profile);

  Future<UserProfile> ensureProfile({
    required String uid,
    required String email,
    String? name,
  });

  Future<void> updateProfile({
    required String uid,
    required String name,
    required String email,
    String? photoUrl,
  });

  Future<void> updatePreferences({
    required String uid,
    required UserPreferences preferences,
  });

  Future<String> uploadProfileImage({
    required String uid,
    required File file,
  });
}
