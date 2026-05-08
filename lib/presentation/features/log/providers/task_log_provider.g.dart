// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_log_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$taskLogControllerHash() => r'9dcddba340c318956dbfb63a88bf1ebe6b7ba6bb';

/// See also [TaskLogController].
@ProviderFor(TaskLogController)
final taskLogControllerProvider =
    AutoDisposeAsyncNotifierProvider<TaskLogController, TaskLogState>.internal(
  TaskLogController.new,
  name: r'taskLogControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$taskLogControllerHash,
  dependencies: <ProviderOrFamily>[logRepositoryProvider],
  allTransitiveDependencies: <ProviderOrFamily>{
    logRepositoryProvider,
    ...?logRepositoryProvider.allTransitiveDependencies
  },
);

typedef _$TaskLogController = AutoDisposeAsyncNotifier<TaskLogState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
