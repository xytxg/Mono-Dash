// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'website_log_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$websiteLogControllerHash() =>
    r'dee107685112bf6112076d2cf0d24a75dbc58995';

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

abstract class _$WebsiteLogController
    extends BuildlessAutoDisposeAsyncNotifier<WebsiteLogFileDto> {
  late final int websiteId;
  late final WebsiteLogType type;

  FutureOr<WebsiteLogFileDto> build(
    int websiteId,
    WebsiteLogType type,
  );
}

/// See also [WebsiteLogController].
@ProviderFor(WebsiteLogController)
const websiteLogControllerProvider = WebsiteLogControllerFamily();

/// See also [WebsiteLogController].
class WebsiteLogControllerFamily extends Family<AsyncValue<WebsiteLogFileDto>> {
  /// See also [WebsiteLogController].
  const WebsiteLogControllerFamily();

  /// See also [WebsiteLogController].
  WebsiteLogControllerProvider call(
    int websiteId,
    WebsiteLogType type,
  ) {
    return WebsiteLogControllerProvider(
      websiteId,
      type,
    );
  }

  @override
  WebsiteLogControllerProvider getProviderOverride(
    covariant WebsiteLogControllerProvider provider,
  ) {
    return call(
      provider.websiteId,
      provider.type,
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
  String? get name => r'websiteLogControllerProvider';
}

/// See also [WebsiteLogController].
class WebsiteLogControllerProvider extends AutoDisposeAsyncNotifierProviderImpl<
    WebsiteLogController, WebsiteLogFileDto> {
  /// See also [WebsiteLogController].
  WebsiteLogControllerProvider(
    int websiteId,
    WebsiteLogType type,
  ) : this._internal(
          () => WebsiteLogController()
            ..websiteId = websiteId
            ..type = type,
          from: websiteLogControllerProvider,
          name: r'websiteLogControllerProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$websiteLogControllerHash,
          dependencies: WebsiteLogControllerFamily._dependencies,
          allTransitiveDependencies:
              WebsiteLogControllerFamily._allTransitiveDependencies,
          websiteId: websiteId,
          type: type,
        );

  WebsiteLogControllerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.websiteId,
    required this.type,
  }) : super.internal();

  final int websiteId;
  final WebsiteLogType type;

  @override
  FutureOr<WebsiteLogFileDto> runNotifierBuild(
    covariant WebsiteLogController notifier,
  ) {
    return notifier.build(
      websiteId,
      type,
    );
  }

  @override
  Override overrideWith(WebsiteLogController Function() create) {
    return ProviderOverride(
      origin: this,
      override: WebsiteLogControllerProvider._internal(
        () => create()
          ..websiteId = websiteId
          ..type = type,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        websiteId: websiteId,
        type: type,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<WebsiteLogController,
      WebsiteLogFileDto> createElement() {
    return _WebsiteLogControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is WebsiteLogControllerProvider &&
        other.websiteId == websiteId &&
        other.type == type;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, websiteId.hashCode);
    hash = _SystemHash.combine(hash, type.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin WebsiteLogControllerRef
    on AutoDisposeAsyncNotifierProviderRef<WebsiteLogFileDto> {
  /// The parameter `websiteId` of this provider.
  int get websiteId;

  /// The parameter `type` of this provider.
  WebsiteLogType get type;
}

class _WebsiteLogControllerProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<WebsiteLogController,
        WebsiteLogFileDto> with WebsiteLogControllerRef {
  _WebsiteLogControllerProviderElement(super.provider);

  @override
  int get websiteId => (origin as WebsiteLogControllerProvider).websiteId;
  @override
  WebsiteLogType get type => (origin as WebsiteLogControllerProvider).type;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
