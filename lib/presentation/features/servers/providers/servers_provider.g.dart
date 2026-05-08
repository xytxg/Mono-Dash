// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'servers_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$serversNotifierHash() => r'a89b4aa208dc7b4b77a2c6d26f224c67f93a537c';

/// 面板列表状态。
///
/// 只负责持久化与展示，连通性测试通过 [HostApi.getOsInfo] 走真实 API，
/// 验证 MD5 鉴权链路是否通畅。
///
/// Copied from [ServersNotifier].
@ProviderFor(ServersNotifier)
final serversNotifierProvider =
    AutoDisposeAsyncNotifierProvider<ServersNotifier, List<Server>>.internal(
  ServersNotifier.new,
  name: r'serversNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$serversNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ServersNotifier = AutoDisposeAsyncNotifier<List<Server>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
