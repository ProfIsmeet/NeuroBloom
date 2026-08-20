/// Narrow abstraction over encrypted key-value storage, used only for the
/// parent PIN's salt+hash — kept separate from the general Hive-backed
/// StorageService per the spec ("salt and hash in secure storage").
abstract class SecureCredentialStore {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);
}
