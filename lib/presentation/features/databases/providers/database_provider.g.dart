// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$mysqlDatabaseListHash() => r'28a9d34e4cb09da2bae94fcbbead7fd1a3ab5469';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [mysqlDatabaseList].
@ProviderFor(mysqlDatabaseList)
const mysqlDatabaseListProvider = MysqlDatabaseListFamily();

/// See also [mysqlDatabaseList].
class MysqlDatabaseListFamily
    extends Family<AsyncValue<List<DatabaseSearchItemDto>>> {
  /// See also [mysqlDatabaseList].
  const MysqlDatabaseListFamily();

  /// See also [mysqlDatabaseList].
  MysqlDatabaseListProvider call(
    ({String dbName, String dbType}) key,
  ) {
    return MysqlDatabaseListProvider(
      key,
    );
  }

  @override
  MysqlDatabaseListProvider getProviderOverride(
    covariant MysqlDatabaseListProvider provider,
  ) {
    return call(
      provider.key,
    );
  }

  static final Iterable<ProviderOrFamily> _dependencies = <ProviderOrFamily>[
    databaseRepositoryProvider
  ];

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static final Iterable<ProviderOrFamily> _allTransitiveDependencies =
      <ProviderOrFamily>{
    databaseRepositoryProvider,
    ...?databaseRepositoryProvider.allTransitiveDependencies
  };

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'mysqlDatabaseListProvider';
}

/// See also [mysqlDatabaseList].
class MysqlDatabaseListProvider
    extends AutoDisposeFutureProvider<List<DatabaseSearchItemDto>> {
  /// See also [mysqlDatabaseList].
  MysqlDatabaseListProvider(
    ({String dbName, String dbType}) key,
  ) : this._internal(
          (ref) => mysqlDatabaseList(
            ref as MysqlDatabaseListRef,
            key,
          ),
          from: mysqlDatabaseListProvider,
          name: r'mysqlDatabaseListProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$mysqlDatabaseListHash,
          dependencies: MysqlDatabaseListFamily._dependencies,
          allTransitiveDependencies:
              MysqlDatabaseListFamily._allTransitiveDependencies,
          key: key,
        );

  MysqlDatabaseListProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.key,
  }) : super.internal();

  final ({String dbName, String dbType}) key;

  @override
  Override overrideWith(
    FutureOr<List<DatabaseSearchItemDto>> Function(
            MysqlDatabaseListRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MysqlDatabaseListProvider._internal(
        (ref) => create(ref as MysqlDatabaseListRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        key: key,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<DatabaseSearchItemDto>>
      createElement() {
    return _MysqlDatabaseListProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MysqlDatabaseListProvider && other.key == key;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, key.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin MysqlDatabaseListRef
    on AutoDisposeFutureProviderRef<List<DatabaseSearchItemDto>> {
  /// The parameter `key` of this provider.
  ({String dbName, String dbType}) get key;
}

class _MysqlDatabaseListProviderElement
    extends AutoDisposeFutureProviderElement<List<DatabaseSearchItemDto>>
    with MysqlDatabaseListRef {
  _MysqlDatabaseListProviderElement(super.provider);

  @override
  ({String dbName, String dbType}) get key =>
      (origin as MysqlDatabaseListProvider).key;
}

String _$pgDatabaseListHash() => r'e955465038c1b70cc8608e2da345544b56b2b82a';

/// See also [pgDatabaseList].
@ProviderFor(pgDatabaseList)
const pgDatabaseListProvider = PgDatabaseListFamily();

/// See also [pgDatabaseList].
class PgDatabaseListFamily
    extends Family<AsyncValue<List<DatabaseSearchItemDto>>> {
  /// See also [pgDatabaseList].
  const PgDatabaseListFamily();

  /// See also [pgDatabaseList].
  PgDatabaseListProvider call(
    ({String dbName, String dbType}) key,
  ) {
    return PgDatabaseListProvider(
      key,
    );
  }

  @override
  PgDatabaseListProvider getProviderOverride(
    covariant PgDatabaseListProvider provider,
  ) {
    return call(
      provider.key,
    );
  }

  static final Iterable<ProviderOrFamily> _dependencies = <ProviderOrFamily>[
    databaseRepositoryProvider
  ];

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static final Iterable<ProviderOrFamily> _allTransitiveDependencies =
      <ProviderOrFamily>{
    databaseRepositoryProvider,
    ...?databaseRepositoryProvider.allTransitiveDependencies
  };

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'pgDatabaseListProvider';
}

/// See also [pgDatabaseList].
class PgDatabaseListProvider
    extends AutoDisposeFutureProvider<List<DatabaseSearchItemDto>> {
  /// See also [pgDatabaseList].
  PgDatabaseListProvider(
    ({String dbName, String dbType}) key,
  ) : this._internal(
          (ref) => pgDatabaseList(
            ref as PgDatabaseListRef,
            key,
          ),
          from: pgDatabaseListProvider,
          name: r'pgDatabaseListProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$pgDatabaseListHash,
          dependencies: PgDatabaseListFamily._dependencies,
          allTransitiveDependencies:
              PgDatabaseListFamily._allTransitiveDependencies,
          key: key,
        );

  PgDatabaseListProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.key,
  }) : super.internal();

  final ({String dbName, String dbType}) key;

  @override
  Override overrideWith(
    FutureOr<List<DatabaseSearchItemDto>> Function(PgDatabaseListRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: PgDatabaseListProvider._internal(
        (ref) => create(ref as PgDatabaseListRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        key: key,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<DatabaseSearchItemDto>>
      createElement() {
    return _PgDatabaseListProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PgDatabaseListProvider && other.key == key;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, key.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin PgDatabaseListRef
    on AutoDisposeFutureProviderRef<List<DatabaseSearchItemDto>> {
  /// The parameter `key` of this provider.
  ({String dbName, String dbType}) get key;
}

class _PgDatabaseListProviderElement
    extends AutoDisposeFutureProviderElement<List<DatabaseSearchItemDto>>
    with PgDatabaseListRef {
  _PgDatabaseListProviderElement(super.provider);

  @override
  ({String dbName, String dbType}) get key =>
      (origin as PgDatabaseListProvider).key;
}

String _$mysqlStatusHash() => r'b6e64104e40db9cddf4f9167d34cecb4dca1c9d7';

/// See also [mysqlStatus].
@ProviderFor(mysqlStatus)
const mysqlStatusProvider = MysqlStatusFamily();

/// See also [mysqlStatus].
class MysqlStatusFamily extends Family<AsyncValue<Map<String, String>>> {
  /// See also [mysqlStatus].
  const MysqlStatusFamily();

  /// See also [mysqlStatus].
  MysqlStatusProvider call(
    ({String dbName, String dbType}) key,
  ) {
    return MysqlStatusProvider(
      key,
    );
  }

  @override
  MysqlStatusProvider getProviderOverride(
    covariant MysqlStatusProvider provider,
  ) {
    return call(
      provider.key,
    );
  }

  static final Iterable<ProviderOrFamily> _dependencies = <ProviderOrFamily>[
    databaseRepositoryProvider
  ];

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static final Iterable<ProviderOrFamily> _allTransitiveDependencies =
      <ProviderOrFamily>{
    databaseRepositoryProvider,
    ...?databaseRepositoryProvider.allTransitiveDependencies
  };

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'mysqlStatusProvider';
}

/// See also [mysqlStatus].
class MysqlStatusProvider
    extends AutoDisposeFutureProvider<Map<String, String>> {
  /// See also [mysqlStatus].
  MysqlStatusProvider(
    ({String dbName, String dbType}) key,
  ) : this._internal(
          (ref) => mysqlStatus(
            ref as MysqlStatusRef,
            key,
          ),
          from: mysqlStatusProvider,
          name: r'mysqlStatusProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$mysqlStatusHash,
          dependencies: MysqlStatusFamily._dependencies,
          allTransitiveDependencies:
              MysqlStatusFamily._allTransitiveDependencies,
          key: key,
        );

  MysqlStatusProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.key,
  }) : super.internal();

  final ({String dbName, String dbType}) key;

  @override
  Override overrideWith(
    FutureOr<Map<String, String>> Function(MysqlStatusRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MysqlStatusProvider._internal(
        (ref) => create(ref as MysqlStatusRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        key: key,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Map<String, String>> createElement() {
    return _MysqlStatusProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MysqlStatusProvider && other.key == key;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, key.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin MysqlStatusRef on AutoDisposeFutureProviderRef<Map<String, String>> {
  /// The parameter `key` of this provider.
  ({String dbName, String dbType}) get key;
}

class _MysqlStatusProviderElement
    extends AutoDisposeFutureProviderElement<Map<String, String>>
    with MysqlStatusRef {
  _MysqlStatusProviderElement(super.provider);

  @override
  ({String dbName, String dbType}) get key =>
      (origin as MysqlStatusProvider).key;
}

String _$redisStatusHash() => r'9b8dd24795ba967b02276b16eb1b754218468603';

/// See also [redisStatus].
@ProviderFor(redisStatus)
const redisStatusProvider = RedisStatusFamily();

/// See also [redisStatus].
class RedisStatusFamily extends Family<AsyncValue<Map<String, String>>> {
  /// See also [redisStatus].
  const RedisStatusFamily();

  /// See also [redisStatus].
  RedisStatusProvider call(
    ({String dbName, String dbType}) key,
  ) {
    return RedisStatusProvider(
      key,
    );
  }

  @override
  RedisStatusProvider getProviderOverride(
    covariant RedisStatusProvider provider,
  ) {
    return call(
      provider.key,
    );
  }

  static final Iterable<ProviderOrFamily> _dependencies = <ProviderOrFamily>[
    databaseRepositoryProvider
  ];

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static final Iterable<ProviderOrFamily> _allTransitiveDependencies =
      <ProviderOrFamily>{
    databaseRepositoryProvider,
    ...?databaseRepositoryProvider.allTransitiveDependencies
  };

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'redisStatusProvider';
}

/// See also [redisStatus].
class RedisStatusProvider
    extends AutoDisposeFutureProvider<Map<String, String>> {
  /// See also [redisStatus].
  RedisStatusProvider(
    ({String dbName, String dbType}) key,
  ) : this._internal(
          (ref) => redisStatus(
            ref as RedisStatusRef,
            key,
          ),
          from: redisStatusProvider,
          name: r'redisStatusProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$redisStatusHash,
          dependencies: RedisStatusFamily._dependencies,
          allTransitiveDependencies:
              RedisStatusFamily._allTransitiveDependencies,
          key: key,
        );

  RedisStatusProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.key,
  }) : super.internal();

  final ({String dbName, String dbType}) key;

  @override
  Override overrideWith(
    FutureOr<Map<String, String>> Function(RedisStatusRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: RedisStatusProvider._internal(
        (ref) => create(ref as RedisStatusRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        key: key,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Map<String, String>> createElement() {
    return _RedisStatusProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is RedisStatusProvider && other.key == key;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, key.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin RedisStatusRef on AutoDisposeFutureProviderRef<Map<String, String>> {
  /// The parameter `key` of this provider.
  ({String dbName, String dbType}) get key;
}

class _RedisStatusProviderElement
    extends AutoDisposeFutureProviderElement<Map<String, String>>
    with RedisStatusRef {
  _RedisStatusProviderElement(super.provider);

  @override
  ({String dbName, String dbType}) get key =>
      (origin as RedisStatusProvider).key;
}

String _$redisConfHash() => r'6527221c28816c392634f59b211e623e4181101a';

/// See also [redisConf].
@ProviderFor(redisConf)
const redisConfProvider = RedisConfFamily();

/// See also [redisConf].
class RedisConfFamily extends Family<AsyncValue<RedisConfDto>> {
  /// See also [redisConf].
  const RedisConfFamily();

  /// See also [redisConf].
  RedisConfProvider call(
    ({String dbName, String dbType}) key,
  ) {
    return RedisConfProvider(
      key,
    );
  }

  @override
  RedisConfProvider getProviderOverride(
    covariant RedisConfProvider provider,
  ) {
    return call(
      provider.key,
    );
  }

  static final Iterable<ProviderOrFamily> _dependencies = <ProviderOrFamily>[
    databaseRepositoryProvider
  ];

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static final Iterable<ProviderOrFamily> _allTransitiveDependencies =
      <ProviderOrFamily>{
    databaseRepositoryProvider,
    ...?databaseRepositoryProvider.allTransitiveDependencies
  };

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'redisConfProvider';
}

/// See also [redisConf].
class RedisConfProvider extends AutoDisposeFutureProvider<RedisConfDto> {
  /// See also [redisConf].
  RedisConfProvider(
    ({String dbName, String dbType}) key,
  ) : this._internal(
          (ref) => redisConf(
            ref as RedisConfRef,
            key,
          ),
          from: redisConfProvider,
          name: r'redisConfProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$redisConfHash,
          dependencies: RedisConfFamily._dependencies,
          allTransitiveDependencies: RedisConfFamily._allTransitiveDependencies,
          key: key,
        );

  RedisConfProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.key,
  }) : super.internal();

  final ({String dbName, String dbType}) key;

  @override
  Override overrideWith(
    FutureOr<RedisConfDto> Function(RedisConfRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: RedisConfProvider._internal(
        (ref) => create(ref as RedisConfRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        key: key,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<RedisConfDto> createElement() {
    return _RedisConfProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is RedisConfProvider && other.key == key;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, key.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin RedisConfRef on AutoDisposeFutureProviderRef<RedisConfDto> {
  /// The parameter `key` of this provider.
  ({String dbName, String dbType}) get key;
}

class _RedisConfProviderElement
    extends AutoDisposeFutureProviderElement<RedisConfDto> with RedisConfRef {
  _RedisConfProviderElement(super.provider);

  @override
  ({String dbName, String dbType}) get key => (origin as RedisConfProvider).key;
}

String _$redisPersistenceHash() => r'50f271952b445a77d4cbfe276485f1be51d44f95';

/// See also [redisPersistence].
@ProviderFor(redisPersistence)
const redisPersistenceProvider = RedisPersistenceFamily();

/// See also [redisPersistence].
class RedisPersistenceFamily extends Family<AsyncValue<RedisPersistenceDto>> {
  /// See also [redisPersistence].
  const RedisPersistenceFamily();

  /// See also [redisPersistence].
  RedisPersistenceProvider call(
    ({String dbName, String dbType}) key,
  ) {
    return RedisPersistenceProvider(
      key,
    );
  }

  @override
  RedisPersistenceProvider getProviderOverride(
    covariant RedisPersistenceProvider provider,
  ) {
    return call(
      provider.key,
    );
  }

  static final Iterable<ProviderOrFamily> _dependencies = <ProviderOrFamily>[
    databaseRepositoryProvider
  ];

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static final Iterable<ProviderOrFamily> _allTransitiveDependencies =
      <ProviderOrFamily>{
    databaseRepositoryProvider,
    ...?databaseRepositoryProvider.allTransitiveDependencies
  };

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'redisPersistenceProvider';
}

/// See also [redisPersistence].
class RedisPersistenceProvider
    extends AutoDisposeFutureProvider<RedisPersistenceDto> {
  /// See also [redisPersistence].
  RedisPersistenceProvider(
    ({String dbName, String dbType}) key,
  ) : this._internal(
          (ref) => redisPersistence(
            ref as RedisPersistenceRef,
            key,
          ),
          from: redisPersistenceProvider,
          name: r'redisPersistenceProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$redisPersistenceHash,
          dependencies: RedisPersistenceFamily._dependencies,
          allTransitiveDependencies:
              RedisPersistenceFamily._allTransitiveDependencies,
          key: key,
        );

  RedisPersistenceProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.key,
  }) : super.internal();

  final ({String dbName, String dbType}) key;

  @override
  Override overrideWith(
    FutureOr<RedisPersistenceDto> Function(RedisPersistenceRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: RedisPersistenceProvider._internal(
        (ref) => create(ref as RedisPersistenceRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        key: key,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<RedisPersistenceDto> createElement() {
    return _RedisPersistenceProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is RedisPersistenceProvider && other.key == key;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, key.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin RedisPersistenceRef on AutoDisposeFutureProviderRef<RedisPersistenceDto> {
  /// The parameter `key` of this provider.
  ({String dbName, String dbType}) get key;
}

class _RedisPersistenceProviderElement
    extends AutoDisposeFutureProviderElement<RedisPersistenceDto>
    with RedisPersistenceRef {
  _RedisPersistenceProviderElement(super.provider);

  @override
  ({String dbName, String dbType}) get key =>
      (origin as RedisPersistenceProvider).key;
}

String _$databaseControllerHash() =>
    r'0117634fef96a208ea7fafdac75feb30943f59ab';

/// 数据库实例列表控制器。
///
/// Copied from [DatabaseController].
@ProviderFor(DatabaseController)
final databaseControllerProvider = AutoDisposeAsyncNotifierProvider<
    DatabaseController, DatabaseState>.internal(
  DatabaseController.new,
  name: r'databaseControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$databaseControllerHash,
  dependencies: <ProviderOrFamily>[
    databaseRepositoryProvider,
    activeServerIdProvider
  ],
  allTransitiveDependencies: <ProviderOrFamily>{
    databaseRepositoryProvider,
    ...?databaseRepositoryProvider.allTransitiveDependencies,
    activeServerIdProvider,
    ...?activeServerIdProvider.allTransitiveDependencies
  },
);

typedef _$DatabaseController = AutoDisposeAsyncNotifier<DatabaseState>;
String _$databaseManagementControllerHash() =>
    r'66085c269e7338fd95e413f95acc0826846821cd';

abstract class _$DatabaseManagementController
    extends BuildlessAutoDisposeAsyncNotifier<DatabaseManagementState> {
  late final String dbType;
  late final String dbName;

  FutureOr<DatabaseManagementState> build(
    String dbType,
    String dbName,
  );
}

/// MySQL 管理页面控制器。
///
/// [dbType] 为数据库类型 key（如 mysql、postgresql），
/// [dbName] 为数据库实例名称（如 mysql-2）。
///
/// Copied from [DatabaseManagementController].
@ProviderFor(DatabaseManagementController)
const databaseManagementControllerProvider =
    DatabaseManagementControllerFamily();

/// MySQL 管理页面控制器。
///
/// [dbType] 为数据库类型 key（如 mysql、postgresql），
/// [dbName] 为数据库实例名称（如 mysql-2）。
///
/// Copied from [DatabaseManagementController].
class DatabaseManagementControllerFamily
    extends Family<AsyncValue<DatabaseManagementState>> {
  /// MySQL 管理页面控制器。
  ///
  /// [dbType] 为数据库类型 key（如 mysql、postgresql），
  /// [dbName] 为数据库实例名称（如 mysql-2）。
  ///
  /// Copied from [DatabaseManagementController].
  const DatabaseManagementControllerFamily();

  /// MySQL 管理页面控制器。
  ///
  /// [dbType] 为数据库类型 key（如 mysql、postgresql），
  /// [dbName] 为数据库实例名称（如 mysql-2）。
  ///
  /// Copied from [DatabaseManagementController].
  DatabaseManagementControllerProvider call(
    String dbType,
    String dbName,
  ) {
    return DatabaseManagementControllerProvider(
      dbType,
      dbName,
    );
  }

  @override
  DatabaseManagementControllerProvider getProviderOverride(
    covariant DatabaseManagementControllerProvider provider,
  ) {
    return call(
      provider.dbType,
      provider.dbName,
    );
  }

  static final Iterable<ProviderOrFamily> _dependencies = <ProviderOrFamily>[
    databaseRepositoryProvider
  ];

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static final Iterable<ProviderOrFamily> _allTransitiveDependencies =
      <ProviderOrFamily>{
    databaseRepositoryProvider,
    ...?databaseRepositoryProvider.allTransitiveDependencies
  };

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'databaseManagementControllerProvider';
}

/// MySQL 管理页面控制器。
///
/// [dbType] 为数据库类型 key（如 mysql、postgresql），
/// [dbName] 为数据库实例名称（如 mysql-2）。
///
/// Copied from [DatabaseManagementController].
class DatabaseManagementControllerProvider
    extends AutoDisposeAsyncNotifierProviderImpl<DatabaseManagementController,
        DatabaseManagementState> {
  /// MySQL 管理页面控制器。
  ///
  /// [dbType] 为数据库类型 key（如 mysql、postgresql），
  /// [dbName] 为数据库实例名称（如 mysql-2）。
  ///
  /// Copied from [DatabaseManagementController].
  DatabaseManagementControllerProvider(
    String dbType,
    String dbName,
  ) : this._internal(
          () => DatabaseManagementController()
            ..dbType = dbType
            ..dbName = dbName,
          from: databaseManagementControllerProvider,
          name: r'databaseManagementControllerProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$databaseManagementControllerHash,
          dependencies: DatabaseManagementControllerFamily._dependencies,
          allTransitiveDependencies:
              DatabaseManagementControllerFamily._allTransitiveDependencies,
          dbType: dbType,
          dbName: dbName,
        );

  DatabaseManagementControllerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.dbType,
    required this.dbName,
  }) : super.internal();

  final String dbType;
  final String dbName;

  @override
  FutureOr<DatabaseManagementState> runNotifierBuild(
    covariant DatabaseManagementController notifier,
  ) {
    return notifier.build(
      dbType,
      dbName,
    );
  }

  @override
  Override overrideWith(DatabaseManagementController Function() create) {
    return ProviderOverride(
      origin: this,
      override: DatabaseManagementControllerProvider._internal(
        () => create()
          ..dbType = dbType
          ..dbName = dbName,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        dbType: dbType,
        dbName: dbName,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<DatabaseManagementController,
      DatabaseManagementState> createElement() {
    return _DatabaseManagementControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DatabaseManagementControllerProvider &&
        other.dbType == dbType &&
        other.dbName == dbName;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, dbType.hashCode);
    hash = _SystemHash.combine(hash, dbName.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin DatabaseManagementControllerRef
    on AutoDisposeAsyncNotifierProviderRef<DatabaseManagementState> {
  /// The parameter `dbType` of this provider.
  String get dbType;

  /// The parameter `dbName` of this provider.
  String get dbName;
}

class _DatabaseManagementControllerProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<
        DatabaseManagementController,
        DatabaseManagementState> with DatabaseManagementControllerRef {
  _DatabaseManagementControllerProviderElement(super.provider);

  @override
  String get dbType => (origin as DatabaseManagementControllerProvider).dbType;
  @override
  String get dbName => (origin as DatabaseManagementControllerProvider).dbName;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
