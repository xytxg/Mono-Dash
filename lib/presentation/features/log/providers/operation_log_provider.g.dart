// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'operation_log_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$operationLogControllerHash() =>
    r'de3fcfde4ed3f05fd39e3c8147e9f0d2c2e139fd';

/// See also [OperationLogController].
@ProviderFor(OperationLogController)
final operationLogControllerProvider = AutoDisposeAsyncNotifierProvider<
    OperationLogController, OperationLogState>.internal(
  OperationLogController.new,
  name: r'operationLogControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$operationLogControllerHash,
  dependencies: <ProviderOrFamily>[logRepositoryProvider],
  allTransitiveDependencies: <ProviderOrFamily>{
    logRepositoryProvider,
    ...?logRepositoryProvider.allTransitiveDependencies
  },
);

typedef _$OperationLogController = AutoDisposeAsyncNotifier<OperationLogState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
