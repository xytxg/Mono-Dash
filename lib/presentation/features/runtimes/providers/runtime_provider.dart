import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/localization/l10n_x.dart';
import '../../../../core/localization/locale_controller.dart';
import '../../../../core/utils/debouncer.dart';
import '../../../../data/repositories_impl/runtime_repository_impl.dart';
import '../../../common/app_toast.dart';
import '../../../common/components/frosted_dialog.dart';
import '../models/runtime_state.dart';

part 'runtime_provider.g.dart';

const runtimeTypes = ['php', 'java', 'node', 'go', 'python', 'dotnet'];

@Riverpod(dependencies: [runtimeRepository])
class RuntimeController extends _$RuntimeController {
  final _searchDebounce = Debouncer();

  @override
  FutureOr<RuntimeState> build() async {
    final repo = await ref.watch(runtimeRepositoryProvider.future);
    await repo.syncRuntimes();

    // 初始仅加载“全部”。
    final data = await repo.searchRuntimes({
      'page': 1,
      'pageSize': 20,
      'type': '',
    });

    final typeStates = <String, RuntimeTypeState>{
      '': RuntimeTypeState(
        items: data.items,
        page: 1,
        total: data.total,
        isInitialized: true,
      ),
    };

    // 其他类型保持未初始化状态。
    for (final type in runtimeTypes) {
      typeStates[type] = const RuntimeTypeState();
    }

    return RuntimeState(typeStates: typeStates);
  }

  /// 懒加载指定类型的数据。
  Future<void> loadType(String type) async {
    final current = state.valueOrNull;
    if (current == null) return;

    final ts = current.typeStates[type];
    // 已加载过的类型不重复请求；空结果也算已初始化。
    if (ts == null || ts.isInitialized || ts.isLoading) {
      return;
    }

    state = AsyncValue.data(
      current.updateType(type, (ts) => ts.copyWith(isLoading: true)),
    );

    try {
      final repo = await ref.read(runtimeRepositoryProvider.future);
      final data = await repo.searchRuntimes({
        'page': 1,
        'pageSize': current.pageSize,
        'type': type,
      });

      final updated = state.valueOrNull;
      if (updated == null) return;

      state = AsyncValue.data(
        updated.updateType(
          type,
          (ts) => ts.copyWith(
            items: data.items,
            page: 1,
            total: data.total,
            isLoading: false,
            isInitialized: true,
          ),
        ),
      );
    } catch (e, st) {
      final updated = state.valueOrNull;
      if (updated != null) {
        state = AsyncValue.data(
          updated.updateType(type, (ts) => ts.copyWith(isLoading: false)),
        );
      }
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refresh() async {
    state = await AsyncValue.guard(() async {
      final repo = await ref.read(runtimeRepositoryProvider.future);
      final current = state.valueOrNull ?? const RuntimeState();
      final pageSize = current.pageSize;

      // 仅刷新已初始化的类型。
      final initializedTypes = current.typeStates.entries
          .where((e) => current.searchQuery.isEmpty && e.value.isInitialized)
          .map((e) => e.key)
          .toList();
      if (current.searchQuery.isNotEmpty) {
        initializedTypes.add('');
      }

      final results = await Future.wait(
        initializedTypes.map(
          (type) => repo.searchRuntimes({
            'page': 1,
            'pageSize': pageSize,
            'type': type,
            if (current.searchQuery.isNotEmpty && type.isEmpty)
              'name': current.searchQuery,
          }),
        ),
      );

      final typeStates = Map<String, RuntimeTypeState>.from(current.typeStates);
      for (var i = 0; i < initializedTypes.length; i++) {
        final type = initializedTypes[i];
        final data = results[i];
        typeStates[type] = RuntimeTypeState(
          items: data.items,
          page: 1,
          total: data.total,
          isInitialized: true,
        );
      }

      return RuntimeState(
        typeStates: typeStates,
        pageSize: pageSize,
        searchQuery: current.searchQuery,
      );
    });
  }

  void search(String query) {
    _searchDebounce(() {
      final current = state.valueOrNull;
      if (current == null) return;

      final trimmed = query.trim();
      state = AsyncValue.data(current.copyWith(searchQuery: trimmed));
      refresh();
    });
  }

  Future<void> loadMore({String? type}) async {
    final current = state.valueOrNull;
    if (current == null) return;

    final targetType = type ?? '';
    final ts = current.typeStates[targetType];
    if (ts == null || ts.isLoading || ts.isLoadingMore || !ts.hasMore) return;

    await _loadMoreType(targetType, current);
  }

  Future<void> _loadMoreType(String targetType, RuntimeState current) async {
    // 标记该类型正在加载更多。
    state = AsyncValue.data(
      current.updateType(targetType, (ts) => ts.copyWith(isLoadingMore: true)),
    );

    try {
      final repo = await ref.read(runtimeRepositoryProvider.future);
      final ts = current.typeStates[targetType]!;
      final nextPage = ts.page + 1;

      final data = await repo.searchRuntimes({
        'page': nextPage,
        'pageSize': current.pageSize,
        'type': targetType,
        if (current.searchQuery.isNotEmpty && targetType.isEmpty)
          'name': current.searchQuery,
      });

      final updated = state.valueOrNull;
      if (updated == null) return;

      state = AsyncValue.data(
        updated.updateType(
          targetType,
          (ts) => ts.copyWith(
            items: [...ts.items, ...data.items],
            page: nextPage,
            total: data.total,
            isLoadingMore: false,
            isInitialized: true,
          ),
        ),
      );
    } catch (e, st) {
      // 恢复 loadingMore 状态。
      final updated = state.valueOrNull;
      if (updated != null) {
        state = AsyncValue.data(
          updated.updateType(
            targetType,
            (ts) => ts.copyWith(isLoadingMore: false),
          ),
        );
      }
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> operate(BuildContext context, int id, String operate) async {
    final l10n = context.l10n;
    final labels = {
      'up': l10n.runtime_start,
      'down': l10n.runtime_stop,
      'restart': l10n.runtime_restart,
    };
    final label = labels[operate] ?? operate;

    final confirmed = await showFrostedConfirmDialog(
      context,
      title: context.l10n.runtime_operateTitle(label),
      icon: operate == 'up'
          ? TablerIcons.player_play
          : operate == 'down'
          ? TablerIcons.player_stop
          : TablerIcons.refresh,
      content: context.l10n.runtime_operateContent(label),
    );

    if (confirmed != true) return;

    try {
      final repo = await ref.read(runtimeRepositoryProvider.future);
      await repo.operateRuntime(id, operate);
      showAppSuccessToast(l10n.runtime_operationSucceeded(label));
      refresh();
    } catch (e) {
      showAppErrorToast(
        l10n.runtime_operationFailed(label),
        description: e.toString(),
      );
    }
  }

  Future<void> delete(int id) async {
    try {
      final repo = await ref.read(runtimeRepositoryProvider.future);
      await repo.deleteRuntime(id, forceDelete: true);
      showAppSuccessToast(
        ref.read(appLocalizationsProvider).runtime_deleteSucceeded,
      );
      refresh();
    } catch (e) {
      showAppErrorToast(
        ref.read(appLocalizationsProvider).runtime_deleteFailed,
        description: e.toString(),
      );
    }
  }
}
