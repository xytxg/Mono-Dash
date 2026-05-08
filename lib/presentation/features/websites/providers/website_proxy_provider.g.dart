// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'website_proxy_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$websiteProxyControllerHash() =>
    r'a2a5fcc3ab385ed4c1e71a9a3db6d19dae7c1913';

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

abstract class _$WebsiteProxyController
    extends BuildlessAutoDisposeAsyncNotifier<List<WebsiteProxyDto>> {
  late final int websiteId;

  FutureOr<List<WebsiteProxyDto>> build(
    int websiteId,
  );
}

/// See also [WebsiteProxyController].
@ProviderFor(WebsiteProxyController)
const websiteProxyControllerProvider = WebsiteProxyControllerFamily();

/// See also [WebsiteProxyController].
class WebsiteProxyControllerFamily
    extends Family<AsyncValue<List<WebsiteProxyDto>>> {
  /// See also [WebsiteProxyController].
  const WebsiteProxyControllerFamily();

  /// See also [WebsiteProxyController].
  WebsiteProxyControllerProvider call(
    int websiteId,
  ) {
    return WebsiteProxyControllerProvider(
      websiteId,
    );
  }

  @override
  WebsiteProxyControllerProvider getProviderOverride(
    covariant WebsiteProxyControllerProvider provider,
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
  String? get name => r'websiteProxyControllerProvider';
}

/// See also [WebsiteProxyController].
class WebsiteProxyControllerProvider
    extends AutoDisposeAsyncNotifierProviderImpl<WebsiteProxyController,
        List<WebsiteProxyDto>> {
  /// See also [WebsiteProxyController].
  WebsiteProxyControllerProvider(
    int websiteId,
  ) : this._internal(
          () => WebsiteProxyController()..websiteId = websiteId,
          from: websiteProxyControllerProvider,
          name: r'websiteProxyControllerProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$websiteProxyControllerHash,
          dependencies: WebsiteProxyControllerFamily._dependencies,
          allTransitiveDependencies:
              WebsiteProxyControllerFamily._allTransitiveDependencies,
          websiteId: websiteId,
        );

  WebsiteProxyControllerProvider._internal(
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
  FutureOr<List<WebsiteProxyDto>> runNotifierBuild(
    covariant WebsiteProxyController notifier,
  ) {
    return notifier.build(
      websiteId,
    );
  }

  @override
  Override overrideWith(WebsiteProxyController Function() create) {
    return ProviderOverride(
      origin: this,
      override: WebsiteProxyControllerProvider._internal(
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
  AutoDisposeAsyncNotifierProviderElement<WebsiteProxyController,
      List<WebsiteProxyDto>> createElement() {
    return _WebsiteProxyControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is WebsiteProxyControllerProvider &&
        other.websiteId == websiteId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, websiteId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin WebsiteProxyControllerRef
    on AutoDisposeAsyncNotifierProviderRef<List<WebsiteProxyDto>> {
  /// The parameter `websiteId` of this provider.
  int get websiteId;
}

class _WebsiteProxyControllerProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<WebsiteProxyController,
        List<WebsiteProxyDto>> with WebsiteProxyControllerRef {
  _WebsiteProxyControllerProviderElement(super.provider);

  @override
  int get websiteId => (origin as WebsiteProxyControllerProvider).websiteId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
