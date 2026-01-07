import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';

import 'package:app_todo/features/tasks/models/user_preferences.dart';
import 'package:app_todo/features/tasks/models/user_profile.dart';
import 'package:app_todo/features/tasks/repository/user_repository.dart';
import 'package:app_todo/features/tasks/view_model/auth_model.dart';

/// Manages the authenticated user's profile data.
class ProfileModel extends ChangeNotifier {
  ProfileModel();

  AuthModel? _authModel;
  UserRepository? _userRepository;
  StreamSubscription<UserProfile?>? _profileSubscription;

  UserProfile? _profile;
  bool _isUpdating = false;
  String? _errorMessage;

  String get name => _profile?.name ?? '';
  String get email => _profile?.email ?? '';
  String? get photoUrl => _profile?.photoUrl;
  UserPreferences get preferences =>
      _profile?.preferences ?? const UserPreferences();
  bool get isUpdating => _isUpdating;
  String? get errorMessage => _errorMessage;

  void bind({
    required AuthModel authModel,
    required UserRepository userRepository,
  }) {
    if (identical(_authModel, authModel) &&
        identical(_userRepository, userRepository)) {
      return;
    }
    _authModel?.removeListener(_handleAuthChanged);
    _authModel = authModel;
    _userRepository = userRepository;
    _authModel?.addListener(_handleAuthChanged);
    _handleAuthChanged();
  }

  Future<void> updateProfile({
    required String name,
    required String email,
    File? photoFile,
  }) async {
    final authUser = _authModel?.currentUser;
    final userRepository = _userRepository;
    if (authUser == null || userRepository == null) {
      return;
    }
    _setUpdating(true);
    _errorMessage = null;
    try {
      var photoUrl = _profile?.photoUrl;
      if (photoFile != null) {
        photoUrl = await userRepository.uploadProfileImage(
          uid: authUser.uid,
          file: photoFile,
        );
      }
      await userRepository.updateProfile(
        uid: authUser.uid,
        name: name,
        email: email,
        photoUrl: photoUrl,
      );
      _profile = (_profile ??
              UserProfile(
                uid: authUser.uid,
                name: name,
                email: email,
                photoUrl: photoUrl,
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
                preferences: const UserPreferences(),
              ))
          .copyWith(
            name: name,
            email: email,
            photoUrl: photoUrl,
            updatedAt: DateTime.now(),
          );
      notifyListeners();
    } catch (_) {
      _errorMessage = 'Não foi possível atualizar o perfil.';
    } finally {
      _setUpdating(false);
    }
  }

  Future<void> updatePreferences({
    bool? notificationsEnabled,
    bool? darkMode,
    String? language,
  }) async {
    final authUser = _authModel?.currentUser;
    final userRepository = _userRepository;
    if (authUser == null || userRepository == null) {
      return;
    }
    _setUpdating(true);
    _errorMessage = null;
    try {
      final updated = preferences.copyWith(
        notificationsEnabled: notificationsEnabled,
        darkMode: darkMode,
        language: language,
      );
      await userRepository.updatePreferences(
        uid: authUser.uid,
        preferences: updated,
      );
      _profile = (_profile ??
              UserProfile(
                uid: authUser.uid,
                name: name,
                email: email,
                photoUrl: photoUrl,
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
                preferences: updated,
              ))
          .copyWith(
            preferences: updated,
            updatedAt: DateTime.now(),
          );
      notifyListeners();
    } catch (_) {
      _errorMessage = 'Não foi possível atualizar preferências.';
    } finally {
      _setUpdating(false);
    }
  }

  void _handleAuthChanged() {
    final authUser = _authModel?.currentUser;
    _profileSubscription?.cancel();
    if (authUser == null) {
      _profile = null;
      notifyListeners();
      return;
    }
    final userRepository = _userRepository;
    if (userRepository == null) {
      return;
    }
    _profileSubscription =
        userRepository.watchProfile(authUser.uid).listen((profile) {
      _profile = profile;
      notifyListeners();
    });
  }

  void _setUpdating(bool value) {
    if (_isUpdating == value) {
      return;
    }
    _isUpdating = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _authModel?.removeListener(_handleAuthChanged);
    _profileSubscription?.cancel();
    super.dispose();
  }
}
