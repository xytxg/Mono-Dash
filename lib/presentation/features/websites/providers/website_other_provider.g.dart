// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'website_other_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$websiteGroupsHash() => r'96e6ed86105729af1d812710b202b721cec0d148';

/// See also [websiteGroups].
@ProviderFor(websiteGroups)
final websiteGroupsProvider =
    AutoDisposeFutureProvider<List<WebsiteGroupDto>>.internal(
  websiteGroups,
  name: r'websiteGroupsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$websiteGroupsHash,
  dependencies: <ProviderOrFamily>[websiteRepositoryProvider],
  allTransitiveDependencies: <ProviderOrFamily>{
    websiteRepositoryProvider,
    ...?websiteRepositoryProvider.allTransitiveDependencies
  },
);

typedef WebsiteGroupsRef = AutoDisposeFutureProviderRef<List<WebsiteGroupDto>>;
String _$websiteOtherControllerHash() =>
    r'b4f9e7cdeba7d668ce98043fba9759db4893a7b3';

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

abstract class _$WebsiteOtherController
    extends BuildlessAutoDisposeAsyncNotifier<void> {
  late final int websiteId;

  FutureOr<void> build(
    int websiteId,
  );
}

/// See also [WebsiteOtherController].
@ProviderFor(WebsiteOtherController)
const websiteOtherControllerProvider = WebsiteOtherControllerFamily();

/// See also [WebsiteOtherController].
class WebsiteOtherControllerFamily extends Family<AsyncValue<void>> {
  /// See also [WebsiteOtherController].
  const WebsiteOtherControllerFamily();

  /// See also [WebsiteOtherController].
  WebsiteOtherControllerProvider call(
    int websiteId,
  ) {
    return WebsiteOtherControllerProvider(
      websiteId,
    );
  }

  @override
  WebsiteOtherControllerProvider getProviderOverride(
    covariant WebsiteOtherControllerProvider provider,
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
  String? get name => r'websiteOtherControllerProvider';
}

/// See also [WebsiteOtherController].
class WebsiteOtherControllerProvider
    extends AutoDisposeAsyncNotifierProviderImpl<WebsiteOtherController, void> {
  /// See also [WebsiteOtherController].
  WebsiteOtherControllerProvider(
    int websiteId,
  ) : this._internal(
          () => WebsiteOtherController()..websiteId = websiteId,
          from: websiteOtherControllerProvider,
          name: r'websiteOtherControllerProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$websiteOtherControllerHash,
          dependencies: WebsiteOtherControllerFamily._dependencies,
          allTransitiveDependencies:
              WebsiteOtherControllerFamily._allTransitiveDependencies,
          websiteId: websiteId,
        );

  WebsiteOtherControllerProvider._internal(
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
  FutureOr<void> runNotifierBuild(
    covariant WebsiteOtherController notifier,
  ) {
    return notifier.build(
      websiteId,
    );
  }

  @override
  Override overrideWith(WebsiteOtherController Function() create) {
    return ProviderOverride(
      origin: this,
      override: WebsiteOtherControllerProvider._internal(
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
  AutoDisposeAsyncNotifierProviderElement<WebsiteOtherController, void>
      createElement() {
    return _WebsiteOtherControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is WebsiteOtherControllerProvider &&
        other.websiteId == websiteId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, websiteId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin WebsiteOtherControllerRef on AutoDisposeAsyncNotifierProviderRef<void> {
  /// The parameter `websiteId` of this provider.
  int get websiteId;
}

class _WebsiteOtherControllerProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<WebsiteOtherController,
        void> with WebsiteOtherControllerRef {
  _WebsiteOtherControllerProviderElement(super.provider);

  @override
  int get websiteId => (origin as WebsiteOtherControllerProvider).websiteId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
