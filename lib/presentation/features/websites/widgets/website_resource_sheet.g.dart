// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'website_resource_sheet.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$websiteResourcesHash() => r'c10ad97b700f18b63ca26160aeb1c1faf687a7e7';

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

/// 网站资源列表 Provider
///
/// Copied from [_websiteResources].
@ProviderFor(_websiteResources)
const _websiteResourcesProvider = _WebsiteResourcesFamily();

/// 网站资源列表 Provider
///
/// Copied from [_websiteResources].
class _WebsiteResourcesFamily
    extends Family<AsyncValue<List<WebsiteResourceDto>>> {
  /// 网站资源列表 Provider
  ///
  /// Copied from [_websiteResources].
  const _WebsiteResourcesFamily();

  /// 网站资源列表 Provider
  ///
  /// Copied from [_websiteResources].
  _WebsiteResourcesProvider call(
    int websiteId,
  ) {
    return _WebsiteResourcesProvider(
      websiteId,
    );
  }

  @override
  _WebsiteResourcesProvider getProviderOverride(
    covariant _WebsiteResourcesProvider provider,
  ) {
    return call(
      provider.websiteId,
    );
  }

  static final Iterable<ProviderOrFamily> _dependencies = <ProviderOrFamily>[
    websiteRepositoryProvider
  ];

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static final Iterable<ProviderOrFamily> _allTransitiveDependencies =
      <ProviderOrFamily>{
    websiteRepositoryProvider,
    ...?websiteRepositoryProvider.allTransitiveDependencies
  };

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'_websiteResourcesProvider';
}

/// 网站资源列表 Provider
///
/// Copied from [_websiteResources].
class _WebsiteResourcesProvider
    extends AutoDisposeFutureProvider<List<WebsiteResourceDto>> {
  /// 网站资源列表 Provider
  ///
  /// Copied from [_websiteResources].
  _WebsiteResourcesProvider(
    int websiteId,
  ) : this._internal(
          (ref) => _websiteResources(
            ref as _WebsiteResourcesRef,
            websiteId,
          ),
          from: _websiteResourcesProvider,
          name: r'_websiteResourcesProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$websiteResourcesHash,
          dependencies: _WebsiteResourcesFamily._dependencies,
          allTransitiveDependencies:
              _WebsiteResourcesFamily._allTransitiveDependencies,
          websiteId: websiteId,
        );

  _WebsiteResourcesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.websiteId,
  }) : super.internal();

  final int websiteId;

  @override
  Override overrideWith(
    FutureOr<List<WebsiteResourceDto>> Function(_WebsiteResourcesRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: _WebsiteResourcesProvider._internal(
        (ref) => create(ref as _WebsiteResourcesRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        websiteId: websiteId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<WebsiteResourceDto>> createElement() {
    return _WebsiteResourcesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is _WebsiteResourcesProvider && other.websiteId == websiteId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, websiteId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin _WebsiteResourcesRef
    on AutoDisposeFutureProviderRef<List<WebsiteResourceDto>> {
  /// The parameter `websiteId` of this provider.
  int get websiteId;
}

class _WebsiteResourcesProviderElement
    extends AutoDisposeFutureProviderElement<List<WebsiteResourceDto>>
    with _WebsiteResourcesRef {
  _WebsiteResourcesProviderElement(super.provider);

  @override
  int get websiteId => (origin as _WebsiteResourcesProvider).websiteId;
}

String _$websiteDatabasesHash() => r'14e6120dbe21c79268d677859786c026d1c2afe8';

/// 可关联数据库列表 Provider
///
/// Copied from [_websiteDatabases].
@ProviderFor(_websiteDatabases)
final _websiteDatabasesProvider =
    AutoDisposeFutureProvider<List<WebsiteDatabaseDto>>.internal(
  _websiteDatabases,
  name: r'_websiteDatabasesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$websiteDatabasesHash,
  dependencies: <ProviderOrFamily>[websiteRepositoryProvider],
  allTransitiveDependencies: <ProviderOrFamily>{
    websiteRepositoryProvider,
    ...?websiteRepositoryProvider.allTransitiveDependencies
  },
);

typedef _WebsiteDatabasesRef
    = AutoDisposeFutureProviderRef<List<WebsiteDatabaseDto>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
