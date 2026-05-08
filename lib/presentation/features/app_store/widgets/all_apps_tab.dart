import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../core/localization/l10n_x.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../common/components/frosted_filter_bar.dart';
import '../../../common/components/frosted_scaffold.dart';
import '../providers/app_catalog_provider.dart';
import 'app_catalog_card.dart';
import 'app_store_empty_state.dart';

class AllAppsTab extends ConsumerStatefulWidget {
  const AllAppsTab({
    super.key,
    required this.scrollController,
    required this.serverId,
  });

  final ScrollController scrollController;
  final int serverId;

  @override
  ConsumerState<AllAppsTab> createState() => _AllAppsTabState();
}

class _AllAppsTabState extends ConsumerState<AllAppsTab> {
  bool _overlaps = false;

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    if (!mounted) return;
    final overlaps =
        widget.scrollController.hasClients &&
        widget.scrollController.offset > 12;
    if (overlaps != _overlaps) {
      setState(() => _overlaps = overlaps);
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncState = ref.watch(appCatalogControllerProvider);
    final topPadding = FrostedScaffold.contentTopPadding(context);

    return Stack(
      children: [
        CustomScrollView(
          controller: widget.scrollController,
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            CupertinoSliverRefreshControl(
              onRefresh: () =>
                  ref.read(appCatalogControllerProvider.notifier).refresh(),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: topPadding + 58 + 4, // 导航栏 + 过滤器高度 + 间距
              ),
            ),
            asyncState.when(
              skipLoadingOnRefresh: true,
              skipError: true,
              data: (state) => SliverPadding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 132),
                sliver: state.isRefreshing && state.apps.isEmpty
                    ? SliverList.list(
                        children: [
                          for (int i = 0; i < 8; i++) ...[
                            const AppCatalogCard(loading: true),
                            const SizedBox(height: 10),
                          ],
                        ],
                      )
                    : state.apps.isEmpty
                    ? SliverFillRemaining(
                        hasScrollBody: false,
                        child: AppStoreEmptyState(
                          icon: TablerIcons.apps_off,
                          title: context.l10n.appStore_noMatchingApps,
                          useCardStyle: false,
                          padding: const EdgeInsets.fromLTRB(14, 24, 14, 132),
                        ),
                      )
                    : SliverList.builder(
                        itemCount:
                            state.apps.length + (state.isLoadingMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == state.apps.length) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Center(
                                child: CupertinoActivityIndicator(),
                              ),
                            );
                          }
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: AppCatalogCard(
                              app: state.apps[index],
                              serverId: widget.serverId,
                            ),
                          );
                        },
                      ),
              ),
              loading: () => SliverPadding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 132),
                sliver: SliverList.list(
                  children: [
                    for (int i = 0; i < 8; i++) ...[
                      const AppCatalogCard(loading: true),
                      const SizedBox(height: 10),
                    ],
                  ],
                ),
              ),
              error: (err, _) => SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          TablerIcons.alert_triangle,
                          size: 46,
                          color: AppColors.tertiaryLabel(context),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          context.l10n.appStore_loadAllAppsFailed,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.label(context),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$err',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.secondaryLabel(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        Positioned(
          top: topPadding,
          left: 0,
          right: 0,
          child: FrostedFilterBar(
            items: [
              FilterItem(label: context.l10n.appStore_allFilter, value: ''),
              ...(asyncState.valueOrNull?.tags ?? []).map(
                (tag) => FilterItem(label: tag.name, value: tag.key),
              ),
            ],
            selectedValue: asyncState.valueOrNull?.selectedTagKey ?? '',
            overlaps: _overlaps,
            onSelected: (value) => ref
                .read(appCatalogControllerProvider.notifier)
                .selectTag(value),
          ),
        ),
      ],
    );
  }
}
