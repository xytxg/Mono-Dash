import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/locale_controller.dart';
import '../../../../core/network/network_exceptions.dart';
import '../../../../data/dto/app/app_tag_dto.dart';
import '../../../../data/dto/app/app_catalog_search_req.dart';
import '../../../../data/repositories_impl/app_repository_impl.dart';
import '../../../common/app_toast.dart';
import '../models/app_catalog_state.dart';

final appCatalogControllerProvider =
    AsyncNotifierProvider<AppCatalogController, AppCatalogState>(
      AppCatalogController.new,
      dependencies: [appRepositoryProvider, appTagsProvider],
    );

final appTagsProvider = FutureProvider<List<AppTagDto>>((ref) async {
  final repo = await ref.watch(appRepositoryProvider.future);
  return repo.listAppTags();
}, dependencies: [appRepositoryProvider]);

class AppCatalogController extends AsyncNotifier<AppCatalogState> {
  static const _pageSize = 60;

  @override
  Future<AppCatalogState> build() => _load(selectedTagKey: '', searchName: '');

  Future<AppCatalogState> _load({
    required String selectedTagKey,
    required String searchName,
    List<AppTagDto>? cachedTags,
  }) async {
    final repo = await ref.read(appRepositoryProvider.future);
    final List<AppTagDto> tags =
        cachedTags ?? await ref.read(appTagsProvider.future);
    final result = await repo.searchApps(
      AppCatalogSearchReq(
        page: 1,
        pageSize: _pageSize,
        tags: selectedTagKey.isEmpty ? const [] : [selectedTagKey],
        name: searchName,
      ),
    );
    return AppCatalogState(
      apps: result.items,
      tags: tags,
      selectedTagKey: selectedTagKey,
      searchName: searchName,
      total: result.total,
      hasMore: result.items.length >= _pageSize,
      isLoadingMore: false,
    );
  }

  Future<void> refresh() async {
    final current = state.valueOrNull;
    final selected = current?.selectedTagKey ?? '';
    final search = current?.searchName ?? '';
    final next = await AsyncValue.guard(
      () => _load(selectedTagKey: selected, searchName: search),
    );
    if (next.hasError && current != null) {
      state = AsyncData(current);
      _showError(next.error);
      return;
    }
    state = next;
  }

  Future<void> selectTag(String tagKey) async {
    final current = state.valueOrNull;
    if (current != null && current.selectedTagKey == tagKey) return;
    if (current == null) {
      state = await AsyncValue.guard(
        () => _load(selectedTagKey: tagKey, searchName: ''),
      );
      return;
    }

    // Keep current data and show refreshing state if we have a way to track it,
    // otherwise just update the state when done.
    final next = await AsyncValue.guard(
      () => _load(
        selectedTagKey: tagKey,
        searchName: current.searchName,
        cachedTags: current.tags,
      ),
    );
    if (next.hasError) {
      state = AsyncData(current);
      _showError(next.error);
      return;
    }
    state = next;
  }

  Future<void> search(String name) async {
    final current = state.valueOrNull;
    if (current != null && current.searchName == name) return;
    if (current == null) {
      state = await AsyncValue.guard(
        () => _load(selectedTagKey: '', searchName: name),
      );
      return;
    }

    // Keep current data and show refreshing state if we have a way to track it,
    // otherwise just update the state when done.
    final next = await AsyncValue.guard(
      () => _load(
        selectedTagKey: current.selectedTagKey,
        searchName: name,
        cachedTags: current.tags,
      ),
    );
    if (next.hasError) {
      state = AsyncData(current);
      _showError(next.error);
      return;
    }
    state = next;
  }

  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || current.isLoadingMore || !current.hasMore) return;

    state = AsyncData(current.copyWith(isLoadingMore: true));
    final nextPage = current.apps.length ~/ _pageSize + 1;

    try {
      final repo = await ref.read(appRepositoryProvider.future);
      final result = await repo.searchApps(
        AppCatalogSearchReq(
          page: nextPage,
          pageSize: _pageSize,
          tags: current.selectedTags,
          name: current.searchName,
        ),
      );
      state = AsyncData(
        current.copyWith(
          apps: [...current.apps, ...result.items],
          total: result.total,
          hasMore: result.items.length >= _pageSize,
          isLoadingMore: false,
        ),
      );
    } catch (error) {
      state = AsyncData(current.copyWith(isLoadingMore: false));
      _showError(
        error,
        fallback: ref.read(appLocalizationsProvider).appStore_loadMoreFailed,
      );
    }
  }

  void _showError(Object? error, {String? fallback}) {
    final l10n = ref.read(appLocalizationsProvider);
    final message = switch (error) {
      AppNetworkException(:final message) => message,
      _ => fallback ?? l10n.appStore_loadAllAppsFailed,
    };
    showAppErrorToast(message);
  }
}
