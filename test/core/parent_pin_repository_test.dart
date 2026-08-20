import 'package:flutter_test/flutter_test.dart';
import 'package:neurobloom/core/security/parent_pin_repository.dart';

import '../support/fake_secure_credential_store.dart';

void main() {
  group('ParentPinRepository', () {
    test('hasPin is false before any PIN is created', () async {
      final repo = ParentPinRepository(FakeSecureCredentialStore());
      expect(await repo.hasPin(), isFalse);
    });

    test('creating a PIN makes hasPin true', () async {
      final repo = ParentPinRepository(FakeSecureCredentialStore());
      await repo.createPin('1234');
      expect(await repo.hasPin(), isTrue);
    });

    test('the correct PIN verifies successfully', () async {
      final repo = ParentPinRepository(FakeSecureCredentialStore());
      await repo.createPin('1234');
      expect(await repo.verifyPin('1234'), isTrue);
    });

    test('a wrong PIN fails verification', () async {
      final repo = ParentPinRepository(FakeSecureCredentialStore());
      await repo.createPin('1234');
      expect(await repo.verifyPin('9999'), isFalse);
    });

    test('verifying before any PIN exists fails rather than throwing', () async {
      final repo = ParentPinRepository(FakeSecureCredentialStore());
      expect(await repo.verifyPin('1234'), isFalse);
    });

    test('the PIN is never stored in plaintext', () async {
      final store = FakeSecureCredentialStore();
      final repo = ParentPinRepository(store);
      await repo.createPin('1234');

      final hash = await store.read('parent_pin_hash');
      final salt = await store.read('parent_pin_salt');
      expect(hash, isNotNull);
      expect(hash, isNot(contains('1234')));
      expect(salt, isNotNull);
    });

    test('PIN persists across a new repository instance over the same store', () async {
      final store = FakeSecureCredentialStore();
      await ParentPinRepository(store).createPin('4242');

      final reloaded = ParentPinRepository(store);
      expect(await reloaded.hasPin(), isTrue);
      expect(await reloaded.verifyPin('4242'), isTrue);
    });
  });
}
