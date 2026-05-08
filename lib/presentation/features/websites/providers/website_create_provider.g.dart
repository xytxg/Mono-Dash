// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'website_create_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$websiteCreateMetadataHash() =>
    r'fb6e335605bf32dca6a3e9e36a9e74c40433b0e5';

/// See also [websiteCreateMetadata].
@ProviderFor(websiteCreateMetadata)
final websiteCreateMetadataProvider =
    AutoDisposeFutureProvider<WebsiteCreateMetadata>.internal(
  websiteCreateMetadata,
  name: r'websiteCreateMetadataProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$websiteCreateMetadataHash,
  dependencies: <ProviderOrFamily>[websiteRepositoryProvider],
  allTransitiveDependencies: <ProviderOrFamily>{
    websiteRepositoryProvider,
    ...?websiteRepositoryProvider.allTransitiveDependencies
  },
);

typedef WebsiteCreateMetadataRef
    = AutoDisposeFutureProviderRef<WebsiteCreateMetadata>;
String _$websiteAcmeAccountsHash() =>
    r'b55d0b0550448b50c6412fc1dae18b43c3f5e690';

/// See also [websiteAcmeAccounts].
@ProviderFor(websiteAcmeAccounts)
final websiteAcmeAccountsProvider =
    AutoDisposeFutureProvider<List<WebsiteAcmeAccountDto>>.internal(
  websiteAcmeAccounts,
  name: r'websiteAcmeAccountsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$websiteAcmeAccountsHash,
  dependencies: <ProviderOrFamily>[websiteRepositoryProvider],
  allTransitiveDependencies: <ProviderOrFamily>{
    websiteRepositoryProvider,
    ...?websiteRepositoryProvider.allTransitiveDependencies
  },
);

typedef WebsiteAcmeAccountsRef
    = AutoDisposeFutureProviderRef<List<WebsiteAcmeAccountDto>>;
String _$websiteSslListHash() => r'490dd0b9ea2c95e08dead5f7734fff1b57b330b3';

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

/// See also [websiteSslList].
@ProviderFor(websiteSslList)
const websiteSslListProvider = WebsiteSslListFamily();

/// See also [websiteSslList].
class WebsiteSslListFamily extends Family<AsyncValue<List<WebsiteSslDto>>> {
  /// See also [websiteSslList].
  const WebsiteSslListFamily();

  /// See also [websiteSslList].
  WebsiteSslListProvider call(
    int acmeAccountId,
  ) {
    return WebsiteSslListProvider(
      acmeAccountId,
    );
  }

  @override
  WebsiteSslListProvider getProviderOverride(
    covariant WebsiteSslListProvider provider,
  ) {
    return call(
      provider.acmeAccountId,
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
  String? get name => r'websiteSslListProvider';
}

/// See also [websiteSslList].
class WebsiteSslListProvider
    extends AutoDisposeFutureProvider<List<WebsiteSslDto>> {
  /// See also [websiteSslList].
  WebsiteSslListProvider(
    int acmeAccountId,
  ) : this._internal(
          (ref) => websiteSslList(
            ref as WebsiteSslListRef,
            acmeAccountId,
          ),
          from: websiteSslListProvider,
          name: r'websiteSslListProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$websiteSslListHash,
          dependencies: WebsiteSslListFamily._dependencies,
          allTransitiveDependencies:
              WebsiteSslListFamily._allTransitiveDependencies,
          acmeAccountId: acmeAccountId,
        );

  WebsiteSslListProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.acmeAccountId,
  }) : super.internal();

  final int acmeAccountId;

  @override
  Override overrideWith(
    FutureOr<List<WebsiteSslDto>> Function(WebsiteSslListRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: WebsiteSslListProvider._internal(
        (ref) => create(ref as WebsiteSslListRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        acmeAccountId: acmeAccountId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<WebsiteSslDto>> createElement() {
    return _WebsiteSslListProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is WebsiteSslListProvider &&
        other.acmeAccountId == acmeAccountId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, acmeAccountId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin WebsiteSslListRef on AutoDisposeFutureProviderRef<List<WebsiteSslDto>> {
  /// The parameter `acmeAccountId` of this provider.
  int get acmeAccountId;
}

class _WebsiteSslListProviderElement
    extends AutoDisposeFutureProviderElement<List<WebsiteSslDto>>
    with WebsiteSslListRef {
  _WebsiteSslListProviderElement(super.provider);

  @override
  int get acmeAccountId => (origin as WebsiteSslListProvider).acmeAccountId;
}

String _$websiteRuntimesHash() => r'886dcc7c38ffd16a2531e06860144f4e752a70be';

/// See also [websiteRuntimes].
@ProviderFor(websiteRuntimes)
const websiteRuntimesProvider = WebsiteRuntimesFamily();

/// See also [websiteRuntimes].
class WebsiteRuntimesFamily extends Family<AsyncValue<List<RuntimeDto>>> {
  /// See also [websiteRuntimes].
  const WebsiteRuntimesFamily();

  /// See also [websiteRuntimes].
  WebsiteRuntimesProvider call(
    String type,
  ) {
    return WebsiteRuntimesProvider(
      type,
    );
  }

  @override
  WebsiteRuntimesProvider getProviderOverride(
    covariant WebsiteRuntimesProvider provider,
  ) {
    return call(
      provider.type,
    );
  }

  static final Iterable<ProviderOrFamily> _dependencies = <ProviderOrFamily>[
    runtimeRepositoryProvider
  ];

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static final Iterable<ProviderOrFamily> _allTransitiveDependencies =
      <ProviderOrFamily>{
    runtimeRepositoryProvider,
    ...?runtimeRepositoryProvider.allTransitiveDependencies
  };

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'websiteRuntimesProvider';
}

/// See also [websiteRuntimes].
class WebsiteRuntimesProvider
    extends AutoDisposeFutureProvider<List<RuntimeDto>> {
  /// See also [websiteRuntimes].
  WebsiteRuntimesProvider(
    String type,
  ) : this._internal(
          (ref) => websiteRuntimes(
            ref as WebsiteRuntimesRef,
            type,
          ),
          from: websiteRuntimesProvider,
          name: r'websiteRuntimesProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$websiteRuntimesHash,
          dependencies: WebsiteRuntimesFamily._dependencies,
          allTransitiveDependencies:
              WebsiteRuntimesFamily._allTransitiveDependencies,
          type: type,
        );

  WebsiteRuntimesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.type,
  }) : super.internal();

  final String type;

  @override
  Override overrideWith(
    FutureOr<List<RuntimeDto>> Function(WebsiteRuntimesRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: WebsiteRuntimesProvider._internal(
        (ref) => create(ref as WebsiteRuntimesRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        type: type,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<RuntimeDto>> createElement() {
    return _WebsiteRuntimesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is WebsiteRuntimesProvider && other.type == type;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, type.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin WebsiteRuntimesRef on AutoDisposeFutureProviderRef<List<RuntimeDto>> {
  /// The parameter `type` of this provider.
  String get type;
}

class _WebsiteRuntimesProviderElement
    extends AutoDisposeFutureProviderElement<List<RuntimeDto>>
    with WebsiteRuntimesRef {
  _WebsiteRuntimesProviderElement(super.provider);

  @override
  String get type => (origin as WebsiteRuntimesProvider).type;
}

String _$websiteDbInstancesHash() =>
    r'1803ac9fa5e758b294eaaf1b8befd689c0e57e31';

/// See also [websiteDbInstances].
@ProviderFor(websiteDbInstances)
const websiteDbInstancesProvider = WebsiteDbInstancesFamily();

/// See also [websiteDbInstances].
class WebsiteDbInstancesFamily extends Family<AsyncValue<List<AppServiceDto>>> {
  /// See also [websiteDbInstances].
  const WebsiteDbInstancesFamily();

  /// See also [websiteDbInstances].
  WebsiteDbInstancesProvider call(
    String key,
  ) {
    return WebsiteDbInstancesProvider(
      key,
    );
  }

  @override
  WebsiteDbInstancesProvider getProviderOverride(
    covariant WebsiteDbInstancesProvider provider,
  ) {
    return call(
      provider.key,
    );
  }

  static final Iterable<ProviderOrFamily> _dependencies = <ProviderOrFamily>[
    activeServerIdProvider
  ];

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static final Iterable<ProviderOrFamily> _allTransitiveDependencies =
      <ProviderOrFamily>{
    activeServerIdProvider,
    ...?activeServerIdProvider.allTransitiveDependencies
  };

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'websiteDbInstancesProvider';
}

/// See also [websiteDbInstances].
class WebsiteDbInstancesProvider
    extends AutoDisposeFutureProvider<List<AppServiceDto>> {
  /// See also [websiteDbInstances].
  WebsiteDbInstancesProvider(
    String key,
  ) : this._internal(
          (ref) => websiteDbInstances(
            ref as WebsiteDbInstancesRef,
            key,
          ),
          from: websiteDbInstancesProvider,
          name: r'websiteDbInstancesProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$websiteDbInstancesHash,
          dependencies: WebsiteDbInstancesFamily._dependencies,
          allTransitiveDependencies:
              WebsiteDbInstancesFamily._allTransitiveDependencies,
          key: key,
        );

  WebsiteDbInstancesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.key,
  }) : super.internal();

  final String key;

  @override
  Override overrideWith(
    FutureOr<List<AppServiceDto>> Function(WebsiteDbInstancesRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: WebsiteDbInstancesProvider._internal(
        (ref) => create(ref as WebsiteDbInstancesRef),
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
  AutoDisposeFutureProviderElement<List<AppServiceDto>> createElement() {
    return _WebsiteDbInstancesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is WebsiteDbInstancesProvider && other.key == key;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, key.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin WebsiteDbInstancesRef
    on AutoDisposeFutureProviderRef<List<AppServiceDto>> {
  /// The parameter `key` of this provider.
  String get key;
}

class _WebsiteDbInstancesProviderElement
    extends AutoDisposeFutureProviderElement<List<AppServiceDto>>
    with WebsiteDbInstancesRef {
  _WebsiteDbInstancesProviderElement(super.provider);

  @override
  String get key => (origin as WebsiteDbInstancesProvider).key;
}

String _$websiteCreateControllerHash() =>
    r'34f2ccdf21b3459523c6d6b2777a1990bb4506da';

/// See also [WebsiteCreateController].
@ProviderFor(WebsiteCreateController)
final websiteCreateControllerProvider = AutoDisposeNotifierProvider<
    WebsiteCreateController, AsyncValue<void>>.internal(
  WebsiteCreateController.new,
  name: r'websiteCreateControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$websiteCreateControllerHash,
  dependencies: <ProviderOrFamily>[
    websiteRepositoryProvider,
    websitesControllerProvider
  ],
  allTransitiveDependencies: <ProviderOrFamily>{
    websiteRepositoryProvider,
    ...?websiteRepositoryProvider.allTransitiveDependencies,
    websitesControllerProvider,
    ...?websitesControllerProvider.allTransitiveDependencies
  },
);

typedef _$WebsiteCreateController = AutoDisposeNotifier<AsyncValue<void>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
