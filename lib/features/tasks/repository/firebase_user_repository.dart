import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:app_todo/features/tasks/models/user_preferences.dart';
import 'package:app_todo/features/tasks/models/user_profile.dart';
import 'package:app_todo/features/tasks/repository/user_repository.dart';

/// Firebase-backed implementation of UserRepository.
class FirebaseUserRepository implements UserRepository {
  FirebaseUserRepository(this._firestore, this._storage);

  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) {
    return _users.doc(uid);
  }

  @override
  Stream<UserProfile?> watchProfile(String uid) {
    return _userDoc(uid).snapshots().map((snapshot) {
      if (!snapshot.exists) {
        return null;
      }
      final data = snapshot.data();
      if (data == null) {
        return null;
      }
      return UserProfile.fromFirestore(uid, data);
    });
  }

  @override
  Future<UserProfile?> fetchProfile(String uid) async {
    final snapshot = await _userDoc(uid).get();
    if (!snapshot.exists) {
      return null;
    }
    final data = snapshot.data();
    if (data == null) {
      return null;
    }
    return UserProfile.fromFirestore(uid, data);
  }

  @override
  Future<UserProfile> createProfile(UserProfile profile) async {
    final data = profile.toFirestore();
    data['createdAt'] = FieldValue.serverTimestamp();
    data['updatedAt'] = FieldValue.serverTimestamp();
    await _userDoc(profile.uid).set(data, SetOptions(merge: true));
    return profile;
  }

  @override
  Future<UserProfile> ensureProfile({
    required String uid,
    required String email,
    String? name,
  }) async {
    final existing = await fetchProfile(uid);
    if (existing != null) {
      return existing;
    }
    final resolvedName = (name == null || name.trim().isEmpty)
        ? (email.split('@').first)
        : name;
    final profile = UserProfile(
      uid: uid,
      name: resolvedName,
      email: email,
      photoUrl: null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
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
    await _userDoc(uid).set(
      {
        'name': name,
        'email': email,
        'photoUrl': photoUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  @override
  Future<void> updatePreferences({
    required String uid,
    required UserPreferences preferences,
  }) async {
    await _userDoc(uid).set(
      {
        'preferences': preferences.toFirestore(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  @override
  Future<String> uploadProfileImage({
    required String uid,
    required File file,
  }) async {
    final ref = _storage.ref().child('users/$uid/profile/avatar.jpg');
    await ref.putFile(file);
    return ref.getDownloadURL();
  }
}
