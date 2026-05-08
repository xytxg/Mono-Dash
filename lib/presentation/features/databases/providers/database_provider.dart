import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../data/dto/database/database_instance_dto.dart';
import '../../../../data/repositories_impl/database_repository_impl.dart';
import '../../../features/server_detail/providers/active_server_provider.dart';
import '../models/database_state.dart';

part 'database_provider.g.dart';

const _databaseTypes =
    'postgresql,postgresql-cluster,mysql,mariadb,mysql-cluster,redis,redis-cluster';

typedef MysqlManagementKey = ({String dbType, String dbName});

/// 数据库实例列表控制器。
@Riverpod(dependencies: [databaseRepository, activeServerId])
class DatabaseController extends _$DatabaseController {
  @override
  FutureOr<DatabaseState> build() async {
    final repo = await ref.watch(databaseRepositoryProvider.future);
    final instances = await repo.listInstances(_databaseTypes);
    return DatabaseState(instances: instances);
  }

  Future<void> refresh() async {
    state = await AsyncValue.guard(() async {
      final repo = await ref.read(databaseRepositoryProvider.future);
      final instances = await repo.listInstances(_databaseTypes);
      return DatabaseState(instances: instances);
    });
  }
}

/// MySQL 管理页面控制器。
///
/// [dbType] 为数据库类型 key（如 mysql、postgresql），
/// [dbName] 为数据库实例名称（如 mysql-2）。
@Riverpod(dependencies: [databaseRepository])
class DatabaseManagementController extends _$DatabaseManagementController {
  @override
  FutureOr<DatabaseManagementState> build(String dbType, String dbName) async {
    final repo = await ref.watch(databaseRepositoryProvider.future);
    final checkResult = await repo.checkInstalled(key: dbType, name: dbName);
    return DatabaseManagementState(checkResult: checkResult);
  }

  Future<void> refresh() async {
    state = await AsyncValue.guard(() async {
      final repo = await ref.read(databaseRepositoryProvider.future);
      final checkResult = await repo.checkInstalled(key: dbType, name: dbName);
      return DatabaseManagementState(checkResult: checkResult);
    });
  }
}

@Riverpod(dependencies: [databaseRepository])
Future<List<DatabaseSearchItemDto>> mysqlDatabaseList(
  Ref ref,
  MysqlManagementKey key,
) async {
  final repo = await ref.watch(databaseRepositoryProvider.future);
  final result = await repo.searchDatabases(database: key.dbName);
  return result.items;
}

@Riverpod(dependencies: [databaseRepository])
Future<List<DatabaseSearchItemDto>> pgDatabaseList(
  Ref ref,
  MysqlManagementKey key,
) async {
  final repo = await ref.watch(databaseRepositoryProvider.future);
  final result = await repo.searchPgDatabases(database: key.dbName);
  return result.items;
}

@Riverpod(dependencies: [databaseRepository])
Future<Map<String, String>> mysqlStatus(
  Ref ref,
  MysqlManagementKey key,
) async {
  final repo = await ref.watch(databaseRepositoryProvider.future);
  return repo.getStatus(type: key.dbType, name: key.dbName);
}

@Riverpod(dependencies: [databaseRepository])
Future<Map<String, String>> redisStatus(
  Ref ref,
  MysqlManagementKey key,
) async {
  final repo = await ref.watch(databaseRepositoryProvider.future);
  return repo.getRedisStatus(type: key.dbType, name: key.dbName);
}

@Riverpod(dependencies: [databaseRepository])
Future<RedisConfDto> redisConf(
  Ref ref,
  MysqlManagementKey key,
) async {
  final repo = await ref.watch(databaseRepositoryProvider.future);
  return repo.getRedisConf(type: key.dbType, name: key.dbName);
}

@Riverpod(dependencies: [databaseRepository])
Future<RedisPersistenceDto> redisPersistence(
  Ref ref,
  MysqlManagementKey key,
) async {
  final repo = await ref.watch(databaseRepositoryProvider.future);
  return repo.getRedisPersistence(type: key.dbType, name: key.dbName);
}
