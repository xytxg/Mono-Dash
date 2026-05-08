// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'website_redirect_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$websiteRedirectControllerHash() =>
    r'3c245b3fad4f821186a9aa1afea46832e2035746';

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

abstract class _$WebsiteRedirectController
    extends BuildlessAutoDisposeAsyncNotifier<List<WebsiteRedirectDto>> {
  late final int websiteId;

  FutureOr<List<WebsiteRedirectDto>> build(
    int websiteId,
  );
}

/// See also [WebsiteRedirectController].
@ProviderFor(WebsiteRedirectController)
const websiteRedirectControllerProvider = WebsiteRedirectControllerFamily();

/// See also [WebsiteRedirectController].
class WebsiteRedirectControllerFamily
    extends Family<AsyncValue<List<WebsiteRedirectDto>>> {
  /// See also [WebsiteRedirectController].
  const WebsiteRedirectControllerFamily();

  /// See also [WebsiteRedirectController].
  WebsiteRedirectControllerProvider call(
    int websiteId,
  ) {
    return WebsiteRedirectControllerProvider(
      websiteId,
    );
  }

  @override
  WebsiteRedirectControllerProvider getProviderOverride(
    covariant WebsiteRedirectControllerProvider provider,
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
  String? get name => r'websiteRedirectControllerProvider';
}

/// See also [WebsiteRedirectController].
class WebsiteRedirectControllerProvider
    extends AutoDisposeAsyncNotifierProviderImpl<WebsiteRedirectController,
        List<WebsiteRedirectDto>> {
  /// See also [WebsiteRedirectController].
  WebsiteRedirectControllerProvider(
    int websiteId,
  ) : this._internal(
          () => WebsiteRedirectController()..websiteId = websiteId,
          from: websiteRedirectControllerProvider,
          name: r'websiteRedirectControllerProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$websiteRedirectControllerHash,
          dependencies: WebsiteRedirectControllerFamily._dependencies,
          allTransitiveDependencies:
              WebsiteRedirectControllerFamily._allTransitiveDependencies,
          websiteId: websiteId,
        );

  WebsiteRedirectControllerProvider._internal(
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
  FutureOr<List<WebsiteRedirectDto>> runNotifierBuild(
    covariant WebsiteRedirectController notifier,
  ) {
    return notifier.build(
      websiteId,
    );
  }

  @override
  Override overrideWith(WebsiteRedirectController Function() create) {
    return ProviderOverride(
      origin: this,
      override: WebsiteRedirectControllerProvider._internal(
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
  AutoDisposeAsyncNotifierProviderElement<WebsiteRedirectController,
      List<WebsiteRedirectDto>> createElement() {
    return _WebsiteRedirectControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is WebsiteRedirectControllerProvider &&
        other.websiteId == websiteId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, websiteId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin WebsiteRedirectControllerRef
    on AutoDisposeAsyncNotifierProviderRef<List<WebsiteRedirectDto>> {
  /// The parameter `websiteId` of this provider.
  int get websiteId;
}

class _WebsiteRedirectControllerProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<WebsiteRedirectController,
        List<WebsiteRedirectDto>> with WebsiteRedirectControllerRef {
  _WebsiteRedirectControllerProviderElement(super.provider);

  @override
  int get websiteId => (origin as WebsiteRedirectControllerProvider).websiteId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
