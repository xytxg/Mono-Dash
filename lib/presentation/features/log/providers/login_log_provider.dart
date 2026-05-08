import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/localization/locale_controller.dart';
import '../../../../core/utils/debouncer.dart';
import '../../../../data/repositories_impl/log_repository_impl.dart';
import '../../../common/app_toast.dart';
import '../models/login_log_state.dart';

part 'login_log_provider.g.dart';

@Riverpod(dependencies: [logRepository])
class LoginLogController extends _$LoginLogController {
  final _searchDebounce = Debouncer();

  @override
  FutureOr<LoginLogState> build() async {
    final repo = await ref.watch(logRepositoryProvider.future);
    final data = await repo.searchLoginLogs(page: 1, pageSize: 20);
    return LoginLogState(items: data.items, total: data.total);
  }

  Future<void> refresh() async {
    state = await AsyncValue.guard(() async {
      final repo = await ref.read(logRepositoryProvider.future);
      final current = state.valueOrNull ?? const LoginLogState();
      final data = await repo.searchLoginLogs(
        page: 1,
        pageSize: current.pageSize,
        ip: current.ipSearch,
        status: current.statusFilter,
      );
      return current.copyWith(items: data.items, page: 1, total: data.total);
    });
  }

  void searchByIp(String ip) {
    _searchDebounce(() {
      final current = state.valueOrNull;
      if (current == null) return;
      state = AsyncValue.data(current.copyWith(ipSearch: ip.trim()));
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
      final data = await repo.searchLoginLogs(
        page: nextPage,
        pageSize: current.pageSize,
        ip: current.ipSearch,
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

  Future<bool> cleanLogs() async {
    try {
      final repo = await ref.read(logRepositoryProvider.future);
      await repo.cleanLogs('login');
      showAppSuccessToast(ref.read(appLocalizationsProvider).log_loginCleared);
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
