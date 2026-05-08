// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'website_limit_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$websiteLimitControllerHash() =>
    r'95f98cac98536b8d21b89bf3828a900dbc3a773a';

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

abstract class _$WebsiteLimitController
    extends BuildlessAutoDisposeAsyncNotifier<WebsiteLimitConfigDto> {
  late final int websiteId;

  FutureOr<WebsiteLimitConfigDto> build(
    int websiteId,
  );
}

/// See also [WebsiteLimitController].
@ProviderFor(WebsiteLimitController)
const websiteLimitControllerProvider = WebsiteLimitControllerFamily();

/// See also [WebsiteLimitController].
class WebsiteLimitControllerFamily
    extends Family<AsyncValue<WebsiteLimitConfigDto>> {
  /// See also [WebsiteLimitController].
  const WebsiteLimitControllerFamily();

  /// See also [WebsiteLimitController].
  WebsiteLimitControllerProvider call(
    int websiteId,
  ) {
    return WebsiteLimitControllerProvider(
      websiteId,
    );
  }

  @override
  WebsiteLimitControllerProvider getProviderOverride(
    covariant WebsiteLimitControllerProvider provider,
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
  String? get name => r'websiteLimitControllerProvider';
}

/// See also [WebsiteLimitController].
class WebsiteLimitControllerProvider
    extends AutoDisposeAsyncNotifierProviderImpl<WebsiteLimitController,
        WebsiteLimitConfigDto> {
  /// See also [WebsiteLimitController].
  WebsiteLimitControllerProvider(
    int websiteId,
  ) : this._internal(
          () => WebsiteLimitController()..websiteId = websiteId,
          from: websiteLimitControllerProvider,
          name: r'websiteLimitControllerProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$websiteLimitControllerHash,
          dependencies: WebsiteLimitControllerFamily._dependencies,
          allTransitiveDependencies:
              WebsiteLimitControllerFamily._allTransitiveDependencies,
          websiteId: websiteId,
        );

  WebsiteLimitControllerProvider._internal(
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
  FutureOr<WebsiteLimitConfigDto> runNotifierBuild(
    covariant WebsiteLimitController notifier,
  ) {
    return notifier.build(
      websiteId,
    );
  }

  @override
  Override overrideWith(WebsiteLimitController Function() create) {
    return ProviderOverride(
      origin: this,
      override: WebsiteLimitControllerProvider._internal(
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
  AutoDisposeAsyncNotifierProviderElement<WebsiteLimitController,
      WebsiteLimitConfigDto> createElement() {
    return _WebsiteLimitControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is WebsiteLimitControllerProvider &&
        other.websiteId == websiteId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, websiteId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin WebsiteLimitControllerRef
    on AutoDisposeAsyncNotifierProviderRef<WebsiteLimitConfigDto> {
  /// The parameter `websiteId` of this provider.
  int get websiteId;
}

class _WebsiteLimitControllerProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<WebsiteLimitController,
        WebsiteLimitConfigDto> with WebsiteLimitControllerRef {
  _WebsiteLimitControllerProviderElement(super.provider);

  @override
  int get websiteId => (origin as WebsiteLimitControllerProvider).websiteId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
