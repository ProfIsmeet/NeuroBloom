import 'package:hive/hive.dart';

import 'storage_service.dart';

/// Hive-backed implementation of [StorageService]. This is the only file
/// in the project (besides main.dart, which opens the box) allowed to
/// import hive.
class HiveStorageService implements StorageService {
  HiveStorageService(this._box);

  final Box<String> _box;

  @override
  Future<String?> readString(String key) async => _box.get(key);

  @override
  Future<void> writeString(String key, String value) async {
    await _box.put(key, value);
  }

  @override
  Future<void> delete(String key) async {
    await _box.delete(key);
  }
}
