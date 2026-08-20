import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

/// PBKDF2-HMAC-SHA256 (RFC 2898), built from the `crypto` package's HMAC
/// primitive since `crypto` has no PBKDF2 of its own. Used only to hash
/// the 4-digit parent PIN — it is never stored or compared in plaintext.
List<int> pbkdf2({
  required String password,
  required List<int> salt,
  int iterations = 20000,
  int keyLengthBytes = 32,
}) {
  final hmac = Hmac(sha256, utf8.encode(password));
  const blockSize = 32; // sha256 digest length
  final blocksNeeded = (keyLengthBytes / blockSize).ceil();
  final output = BytesBuilder();

  for (var blockIndex = 1; blockIndex <= blocksNeeded; blockIndex++) {
    final blockIndexBytes = ByteData(4)..setUint32(0, blockIndex, Endian.big);
    var u = hmac.convert([...salt, ...blockIndexBytes.buffer.asUint8List()]).bytes;
    var block = Uint8List.fromList(u);

    for (var i = 1; i < iterations; i++) {
      u = hmac.convert(u).bytes;
      for (var j = 0; j < block.length; j++) {
        block[j] ^= u[j];
      }
    }
    output.add(block);
  }

  return output.toBytes().sublist(0, keyLengthBytes);
}

/// Cryptographically random salt for a new PIN.
List<int> generateSalt({int lengthBytes = 16}) {
  final random = Random.secure();
  return List<int>.generate(lengthBytes, (_) => random.nextInt(256));
}

String bytesToHex(List<int> bytes) =>
    bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();

List<int> hexToBytes(String hex) {
  final result = <int>[];
  for (var i = 0; i < hex.length; i += 2) {
    result.add(int.parse(hex.substring(i, i + 2), radix: 16));
  }
  return result;
}
