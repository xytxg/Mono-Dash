// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'website_domains_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$websiteDomainsControllerHash() =>
    r'040f09f37828cbcf1ef209082cd34c623273a38f';

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

abstract class _$WebsiteDomainsController
    extends BuildlessAutoDisposeAsyncNotifier<List<WebsiteDomainDto>> {
  late final int websiteId;

  FutureOr<List<WebsiteDomainDto>> build(
    int websiteId,
  );
}

/// See also [WebsiteDomainsController].
@ProviderFor(WebsiteDomainsController)
const websiteDomainsControllerProvider = WebsiteDomainsControllerFamily();

/// See also [WebsiteDomainsController].
class WebsiteDomainsControllerFamily
    extends Family<AsyncValue<List<WebsiteDomainDto>>> {
  /// See also [WebsiteDomainsController].
  const WebsiteDomainsControllerFamily();

  /// See also [WebsiteDomainsController].
  WebsiteDomainsControllerProvider call(
    int websiteId,
  ) {
    return WebsiteDomainsControllerProvider(
      websiteId,
    );
  }

  @override
  WebsiteDomainsControllerProvider getProviderOverride(
    covariant WebsiteDomainsControllerProvider provider,
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
  String? get name => r'websiteDomainsControllerProvider';
}

/// See also [WebsiteDomainsController].
class WebsiteDomainsControllerProvider
    extends AutoDisposeAsyncNotifierProviderImpl<WebsiteDomainsController,
        List<WebsiteDomainDto>> {
  /// See also [WebsiteDomainsController].
  WebsiteDomainsControllerProvider(
    int websiteId,
  ) : this._internal(
          () => WebsiteDomainsController()..websiteId = websiteId,
          from: websiteDomainsControllerProvider,
          name: r'websiteDomainsControllerProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$websiteDomainsControllerHash,
          dependencies: WebsiteDomainsControllerFamily._dependencies,
          allTransitiveDependencies:
              WebsiteDomainsControllerFamily._allTransitiveDependencies,
          websiteId: websiteId,
        );

  WebsiteDomainsControllerProvider._internal(
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
  FutureOr<List<WebsiteDomainDto>> runNotifierBuild(
    covariant WebsiteDomainsController notifier,
  ) {
    return notifier.build(
      websiteId,
    );
  }

  @override
  Override overrideWith(WebsiteDomainsController Function() create) {
    return ProviderOverride(
      origin: this,
      override: WebsiteDomainsControllerProvider._internal(
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
  AutoDisposeAsyncNotifierProviderElement<WebsiteDomainsController,
      List<WebsiteDomainDto>> createElement() {
    return _WebsiteDomainsControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is WebsiteDomainsControllerProvider &&
        other.websiteId == websiteId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, websiteId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin WebsiteDomainsControllerRef
    on AutoDisposeAsyncNotifierProviderRef<List<WebsiteDomainDto>> {
  /// The parameter `websiteId` of this provider.
  int get websiteId;
}

class _WebsiteDomainsControllerProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<WebsiteDomainsController,
        List<WebsiteDomainDto>> with WebsiteDomainsControllerRef {
  _WebsiteDomainsControllerProviderElement(super.provider);

  @override
  int get websiteId => (origin as WebsiteDomainsControllerProvider).websiteId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
