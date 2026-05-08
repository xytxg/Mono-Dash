// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'website_detail_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$websiteDetailHash() => r'cb8c3c875cff3db908dffd7bdea0542b812cfe1e';

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

/// See also [websiteDetail].
@ProviderFor(websiteDetail)
const websiteDetailProvider = WebsiteDetailFamily();

/// See also [websiteDetail].
class WebsiteDetailFamily extends Family<AsyncValue<WebsiteDetailDto>> {
  /// See also [websiteDetail].
  const WebsiteDetailFamily();

  /// See also [websiteDetail].
  WebsiteDetailProvider call(
    int websiteId,
  ) {
    return WebsiteDetailProvider(
      websiteId,
    );
  }

  @override
  WebsiteDetailProvider getProviderOverride(
    covariant WebsiteDetailProvider provider,
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
  String? get name => r'websiteDetailProvider';
}

/// See also [websiteDetail].
class WebsiteDetailProvider
    extends AutoDisposeFutureProvider<WebsiteDetailDto> {
  /// See also [websiteDetail].
  WebsiteDetailProvider(
    int websiteId,
  ) : this._internal(
          (ref) => websiteDetail(
            ref as WebsiteDetailRef,
            websiteId,
          ),
          from: websiteDetailProvider,
          name: r'websiteDetailProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$websiteDetailHash,
          dependencies: WebsiteDetailFamily._dependencies,
          allTransitiveDependencies:
              WebsiteDetailFamily._allTransitiveDependencies,
          websiteId: websiteId,
        );

  WebsiteDetailProvider._internal(
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
    FutureOr<WebsiteDetailDto> Function(WebsiteDetailRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: WebsiteDetailProvider._internal(
        (ref) => create(ref as WebsiteDetailRef),
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
  AutoDisposeFutureProviderElement<WebsiteDetailDto> createElement() {
    return _WebsiteDetailProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is WebsiteDetailProvider && other.websiteId == websiteId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, websiteId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin WebsiteDetailRef on AutoDisposeFutureProviderRef<WebsiteDetailDto> {
  /// The parameter `websiteId` of this provider.
  int get websiteId;
}

class _WebsiteDetailProviderElement
    extends AutoDisposeFutureProviderElement<WebsiteDetailDto>
    with WebsiteDetailRef {
  _WebsiteDetailProviderElement(super.provider);

  @override
  int get websiteId => (origin as WebsiteDetailProvider).websiteId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
