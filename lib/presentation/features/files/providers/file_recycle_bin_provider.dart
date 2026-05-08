import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../data/dto/file/recycle_bin_dto.dart';
import '../../../../data/repositories_impl/file_repository_impl.dart';
import '../../../../data/repositories_impl/setting_repository_impl.dart';
import '../../../../core/localization/locale_controller.dart';
import '../../../common/app_toast.dart';

part 'file_recycle_bin_provider.g.dart';

@Riverpod(dependencies: [fileRepository, settingRepository, appLocalizations])
class FileRecycleBinController extends _$FileRecycleBinController {
  @override
  Future<List<RecycleBinDto>> build() async {
    return _fetchItems(1);
  }

  int _currentPage = 1;
  bool _hasMore = true;
  bool _isLoadingMore = false;
  String _status = 'Disable';

  bool get hasMore => _hasMore;
  bool get isLoadingMore => _isLoadingMore;
  String get status => _status;

  Future<List<RecycleBinDto>> _fetchItems(int page) async {
    final repo = await ref.read(fileRepositoryProvider.future);

    // 同时获取状态（仅在第一页时）
    if (page == 1) {
      _status = await repo.getRecycleBinStatus();
    }

    final result = await repo.searchRecycleBin(page: page, pageSize: 20);

    final rawItems = result['items'];
    if (rawItems == null) return [];

    final items = (rawItems as List)
        .map((e) => RecycleBinDto.fromJson(e as Map<String, dynamic>))
        .toList();
    _hasMore = items.length >= 20;
    return items;
  }

  Future<void> loadMore() async {
    if (_isLoadingMore || !_hasMore) return;

    _isLoadingMore = true;
    try {
      final nextPage = _currentPage + 1;
      final newItems = await _fetchItems(nextPage);

      final currentItems = state.valueOrNull ?? [];
      state = AsyncData([...currentItems, ...newItems]);
      _currentPage = nextPage;
    } catch (e) {
      showAppErrorToast(
        ref.read(appLocalizationsProvider).files_loadMoreFailed,
      );
    } finally {
      _isLoadingMore = false;
    }
  }

  Future<void> restoreItem(RecycleBinDto item) async {
    try {
      final repo = await ref.read(fileRepositoryProvider.future);
      await repo.restoreRecycleItem(from: item.from, rName: item.rName);

      final currentItems = state.valueOrNull ?? [];
      state = AsyncData(
        currentItems.where((i) => i.rName != item.rName).toList(),
      );
      showAppSuccessToast(
        ref.read(appLocalizationsProvider).files_recycleRestored(item.name),
      );
    } catch (e) {
      showAppErrorToast(
        ref.read(appLocalizationsProvider).files_recycleRestoreFailed,
      );
    }
  }

  Future<void> deleteItem(RecycleBinDto item) async {
    try {
      final repo = await ref.read(fileRepositoryProvider.future);
      // 回收站文件的物理路径是 from + '/' + rName
      final path = '${item.from}/${item.rName}';
      await repo.deleteFile(path: path, isDir: item.isDir, forceDelete: true);

      final currentItems = state.valueOrNull ?? [];
      state = AsyncData(
        currentItems.where((i) => i.rName != item.rName).toList(),
      );
      showAppSuccessToast(
        ref.read(appLocalizationsProvider).files_recycleDeleted(item.name),
      );
    } catch (e) {
      showAppErrorToast(ref.read(appLocalizationsProvider).files_deleteFailed);
    }
  }

  Future<void> clearAll() async {
    try {
      final repo = await ref.read(fileRepositoryProvider.future);
      await repo.clearRecycleBin();

      state = const AsyncData([]);
      showAppSuccessToast(
        ref.read(appLocalizationsProvider).files_recycleClearStarted,
      );

      // 延迟静默刷新以确认结果
      Future.delayed(const Duration(seconds: 2), () => silentRefresh());
    } catch (e) {
      showAppErrorToast(
        ref.read(appLocalizationsProvider).files_recycleClearFailed,
      );
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    _currentPage = 1;
    final newState = await AsyncValue.guard(() => _fetchItems(1));
    state = newState;
  }

  Future<void> silentRefresh() async {
    try {
      _currentPage = 1;
      final newItems = await _fetchItems(1);
      state = AsyncData(newItems);
    } catch (e) {
      // 静默刷新失败不干扰 UI
    }
  }

  Future<void> toggleStatus(bool enabled) async {
    try {
      final repo = await ref.read(settingRepositoryProvider.future);
      final newValue = enabled ? 'Enable' : 'Disable';
      await repo.updateSetting(key: 'FileRecycleBin', value: newValue);
      _status = newValue;
      state = state; // 触发 UI 刷新
      final l10n = ref.read(appLocalizationsProvider);
      showAppSuccessToast(
        enabled ? l10n.files_recycleEnabled : l10n.files_recycleDisabled,
      );
    } catch (e) {
      showAppErrorToast(
        ref.read(appLocalizationsProvider).files_recycleSettingFailed,
      );
    }
  }
}
