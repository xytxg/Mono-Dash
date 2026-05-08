// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'website_dir_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$websiteDirControllerHash() =>
    r'f86275d90ad73d1518c26456c0c6b3057b76bf6b';

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

abstract class _$WebsiteDirController
    extends BuildlessAutoDisposeAsyncNotifier<WebsiteDirDto> {
  late final int websiteId;

  FutureOr<WebsiteDirDto> build(
    int websiteId,
  );
}

/// See also [WebsiteDirController].
@ProviderFor(WebsiteDirController)
const websiteDirControllerProvider = WebsiteDirControllerFamily();

/// See also [WebsiteDirController].
class WebsiteDirControllerFamily extends Family<AsyncValue<WebsiteDirDto>> {
  /// See also [WebsiteDirController].
  const WebsiteDirControllerFamily();

  /// See also [WebsiteDirController].
  WebsiteDirControllerProvider call(
    int websiteId,
  ) {
    return WebsiteDirControllerProvider(
      websiteId,
    );
  }

  @override
  WebsiteDirControllerProvider getProviderOverride(
    covariant WebsiteDirControllerProvider provider,
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
  String? get name => r'websiteDirControllerProvider';
}

/// See also [WebsiteDirController].
class WebsiteDirControllerProvider extends AutoDisposeAsyncNotifierProviderImpl<
    WebsiteDirController, WebsiteDirDto> {
  /// See also [WebsiteDirController].
  WebsiteDirControllerProvider(
    int websiteId,
  ) : this._internal(
          () => WebsiteDirController()..websiteId = websiteId,
          from: websiteDirControllerProvider,
          name: r'websiteDirControllerProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$websiteDirControllerHash,
          dependencies: WebsiteDirControllerFamily._dependencies,
          allTransitiveDependencies:
              WebsiteDirControllerFamily._allTransitiveDependencies,
          websiteId: websiteId,
        );

  WebsiteDirControllerProvider._internal(
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
  FutureOr<WebsiteDirDto> runNotifierBuild(
    covariant WebsiteDirController notifier,
  ) {
    return notifier.build(
      websiteId,
    );
  }

  @override
  Override overrideWith(WebsiteDirController Function() create) {
    return ProviderOverride(
      origin: this,
      override: WebsiteDirControllerProvider._internal(
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
  AutoDisposeAsyncNotifierProviderElement<WebsiteDirController, WebsiteDirDto>
      createElement() {
    return _WebsiteDirControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is WebsiteDirControllerProvider &&
        other.websiteId == websiteId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, websiteId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin WebsiteDirControllerRef
    on AutoDisposeAsyncNotifierProviderRef<WebsiteDirDto> {
  /// The parameter `websiteId` of this provider.
  int get websiteId;
}

class _WebsiteDirControllerProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<WebsiteDirController,
        WebsiteDirDto> with WebsiteDirControllerRef {
  _WebsiteDirControllerProviderElement(super.provider);

  @override
  int get websiteId => (origin as WebsiteDirControllerProvider).websiteId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
