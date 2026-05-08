// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'file_editor_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$fileEditorControllerHash() =>
    r'da9ff2793094127a7eb13a698f000c8405e848d3';

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

abstract class _$FileEditorController
    extends BuildlessAutoDisposeAsyncNotifier<FileItemDto> {
  late final String path;

  FutureOr<FileItemDto> build(
    String path,
  );
}

/// See also [FileEditorController].
@ProviderFor(FileEditorController)
const fileEditorControllerProvider = FileEditorControllerFamily();

/// See also [FileEditorController].
class FileEditorControllerFamily extends Family<AsyncValue<FileItemDto>> {
  /// See also [FileEditorController].
  const FileEditorControllerFamily();

  /// See also [FileEditorController].
  FileEditorControllerProvider call(
    String path,
  ) {
    return FileEditorControllerProvider(
      path,
    );
  }

  @override
  FileEditorControllerProvider getProviderOverride(
    covariant FileEditorControllerProvider provider,
  ) {
    return call(
      provider.path,
    );
  }

  static final Iterable<ProviderOrFamily> _dependencies = <ProviderOrFamily>[
    fileRepositoryProvider
  ];

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static final Iterable<ProviderOrFamily> _allTransitiveDependencies =
      <ProviderOrFamily>{
    fileRepositoryProvider,
    ...?fileRepositoryProvider.allTransitiveDependencies
  };

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'fileEditorControllerProvider';
}

/// See also [FileEditorController].
class FileEditorControllerProvider extends AutoDisposeAsyncNotifierProviderImpl<
    FileEditorController, FileItemDto> {
  /// See also [FileEditorController].
  FileEditorControllerProvider(
    String path,
  ) : this._internal(
          () => FileEditorController()..path = path,
          from: fileEditorControllerProvider,
          name: r'fileEditorControllerProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$fileEditorControllerHash,
          dependencies: FileEditorControllerFamily._dependencies,
          allTransitiveDependencies:
              FileEditorControllerFamily._allTransitiveDependencies,
          path: path,
        );

  FileEditorControllerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.path,
  }) : super.internal();

  final String path;

  @override
  FutureOr<FileItemDto> runNotifierBuild(
    covariant FileEditorController notifier,
  ) {
    return notifier.build(
      path,
    );
  }

  @override
  Override overrideWith(FileEditorController Function() create) {
    return ProviderOverride(
      origin: this,
      override: FileEditorControllerProvider._internal(
        () => create()..path = path,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        path: path,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<FileEditorController, FileItemDto>
      createElement() {
    return _FileEditorControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FileEditorControllerProvider && other.path == path;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, path.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin FileEditorControllerRef
    on AutoDisposeAsyncNotifierProviderRef<FileItemDto> {
  /// The parameter `path` of this provider.
  String get path;
}

class _FileEditorControllerProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<FileEditorController,
        FileItemDto> with FileEditorControllerRef {
  _FileEditorControllerProviderElement(super.provider);

  @override
  String get path => (origin as FileEditorControllerProvider).path;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
