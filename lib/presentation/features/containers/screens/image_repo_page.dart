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
import '../providers/image_repo_provider.dart';
import '../widgets/image_repo_card.dart';
import '../widgets/image_repo_action_sheet.dart';
import '../widgets/image_repo_create_sheet.dart';

class ImageRepoPage extends StatelessWidget {
  const ImageRepoPage({super.key, required this.serverId});

  final int serverId;

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [activeServerIdProvider.overrideWithValue(serverId)],
      child: const _ImageRepoContent(),
    );
  }
}

class _ImageRepoContent extends ConsumerStatefulWidget {
  const _ImageRepoContent();

  @override
  ConsumerState<_ImageRepoContent> createState() => _ImageRepoContentState();
}

class _ImageRepoContentState extends ConsumerState<_ImageRepoContent>
    with SheetDismissRefreshMixin {
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();
  bool _isSearching = false;

  @override
  void onAllSheetsClosed() {
    ref.read(imageRepoControllerProvider.notifier).refresh();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final asyncState = ref.watch(imageRepoControllerProvider);
    final notifier = ref.read(imageRepoControllerProvider.notifier);

    return FrostedScaffold(
      title: _isSearching ? '' : context.l10n.containers_imageRepos,
      showBackButton: !_isSearching,
      trailingBuilder: (isDark, isOverlapping) {
        if (_isSearching) {
          return AppHeaderSearchField(
            controller: _searchController,
            focusNode: _searchFocusNode,
            placeholder: context.l10n.containers_searchRepos,
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
              text: context.l10n.containers_addRepo,
              icon: TablerIcons.plus,
              action: () => showImageRepoCreateSheet(context),
            ),
            FrostedMenuItem(
              text: context.l10n.containers_searchRepos,
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
                    ref.read(imageRepoControllerProvider.notifier).refresh(),
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
                          return ImageRepoCard(
                            item: item,
                            onTap: () =>
                                showImageRepoActionSheet(context, item),
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
                    icon: TablerIcons.database,
                    title: state.searchQuery.isNotEmpty
                        ? context.l10n.containers_noRepoFound
                        : context.l10n.containers_noRepo,
                    subtitle: state.searchQuery.isNotEmpty
                        ? context.l10n.containers_tryAnotherKeyword
                        : context.l10n.containers_noRepoSubtitle,
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
                  title: context.l10n.containers_loadRepoListFailed,
                  error: err,
                  onRetry: () =>
                      ref.read(imageRepoControllerProvider.notifier).refresh(),
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
                        width: 120 + (index % 2) * 40.0,
                        height: 12,
                        borderRadius: 3,
                      ),
                    ],
                  ),
                ),
                const SkeletonItem(width: 40, height: 20, borderRadius: 10),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const SkeletonItem(width: 46, height: 18, borderRadius: 6),
                if (index % 2 == 0) ...[
                  const SizedBox(width: 8),
                  const SkeletonItem(width: 36, height: 18, borderRadius: 6),
                ],
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
