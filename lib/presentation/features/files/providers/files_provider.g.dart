// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'files_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$filesControllerHash() => r'c7a603ec5622ac88f945ef0e36856c714a5659b0';

/// See also [FilesController].
@ProviderFor(FilesController)
final filesControllerProvider =
    AutoDisposeAsyncNotifierProvider<FilesController, FilesViewState>.internal(
      FilesController.new,
      name: r'filesControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$filesControllerHash,
      dependencies: <ProviderOrFamily>[
        fileRepositoryProvider,
        activeServerIdProvider,
        storageServiceProvider,
        appLocalizationsProvider,
      ],
      allTransitiveDependencies: <ProviderOrFamily>{
        fileRepositoryProvider,
        ...?fileRepositoryProvider.allTransitiveDependencies,
        activeServerIdProvider,
        ...?activeServerIdProvider.allTransitiveDependencies,
        storageServiceProvider,
        ...?storageServiceProvider.allTransitiveDependencies,
        appLocalizationsProvider,
        ...?appLocalizationsProvider.allTransitiveDependencies,
      },
    );

typedef _$FilesController = AutoDisposeAsyncNotifier<FilesViewState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
