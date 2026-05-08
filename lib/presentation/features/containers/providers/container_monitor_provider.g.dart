// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'container_monitor_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$containerMonitorHash() => r'2d11afbb031da88ed2a92fdc9e02b9861c316b09';

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

abstract class _$ContainerMonitor
    extends BuildlessAutoDisposeNotifier<ContainerMonitorState> {
  late final String containerId;

  ContainerMonitorState build(
    String containerId,
  );
}

/// See also [ContainerMonitor].
@ProviderFor(ContainerMonitor)
const containerMonitorProvider = ContainerMonitorFamily();

/// See also [ContainerMonitor].
class ContainerMonitorFamily extends Family<ContainerMonitorState> {
  /// See also [ContainerMonitor].
  const ContainerMonitorFamily();

  /// See also [ContainerMonitor].
  ContainerMonitorProvider call(
    String containerId,
  ) {
    return ContainerMonitorProvider(
      containerId,
    );
  }

  @override
  ContainerMonitorProvider getProviderOverride(
    covariant ContainerMonitorProvider provider,
  ) {
    return call(
      provider.containerId,
    );
  }

  static final Iterable<ProviderOrFamily> _dependencies = <ProviderOrFamily>[
    containerRepositoryProvider
  ];

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static final Iterable<ProviderOrFamily> _allTransitiveDependencies =
      <ProviderOrFamily>{
    containerRepositoryProvider,
    ...?containerRepositoryProvider.allTransitiveDependencies
  };

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'containerMonitorProvider';
}

/// See also [ContainerMonitor].
class ContainerMonitorProvider extends AutoDisposeNotifierProviderImpl<
    ContainerMonitor, ContainerMonitorState> {
  /// See also [ContainerMonitor].
  ContainerMonitorProvider(
    String containerId,
  ) : this._internal(
          () => ContainerMonitor()..containerId = containerId,
          from: containerMonitorProvider,
          name: r'containerMonitorProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$containerMonitorHash,
          dependencies: ContainerMonitorFamily._dependencies,
          allTransitiveDependencies:
              ContainerMonitorFamily._allTransitiveDependencies,
          containerId: containerId,
        );

  ContainerMonitorProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.containerId,
  }) : super.internal();

  final String containerId;

  @override
  ContainerMonitorState runNotifierBuild(
    covariant ContainerMonitor notifier,
  ) {
    return notifier.build(
      containerId,
    );
  }

  @override
  Override overrideWith(ContainerMonitor Function() create) {
    return ProviderOverride(
      origin: this,
      override: ContainerMonitorProvider._internal(
        () => create()..containerId = containerId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        containerId: containerId,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<ContainerMonitor, ContainerMonitorState>
      createElement() {
    return _ContainerMonitorProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ContainerMonitorProvider &&
        other.containerId == containerId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, containerId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin ContainerMonitorRef
    on AutoDisposeNotifierProviderRef<ContainerMonitorState> {
  /// The parameter `containerId` of this provider.
  String get containerId;
}

class _ContainerMonitorProviderElement
    extends AutoDisposeNotifierProviderElement<ContainerMonitor,
        ContainerMonitorState> with ContainerMonitorRef {
  _ContainerMonitorProviderElement(super.provider);

  @override
  String get containerId => (origin as ContainerMonitorProvider).containerId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
