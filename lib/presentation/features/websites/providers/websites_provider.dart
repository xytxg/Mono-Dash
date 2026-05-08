import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/network_exceptions.dart';
import '../../../../data/dto/app/app_installed_check_req.dart';
import '../../../../data/dto/website/website_search_req.dart';
import '../../../../data/repositories_impl/app_repository_impl.dart';
import '../../../../data/repositories_impl/website_repository_impl.dart';
import '../../../common/app_toast.dart';
import '../models/websites_view_state.dart';

part 'websites_provider.g.dart';

@Riverpod(dependencies: [websiteRepository, appRepository])
class WebsitesController extends _$WebsitesController {
  static const int _pageSize = 20;

  @override
  Future<WebsitesViewState> build() async {
    final repo = await ref.watch(websiteRepositoryProvider.future);
    final appRepo = await ref.watch(appRepositoryProvider.future);

    final result = await repo.searchWebsites(
      const WebsiteSearchReq(page: 1, pageSize: _pageSize),
    );
    final groups = await repo.searchWebsiteGroups();

    final appRes = await appRepo.checkAppInstalled(
      const AppInstalledCheckReq(key: 'openresty'),
    );

    return WebsitesViewState(
      websites: result.items,
      groups: groups,
      currentPage: 1,
      hasMore: result.items.length >= _pageSize,
      isLoadingMore: false,
      isCheckingOpenResty: false,
      isOpenRestyInstalled: appRes.isExist,
      openRestyStatus: appRes.status,
      openRestyAppInstallId: appRes.appInstallId,
    );
  }

  Future<void> refresh() async {
    final previous = state.valueOrNull;
    final nextState = await AsyncValue.guard(() async {
      final repo = await ref.read(websiteRepositoryProvider.future);
      final appRepo = await ref.read(appRepositoryProvider.future);

      final result = await repo.searchWebsites(
        const WebsiteSearchReq(page: 1, pageSize: _pageSize),
      );
      final groups = await repo.searchWebsiteGroups();

      final appRes = await appRepo.checkAppInstalled(
        const AppInstalledCheckReq(key: 'openresty'),
      );

      return WebsitesViewState(
        websites: result.items,
        groups: groups,
        currentPage: 1,
        hasMore: result.items.length >= _pageSize,
        isLoadingMore: false,
        isCheckingOpenResty: false,
        isOpenRestyInstalled: appRes.isExist,
        openRestyStatus: appRes.status,
        openRestyAppInstallId: appRes.appInstallId,
      );
    });

    if (nextState.hasError && previous != null) {
      state = AsyncData(previous);
      final error = nextState.error;
      final message = switch (error) {
        AppNetworkException(:final message) => message,
        _ => 'Refresh failed',
      };
      showAppErrorToast(message);
      return;
    }

    state = nextState;
  }

  Future<void> search(String query) async {
    final current = state.valueOrNull;
    if (current == null) return;

    final trimmed = query.trim();
    state = AsyncData(
      current.copyWith(
        searchText: trimmed,
        websites: [],
        currentPage: 1,
        hasMore: true,
        isLoadingMore: false,
      ),
    );

    try {
      final repo = await ref.read(websiteRepositoryProvider.future);
      final result = await repo.searchWebsites(
        WebsiteSearchReq(
          name: trimmed,
          page: 1,
          pageSize: _pageSize,
          orderBy: 'favorite',
          order: 'descending',
        ),
      );

      state = AsyncData(
        current.copyWith(
          websites: result.items,
          searchText: trimmed,
          currentPage: 1,
          hasMore: result.items.length >= _pageSize,
        ),
      );
    } catch (e) {
      state = AsyncData(current.copyWith(searchText: trimmed));
      final message = switch (e) {
        AppNetworkException(:final message) => message,
        _ => 'Search failed',
      };
      showAppErrorToast(message);
    }
  }

  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || current.isLoadingMore || !current.hasMore) return;

    state = AsyncData(current.copyWith(isLoadingMore: true));

    final nextPage = current.currentPage + 1;
    try {
      final repo = await ref.read(websiteRepositoryProvider.future);
      final result = await repo.searchWebsites(
        WebsiteSearchReq(
          name: current.searchText,
          page: nextPage,
          pageSize: _pageSize,
          orderBy: current.searchText.isNotEmpty ? 'favorite' : 'createdAt',
          order: 'descending',
        ),
      );

      final newItems = [...current.websites, ...result.items];

      state = AsyncData(
        current.copyWith(
          websites: newItems,
          currentPage: nextPage,
          hasMore: result.items.length >= _pageSize,
          isLoadingMore: false,
        ),
      );
    } catch (e) {
      // Restore only the loading state and keep existing data.
      state = AsyncData(current.copyWith(isLoadingMore: false));
      final message = switch (e) {
        AppNetworkException(:final message) => message,
        _ => 'Failed to load more',
      };
      showAppErrorToast(message);
    }
  }
}
