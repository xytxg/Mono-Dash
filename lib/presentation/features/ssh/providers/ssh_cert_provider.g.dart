// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ssh_cert_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$sshCertControllerHash() => r'49bbe0115f182720080bbbf6bb519758d3617ff4';

/// See also [SshCertController].
@ProviderFor(SshCertController)
final sshCertControllerProvider =
    AutoDisposeAsyncNotifierProvider<
      SshCertController,
      List<SshCertDto>
    >.internal(
      SshCertController.new,
      name: r'sshCertControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$sshCertControllerHash,
      dependencies: <ProviderOrFamily>[activeServerIdProvider],
      allTransitiveDependencies: <ProviderOrFamily>{
        activeServerIdProvider,
        ...?activeServerIdProvider.allTransitiveDependencies,
      },
    );

typedef _$SshCertController = AutoDisposeAsyncNotifier<List<SshCertDto>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
