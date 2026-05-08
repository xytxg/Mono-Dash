import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/locale_controller.dart';
import '../../../../core/network/network_exceptions.dart';
import '../../../../data/dto/app/app_installed_dto.dart';
import '../../../../data/dto/app/app_installed_search_req.dart';
import '../../../../data/repositories_impl/app_repository_impl.dart';
import '../../../../data/repositories_impl/container_repository_impl.dart';
import '../../../common/app_toast.dart';
import '../models/app_store_state.dart';

final appStoreControllerProvider =
    AsyncNotifierProvider<AppStoreController, AppStoreState>(
      AppStoreController.new,
      dependencies: [containerRepositoryProvider, appRepositoryProvider],
    );

final appIconProvider = FutureProvider.family<Uint8List, String>((
  ref,
  appName,
) async {
  final repo = await ref.watch(appRepositoryProvider.future);
  return AppIconCache.instance.get(appName, repo.getAppIcon);
}, dependencies: [appRepositoryProvider]);

class AppIconCache {
  AppIconCache._();

  static final instance = AppIconCache._();

  final Map<String, Future<Uint8List>> _pending = {};
  final Map<String, Uint8List> _completed = {};

  Future<Uint8List> get(
    String iconRef,
    Future<Uint8List> Function(String iconRef) fetch,
  ) {
    final key = normalizeKey(iconRef);
    final cached = _completed[key];
    if (cached != null) return Future.value(cached);

    final pending = _pending[key];
    if (pending != null) return pending;

    final request = fetch(iconRef)
        .then((bytes) {
          _completed[key] = bytes;
          _pending.remove(key);
          return bytes;
        })
        .catchError((Object error) {
          _pending.remove(key);
          throw error;
        });
    _pending[key] = request;
    return request;
  }

  String normalizeKey(String iconRef) {
    final raw = iconRef.trim();
    final uri = Uri.tryParse(raw);
    if (uri != null && uri.hasScheme && uri.host.isNotEmpty) {
      return uri.path.isEmpty ? raw : uri.path;
    }
    return raw;
  }

  void clear() {
    _pending.clear();
    _completed.clear();
  }
}

/// 用于同步更新页面的搜索关键词。
final updateSearchQueryProvider = StateProvider.autoDispose<String>(
  (ref) => '',
);

class AppStoreController extends AsyncNotifier<AppStoreState> {
  static const _pageSize = 20;
  static const _statusPollMaxPageSize = 100;

  Timer? _statusTimer;
  int _searchGeneration = 0;

  @override
  Future<AppStoreState> build() {
    ref.onDispose(() => _statusTimer?.cancel());
    return _load(searchName: '');
  }

  Future<AppStoreState> _load({required String searchName}) async {
    final containerRepo = await ref.read(containerRepositoryProvider.future);
    final appRepo = await ref.read(appRepositoryProvider.future);

    final dockerStatus = await containerRepo.getDockerStatus();
    final installed = await appRepo.searchInstalledApps(
      AppInstalledSearchReq(page: 1, pageSize: _pageSize, name: searchName),
    );

    // 额外检查是否有可升级的应用（用于显示红点）
    final updates = await appRepo.searchInstalledApps(
      const AppInstalledSearchReq(page: 1, pageSize: 1, update: true),
    );

    return AppStoreState(
      dockerStatus: dockerStatus,
      installedApps: installed.items,
      total: installed.total,
      hasMore: installed.items.length >= _pageSize,
      isLoadingMore: false,
      searchName: searchName,
      hasAvailableUpdates: updates.total > 0,
    );
  }

  /// 静默拉取已展示条目的最新状态（用于 Rebuilding 轮询，失败不弹 Toast）。
  Future<void> syncInstalledAppsStatusQuietly() async {
    final current = state.valueOrNull;
    if (current == null || current.installedApps.isEmpty) return;

    final pageSize = current.installedApps.length.clamp(
      1,
      _statusPollMaxPageSize,
    );
    try {
      final appRepo = await ref.read(appRepositoryProvider.future);
      final result = await appRepo.searchInstalledApps(
        AppInstalledSearchReq(
          page: 1,
          pageSize: pageSize,
          sync: true,
          name: current.searchName,
        ),
      );
      final byId = {for (final a in result.items) a.id: a};
      final merged = current.installedApps
          .map((e) => byId[e.id] ?? e)
          .toList(growable: false);
      state = AsyncData(current.copyWith(installedApps: merged));
    } catch (_) {}
  }

  void _syncTimer() {
    final current = state.valueOrNull;
    if (current == null) return;

    final hasRebuilding = current.installedApps.any(
      (a) => a.status.toLowerCase() == 'rebuilding',
    );

    if (hasRebuilding && _statusTimer == null) {
      _statusTimer = Timer.periodic(const Duration(seconds: 5), (_) {
        syncInstalledAppsStatusQuietly();
      });
    } else if (!hasRebuilding && _statusTimer != null) {
      _statusTimer?.cancel();
      _statusTimer = null;
    }
  }

  @override
  set state(AsyncValue<AppStoreState> newState) {
    super.state = newState;
    _syncTimer();
  }

  Future<void> refresh() async {
    final previous = state.valueOrNull;
    final search = previous?.searchName ?? '';
    final nextState = await AsyncValue.guard(() => _load(searchName: search));
    if (nextState.hasError && previous != null) {
      state = AsyncData(previous);
      _showRefreshError(nextState.error);
      return;
    }
    state = nextState;
  }

  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || current.isLoadingMore || !current.hasMore) return;

    state = AsyncData(current.copyWith(isLoadingMore: true));
    final nextPage = current.installedApps.length ~/ _pageSize + 1;

    try {
      final appRepo = await ref.read(appRepositoryProvider.future);
      final result = await appRepo.searchInstalledApps(
        AppInstalledSearchReq(
          page: nextPage,
          pageSize: _pageSize,
          name: current.searchName,
        ),
      );
      final apps = [...current.installedApps, ...result.items];
      state = AsyncData(
        current.copyWith(
          installedApps: apps,
          total: result.total,
          hasMore: result.items.length >= _pageSize,
          isLoadingMore: false,
        ),
      );
    } catch (error) {
      state = AsyncData(current.copyWith(isLoadingMore: false));
      final message = switch (error) {
        AppNetworkException(:final message) => message,
        _ => ref.read(appLocalizationsProvider).appStore_loadMoreFailed,
      };
      showAppErrorToast(message);
    }
  }

  Future<void> search(String name) async {
    final current = state.valueOrNull;
    if (current != null && current.searchName == name) return;

    if (current == null) {
      state = await AsyncValue.guard(() => _load(searchName: name));
      return;
    }

    final generation = ++_searchGeneration;
    state = AsyncData(current.copyWith(searchName: name, isLoadingMore: false));

    try {
      final appRepo = await ref.read(appRepositoryProvider.future);
      final result = await appRepo.searchInstalledApps(
        AppInstalledSearchReq(page: 1, pageSize: _pageSize, name: name),
      );
      if (generation != _searchGeneration) return;

      final latest = state.valueOrNull;
      if (latest == null) return;
      state = AsyncData(
        latest.copyWith(
          installedApps: result.items,
          total: result.total,
          hasMore: result.items.length >= _pageSize,
          isLoadingMore: false,
          searchName: name,
        ),
      );
    } catch (error) {
      if (generation != _searchGeneration) return;
      state = AsyncData(current);
      final message = switch (error) {
        AppNetworkException(:final message) => message,
        _ => ref.read(appLocalizationsProvider).appStore_searchFailed,
      };
      showAppErrorToast(message);
    }
  }

  /// 切换已安装应用收藏状态。
  Future<void> toggleInstalledFavorite(AppInstalledDto app) async {
    final current = state.valueOrNull;
    if (current == null) return;

    final nextFavorite = !app.favorite;
    try {
      final repo = await ref.read(appRepositoryProvider.future);
      await repo.operateInstalled(
        installId: app.id,
        detailId: app.appDetailId,
        favorite: nextFavorite,
      );
      final updated = current.installedApps
          .map((e) => e.id == app.id ? e.copyWith(favorite: nextFavorite) : e)
          .toList(growable: false);
      state = AsyncData(current.copyWith(installedApps: updated));
      final l10n = ref.read(appLocalizationsProvider);
      showAppToast(
        nextFavorite
            ? l10n.appStore_addedFavorite
            : l10n.appStore_removedFavorite,
      );
    } catch (error) {
      final message = switch (error) {
        AppNetworkException(:final message) => message,
        _ => ref.read(appLocalizationsProvider).appStore_operationFailed,
      };
      showAppErrorToast(message);
    }
  }

  /// 重建已安装应用；成功后刷新列表（sync 与首页一致，状态可能变为 Rebuilding）。
  Future<void> rebuildInstalledApp(AppInstalledDto app) async {
    try {
      final repo = await ref.read(appRepositoryProvider.future);
      await repo.rebuildInstalled(installId: app.id, detailId: app.appDetailId);
      showAppToast(
        ref.read(appLocalizationsProvider).appStore_rebuildStarted,
        description: app.displayName,
      );
      await refresh();
    } catch (error) {
      final message = switch (error) {
        AppNetworkException(:final message) => message,
        _ => ref.read(appLocalizationsProvider).appStore_rebuildFailed,
      };
      showAppErrorToast(message);
    }
  }

  Future<void> restartInstalledApp(AppInstalledDto app) async {
    try {
      final repo = await ref.read(appRepositoryProvider.future);
      await repo.restartInstalled(installId: app.id, detailId: app.appDetailId);
      showAppToast(
        ref.read(appLocalizationsProvider).appStore_restartSent,
        description: app.displayName,
      );
      await refresh();
    } catch (error) {
      final message = switch (error) {
        AppNetworkException(:final message) => message,
        _ => ref.read(appLocalizationsProvider).appStore_restartFailed,
      };
      showAppErrorToast(message);
    }
  }

  Future<void> stopInstalledApp(AppInstalledDto app) async {
    try {
      final repo = await ref.read(appRepositoryProvider.future);
      await repo.stopInstalled(installId: app.id, detailId: app.appDetailId);
      showAppToast(
        ref.read(appLocalizationsProvider).appStore_stopSent,
        description: app.displayName,
      );
      await refresh();
    } catch (error) {
      final message = switch (error) {
        AppNetworkException(:final message) => message,
        _ => ref.read(appLocalizationsProvider).appStore_stopFailed,
      };
      showAppErrorToast(message);
    }
  }

  Future<void> startInstalledApp(AppInstalledDto app) async {
    try {
      final repo = await ref.read(appRepositoryProvider.future);
      await repo.startInstalled(installId: app.id, detailId: app.appDetailId);
      showAppToast(
        ref.read(appLocalizationsProvider).appStore_startSent,
        description: app.displayName,
      );
      await refresh();
    } catch (error) {
      final message = switch (error) {
        AppNetworkException(:final message) => message,
        _ => ref.read(appLocalizationsProvider).appStore_startFailed,
      };
      showAppErrorToast(message);
    }
  }

  Future<void> syncRemoteApps(String taskID) async {
    final repo = await ref.read(appRepositoryProvider.future);
    final msg = await repo.syncRemoteApps(taskID);
    if (msg != null && msg.isNotEmpty) {
      showAppToast(msg);
    }
    await refresh();
  }

  Future<void> syncLocalApps(String taskID) async {
    final repo = await ref.read(appRepositoryProvider.future);
    await repo.syncLocalApps(taskID);
    await refresh();
  }

  void _showRefreshError(Object? error) {
    final message = switch (error) {
      AppNetworkException(:final message) => message,
      _ => ref.read(appLocalizationsProvider).appStore_refreshFailed,
    };
    showAppErrorToast(message);
  }
}
