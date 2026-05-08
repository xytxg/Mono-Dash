// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_log_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$loginLogControllerHash() =>
    r'648fb0da3dffac7755b32e779ab37178b67a30c5';

/// See also [LoginLogController].
@ProviderFor(LoginLogController)
final loginLogControllerProvider = AutoDisposeAsyncNotifierProvider<
    LoginLogController, LoginLogState>.internal(
  LoginLogController.new,
  name: r'loginLogControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$loginLogControllerHash,
  dependencies: <ProviderOrFamily>[logRepositoryProvider],
  allTransitiveDependencies: <ProviderOrFamily>{
    logRepositoryProvider,
    ...?logRepositoryProvider.allTransitiveDependencies
  },
);

typedef _$LoginLogController = AutoDisposeAsyncNotifier<LoginLogState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
