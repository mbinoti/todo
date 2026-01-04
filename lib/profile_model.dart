import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileModel extends ChangeNotifier {
  static const String _nameKey = 'profile_name';
  static const String _emailKey = 'profile_email';
  static const String _photoPathKey = 'profile_photo_path';

  ProfileModel({
    String name = 'sdsd',
    String email = 'sdsd@gmail.com',
    String? photoPath,
  })  : _name = name,
        _email = email,
        _photoPath = photoPath;

  String _name;
  String _email;
  String? _photoPath;

  String get name => _name;
  String get email => _email;
  String? get photoPath => _photoPath;

  Future<void> loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _name = prefs.getString(_nameKey) ?? _name;
    _email = prefs.getString(_emailKey) ?? _email;
    final storedPhoto = prefs.getString(_photoPathKey);
    _photoPath =
        storedPhoto == null || storedPhoto.trim().isEmpty ? null : storedPhoto;
    notifyListeners();
  }

  Future<void> update({
    required String name,
    required String email,
    String? photoPath,
  }) async {
    _name = name;
    _email = email;
    _photoPath = photoPath;
    notifyListeners();
    await _saveToPrefs();
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_nameKey, _name);
    await prefs.setString(_emailKey, _email);
    if (_photoPath == null || _photoPath!.trim().isEmpty) {
      await prefs.remove(_photoPathKey);
    } else {
      await prefs.setString(_photoPathKey, _photoPath!);
    }
  }
}
