import 'package:neurobloom/core/storage/storage_service.dart';

class FakeStorageService implements StorageService {
  final Map<String, String> _data = {};

  @override
  Future<String?> readString(String key) async => _data[key];

  @override
  Future<void> writeString(String key, String value) async {
    _data[key] = value;
  }

  @override
  Future<void> delete(String key) async {
    _data.remove(key);
  }

  void seedRaw(String key, String value) {
    _data[key] = value;
  }
}
