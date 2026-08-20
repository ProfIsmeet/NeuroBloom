import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/storage_service.dart';
import '../data/profile_repository.dart';
import '../domain/user_profile.dart';

/// Overridden in main.dart once the Hive box has been opened.
final storageServiceProvider = Provider<StorageService>((ref) {
  throw UnimplementedError('storageServiceProvider must be overridden');
});

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository(ref.watch(storageServiceProvider));
});

final profileControllerProvider =
    AsyncNotifierProvider<ProfileController, UserProfile?>(
      ProfileController.new,
    );

class ProfileController extends AsyncNotifier<UserProfile?> {
  @override
  Future<UserProfile?> build() {
    return ref.watch(profileRepositoryProvider).loadProfile();
  }

  Future<void> createProfile({
    required String name,
    required int age,
    required String gender,
    required int avatarId,
  }) async {
    final profile = UserProfile(
      name: name,
      age: age,
      gender: gender,
      avatarId: avatarId,
      createdAt: DateTime.now(),
      onboardingCompleted: true,
    );
    await ref.read(profileRepositoryProvider).saveProfile(profile);
    state = AsyncData(profile);
  }

  Future<void> updateAvatar(int avatarId) async {
    final current = state.valueOrNull;
    if (current == null) return;
    final updated = current.copyWith(avatarId: avatarId);
    await ref.read(profileRepositoryProvider).saveProfile(updated);
    state = AsyncData(updated);
  }
}
