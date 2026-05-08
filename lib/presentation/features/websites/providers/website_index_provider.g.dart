// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'website_index_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$websiteIndexControllerHash() =>
    r'ee0220a6787533945973d2d33eb129b919dadec5';

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

abstract class _$WebsiteIndexController
    extends BuildlessAutoDisposeAsyncNotifier<WebsiteIndexConfigDto> {
  late final int websiteId;

  FutureOr<WebsiteIndexConfigDto> build(
    int websiteId,
  );
}

/// See also [WebsiteIndexController].
@ProviderFor(WebsiteIndexController)
const websiteIndexControllerProvider = WebsiteIndexControllerFamily();

/// See also [WebsiteIndexController].
class WebsiteIndexControllerFamily
    extends Family<AsyncValue<WebsiteIndexConfigDto>> {
  /// See also [WebsiteIndexController].
  const WebsiteIndexControllerFamily();

  /// See also [WebsiteIndexController].
  WebsiteIndexControllerProvider call(
    int websiteId,
  ) {
    return WebsiteIndexControllerProvider(
      websiteId,
    );
  }

  @override
  WebsiteIndexControllerProvider getProviderOverride(
    covariant WebsiteIndexControllerProvider provider,
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
  String? get name => r'websiteIndexControllerProvider';
}

/// See also [WebsiteIndexController].
class WebsiteIndexControllerProvider
    extends AutoDisposeAsyncNotifierProviderImpl<WebsiteIndexController,
        WebsiteIndexConfigDto> {
  /// See also [WebsiteIndexController].
  WebsiteIndexControllerProvider(
    int websiteId,
  ) : this._internal(
          () => WebsiteIndexController()..websiteId = websiteId,
          from: websiteIndexControllerProvider,
          name: r'websiteIndexControllerProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$websiteIndexControllerHash,
          dependencies: WebsiteIndexControllerFamily._dependencies,
          allTransitiveDependencies:
              WebsiteIndexControllerFamily._allTransitiveDependencies,
          websiteId: websiteId,
        );

  WebsiteIndexControllerProvider._internal(
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
  FutureOr<WebsiteIndexConfigDto> runNotifierBuild(
    covariant WebsiteIndexController notifier,
  ) {
    return notifier.build(
      websiteId,
    );
  }

  @override
  Override overrideWith(WebsiteIndexController Function() create) {
    return ProviderOverride(
      origin: this,
      override: WebsiteIndexControllerProvider._internal(
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
  AutoDisposeAsyncNotifierProviderElement<WebsiteIndexController,
      WebsiteIndexConfigDto> createElement() {
    return _WebsiteIndexControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is WebsiteIndexControllerProvider &&
        other.websiteId == websiteId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, websiteId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin WebsiteIndexControllerRef
    on AutoDisposeAsyncNotifierProviderRef<WebsiteIndexConfigDto> {
  /// The parameter `websiteId` of this provider.
  int get websiteId;
}

class _WebsiteIndexControllerProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<WebsiteIndexController,
        WebsiteIndexConfigDto> with WebsiteIndexControllerRef {
  _WebsiteIndexControllerProviderElement(super.provider);

  @override
  int get websiteId => (origin as WebsiteIndexControllerProvider).websiteId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
