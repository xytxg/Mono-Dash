// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'file_shares_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$fileSharesControllerHash() =>
    r'c656ee2e19a06b383b2ed3bcaf7bc559702a27fe';

/// See also [FileSharesController].
@ProviderFor(FileSharesController)
final fileSharesControllerProvider =
    AutoDisposeAsyncNotifierProvider<
      FileSharesController,
      List<FileShareDto>
    >.internal(
      FileSharesController.new,
      name: r'fileSharesControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$fileSharesControllerHash,
      dependencies: <ProviderOrFamily>[
        fileRepositoryProvider,
        appLocalizationsProvider,
      ],
      allTransitiveDependencies: <ProviderOrFamily>{
        fileRepositoryProvider,
        ...?fileRepositoryProvider.allTransitiveDependencies,
        appLocalizationsProvider,
        ...?appLocalizationsProvider.allTransitiveDependencies,
      },
    );

typedef _$FileSharesController = AutoDisposeAsyncNotifier<List<FileShareDto>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
