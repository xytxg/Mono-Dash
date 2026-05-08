import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../data/repositories_impl/log_repository_impl.dart';
import '../models/task_log_state.dart';

part 'task_log_provider.g.dart';

@Riverpod(dependencies: [logRepository])
class TaskLogController extends _$TaskLogController {
  @override
  FutureOr<TaskLogState> build() async {
    final repo = await ref.watch(logRepositoryProvider.future);
    final data = await repo.searchTaskLogs(page: 1, pageSize: 20);
    return TaskLogState(items: data.items, total: data.total);
  }

  Future<void> refresh() async {
    state = await AsyncValue.guard(() async {
      final repo = await ref.read(logRepositoryProvider.future);
      final current = state.valueOrNull ?? const TaskLogState();
      final data = await repo.searchTaskLogs(
        page: 1,
        pageSize: current.pageSize,
        status: current.statusFilter,
      );
      return current.copyWith(items: data.items, page: 1, total: data.total);
    });
  }

  void filterByStatus(String status) {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncValue.data(current.copyWith(statusFilter: status));
    refresh();
  }

  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || current.isLoadingMore || !current.hasMore) return;

    state = AsyncValue.data(current.copyWith(isLoadingMore: true));

    try {
      final repo = await ref.read(logRepositoryProvider.future);
      final nextPage = current.page + 1;
      final data = await repo.searchTaskLogs(
        page: nextPage,
        pageSize: current.pageSize,
        status: current.statusFilter,
      );

      final updated = state.valueOrNull;
      if (updated == null) return;

      state = AsyncValue.data(
        updated.copyWith(
          items: [...updated.items, ...data.items],
          page: nextPage,
          total: data.total,
          isLoadingMore: false,
        ),
      );
    } catch (e, st) {
      final updated = state.valueOrNull;
      if (updated != null) {
        state = AsyncValue.data(updated.copyWith(isLoadingMore: false));
      }
      state = AsyncValue.error(e, st);
    }
  }
}
