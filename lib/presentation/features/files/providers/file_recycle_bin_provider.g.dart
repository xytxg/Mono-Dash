// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'file_recycle_bin_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$fileRecycleBinControllerHash() =>
    r'294850fd8f2b2021efd613bbf4b323fc28bb6376';

/// See also [FileRecycleBinController].
@ProviderFor(FileRecycleBinController)
final fileRecycleBinControllerProvider =
    AutoDisposeAsyncNotifierProvider<
      FileRecycleBinController,
      List<RecycleBinDto>
    >.internal(
      FileRecycleBinController.new,
      name: r'fileRecycleBinControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$fileRecycleBinControllerHash,
      dependencies: <ProviderOrFamily>[
        fileRepositoryProvider,
        settingRepositoryProvider,
        appLocalizationsProvider,
      ],
      allTransitiveDependencies: <ProviderOrFamily>{
        fileRepositoryProvider,
        ...?fileRepositoryProvider.allTransitiveDependencies,
        settingRepositoryProvider,
        ...?settingRepositoryProvider.allTransitiveDependencies,
        appLocalizationsProvider,
        ...?appLocalizationsProvider.allTransitiveDependencies,
      },
    );

typedef _$FileRecycleBinController =
    AutoDisposeAsyncNotifier<List<RecycleBinDto>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
