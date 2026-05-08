// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'website_leech_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$websiteLeechControllerHash() =>
    r'e5ca374e38f9061eb1a1780718c42c2acb85b762';

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

abstract class _$WebsiteLeechController
    extends BuildlessAutoDisposeAsyncNotifier<WebsiteLeechDto> {
  late final int websiteId;

  FutureOr<WebsiteLeechDto> build(
    int websiteId,
  );
}

/// See also [WebsiteLeechController].
@ProviderFor(WebsiteLeechController)
const websiteLeechControllerProvider = WebsiteLeechControllerFamily();

/// See also [WebsiteLeechController].
class WebsiteLeechControllerFamily extends Family<AsyncValue<WebsiteLeechDto>> {
  /// See also [WebsiteLeechController].
  const WebsiteLeechControllerFamily();

  /// See also [WebsiteLeechController].
  WebsiteLeechControllerProvider call(
    int websiteId,
  ) {
    return WebsiteLeechControllerProvider(
      websiteId,
    );
  }

  @override
  WebsiteLeechControllerProvider getProviderOverride(
    covariant WebsiteLeechControllerProvider provider,
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
  String? get name => r'websiteLeechControllerProvider';
}

/// See also [WebsiteLeechController].
class WebsiteLeechControllerProvider
    extends AutoDisposeAsyncNotifierProviderImpl<WebsiteLeechController,
        WebsiteLeechDto> {
  /// See also [WebsiteLeechController].
  WebsiteLeechControllerProvider(
    int websiteId,
  ) : this._internal(
          () => WebsiteLeechController()..websiteId = websiteId,
          from: websiteLeechControllerProvider,
          name: r'websiteLeechControllerProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$websiteLeechControllerHash,
          dependencies: WebsiteLeechControllerFamily._dependencies,
          allTransitiveDependencies:
              WebsiteLeechControllerFamily._allTransitiveDependencies,
          websiteId: websiteId,
        );

  WebsiteLeechControllerProvider._internal(
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
  FutureOr<WebsiteLeechDto> runNotifierBuild(
    covariant WebsiteLeechController notifier,
  ) {
    return notifier.build(
      websiteId,
    );
  }

  @override
  Override overrideWith(WebsiteLeechController Function() create) {
    return ProviderOverride(
      origin: this,
      override: WebsiteLeechControllerProvider._internal(
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
  AutoDisposeAsyncNotifierProviderElement<WebsiteLeechController,
      WebsiteLeechDto> createElement() {
    return _WebsiteLeechControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is WebsiteLeechControllerProvider &&
        other.websiteId == websiteId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, websiteId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin WebsiteLeechControllerRef
    on AutoDisposeAsyncNotifierProviderRef<WebsiteLeechDto> {
  /// The parameter `websiteId` of this provider.
  int get websiteId;
}

class _WebsiteLeechControllerProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<WebsiteLeechController,
        WebsiteLeechDto> with WebsiteLeechControllerRef {
  _WebsiteLeechControllerProviderElement(super.provider);

  @override
  int get websiteId => (origin as WebsiteLeechControllerProvider).websiteId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
