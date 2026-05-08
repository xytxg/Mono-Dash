import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/localization/locale_controller.dart';
import '../../../../data/dto/file/file_share_dto.dart';
import '../../../../data/repositories_impl/file_repository_impl.dart';
import '../../../common/app_toast.dart';

part 'file_shares_provider.g.dart';

@Riverpod(dependencies: [fileRepository, appLocalizations])
class FileSharesController extends _$FileSharesController {
  @override
  Future<List<FileShareDto>> build() async {
    return _fetchShares(1);
  }

  int _currentPage = 1;
  int _totalCount = 0;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  bool get hasMore => _hasMore;
  bool get isLoadingMore => _isLoadingMore;

  Future<List<FileShareDto>> _fetchShares(int page) async {
    final repo = await ref.read(fileRepositoryProvider.future);
    final result = await repo.searchFileShares(page: page, pageSize: 20);

    final rawItems = result['items'];
    if (rawItems == null) return [];

    final items = (rawItems as List)
        .map((e) => FileShareDto.fromJson(e as Map<String, dynamic>))
        .toList();
    _totalCount = result['total'] as int? ?? 0;
    _hasMore = items.length >= 20;
    return items;
  }

  Future<void> loadMore() async {
    if (_isLoadingMore || !_hasMore) return;

    _isLoadingMore = true;
    try {
      final nextPage = _currentPage + 1;
      final newItems = await _fetchShares(nextPage);

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

  Future<void> deleteShare(String path) async {
    try {
      final repo = await ref.read(fileRepositoryProvider.future);
      await repo.deleteFileShare(path);

      final currentItems = state.valueOrNull ?? [];
      state = AsyncData(currentItems.where((i) => i.path != path).toList());
      showAppSuccessToast(
        ref.read(appLocalizationsProvider).files_shareCancelSuccess,
      );
    } catch (e) {
      showAppErrorToast(
        ref.read(appLocalizationsProvider).files_shareCancelFailed,
      );
    }
  }

  Future<void> refresh() async {
    _currentPage = 1;
    // 不再手动设置 AsyncLoading，以实现无感刷新
    final newState = await AsyncValue.guard(() => _fetchShares(1));
    state = newState;
  }
}
