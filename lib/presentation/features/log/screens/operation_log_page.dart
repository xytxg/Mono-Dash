import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:intl/intl.dart';

import '../../../../core/localization/l10n_x.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../common/components/app_empty_state.dart';
import '../../../common/components/app_header_search_field.dart';
import '../../../common/components/app_meta_chip.dart';
import '../../../common/components/frosted_dialog.dart';
import '../../../common/components/frosted_overlay_menu.dart';
import '../../../common/components/frosted_scaffold.dart';
import '../../../common/components/skeleton_item.dart';
import '../../../common/components/status_pill.dart';
import '../../server_detail/providers/active_server_provider.dart';
import '../providers/operation_log_provider.dart';

/// 打开操作日志页面。
Future<void> openOperationLogPage(BuildContext context, int serverId) {
  return Navigator.of(context).push(
    CupertinoPageRoute<void>(
      builder: (_) => OperationLogPage(serverId: serverId),
    ),
  );
}

class OperationLogPage extends StatelessWidget {
  const OperationLogPage({super.key, required this.serverId});

  final int serverId;

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [activeServerIdProvider.overrideWithValue(serverId)],
      child: const _OperationLogContent(),
    );
  }
}

class _OperationLogContent extends ConsumerStatefulWidget {
  const _OperationLogContent();

  @override
  ConsumerState<_OperationLogContent> createState() =>
      _OperationLogContentState();
}

class _OperationLogContentState extends ConsumerState<_OperationLogContent> {
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  bool _handleListScroll(ScrollNotification notification) {
    if (notification is ScrollEndNotification &&
        notification.metrics.pixels >=
            notification.metrics.maxScrollExtent - 200) {
      ref.read(operationLogControllerProvider.notifier).loadMore();
    }
    return false;
  }

  Future<void> _confirmClean() async {
    final l10n = context.l10n;
    final confirmed = await showFrostedConfirmDialog(
      context,
      title: l10n.log_clearOperationTitle,
      icon: TablerIcons.trash,
      content: l10n.log_clearOperationContent,
    );
    if (confirmed == true) {
      await ref.read(operationLogControllerProvider.notifier).cleanLogs();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final stateAsync = ref.watch(operationLogControllerProvider);
    final notifier = ref.read(operationLogControllerProvider.notifier);

    return FrostedScaffold(
      title: _isSearching ? '' : l10n.log_operationLog,
      showBackButton: !_isSearching,
      trailingBuilder: (isDark, isOverlapping) {
        if (_isSearching) {
          return AppHeaderSearchField(
            controller: _searchController,
            focusNode: _searchFocusNode,
            placeholder: l10n.log_searchOperationPlaceholder,
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
          label: l10n.log_actions,
          isDark: isDark,
          isOverlapping: isOverlapping,
          items: [
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
            FrostedMenuItem(
              text: l10n.log_clearLogs,
              icon: TablerIcons.trash,
              iconColor: CupertinoColors.systemRed,
              action: _confirmClean,
            ),
          ],
        );
      },
      body: stateAsync.when(
        loading: () => ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          itemCount: 8,
          padding: EdgeInsets.only(
            top: FrostedScaffold.contentTopPadding(context),
            bottom: 132,
          ),
          itemBuilder: (_, _) => const Padding(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            child: SkeletonItem(width: double.infinity, height: 92),
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
          if (state.items.isEmpty) {
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
                  icon: TablerIcons.clipboard_list,
                  title: l10n.log_noOperationLogs,
                  subtitle: l10n.log_noOperationLogsSubtitle,
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
                CupertinoSliverRefreshControl(onRefresh: notifier.refresh),
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
                      return _OperationLogRow(
                        source: item.source,
                        detail: item.detailZH.isNotEmpty
                            ? item.detailZH
                            : item.detailEN,
                        status: item.status,
                        time: item.createdAt,
                        successLabel: l10n.log_success,
                        failedLabel: l10n.log_failed,
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

class _OperationLogRow extends StatelessWidget {
  const _OperationLogRow({
    required this.source,
    required this.detail,
    required this.status,
    required this.time,
    required this.successLabel,
    required this.failedLabel,
  });

  final String source;
  final String detail;
  final String status;
  final DateTime time;
  final String successLabel;
  final String failedLabel;

  @override
  Widget build(BuildContext context) {
    final isSuccess = status == 'Success' || status == 'success';
    final statusColor = isSuccess
        ? CupertinoColors.systemGreen.resolveFrom(context)
        : CupertinoColors.systemRed.resolveFrom(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.secondaryBackground(context).withValues(alpha: 0.58),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.separator(context).withValues(alpha: 0.12),
            width: 0.5,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 状态图标
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(
                isSuccess
                    ? TablerIcons.clipboard_check
                    : TablerIcons.clipboard_x,
                size: 18,
                color: statusColor,
              ),
            ),
            const SizedBox(width: 12),

            // 内容区
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          detail,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.label(context),
                            letterSpacing: -0.3,
                            height: 1.3,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      StatusPill(
                        label: isSuccess ? successLabel : failedLabel,
                        active: isSuccess,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // 元数据行
                  Wrap(
                    spacing: 12,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      AppMetaChip(
                        label: source,
                        color: AppColors.secondaryLabel(context),
                      ),
                      _MetaInfo(
                        icon: TablerIcons.clock,
                        text: DateFormat('MM-dd HH:mm:ss').format(time),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetaInfo extends StatelessWidget {
  const _MetaInfo({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: AppColors.tertiaryLabel(context)),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.secondaryLabel(context),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
