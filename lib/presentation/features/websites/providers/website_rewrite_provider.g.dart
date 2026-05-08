// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'website_rewrite_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$websiteRewriteControllerHash() =>
    r'7794aa825c2d770044c85c0237db258cc7067cf9';

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

abstract class _$WebsiteRewriteController
    extends BuildlessAutoDisposeAsyncNotifier<WebsiteRewriteState> {
  late final int websiteId;

  FutureOr<WebsiteRewriteState> build(
    int websiteId,
  );
}

/// See also [WebsiteRewriteController].
@ProviderFor(WebsiteRewriteController)
const websiteRewriteControllerProvider = WebsiteRewriteControllerFamily();

/// See also [WebsiteRewriteController].
class WebsiteRewriteControllerFamily
    extends Family<AsyncValue<WebsiteRewriteState>> {
  /// See also [WebsiteRewriteController].
  const WebsiteRewriteControllerFamily();

  /// See also [WebsiteRewriteController].
  WebsiteRewriteControllerProvider call(
    int websiteId,
  ) {
    return WebsiteRewriteControllerProvider(
      websiteId,
    );
  }

  @override
  WebsiteRewriteControllerProvider getProviderOverride(
    covariant WebsiteRewriteControllerProvider provider,
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
  String? get name => r'websiteRewriteControllerProvider';
}

/// See also [WebsiteRewriteController].
class WebsiteRewriteControllerProvider
    extends AutoDisposeAsyncNotifierProviderImpl<WebsiteRewriteController,
        WebsiteRewriteState> {
  /// See also [WebsiteRewriteController].
  WebsiteRewriteControllerProvider(
    int websiteId,
  ) : this._internal(
          () => WebsiteRewriteController()..websiteId = websiteId,
          from: websiteRewriteControllerProvider,
          name: r'websiteRewriteControllerProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$websiteRewriteControllerHash,
          dependencies: WebsiteRewriteControllerFamily._dependencies,
          allTransitiveDependencies:
              WebsiteRewriteControllerFamily._allTransitiveDependencies,
          websiteId: websiteId,
        );

  WebsiteRewriteControllerProvider._internal(
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
  FutureOr<WebsiteRewriteState> runNotifierBuild(
    covariant WebsiteRewriteController notifier,
  ) {
    return notifier.build(
      websiteId,
    );
  }

  @override
  Override overrideWith(WebsiteRewriteController Function() create) {
    return ProviderOverride(
      origin: this,
      override: WebsiteRewriteControllerProvider._internal(
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
  AutoDisposeAsyncNotifierProviderElement<WebsiteRewriteController,
      WebsiteRewriteState> createElement() {
    return _WebsiteRewriteControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is WebsiteRewriteControllerProvider &&
        other.websiteId == websiteId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, websiteId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin WebsiteRewriteControllerRef
    on AutoDisposeAsyncNotifierProviderRef<WebsiteRewriteState> {
  /// The parameter `websiteId` of this provider.
  int get websiteId;
}

class _WebsiteRewriteControllerProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<WebsiteRewriteController,
        WebsiteRewriteState> with WebsiteRewriteControllerRef {
  _WebsiteRewriteControllerProviderElement(super.provider);

  @override
  int get websiteId => (origin as WebsiteRewriteControllerProvider).websiteId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
