import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import '../../../../core/localization/l10n_x.dart';
import '../../../../core/router/sheet_dismiss_refresh_mixin.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../common/components/app_header_search_field.dart';
import '../../../common/components/frosted_scaffold.dart';
import '../../../common/components/app_empty_state.dart';
import '../../../common/components/frosted_dialog.dart';
import '../../../common/components/skeleton_item.dart';
import '../../../common/app_toast.dart';
import '../../server_detail/providers/active_server_provider.dart';
import '../../../../data/dto/container/container_compose_dto.dart';
import '../../../../data/repositories_impl/container_repository_impl.dart';
import '../providers/container_compose_provider.dart';
import '../widgets/compose_card.dart';
import '../widgets/compose_action_sheet.dart';
import '../widgets/compose_create_sheet.dart';
import '../../../common/components/frosted_overlay_menu.dart';

class ContainerComposePage extends StatelessWidget {
  const ContainerComposePage({super.key, required this.serverId});

  final int serverId;

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [activeServerIdProvider.overrideWithValue(serverId)],
      child: const _ContainerComposeContent(),
    );
  }
}

class _ContainerComposeContent extends ConsumerStatefulWidget {
  const _ContainerComposeContent();

  @override
  ConsumerState<_ContainerComposeContent> createState() =>
      _ContainerComposeContentState();
}

class _ContainerComposeContentState
    extends ConsumerState<_ContainerComposeContent>
    with SheetDismissRefreshMixin {
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();
  bool _isSearching = false;

  @override
  void onAllSheetsClosed() {
    ref.read(containerComposeControllerProvider.notifier).refresh();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final asyncState = ref.watch(containerComposeControllerProvider);
    final notifier = ref.read(containerComposeControllerProvider.notifier);

    return FrostedScaffold(
      title: _isSearching ? '' : context.l10n.containers_containerCompose,
      showBackButton: !_isSearching,
      trailingBuilder: (isDark, isOverlapping) {
        if (_isSearching) {
          return AppHeaderSearchField(
            controller: _searchController,
            focusNode: _searchFocusNode,
            placeholder: context.l10n.containers_searchCompose,
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
          label: context.l10n.containers_more,
          isDark: isDark,
          isOverlapping: isOverlapping,
          items: [
            FrostedMenuItem(
              text: context.l10n.containers_createCompose,
              icon: TablerIcons.plus,
              action: () => showComposeCreateSheet(context),
            ),
            FrostedMenuItem(
              text: context.l10n.containers_searchCompose,
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
      body: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        slivers: [
          SliverToBoxAdapter(
            child: SizedBox(
              height: FrostedScaffold.contentTopPadding(context) + 8,
            ),
          ),
          CupertinoSliverRefreshControl(
            onRefresh: () =>
                ref.read(containerComposeControllerProvider.notifier).refresh(),
          ),
          asyncState.when(
            skipLoadingOnRefresh: true,
            skipLoadingOnReload: true,
            data: (state) {
              final items = state.items;
              if (items.isEmpty) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: AppEmptyState(
                    icon: TablerIcons.stack_2,
                    title: state.searchQuery.isNotEmpty
                        ? context.l10n.containers_noComposeFound
                        : context.l10n.containers_noCompose,
                    subtitle: state.searchQuery.isNotEmpty
                        ? context.l10n.containers_tryAnotherKeyword
                        : context.l10n.containers_noComposeSubtitle,
                  ),
                );
              }
              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final item = items[index];
                    return ComposeCard(
                      item: item,
                      onTap: () => showComposeActionSheet(context, ref, item),
                      onStart: () => _operate(context, item, 'up'),
                      onStop: () => _operate(context, item, 'stop'),
                      onRestart: () => _operate(context, item, 'restart'),
                    );
                  }, childCount: items.length),
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
            error: (err, _) => SliverFillRemaining(
              hasScrollBody: false,
              child: AppErrorState(
                title: context.l10n.containers_loadComposeListFailed,
                error: err,
                onRetry: () => ref
                    .read(containerComposeControllerProvider.notifier)
                    .refresh(),
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
          color: AppColors.separator(context).withValues(alpha: 0.16),
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
                const SkeletonItem(width: 50, height: 22, borderRadius: 8),
              ],
            ),
            const SizedBox(height: 12),
            const Row(
              children: [
                SkeletonItem(width: 14, height: 14, borderRadius: 3),
                SizedBox(width: 6),
                SkeletonItem(width: 50, height: 12, borderRadius: 3),
                SizedBox(width: 8),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: SkeletonItem(width: 80, height: 12, borderRadius: 3),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Row(
              children: [
                SkeletonItem(width: 14, height: 14, borderRadius: 3),
                SizedBox(width: 6),
                SkeletonItem(width: 50, height: 12, borderRadius: 3),
                SizedBox(width: 8),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: SkeletonItem(
                      width: 120,
                      height: 12,
                      borderRadius: 3,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Row(
              children: [
                Expanded(
                  child: SkeletonItem(
                    width: double.infinity,
                    height: 36,
                    borderRadius: 10,
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: SkeletonItem(
                    width: double.infinity,
                    height: 36,
                    borderRadius: 10,
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: SkeletonItem(
                    width: double.infinity,
                    height: 36,
                    borderRadius: 10,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _operate(
    BuildContext context,
    ContainerComposeDto item,
    String operation,
  ) async {
    final title = _composeOperationTitle(context, operation);
    final confirmed = await showFrostedConfirmDialog(
      context,
      title: title,
      content: context.l10n.containers_composeOperationConfirm(
        title,
        item.name,
      ),
    );

    if (confirmed != true || !context.mounted) return;

    try {
      final repo = await ref.read(containerRepositoryProvider.future);
      await repo.operateCompose(
        name: item.name,
        path: item.path,
        operation: operation,
      );

      if (context.mounted) {
        showAppSuccessToast(context.l10n.containers_operationSubmitted(title));
        ref.read(containerComposeControllerProvider.notifier).refresh();
      }
    } catch (e) {
      if (!context.mounted) return;
      showAppErrorToast(
        context.l10n.containers_operationNamedFailed(title),
        description: e.toString(),
      );
    }
  }

  String _composeOperationTitle(BuildContext context, String operation) {
    return switch (operation) {
      'up' => context.l10n.containers_start,
      'stop' => context.l10n.containers_stop,
      _ => context.l10n.containers_restart,
    };
  }
}
