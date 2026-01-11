import 'dart:async';
import 'dart:io';

import 'package:hive/hive.dart';

import 'package:app_todo/features/tasks/models/user_preferences.dart';
import 'package:app_todo/features/tasks/models/user_profile.dart';
import 'package:app_todo/features/tasks/repository/user_repository.dart';

/// Local user profile store backed by Hive for persistence.
class LocalUserRepository implements UserRepository {
  LocalUserRepository(this._box) {
    _loadFromStorage();
  }

  final Box<dynamic> _box;
  final Map<String, UserProfile> _profiles = {};
  final Map<String, StreamController<UserProfile?>> _controllers = {};

  @override
  Stream<UserProfile?> watchProfile(String uid) {
    final controller = _controllers.putIfAbsent(
      uid,
      () => StreamController<UserProfile?>.broadcast(),
    );
    Future.microtask(() {
      if (controller.isClosed) {
        return;
      }
      controller.add(_profiles[uid]);
    });
    return controller.stream;
  }

  @override
  Future<UserProfile?> fetchProfile(String uid) async {
    return _profiles[uid];
  }

  @override
  Future<UserProfile> createProfile(UserProfile profile) async {
    _profiles[profile.uid] = profile;
    await _persistProfile(profile.uid);
    _emitProfile(profile.uid);
    return profile;
  }

  @override
  Future<UserProfile> ensureProfile({
    required String uid,
    required String email,
    String? name,
  }) async {
    final existing = _profiles[uid];
    if (existing != null) {
      return existing;
    }
    final resolvedName = (name == null || name.trim().isEmpty)
        ? (email.split('@').first)
        : name;
    final now = DateTime.now();
    final profile = UserProfile(
      uid: uid,
      name: resolvedName,
      email: email,
      photoUrl: null,
      createdAt: now,
      updatedAt: now,
      preferences: const UserPreferences(),
    );
    await createProfile(profile);
    return profile;
  }

  @override
  Future<void> updateProfile({
    required String uid,
    required String name,
    required String email,
    String? photoUrl,
  }) async {
    final existing = _profiles[uid];
    final now = DateTime.now();
    final updated = (existing ??
            UserProfile(
              uid: uid,
              name: name,
              email: email,
              photoUrl: photoUrl,
              createdAt: now,
              updatedAt: now,
              preferences: const UserPreferences(),
            ))
        .copyWith(
          name: name,
          email: email,
          photoUrl: photoUrl ?? existing?.photoUrl,
          updatedAt: now,
        );
    _profiles[uid] = updated;
    await _persistProfile(uid);
    _emitProfile(uid);
  }

  @override
  Future<void> updatePreferences({
    required String uid,
    required UserPreferences preferences,
  }) async {
    final existing = _profiles[uid];
    final now = DateTime.now();
    final updated = (existing ??
            UserProfile(
              uid: uid,
              name: '',
              email: '',
              photoUrl: null,
              createdAt: now,
              updatedAt: now,
              preferences: preferences,
            ))
        .copyWith(
          preferences: preferences,
          updatedAt: now,
        );
    _profiles[uid] = updated;
    await _persistProfile(uid);
    _emitProfile(uid);
  }

  @override
  Future<String> uploadProfileImage({
    required String uid,
    required File file,
  }) async {
    return file.path;
  }

  void _loadFromStorage() {
    for (final key in _box.keys) {
      if (key is! String || key.isEmpty) {
        continue;
      }
      final raw = _box.get(key);
      if (raw is Map) {
        final data = Map<String, Object?>.from(raw);
        _profiles[key] = UserProfile.fromFirestore(key, data);
      }
    }
  }

  Future<void> _persistProfile(String uid) {
    final profile = _profiles[uid];
    if (profile == null) {
      return Future.value();
    }
    final data = _encodeMap(profile.toFirestore());
    return _box.put(uid, data);
  }

  void _emitProfile(String uid) {
    final controller = _controllers[uid];
    if (controller == null || controller.isClosed) {
      return;
    }
    controller.add(_profiles[uid]);
  }

  Map<String, Object?> _encodeMap(Map<String, Object?> data) {
    return data.map((key, value) => MapEntry(key, _encodeValue(value)));
  }

  Object? _encodeValue(Object? value) {
    if (value is DateTime) {
      return value.toIso8601String();
    }
    if (value is Map) {
      return value.map((key, nested) => MapEntry(key, _encodeValue(nested)));
    }
    if (value is List) {
      return value.map(_encodeValue).toList(growable: false);
    }
    return value;
  }
}
