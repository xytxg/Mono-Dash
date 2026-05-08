// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'website_config_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$websiteConfigControllerHash() =>
    r'94fb3b166b4fb7bf973c82a16b181b16257c5e61';

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

abstract class _$WebsiteConfigController
    extends BuildlessAutoDisposeAsyncNotifier<WebsiteConfigFileDto> {
  late final int websiteId;

  FutureOr<WebsiteConfigFileDto> build(
    int websiteId,
  );
}

/// See also [WebsiteConfigController].
@ProviderFor(WebsiteConfigController)
const websiteConfigControllerProvider = WebsiteConfigControllerFamily();

/// See also [WebsiteConfigController].
class WebsiteConfigControllerFamily
    extends Family<AsyncValue<WebsiteConfigFileDto>> {
  /// See also [WebsiteConfigController].
  const WebsiteConfigControllerFamily();

  /// See also [WebsiteConfigController].
  WebsiteConfigControllerProvider call(
    int websiteId,
  ) {
    return WebsiteConfigControllerProvider(
      websiteId,
    );
  }

  @override
  WebsiteConfigControllerProvider getProviderOverride(
    covariant WebsiteConfigControllerProvider provider,
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
  String? get name => r'websiteConfigControllerProvider';
}

/// See also [WebsiteConfigController].
class WebsiteConfigControllerProvider
    extends AutoDisposeAsyncNotifierProviderImpl<WebsiteConfigController,
        WebsiteConfigFileDto> {
  /// See also [WebsiteConfigController].
  WebsiteConfigControllerProvider(
    int websiteId,
  ) : this._internal(
          () => WebsiteConfigController()..websiteId = websiteId,
          from: websiteConfigControllerProvider,
          name: r'websiteConfigControllerProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$websiteConfigControllerHash,
          dependencies: WebsiteConfigControllerFamily._dependencies,
          allTransitiveDependencies:
              WebsiteConfigControllerFamily._allTransitiveDependencies,
          websiteId: websiteId,
        );

  WebsiteConfigControllerProvider._internal(
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
  FutureOr<WebsiteConfigFileDto> runNotifierBuild(
    covariant WebsiteConfigController notifier,
  ) {
    return notifier.build(
      websiteId,
    );
  }

  @override
  Override overrideWith(WebsiteConfigController Function() create) {
    return ProviderOverride(
      origin: this,
      override: WebsiteConfigControllerProvider._internal(
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
  AutoDisposeAsyncNotifierProviderElement<WebsiteConfigController,
      WebsiteConfigFileDto> createElement() {
    return _WebsiteConfigControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is WebsiteConfigControllerProvider &&
        other.websiteId == websiteId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, websiteId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin WebsiteConfigControllerRef
    on AutoDisposeAsyncNotifierProviderRef<WebsiteConfigFileDto> {
  /// The parameter `websiteId` of this provider.
  int get websiteId;
}

class _WebsiteConfigControllerProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<WebsiteConfigController,
        WebsiteConfigFileDto> with WebsiteConfigControllerRef {
  _WebsiteConfigControllerProviderElement(super.provider);

  @override
  int get websiteId => (origin as WebsiteConfigControllerProvider).websiteId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
