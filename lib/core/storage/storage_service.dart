import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/server.dart';

import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'storage_service.g.dart';

/// 同步提供 [StorageService] 的实例。
///
/// 必须在 main.dart 中完成初始化并通过 `ProviderScope.overrides` 覆盖此 Provider，
/// 否则任何读取都会抛出 [UnimplementedError]。
@Riverpod(keepAlive: true)
StorageService storageService(Ref ref) {
  throw UnimplementedError('storageServiceProvider 必须在 main.dart 中 override');
}

class StorageService {
  late final Isar isar;
  late final SharedPreferences _prefs;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  static const _legacyAllowInsecureConnectionsKey =
      'allow_insecure_connections';

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open([ServerSchema], directory: dir.path);
    await _migrateLegacyAllowInsecureConnections();
  }

  Future<void> _migrateLegacyAllowInsecureConnections() async {
    final legacyValue = _prefs.getBool(_legacyAllowInsecureConnectionsKey);
    if (legacyValue != true) return;

    final servers = await isar.servers.where().findAll();
    await isar.writeTxn(() async {
      for (final server in servers) {
        server.allowInsecureConnections = true;
        await isar.servers.put(server);
      }
    });
    await _prefs.remove(_legacyAllowInsecureConnectionsKey);
  }

  // --- UI State (Shared Preferences) ---

  String? getString(String key) => _prefs.getString(key);

  Future<void> setString(String key, String value) async {
    await _prefs.setString(key, value);
  }

  Future<void> remove(String key) async {
    await _prefs.remove(key);
  }

  // --- Servers (Isar) ---

  Future<List<Server>> getServers() async {
    return await isar.servers.where().sortBySortIndex().findAll();
  }

  Future<Server?> getServer(int id) async {
    return await isar.servers.get(id);
  }

  Future<void> saveServer(Server server) async {
    await isar.writeTxn(() async {
      await isar.servers.put(server);
    });
  }

  Future<void> deleteServer(int id) async {
    await isar.writeTxn(() async {
      final success = await isar.servers.delete(id);
      if (success) {
        await deleteApiKey(id);
      }
    });
  }

  // --- API Keys (Secure Storage) ---

  String _apiKeyKey(int id) => 'api_key_$id';

  Future<void> saveApiKey(int id, String apiKey) async {
    await _secureStorage.write(key: _apiKeyKey(id), value: apiKey);
  }

  Future<String?> getApiKey(int id) async {
    return await _secureStorage.read(key: _apiKeyKey(id));
  }

  Future<void> deleteApiKey(int id) async {
    await _secureStorage.delete(key: _apiKeyKey(id));
  }
}
