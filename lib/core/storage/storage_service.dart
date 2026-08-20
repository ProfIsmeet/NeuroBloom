/// Abstract persistence interface. UI and repositories depend only on this;
/// nothing outside core/storage/ may import hive directly.
abstract class StorageService {
  Future<String?> readString(String key);
  Future<void> writeString(String key, String value);
  Future<void> delete(String key);
}
