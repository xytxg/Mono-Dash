import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../core/localization/l10n_x.dart';
import '../../../../data/repositories_impl/cronjob_repository_impl.dart';
import '../../../common/components/app_empty_state.dart';
import '../../../common/components/app_header_search_field.dart';
import '../../../common/components/frosted_overlay_menu.dart';
import '../../../common/components/frosted_scaffold.dart';
import '../../../common/components/skeleton_item.dart';
import '../../server_detail/providers/active_server_provider.dart';
import '../providers/cronjob_provider.dart';
import '../widgets/cronjob_action_sheet.dart';
import '../widgets/cronjob_card.dart';
import '../widgets/cronjob_form_sheet.dart';
import '../widgets/cronjob_records_sheet.dart';

/// 打开计划任务页面。
Future<void> openCronjobPage(BuildContext context, int serverId) {
  return Navigator.of(context).push(
    CupertinoPageRoute<void>(builder: (_) => CronjobPage(serverId: serverId)),
  );
}

class CronjobPage extends StatelessWidget {
  const CronjobPage({super.key, required this.serverId});

  final int serverId;

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [activeServerIdProvider.overrideWithValue(serverId)],
      child: const _CronjobContent(),
    );
  }
}

class _CronjobContent extends ConsumerStatefulWidget {
  const _CronjobContent();

  @override
  ConsumerState<_CronjobContent> createState() => _CronjobContentState();
}

class _CronjobContentState extends ConsumerState<_CronjobContent> {
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _onSubmit(dynamic req) async {
    final repo = await ref.read(cronjobRepositoryProvider.future);
    if (req.id != null) {
      await repo.updateCronjob(req);
    } else {
      await repo.createCronjob(req);
    }
    ref.read(cronjobControllerProvider.notifier).refresh();
  }

  void _openCreateSheet() {
    showCronjobFormSheet(context, onSubmit: _onSubmit);
  }

  void _openActionSheet(dynamic item) {
    showCronjobActionSheet(
      context,
      item: item,
      onEdit: () async {
        final repo = await ref.read(cronjobRepositoryProvider.future);
        final detail = await repo.getCronjobInfo(item.id);
        if (!mounted) return;
        showCronjobFormSheet(context, editItem: detail, onSubmit: _onSubmit);
      },
      onToggleStatus: () async {
        await ref
            .read(cronjobControllerProvider.notifier)
            .toggleStatus(context, item.id, item.status);
      },
      onHandleOnce: () async {
        await ref.read(cronjobControllerProvider.notifier).handleOnce(item.id);
      },
      onDelete: () async {
        await ref.read(cronjobControllerProvider.notifier).delete(item.id);
      },
      onViewRecords: () {
        showCronjobRecordsSheet(context, item: item);
      },
    );
  }

  bool _handleListScroll(ScrollNotification notification) {
    if (notification is ScrollEndNotification &&
        notification.metrics.pixels >=
            notification.metrics.maxScrollExtent - 200) {
      ref.read(cronjobControllerProvider.notifier).loadMore();
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final stateAsync = ref.watch(cronjobControllerProvider);
    final notifier = ref.read(cronjobControllerProvider.notifier);
    final l10n = context.l10n;

    return FrostedScaffold(
      title: _isSearching ? '' : l10n.cronjobs_title,
      showBackButton: !_isSearching,
      trailingBuilder: (isDark, isOverlapping) {
        if (_isSearching) {
          return AppHeaderSearchField(
            controller: _searchController,
            focusNode: _searchFocusNode,
            placeholder: l10n.cronjobs_searchPlaceholder,
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
          label: l10n.common_menu,
          isDark: isDark,
          isOverlapping: isOverlapping,
          items: [
            FrostedMenuItem(
              text: l10n.common_create,
              icon: TablerIcons.plus,
              iconColor: CupertinoColors.systemGreen,
              action: _openCreateSheet,
            ),
            FrostedMenuItem(
              text: l10n.common_search,
              icon: TablerIcons.search,
              action: () {
                setState(() => _isSearching = true);
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) _searchFocusNode.requestFocus();
                });
              },
            ),
            FrostedMenuItem(
              text: l10n.common_refresh,
              icon: TablerIcons.refresh,
              action: notifier.refresh,
            ),
          ],
        );
      },
      body: stateAsync.when(
        loading: () => ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          itemCount: 5,
          padding: EdgeInsets.only(
            top: FrostedScaffold.contentTopPadding(context),
            bottom: 132,
          ),
          itemBuilder: (_, _) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SkeletonItem(
              width: MediaQuery.of(context).size.width - 32,
              height: 120,
            ),
          ),
        ),
        error: (e, _) => ListView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          padding: EdgeInsets.only(
            top: FrostedScaffold.contentTopPadding(context),
          ),
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.2),
            AppEmptyState(
              icon: TablerIcons.alert_triangle,
              title: l10n.common_loadingFailed,
              subtitle: e.toString(),
              actionLabel: l10n.common_retry,
              onAction: notifier.refresh,
            ),
          ],
        ),
        data: (state) {
          if (state.items.isEmpty && state.searchQuery.isEmpty) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: EdgeInsets.only(
                top: FrostedScaffold.contentTopPadding(context),
              ),
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.15),
                AppEmptyState(
                  icon: TablerIcons.clock,
                  title: l10n.cronjobs_emptyTitle,
                  subtitle: l10n.cronjobs_emptySubtitle,
                  actionLabel: l10n.cronjobs_newTask,
                  onAction: _openCreateSheet,
                ),
              ],
            );
          }

          if (state.items.isEmpty && state.searchQuery.isNotEmpty) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: EdgeInsets.only(
                top: FrostedScaffold.contentTopPadding(context),
              ),
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.2),
                AppEmptyState(
                  icon: TablerIcons.search,
                  title: l10n.cronjobs_noSearchResults,
                  subtitle: l10n.cronjobs_noSearchResultsSubtitle(
                    state.searchQuery,
                  ),
                ),
              ],
            );
          }

          return NotificationListener<ScrollNotification>(
            onNotification: _handleListScroll,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              slivers: [
                CupertinoSliverRefreshControl(
                  onRefresh: () =>
                      ref.read(cronjobControllerProvider.notifier).refresh(),
                ),
                SliverPadding(
                  padding: EdgeInsets.only(
                    top: FrostedScaffold.contentTopPadding(context),
                    bottom: 132,
                  ),
                  sliver: SliverList.builder(
                    itemCount: state.items.length + (state.hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == state.items.length) {
                        return state.isLoadingMore
                            ? const Padding(
                                padding: EdgeInsets.all(16),
                                child: Center(
                                  child: CupertinoActivityIndicator(),
                                ),
                              )
                            : const SizedBox.shrink();
                      }
                      final item = state.items[index];
                      return CronjobCard(
                        item: item,
                        onTap: () => _openActionSheet(item),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
