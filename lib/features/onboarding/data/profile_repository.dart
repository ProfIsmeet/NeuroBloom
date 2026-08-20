import 'dart:convert';

import '../../../core/constants/storage_keys.dart';
import '../../../core/storage/storage_service.dart';
import '../domain/user_profile.dart';

class ProfileRepository {
  ProfileRepository(this._storage);

  final StorageService _storage;

  Future<UserProfile?> loadProfile() async {
    final raw = await _storage.readString(StorageKeys.userProfile);
    if (raw == null) return null;
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return UserProfile.fromJson(json);
    } catch (_) {
      // Corrupted or schema-mismatched data must never crash the app.
      return null;
    }
  }

  Future<void> saveProfile(UserProfile profile) async {
    await _storage.writeString(
      StorageKeys.userProfile,
      jsonEncode(profile.toJson()),
    );
  }
}
