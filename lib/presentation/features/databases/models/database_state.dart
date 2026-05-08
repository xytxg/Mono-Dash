import '../../../../data/dto/database/database_instance_dto.dart';

/// 数据库实例列表页状态。
class DatabaseState {
  const DatabaseState({
    this.instances = const [],
    this.isLoading = false,
    this.error,
  });

  final List<DatabaseInstanceDto> instances;
  final bool isLoading;
  final Object? error;

  /// 按类型分组，保持指定排序顺序。
  Map<String, List<DatabaseInstanceDto>> get groupedByType {
    final map = <String, List<DatabaseInstanceDto>>{};
    for (final inst in instances) {
      map.putIfAbsent(inst.type, () => []).add(inst);
    }
    // 按预定义顺序排序
    final ordered = <String, List<DatabaseInstanceDto>>{};
    for (final type in _typeOrder) {
      if (map.containsKey(type)) {
        ordered[type] = map[type]!;
      }
    }
    return ordered;
  }

  static const _typeOrder = [
    'mysql',
    'mariadb',
    'mysql-cluster',
    'postgresql',
    'postgresql-cluster',
    'redis',
    'redis-cluster',
  ];

  DatabaseState copyWith({
    List<DatabaseInstanceDto>? instances,
    bool? isLoading,
    Object? error,
  }) {
    return DatabaseState(
      instances: instances ?? this.instances,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// MySQL 管理页面状态。
class DatabaseManagementState {
  const DatabaseManagementState({
    this.checkResult,
    this.databases = const [],
    this.status = const {},
    this.isLoadingCheck = false,
    this.isLoadingDatabases = false,
    this.isLoadingStatus = false,
    this.checkError,
    this.databasesError,
    this.statusError,
  });

  final DatabaseCheckDto? checkResult;
  final List<DatabaseSearchItemDto> databases;
  final Map<String, String> status;
  final bool isLoadingCheck;
  final bool isLoadingDatabases;
  final bool isLoadingStatus;
  final Object? checkError;
  final Object? databasesError;
  final Object? statusError;

  bool get isRunning => checkResult?.status == 'Running';

  DatabaseManagementState copyWith({
    DatabaseCheckDto? checkResult,
    List<DatabaseSearchItemDto>? databases,
    Map<String, String>? status,
    bool? isLoadingCheck,
    bool? isLoadingDatabases,
    bool? isLoadingStatus,
    Object? checkError,
    Object? databasesError,
    Object? statusError,
  }) {
    return DatabaseManagementState(
      checkResult: checkResult ?? this.checkResult,
      databases: databases ?? this.databases,
      status: status ?? this.status,
      isLoadingCheck: isLoadingCheck ?? this.isLoadingCheck,
      isLoadingDatabases: isLoadingDatabases ?? this.isLoadingDatabases,
      isLoadingStatus: isLoadingStatus ?? this.isLoadingStatus,
      checkError: checkError,
      databasesError: databasesError,
      statusError: statusError,
    );
  }
}
