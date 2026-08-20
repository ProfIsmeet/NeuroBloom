import 'package:flutter_test/flutter_test.dart';
import 'package:neurobloom/core/security/pbkdf2.dart';

void main() {
  group('pbkdf2', () {
    test('is deterministic: same password + salt -> same hash', () {
      final salt = generateSalt();
      final a = pbkdf2(password: '1234', salt: salt, iterations: 1000);
      final b = pbkdf2(password: '1234', salt: salt, iterations: 1000);
      expect(bytesToHex(a), bytesToHex(b));
    });

    test('different passwords produce different hashes', () {
      final salt = generateSalt();
      final a = pbkdf2(password: '1234', salt: salt, iterations: 1000);
      final b = pbkdf2(password: '4321', salt: salt, iterations: 1000);
      expect(bytesToHex(a), isNot(bytesToHex(b)));
    });

    test('different salts produce different hashes for the same password', () {
      final a = pbkdf2(password: '1234', salt: generateSalt(), iterations: 1000);
      final b = pbkdf2(password: '1234', salt: generateSalt(), iterations: 1000);
      expect(bytesToHex(a), isNot(bytesToHex(b)));
    });

    test('generateSalt returns distinct values each call', () {
      final a = generateSalt();
      final b = generateSalt();
      expect(a, isNot(b));
    });

    test('hex round-trip preserves bytes', () {
      final bytes = generateSalt(lengthBytes: 8);
      expect(hexToBytes(bytesToHex(bytes)), bytes);
    });
  });
}
