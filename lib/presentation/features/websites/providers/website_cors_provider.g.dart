// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'website_cors_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$websiteCorsControllerHash() =>
    r'e6bd869c8c3c400846e9ecf9f63b7900112bd4c2';

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

abstract class _$WebsiteCorsController
    extends BuildlessAutoDisposeAsyncNotifier<WebsiteCorsDto> {
  late final int websiteId;

  FutureOr<WebsiteCorsDto> build(
    int websiteId,
  );
}

/// See also [WebsiteCorsController].
@ProviderFor(WebsiteCorsController)
const websiteCorsControllerProvider = WebsiteCorsControllerFamily();

/// See also [WebsiteCorsController].
class WebsiteCorsControllerFamily extends Family<AsyncValue<WebsiteCorsDto>> {
  /// See also [WebsiteCorsController].
  const WebsiteCorsControllerFamily();

  /// See also [WebsiteCorsController].
  WebsiteCorsControllerProvider call(
    int websiteId,
  ) {
    return WebsiteCorsControllerProvider(
      websiteId,
    );
  }

  @override
  WebsiteCorsControllerProvider getProviderOverride(
    covariant WebsiteCorsControllerProvider provider,
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
  String? get name => r'websiteCorsControllerProvider';
}

/// See also [WebsiteCorsController].
class WebsiteCorsControllerProvider
    extends AutoDisposeAsyncNotifierProviderImpl<WebsiteCorsController,
        WebsiteCorsDto> {
  /// See also [WebsiteCorsController].
  WebsiteCorsControllerProvider(
    int websiteId,
  ) : this._internal(
          () => WebsiteCorsController()..websiteId = websiteId,
          from: websiteCorsControllerProvider,
          name: r'websiteCorsControllerProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$websiteCorsControllerHash,
          dependencies: WebsiteCorsControllerFamily._dependencies,
          allTransitiveDependencies:
              WebsiteCorsControllerFamily._allTransitiveDependencies,
          websiteId: websiteId,
        );

  WebsiteCorsControllerProvider._internal(
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
  FutureOr<WebsiteCorsDto> runNotifierBuild(
    covariant WebsiteCorsController notifier,
  ) {
    return notifier.build(
      websiteId,
    );
  }

  @override
  Override overrideWith(WebsiteCorsController Function() create) {
    return ProviderOverride(
      origin: this,
      override: WebsiteCorsControllerProvider._internal(
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
  AutoDisposeAsyncNotifierProviderElement<WebsiteCorsController, WebsiteCorsDto>
      createElement() {
    return _WebsiteCorsControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is WebsiteCorsControllerProvider &&
        other.websiteId == websiteId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, websiteId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin WebsiteCorsControllerRef
    on AutoDisposeAsyncNotifierProviderRef<WebsiteCorsDto> {
  /// The parameter `websiteId` of this provider.
  int get websiteId;
}

class _WebsiteCorsControllerProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<WebsiteCorsController,
        WebsiteCorsDto> with WebsiteCorsControllerRef {
  _WebsiteCorsControllerProviderElement(super.provider);

  @override
  int get websiteId => (origin as WebsiteCorsControllerProvider).websiteId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
