import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../core/localization/l10n_x.dart';
import '../../../../core/router/sheet_dismiss_refresh_mixin.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../common/components/app_empty_state.dart';
import '../../../common/components/app_header_search_field.dart';
import '../../../common/components/frosted_overlay_menu.dart';
import '../../../common/components/frosted_scaffold.dart';
import '../../../common/components/skeleton_item.dart';
import '../../server_detail/providers/active_server_provider.dart';
import '../providers/network_provider.dart';
import '../widgets/network_card.dart';
import '../widgets/network_create_sheet.dart';
import '../widgets/network_detail_sheet.dart';

class NetworkPage extends StatelessWidget {
  const NetworkPage({super.key, required this.serverId});

  final int serverId;

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [activeServerIdProvider.overrideWithValue(serverId)],
      child: const _NetworkContent(),
    );
  }
}

class _NetworkContent extends ConsumerStatefulWidget {
  const _NetworkContent();

  @override
  ConsumerState<_NetworkContent> createState() => _NetworkContentState();
}

class _NetworkContentState extends ConsumerState<_NetworkContent>
    with SheetDismissRefreshMixin {
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();
  bool _isSearching = false;

  @override
  void onAllSheetsClosed() {
    ref.read(networkControllerProvider.notifier).refresh();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final asyncState = ref.watch(networkControllerProvider);
    final notifier = ref.read(networkControllerProvider.notifier);

    return FrostedScaffold(
      title: _isSearching ? '' : context.l10n.containers_networks,
      showBackButton: !_isSearching,
      trailingBuilder: (isDark, isOverlapping) {
        if (_isSearching) {
          return AppHeaderSearchField(
            controller: _searchController,
            focusNode: _searchFocusNode,
            placeholder: context.l10n.containers_searchNetworks,
            onChanged: notifier.search,
            onClear: () => notifier.search(''),
            onCancel: () {
              setState(() {
                _isSearching = false;
                _searchController.clear();
              });
              notifier.search('');
            },
          );
        }

        return FrostedOverlayMenuButton(
          label: context.l10n.common_menu,
          isDark: isDark,
          isOverlapping: isOverlapping,
          items: [
            FrostedMenuItem(
              text: context.l10n.containers_createNetwork,
              icon: TablerIcons.plus,
              action: () => showNetworkCreateSheet(context),
            ),
            FrostedMenuItem(
              text: context.l10n.containers_pruneUnusedNetworks,
              icon: TablerIcons.eraser,
              action: () => notifier.pruneNetworks(context),
            ),
            FrostedMenuItem(
              text: context.l10n.containers_searchNetworks,
              icon: TablerIcons.search,
              action: () {
                setState(() => _isSearching = true);
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) _searchFocusNode.requestFocus();
                });
              },
            ),
            FrostedMenuItem(
              text: context.l10n.containers_refreshList,
              icon: TablerIcons.refresh,
              action: notifier.refresh,
            ),
          ],
        );
      },
      body: Stack(
        children: [
          CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              CupertinoSliverRefreshControl(
                onRefresh: () =>
                    ref.read(networkControllerProvider.notifier).refresh(),
              ),
              asyncState.when(
                skipLoadingOnRefresh: true,
                skipLoadingOnReload: true,
                data: (state) {
                  if (state.items.isEmpty) {
                    return const SliverToBoxAdapter(child: SizedBox.shrink());
                  }
                  return SliverPadding(
                    padding: EdgeInsets.fromLTRB(
                      16,
                      FrostedScaffold.contentTopPadding(context) + 12,
                      16,
                      40,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          if (index >= state.items.length) {
                            if (state.isLoadingMore) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child: Center(
                                  child: CupertinoActivityIndicator(),
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          }
                          final item = state.items[index];
                          return NetworkCard(
                            item: item,
                            onTap: () => showNetworkDetailSheet(context, item),
                          );
                        },
                        childCount:
                            state.items.length + (state.isLoadingMore ? 1 : 0),
                      ),
                    ),
                  );
                },
                loading: () => SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    16,
                    FrostedScaffold.contentTopPadding(context) + 12,
                    16,
                    40,
                  ),
                  sliver: SliverList.builder(
                    itemCount: 5,
                    itemBuilder: _buildSkeletonItem,
                  ),
                ),
                error: (err, _) =>
                    const SliverToBoxAdapter(child: SizedBox.shrink()),
              ),
            ],
          ),
          asyncState.when(
            data: (state) {
              if (state.items.isNotEmpty || state.isLoadingMore) {
                return const SizedBox.shrink();
              }
              return Center(
                child: Padding(
                  padding: EdgeInsets.only(
                    top: FrostedScaffold.contentTopPadding(context),
                  ),
                  child: AppEmptyState(
                    icon: TablerIcons.network,
                    title: state.searchQuery.isNotEmpty
                        ? context.l10n.containers_noNetworkFound
                        : context.l10n.containers_noNetwork,
                    subtitle: state.searchQuery.isNotEmpty
                        ? context.l10n.containers_tryAnotherKeyword
                        : context.l10n.containers_noNetworkSubtitle,
                    useCardStyle: false,
                    padding: const EdgeInsets.only(bottom: 40),
                  ),
                ),
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (err, _) => Center(
              child: Padding(
                padding: EdgeInsets.only(
                  top: FrostedScaffold.contentTopPadding(context),
                ),
                child: AppErrorState(
                  title: context.l10n.containers_loadNetworkListFailed,
                  error: err,
                  onRetry: () =>
                      ref.read(networkControllerProvider.notifier).refresh(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonItem(BuildContext context, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground(context).withValues(alpha: 0.68),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.separator(context).withValues(alpha: 0.1),
          width: 0.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const SkeletonItem(width: 40, height: 40, borderRadius: 10),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonItem(
                        width: 100 + (index % 3) * 30.0,
                        height: 17,
                        borderRadius: 4,
                      ),
                      const SizedBox(height: 6),
                      SkeletonItem(
                        width: 60 + (index % 2) * 20.0,
                        height: 12,
                        borderRadius: 3,
                      ),
                    ],
                  ),
                ),
                if (index % 3 == 0)
                  const SkeletonItem(width: 28, height: 28, borderRadius: 8),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const SkeletonItem(width: 70, height: 18, borderRadius: 6),
                const SizedBox(width: 8),
                SkeletonItem(
                  width: 40 + (index % 2) * 15.0,
                  height: 18,
                  borderRadius: 6,
                ),
                const Spacer(),
                const SkeletonItem(width: 80, height: 12, borderRadius: 3),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
