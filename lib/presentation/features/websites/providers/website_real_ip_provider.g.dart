// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'website_real_ip_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$websiteRealIpControllerHash() =>
    r'5ddc0f5655c1b87b58ad4e34c5aa5c72330ae80c';

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

abstract class _$WebsiteRealIpController
    extends BuildlessAutoDisposeAsyncNotifier<WebsiteRealIpDto> {
  late final int websiteId;

  FutureOr<WebsiteRealIpDto> build(
    int websiteId,
  );
}

/// See also [WebsiteRealIpController].
@ProviderFor(WebsiteRealIpController)
const websiteRealIpControllerProvider = WebsiteRealIpControllerFamily();

/// See also [WebsiteRealIpController].
class WebsiteRealIpControllerFamily
    extends Family<AsyncValue<WebsiteRealIpDto>> {
  /// See also [WebsiteRealIpController].
  const WebsiteRealIpControllerFamily();

  /// See also [WebsiteRealIpController].
  WebsiteRealIpControllerProvider call(
    int websiteId,
  ) {
    return WebsiteRealIpControllerProvider(
      websiteId,
    );
  }

  @override
  WebsiteRealIpControllerProvider getProviderOverride(
    covariant WebsiteRealIpControllerProvider provider,
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
  String? get name => r'websiteRealIpControllerProvider';
}

/// See also [WebsiteRealIpController].
class WebsiteRealIpControllerProvider
    extends AutoDisposeAsyncNotifierProviderImpl<WebsiteRealIpController,
        WebsiteRealIpDto> {
  /// See also [WebsiteRealIpController].
  WebsiteRealIpControllerProvider(
    int websiteId,
  ) : this._internal(
          () => WebsiteRealIpController()..websiteId = websiteId,
          from: websiteRealIpControllerProvider,
          name: r'websiteRealIpControllerProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$websiteRealIpControllerHash,
          dependencies: WebsiteRealIpControllerFamily._dependencies,
          allTransitiveDependencies:
              WebsiteRealIpControllerFamily._allTransitiveDependencies,
          websiteId: websiteId,
        );

  WebsiteRealIpControllerProvider._internal(
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
  FutureOr<WebsiteRealIpDto> runNotifierBuild(
    covariant WebsiteRealIpController notifier,
  ) {
    return notifier.build(
      websiteId,
    );
  }

  @override
  Override overrideWith(WebsiteRealIpController Function() create) {
    return ProviderOverride(
      origin: this,
      override: WebsiteRealIpControllerProvider._internal(
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
  AutoDisposeAsyncNotifierProviderElement<WebsiteRealIpController,
      WebsiteRealIpDto> createElement() {
    return _WebsiteRealIpControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is WebsiteRealIpControllerProvider &&
        other.websiteId == websiteId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, websiteId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin WebsiteRealIpControllerRef
    on AutoDisposeAsyncNotifierProviderRef<WebsiteRealIpDto> {
  /// The parameter `websiteId` of this provider.
  int get websiteId;
}

class _WebsiteRealIpControllerProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<WebsiteRealIpController,
        WebsiteRealIpDto> with WebsiteRealIpControllerRef {
  _WebsiteRealIpControllerProviderElement(super.provider);

  @override
  int get websiteId => (origin as WebsiteRealIpControllerProvider).websiteId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
