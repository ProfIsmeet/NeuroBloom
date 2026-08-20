import 'package:flutter_test/flutter_test.dart';
import 'package:neurobloom/core/constants/storage_keys.dart';
import 'package:neurobloom/features/onboarding/data/profile_repository.dart';
import 'package:neurobloom/features/onboarding/domain/user_profile.dart';

import '../../support/fake_storage_service.dart';

void main() {
  group('ProfileRepository', () {
    test('returns null when nothing saved yet', () async {
      final repo = ProfileRepository(FakeStorageService());
      expect(await repo.loadProfile(), isNull);
    });

    test('round-trips a saved profile', () async {
      final storage = FakeStorageService();
      final repo = ProfileRepository(storage);
      final profile = UserProfile(
        name: 'Ada',
        age: 7,
        gender: 'Kız',
        avatarId: 3,
        createdAt: DateTime(2026, 1, 1),
        onboardingCompleted: true,
      );

      await repo.saveProfile(profile);
      final loaded = await repo.loadProfile();

      expect(loaded, isNotNull);
      expect(loaded!.name, 'Ada');
      expect(loaded.age, 7);
      expect(loaded.gender, 'Kız');
      expect(loaded.avatarId, 3);
      expect(loaded.onboardingCompleted, isTrue);
    });

    test('corrupted JSON returns null instead of throwing', () async {
      final storage = FakeStorageService()
        ..seedRaw(StorageKeys.userProfile, '{not valid json');
      final repo = ProfileRepository(storage);

      expect(await repo.loadProfile(), isNull);
    });

    test('missing required field returns null instead of throwing', () async {
      final storage = FakeStorageService()
        ..seedRaw(StorageKeys.userProfile, '{"name":"Ada"}');
      final repo = ProfileRepository(storage);

      expect(await repo.loadProfile(), isNull);
    });
  });
}
