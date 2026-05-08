import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'active_server_provider.g.dart';

/// 当前激活服务器的 id。
///
/// 在 `ServerDetailPage` 入口通过 `ProviderScope.overrides` 注入，
/// 子树内任意 Tab / Provider 可 `ref.watch(activeServerIdProvider)` 获取。
@Riverpod(keepAlive: true)
int activeServerId(Ref ref) => throw UnimplementedError(
  'activeServerIdProvider must be overridden at the ServerDetailPage entry',
);
