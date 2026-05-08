// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ssh_info_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$sshInfoControllerHash() => r'c7c7534fa6801757f62f9df9fee2756a895bfd58';

/// See also [SshInfoController].
@ProviderFor(SshInfoController)
final sshInfoControllerProvider =
    AutoDisposeAsyncNotifierProvider<SshInfoController, SshInfoDto>.internal(
      SshInfoController.new,
      name: r'sshInfoControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$sshInfoControllerHash,
      dependencies: <ProviderOrFamily>[activeServerIdProvider],
      allTransitiveDependencies: <ProviderOrFamily>{
        activeServerIdProvider,
        ...?activeServerIdProvider.allTransitiveDependencies,
      },
    );

typedef _$SshInfoController = AutoDisposeAsyncNotifier<SshInfoDto>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
