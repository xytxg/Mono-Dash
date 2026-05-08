import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/utils/debouncer.dart';
import '../../../../data/repositories_impl/log_repository_impl.dart';
import '../models/ssh_log_state.dart';

part 'ssh_log_provider.g.dart';

@Riverpod(dependencies: [logRepository])
class SshLogController extends _$SshLogController {
  final _searchDebounce = Debouncer();

  @override
  FutureOr<SshLogState> build() async {
    final repo = await ref.watch(logRepositoryProvider.future);
    final data = await repo.searchSshLogs(page: 1, pageSize: 20);
    return SshLogState(items: data.items, total: data.total);
  }

  Future<void> refresh() async {
    state = await AsyncValue.guard(() async {
      final repo = await ref.read(logRepositoryProvider.future);
      final current = state.valueOrNull ?? const SshLogState();
      final data = await repo.searchSshLogs(
        page: 1,
        pageSize: current.pageSize,
        info: current.infoSearch,
        status: current.statusFilter,
      );
      return current.copyWith(items: data.items, page: 1, total: data.total);
    });
  }

  void searchByInfo(String info) {
    _searchDebounce(() {
      final current = state.valueOrNull;
      if (current == null) return;
      state = AsyncValue.data(current.copyWith(infoSearch: info.trim()));
      refresh();
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
      final data = await repo.searchSshLogs(
        page: nextPage,
        pageSize: current.pageSize,
        info: current.infoSearch,
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
