// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'container_compose_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$containerComposeControllerHash() =>
    r'86a86bcc8e36eb7929b77e6f9edc9d762bac155d';

/// See also [ContainerComposeController].
@ProviderFor(ContainerComposeController)
final containerComposeControllerProvider = AutoDisposeAsyncNotifierProvider<
    ContainerComposeController, ContainerComposeState>.internal(
  ContainerComposeController.new,
  name: r'containerComposeControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$containerComposeControllerHash,
  dependencies: <ProviderOrFamily>[containerRepositoryProvider],
  allTransitiveDependencies: <ProviderOrFamily>{
    containerRepositoryProvider,
    ...?containerRepositoryProvider.allTransitiveDependencies
  },
);

typedef _$ContainerComposeController
    = AutoDisposeAsyncNotifier<ContainerComposeState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
