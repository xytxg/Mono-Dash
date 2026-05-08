import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/localization/locale_controller.dart';
import '../../../../core/utils/debouncer.dart';
import '../../../../data/repositories_impl/log_repository_impl.dart';
import '../../../common/app_toast.dart';
import '../models/operation_log_state.dart';

part 'operation_log_provider.g.dart';

@Riverpod(dependencies: [logRepository])
class OperationLogController extends _$OperationLogController {
  final _searchDebounce = Debouncer();

  @override
  FutureOr<OperationLogState> build() async {
    final repo = await ref.watch(logRepositoryProvider.future);
    final data = await repo.searchOperationLogs(page: 1, pageSize: 20);
    return OperationLogState(items: data.items, total: data.total);
  }

  Future<void> refresh() async {
    state = await AsyncValue.guard(() async {
      final repo = await ref.read(logRepositoryProvider.future);
      final current = state.valueOrNull ?? const OperationLogState();
      final data = await repo.searchOperationLogs(
        page: 1,
        pageSize: current.pageSize,
        source: current.sourceFilter,
        status: current.statusFilter,
        operation: current.searchQuery,
      );
      return current.copyWith(items: data.items, page: 1, total: data.total);
    });
  }

  void search(String query) {
    _searchDebounce(() {
      final current = state.valueOrNull;
      if (current == null) return;
      state = AsyncValue.data(current.copyWith(searchQuery: query.trim()));
      refresh();
    });
  }

  void filterBySource(String source) {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncValue.data(current.copyWith(sourceFilter: source));
    refresh();
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
      final data = await repo.searchOperationLogs(
        page: nextPage,
        pageSize: current.pageSize,
        source: current.sourceFilter,
        status: current.statusFilter,
        operation: current.searchQuery,
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

  Future<bool> cleanLogs() async {
    try {
      final repo = await ref.read(logRepositoryProvider.future);
      await repo.cleanLogs('operation');
      showAppSuccessToast(
        ref.read(appLocalizationsProvider).log_operationCleared,
      );
      refresh();
      return true;
    } catch (e) {
      showAppErrorToast(
        ref.read(appLocalizationsProvider).log_clearFailed,
        description: e.toString(),
      );
      return false;
    }
  }
}
