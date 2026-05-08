// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'runtime_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$runtimeControllerHash() => r'd762d67bc5289b0583d3ea9ae4254df17b28956b';

/// See also [RuntimeController].
@ProviderFor(RuntimeController)
final runtimeControllerProvider =
    AutoDisposeAsyncNotifierProvider<RuntimeController, RuntimeState>.internal(
      RuntimeController.new,
      name: r'runtimeControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$runtimeControllerHash,
      dependencies: <ProviderOrFamily>[runtimeRepositoryProvider],
      allTransitiveDependencies: <ProviderOrFamily>{
        runtimeRepositoryProvider,
        ...?runtimeRepositoryProvider.allTransitiveDependencies,
      },
    );

typedef _$RuntimeController = AutoDisposeAsyncNotifier<RuntimeState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
