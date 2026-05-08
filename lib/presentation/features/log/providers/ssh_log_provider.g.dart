// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ssh_log_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$sshLogControllerHash() => r'adb05a6b3e6380a8ead60e126e8859c0f6c592dc';

/// See also [SshLogController].
@ProviderFor(SshLogController)
final sshLogControllerProvider =
    AutoDisposeAsyncNotifierProvider<SshLogController, SshLogState>.internal(
  SshLogController.new,
  name: r'sshLogControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$sshLogControllerHash,
  dependencies: <ProviderOrFamily>[logRepositoryProvider],
  allTransitiveDependencies: <ProviderOrFamily>{
    logRepositoryProvider,
    ...?logRepositoryProvider.allTransitiveDependencies
  },
);

typedef _$SshLogController = AutoDisposeAsyncNotifier<SshLogState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
