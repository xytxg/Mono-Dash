// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'website_https_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$websiteHttpsControllerHash() =>
    r'48c97af9b5d4678e5d00b83e02d1ab930c54379d';

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

abstract class _$WebsiteHttpsController
    extends BuildlessAutoDisposeAsyncNotifier<WebsiteHttpsDto> {
  late final int websiteId;

  FutureOr<WebsiteHttpsDto> build(
    int websiteId,
  );
}

/// See also [WebsiteHttpsController].
@ProviderFor(WebsiteHttpsController)
const websiteHttpsControllerProvider = WebsiteHttpsControllerFamily();

/// See also [WebsiteHttpsController].
class WebsiteHttpsControllerFamily extends Family<AsyncValue<WebsiteHttpsDto>> {
  /// See also [WebsiteHttpsController].
  const WebsiteHttpsControllerFamily();

  /// See also [WebsiteHttpsController].
  WebsiteHttpsControllerProvider call(
    int websiteId,
  ) {
    return WebsiteHttpsControllerProvider(
      websiteId,
    );
  }

  @override
  WebsiteHttpsControllerProvider getProviderOverride(
    covariant WebsiteHttpsControllerProvider provider,
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
  String? get name => r'websiteHttpsControllerProvider';
}

/// See also [WebsiteHttpsController].
class WebsiteHttpsControllerProvider
    extends AutoDisposeAsyncNotifierProviderImpl<WebsiteHttpsController,
        WebsiteHttpsDto> {
  /// See also [WebsiteHttpsController].
  WebsiteHttpsControllerProvider(
    int websiteId,
  ) : this._internal(
          () => WebsiteHttpsController()..websiteId = websiteId,
          from: websiteHttpsControllerProvider,
          name: r'websiteHttpsControllerProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$websiteHttpsControllerHash,
          dependencies: WebsiteHttpsControllerFamily._dependencies,
          allTransitiveDependencies:
              WebsiteHttpsControllerFamily._allTransitiveDependencies,
          websiteId: websiteId,
        );

  WebsiteHttpsControllerProvider._internal(
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
  FutureOr<WebsiteHttpsDto> runNotifierBuild(
    covariant WebsiteHttpsController notifier,
  ) {
    return notifier.build(
      websiteId,
    );
  }

  @override
  Override overrideWith(WebsiteHttpsController Function() create) {
    return ProviderOverride(
      origin: this,
      override: WebsiteHttpsControllerProvider._internal(
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
  AutoDisposeAsyncNotifierProviderElement<WebsiteHttpsController,
      WebsiteHttpsDto> createElement() {
    return _WebsiteHttpsControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is WebsiteHttpsControllerProvider &&
        other.websiteId == websiteId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, websiteId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin WebsiteHttpsControllerRef
    on AutoDisposeAsyncNotifierProviderRef<WebsiteHttpsDto> {
  /// The parameter `websiteId` of this provider.
  int get websiteId;
}

class _WebsiteHttpsControllerProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<WebsiteHttpsController,
        WebsiteHttpsDto> with WebsiteHttpsControllerRef {
  _WebsiteHttpsControllerProviderElement(super.provider);

  @override
  int get websiteId => (origin as WebsiteHttpsControllerProvider).websiteId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
