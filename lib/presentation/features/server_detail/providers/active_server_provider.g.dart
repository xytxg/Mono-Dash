// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'active_server_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$activeServerIdHash() => r'4756066804bad97db41795475290f9dc6248b647';

/// 当前激活服务器的 id。
///
/// 在 `ServerDetailPage` 入口通过 `ProviderScope.overrides` 注入，
/// 子树内任意 Tab / Provider 可 `ref.watch(activeServerIdProvider)` 获取。
///
/// Copied from [activeServerId].
@ProviderFor(activeServerId)
final activeServerIdProvider = Provider<int>.internal(
  activeServerId,
  name: r'activeServerIdProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$activeServerIdHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef ActiveServerIdRef = ProviderRef<int>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
