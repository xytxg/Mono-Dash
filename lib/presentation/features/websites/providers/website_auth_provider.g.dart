// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'website_auth_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$websiteAuthControllerHash() =>
    r'ab1e4fa1305b7d7a60f4718082cf9d99ac91013f';

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

abstract class _$WebsiteAuthController
    extends BuildlessAutoDisposeAsyncNotifier<WebsiteAuthDto> {
  late final int websiteId;

  FutureOr<WebsiteAuthDto> build(
    int websiteId,
  );
}

/// See also [WebsiteAuthController].
@ProviderFor(WebsiteAuthController)
const websiteAuthControllerProvider = WebsiteAuthControllerFamily();

/// See also [WebsiteAuthController].
class WebsiteAuthControllerFamily extends Family<AsyncValue<WebsiteAuthDto>> {
  /// See also [WebsiteAuthController].
  const WebsiteAuthControllerFamily();

  /// See also [WebsiteAuthController].
  WebsiteAuthControllerProvider call(
    int websiteId,
  ) {
    return WebsiteAuthControllerProvider(
      websiteId,
    );
  }

  @override
  WebsiteAuthControllerProvider getProviderOverride(
    covariant WebsiteAuthControllerProvider provider,
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
  String? get name => r'websiteAuthControllerProvider';
}

/// See also [WebsiteAuthController].
class WebsiteAuthControllerProvider
    extends AutoDisposeAsyncNotifierProviderImpl<WebsiteAuthController,
        WebsiteAuthDto> {
  /// See also [WebsiteAuthController].
  WebsiteAuthControllerProvider(
    int websiteId,
  ) : this._internal(
          () => WebsiteAuthController()..websiteId = websiteId,
          from: websiteAuthControllerProvider,
          name: r'websiteAuthControllerProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$websiteAuthControllerHash,
          dependencies: WebsiteAuthControllerFamily._dependencies,
          allTransitiveDependencies:
              WebsiteAuthControllerFamily._allTransitiveDependencies,
          websiteId: websiteId,
        );

  WebsiteAuthControllerProvider._internal(
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
  FutureOr<WebsiteAuthDto> runNotifierBuild(
    covariant WebsiteAuthController notifier,
  ) {
    return notifier.build(
      websiteId,
    );
  }

  @override
  Override overrideWith(WebsiteAuthController Function() create) {
    return ProviderOverride(
      origin: this,
      override: WebsiteAuthControllerProvider._internal(
        () => create()..websiteId = websiteId,
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
  AutoDisposeAsyncNotifierProviderElement<WebsiteAuthController, WebsiteAuthDto>
      createElement() {
    return _WebsiteAuthControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is WebsiteAuthControllerProvider &&
        other.websiteId == websiteId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, websiteId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin WebsiteAuthControllerRef
    on AutoDisposeAsyncNotifierProviderRef<WebsiteAuthDto> {
  /// The parameter `websiteId` of this provider.
  int get websiteId;
}

class _WebsiteAuthControllerProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<WebsiteAuthController,
        WebsiteAuthDto> with WebsiteAuthControllerRef {
  _WebsiteAuthControllerProviderElement(super.provider);

  @override
  int get websiteId => (origin as WebsiteAuthControllerProvider).websiteId;
}

String _$websitePathAuthControllerHash() =>
    r'e9b2495d80aa834ae21be5df3a0a47643d41c013';

abstract class _$WebsitePathAuthController
    extends BuildlessAutoDisposeAsyncNotifier<List<WebsitePathAuthItemDto>> {
  late final int websiteId;

  FutureOr<List<WebsitePathAuthItemDto>> build(
    int websiteId,
  );
}

/// See also [WebsitePathAuthController].
@ProviderFor(WebsitePathAuthController)
const websitePathAuthControllerProvider = WebsitePathAuthControllerFamily();

/// See also [WebsitePathAuthController].
class WebsitePathAuthControllerFamily
    extends Family<AsyncValue<List<WebsitePathAuthItemDto>>> {
  /// See also [WebsitePathAuthController].
  const WebsitePathAuthControllerFamily();

  /// See also [WebsitePathAuthController].
  WebsitePathAuthControllerProvider call(
    int websiteId,
  ) {
    return WebsitePathAuthControllerProvider(
      websiteId,
    );
  }

  @override
  WebsitePathAuthControllerProvider getProviderOverride(
    covariant WebsitePathAuthControllerProvider provider,
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
  String? get name => r'websitePathAuthControllerProvider';
}

/// See also [WebsitePathAuthController].
class WebsitePathAuthControllerProvider
    extends AutoDisposeAsyncNotifierProviderImpl<WebsitePathAuthController,
        List<WebsitePathAuthItemDto>> {
  /// See also [WebsitePathAuthController].
  WebsitePathAuthControllerProvider(
    int websiteId,
  ) : this._internal(
          () => WebsitePathAuthController()..websiteId = websiteId,
          from: websitePathAuthControllerProvider,
          name: r'websitePathAuthControllerProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$websitePathAuthControllerHash,
          dependencies: WebsitePathAuthControllerFamily._dependencies,
          allTransitiveDependencies:
              WebsitePathAuthControllerFamily._allTransitiveDependencies,
          websiteId: websiteId,
        );

  WebsitePathAuthControllerProvider._internal(
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
  FutureOr<List<WebsitePathAuthItemDto>> runNotifierBuild(
    covariant WebsitePathAuthController notifier,
  ) {
    return notifier.build(
      websiteId,
    );
  }

  @override
  Override overrideWith(WebsitePathAuthController Function() create) {
    return ProviderOverride(
      origin: this,
      override: WebsitePathAuthControllerProvider._internal(
        () => create()..websiteId = websiteId,
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
  AutoDisposeAsyncNotifierProviderElement<WebsitePathAuthController,
      List<WebsitePathAuthItemDto>> createElement() {
    return _WebsitePathAuthControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is WebsitePathAuthControllerProvider &&
        other.websiteId == websiteId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, websiteId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin WebsitePathAuthControllerRef
    on AutoDisposeAsyncNotifierProviderRef<List<WebsitePathAuthItemDto>> {
  /// The parameter `websiteId` of this provider.
  int get websiteId;
}

class _WebsitePathAuthControllerProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<WebsitePathAuthController,
        List<WebsitePathAuthItemDto>> with WebsitePathAuthControllerRef {
  _WebsitePathAuthControllerProviderElement(super.provider);

  @override
  int get websiteId => (origin as WebsitePathAuthControllerProvider).websiteId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
