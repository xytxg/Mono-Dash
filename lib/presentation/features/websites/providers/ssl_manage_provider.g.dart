// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ssl_manage_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$sslManageControllerHash() =>
    r'ffc8f3bcdde7cbd66a633089dd368d4c93f824e0';

/// See also [SslManageController].
@ProviderFor(SslManageController)
final sslManageControllerProvider = AutoDisposeAsyncNotifierProvider<
    SslManageController, SslManageState>.internal(
  SslManageController.new,
  name: r'sslManageControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$sslManageControllerHash,
  dependencies: <ProviderOrFamily>[websiteRepositoryProvider],
  allTransitiveDependencies: <ProviderOrFamily>{
    websiteRepositoryProvider,
    ...?websiteRepositoryProvider.allTransitiveDependencies
  },
);

typedef _$SslManageController = AutoDisposeAsyncNotifier<SslManageState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
