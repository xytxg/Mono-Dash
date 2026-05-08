import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../core/localization/l10n_x.dart';
import '../../../../data/dto/app/app_installed_dto.dart';
import '../../../../data/dto/app/app_installed_search_req.dart';
import '../../../../data/repositories_impl/app_repository_impl.dart';
import '../../../common/components/frosted_scaffold.dart';
import '../providers/app_store_provider.dart';
import 'app_store_empty_state.dart';
import 'app_update_card.dart';

class UpdatesTab extends ConsumerStatefulWidget {
  const UpdatesTab({super.key, required this.serverId});

  final int serverId;

  @override
  ConsumerState<UpdatesTab> createState() => _UpdatesTabState();
}

class _UpdatesTabState extends ConsumerState<UpdatesTab> {
  static const _pageSize = 20;

  final _scrollController = ScrollController();
  List<AppInstalledDto> _items = [];
  bool _loading = true;
  bool _loadingMore = false;
  bool _hasMore = false;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _load();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 180) {
      _loadMore();
    }
  }

  Future<void> _load() async {
    final query = ref.read(updateSearchQueryProvider);
    setState(() {
      _loading = true;
      _loadingMore = false;
      _error = null;
    });
    try {
      final repo = await ref.read(appRepositoryProvider.future);
      final result = await repo.searchInstalledApps(
        AppInstalledSearchReq(
          page: 1,
          pageSize: _pageSize,
          name: query,
          update: true,
          sync: true,
        ),
      );
      if (mounted) {
        setState(() {
          _items = result.items;
          _hasMore = result.items.length >= _pageSize;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e;
          _loading = false;
        });
      }
    }
  }

  Future<void> _loadMore() async {
    if (_loading || _loadingMore || !_hasMore || _items.isEmpty) return;

    final query = ref.read(updateSearchQueryProvider);
    setState(() => _loadingMore = true);
    try {
      final repo = await ref.read(appRepositoryProvider.future);
      final result = await repo.searchInstalledApps(
        AppInstalledSearchReq(
          page: _items.length ~/ _pageSize + 1,
          pageSize: _pageSize,
          name: query,
          update: true,
          sync: true,
        ),
      );
      if (!mounted) return;
      setState(() {
        _items = [..._items, ...result.items];
        _hasMore = result.items.length >= _pageSize;
        _loadingMore = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loadingMore = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 监听搜索词变化并刷新。
    ref.listen(updateSearchQueryProvider, (_, next) => _load());

    return CustomScrollView(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      slivers: [
        CupertinoSliverRefreshControl(onRefresh: _load),
        SliverToBoxAdapter(
          child: SizedBox(
            height: FrostedScaffold.contentTopPadding(context) + 8,
          ),
        ),
        if (_loading && _items.isEmpty)
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 132),
            sliver: SliverList.list(
              children: [
                for (int i = 0; i < 3; i++) const AppUpdateCard(loading: true),
              ],
            ),
          )
        else if (_error != null)
          SliverFillRemaining(
            hasScrollBody: false,
            child: AppStoreEmptyState(
              icon: TablerIcons.alert_circle,
              title: context.l10n.common_loadingFailed,
              subtitle: _error.toString(),
              onAction: _load,
              actionLabel: context.l10n.common_retry,
            ),
          )
        else if (_items.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: AppStoreEmptyState(
              icon: TablerIcons.circle_check,
              title: ref.read(updateSearchQueryProvider).isEmpty
                  ? context.l10n.appStore_noUpdatableApps
                  : context.l10n.appStore_noRelatedApps,
              subtitle: ref.read(updateSearchQueryProvider).isEmpty
                  ? context.l10n.appStore_allAppsUpToDate
                  : context.l10n.appStore_tryAnotherSearch,
            ),
          )
        else
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              16,
              12,
              16,
              MediaQuery.paddingOf(context).bottom + 132,
            ),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                if (index == _items.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(child: CupertinoActivityIndicator()),
                  );
                }
                return AppUpdateCard(app: _items[index]);
              }, childCount: _items.length + (_loadingMore ? 1 : 0)),
            ),
          ),
      ],
    );
  }
}
