import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:intl/intl.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/localization/l10n_x.dart';
import '../../../../core/network/dio_client_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/api/file_api.dart';
import '../../../../data/dto/common/task_log_dto.dart' as common;
import '../../../common/components/app_empty_state.dart';
import '../../../common/components/app_meta_chip.dart';
import '../../../common/components/frosted_overlay_menu.dart';
import '../../../common/components/frosted_scaffold.dart';
import '../../../common/components/skeleton_item.dart';
import '../../../common/components/status_pill.dart';
import '../../../common/components/task_log_sheet.dart';
import '../../server_detail/providers/active_server_provider.dart';
import '../providers/task_log_provider.dart';

/// 打开任务日志页面。
Future<void> openTaskLogPage(BuildContext context, int serverId) {
  return Navigator.of(context).push(
    CupertinoPageRoute<void>(builder: (_) => TaskLogPage(serverId: serverId)),
  );
}

class TaskLogPage extends StatelessWidget {
  const TaskLogPage({super.key, required this.serverId});

  final int serverId;

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [activeServerIdProvider.overrideWithValue(serverId)],
      child: const _TaskLogContent(),
    );
  }
}

class _TaskLogContent extends ConsumerStatefulWidget {
  const _TaskLogContent();

  @override
  ConsumerState<_TaskLogContent> createState() => _TaskLogContentState();
}

class _TaskLogContentState extends ConsumerState<_TaskLogContent> {
  bool _handleListScroll(ScrollNotification notification) {
    if (notification is ScrollEndNotification &&
        notification.metrics.pixels >=
            notification.metrics.maxScrollExtent - 200) {
      ref.read(taskLogControllerProvider.notifier).loadMore();
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final stateAsync = ref.watch(taskLogControllerProvider);
    final notifier = ref.read(taskLogControllerProvider.notifier);

    return FrostedScaffold(
      title: l10n.log_taskLog,
      trailingBuilder: (isDark, isOverlapping) {
        return FrostedOverlayMenuButton(
          label: l10n.log_actions,
          isDark: isDark,
          isOverlapping: isOverlapping,
          items: [
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
                  icon: TablerIcons.list_check,
                  title: l10n.log_noTaskLogs,
                  subtitle: l10n.log_noTaskLogsSubtitle,
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
                      return _TaskLogRow(
                        id: item.id,
                        name: item.name,
                        type: item.type,
                        status: item.status,
                        errorMsg: item.errorMsg,
                        time: item.createdAt,
                        l10n: l10n,
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

class _TaskLogRow extends ConsumerWidget {
  const _TaskLogRow({
    required this.id,
    required this.name,
    required this.type,
    required this.status,
    required this.errorMsg,
    required this.time,
    required this.l10n,
  });

  final String id;
  final String name;
  final String type;
  final String status;
  final String errorMsg;
  final DateTime time;
  final AppLocalizations l10n;

  Color _statusColor(BuildContext context) {
    switch (status) {
      case 'Success':
        return CupertinoColors.systemGreen.resolveFrom(context);
      case 'Failed':
        return CupertinoColors.systemRed.resolveFrom(context);
      case 'Executing':
        return CupertinoColors.systemOrange.resolveFrom(context);
      default:
        return CupertinoColors.systemGrey.resolveFrom(context);
    }
  }

  IconData _statusIcon() {
    switch (status) {
      case 'Success':
        return TablerIcons.circle_check;
      case 'Failed':
        return TablerIcons.circle_x;
      case 'Executing':
        return TablerIcons.loader_2;
      default:
        return TablerIcons.circle;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusColor = _statusColor(context);
    final isExecuting = status == 'Executing';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: GestureDetector(
        onTap: () => _showLog(context, ref),
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.secondaryBackground(
              context,
            ).withValues(alpha: 0.58),
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
                child: isExecuting
                    ? const Center(child: CupertinoActivityIndicator(radius: 8))
                    : Icon(_statusIcon(), size: 18, color: statusColor),
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
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.label(context),
                              letterSpacing: -0.4,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        StatusPill(
                          label: _statusLabel(),
                          active: status == 'Success',
                          activeColor: statusColor,
                          inactiveColor: statusColor,
                        ),
                      ],
                    ),
                    const SizedBox(height: 7),

                    // 元数据
                    Wrap(
                      spacing: 12,
                      runSpacing: 4,
                      children: [
                        if (type.isNotEmpty)
                          AppMetaChip(
                            label: type,
                            color: AppColors.secondaryLabel(context),
                          ),
                        _MetaInfo(
                          icon: TablerIcons.clock,
                          text: DateFormat('MM-dd HH:mm:ss').format(time),
                        ),
                      ],
                    ),

                    if (status == 'Failed' && errorMsg.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: CupertinoColors.systemRed
                              .resolveFrom(context)
                              .withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          errorMsg,
                          style: TextStyle(
                            fontSize: 12,
                            color: CupertinoColors.systemRed.resolveFrom(
                              context,
                            ),
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                CupertinoIcons.chevron_right,
                size: 14,
                color: AppColors.tertiaryLabel(context).withValues(alpha: 0.4),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _statusLabel() {
    switch (status) {
      case 'Success':
        return l10n.log_success;
      case 'Failed':
        return l10n.log_failed;
      case 'Executing':
        return l10n.log_executing;
      default:
        return status;
    }
  }

  Future<void> _showLog(BuildContext context, WidgetRef ref) async {
    final serverId = ref.read(activeServerIdProvider);

    await showTaskLogSheet(
      context,
      title: name,
      taskID: id,
      reader: (taskID) async {
        final client = await ref.read(dioClientProvider(serverId).future);
        return FileApi(client).readFile<common.TaskLogDto>(
          type: 'task',
          taskID: taskID,
          fromJson: common.TaskLogDto.fromJson,
        );
      },
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
