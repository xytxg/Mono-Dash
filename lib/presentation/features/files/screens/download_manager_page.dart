import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../core/localization/l10n_x.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/format_utils.dart';
import '../../../common/components/frosted_overlay_menu.dart';
import '../../../common/components/frosted_scaffold.dart';
import '../../../common/components/wave_progress_item.dart';
import '../../server_detail/providers/active_server_provider.dart';
import '../models/download_task.dart';
import '../providers/download_manager_provider.dart';

class DownloadManagerPage extends ConsumerWidget {
  const DownloadManagerPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final serverId = ref.watch(activeServerIdProvider);
    final allTasks = ref.watch(downloadManagerProvider);
    final tasks = allTasks.where((t) => t.serverId == serverId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    final active = tasks.where((t) => !t.isDone).toList();
    final done = tasks.where((t) => t.isDone).toList();

    return FrostedScaffold(
      title: context.l10n.download_managerTitle,
      showBackButton: true,
      trailingBuilder: tasks.isNotEmpty
          ? (isDark, overlaps) => FrostedOverlayMenuButton(
              label: context.l10n.download_actionsMenu,
              isDark: isDark,
              isOverlapping: overlaps,
              items: [
                if (done.isNotEmpty)
                  FrostedMenuItem(
                    text: context.l10n.download_clearCompletedRecords,
                    icon: TablerIcons.circle_check,
                    action: () => ref
                        .read(downloadManagerProvider.notifier)
                        .clearCompleted(serverId),
                  ),
                FrostedMenuItem(
                  text: context.l10n.download_deleteAllFiles,
                  icon: TablerIcons.trash,
                  iconColor: CupertinoColors.destructiveRed,
                  action: () => _confirmDeleteAll(context, ref, serverId),
                ),
              ],
            )
          : null,
      body: tasks.isEmpty
          ? _buildEmpty(context)
          : ListView(
              padding: EdgeInsets.only(
                top: FrostedScaffold.contentTopPadding(context) + 8,
                bottom: MediaQuery.paddingOf(context).bottom + 20,
                left: 16,
                right: 16,
              ),
              children: [
                if (active.isNotEmpty) ...[
                  _SectionHeader(
                    icon: TablerIcons.download,
                    title: context.l10n.download_activeSection,
                  ),
                  const SizedBox(height: 6),
                  _TaskGroup(
                    children: active
                        .map((t) => _ActiveTaskItem(task: t))
                        .toList(),
                  ),
                  const SizedBox(height: 20),
                ],
                if (done.isNotEmpty) ...[
                  _SectionHeader(
                    icon: TablerIcons.circle_check,
                    title: context.l10n.download_completedSection,
                  ),
                  const SizedBox(height: 6),
                  _TaskGroup(
                    children: done.map((t) => _DoneTaskItem(task: t)).toList(),
                  ),
                ],
              ],
            ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            TablerIcons.download_off,
            size: 48,
            color: AppColors.secondaryLabel(context).withValues(alpha: 0.4),
          ),
          const SizedBox(height: 12),
          Text(
            context.l10n.download_emptyTasks,
            style: TextStyle(
              fontSize: 15,
              color: AppColors.secondaryLabel(context),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteAll(BuildContext context, WidgetRef ref, int serverId) {
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: Text(context.l10n.download_deleteAllTitle),
        content: Text(context.l10n.download_deleteAllContent),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: Text(context.l10n.common_cancel),
            onPressed: () => Navigator.pop(ctx),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: Text(context.l10n.download_deleteAllAction),
            onPressed: () {
              Navigator.pop(ctx);
              ref
                  .read(downloadManagerProvider.notifier)
                  .deleteAllDownloads(serverId);
            },
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 内部组件
// ---------------------------------------------------------------------------

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.icon, required this.title});
  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppColors.secondaryLabel(context)),
          const SizedBox(width: 6),
          Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.secondaryLabel(context),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _TaskGroup extends StatelessWidget {
  const _TaskGroup({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground(context).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: children.asMap().entries.map((entry) {
          final isLast = entry.key == children.length - 1;
          if (isLast) return entry.value;
          return Column(
            children: [
              entry.value,
              Padding(
                padding: const EdgeInsets.only(left: 54),
                child: Container(
                  height: 0.5,
                  color: AppColors.separator(context).withValues(alpha: 0.3),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

/// 下载中/等待中的任务项
class _ActiveTaskItem extends ConsumerWidget {
  const _ActiveTaskItem({required this.task});
  final DownloadTask task;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = CupertinoColors.systemBlue.resolveFrom(context);

    return Stack(
      children: [
        Positioned.fill(
          child: WaveProgressLayer(
            progress: task.progress,
            color: color.withValues(alpha: 0.1),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(TablerIcons.file_download, size: 22, color: color),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.fileName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      task.status == DownloadStatus.pending
                          ? context.l10n.download_waiting
                          : '${(task.progress * 100).toStringAsFixed(1)}%  ·  ${formatByteRate(task.speed.toInt())}',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.secondaryLabel(context),
                      ),
                    ),
                  ],
                ),
              ),
              CupertinoButton(
                padding: EdgeInsets.zero,
                minimumSize: const Size.square(32),
                onPressed: () => ref
                    .read(downloadManagerProvider.notifier)
                    .cancelDownload(task.id),
                child: Icon(
                  TablerIcons.x,
                  size: 18,
                  color: CupertinoColors.systemRed.resolveFrom(context),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// 已完成/失败/已取消的任务项
class _DoneTaskItem extends ConsumerWidget {
  const _DoneTaskItem({required this.task});
  final DownloadTask task;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final manager = ref.read(downloadManagerProvider.notifier);

    final (icon, iconColor, subtitle) = switch (task.status) {
      DownloadStatus.completed => (
        TablerIcons.circle_check_filled,
        CupertinoColors.systemGreen.resolveFrom(context),
        '${formatBytes(task.fileSize)}  ·  ${_formatDate(task.createdAt)}',
      ),
      DownloadStatus.failed => (
        TablerIcons.circle_x_filled,
        CupertinoColors.systemRed.resolveFrom(context),
        task.errorMessage ?? context.l10n.download_failed,
      ),
      _ => (
        TablerIcons.circle_minus,
        CupertinoColors.systemOrange.resolveFrom(context),
        context.l10n.download_cancelled,
      ),
    };

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 22, color: iconColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.fileName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.secondaryLabel(context),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (task.status == DownloadStatus.completed) ...[
            CupertinoButton(
              padding: EdgeInsets.zero,
              minimumSize: const Size.square(32),
              onPressed: () => manager.shareFile(task.id),
              child: Icon(
                TablerIcons.share,
                size: 18,
                color: CupertinoColors.systemBlue.resolveFrom(context),
              ),
            ),
            const SizedBox(width: 4),
          ],
          if (task.status == DownloadStatus.failed ||
              task.status == DownloadStatus.cancelled) ...[
            CupertinoButton(
              padding: EdgeInsets.zero,
              minimumSize: const Size.square(32),
              onPressed: () => manager.retryDownload(task.id),
              child: Icon(
                TablerIcons.refresh,
                size: 18,
                color: CupertinoColors.systemBlue.resolveFrom(context),
              ),
            ),
            const SizedBox(width: 4),
          ],
          CupertinoButton(
            padding: EdgeInsets.zero,
            minimumSize: const Size.square(32),
            onPressed: () => _confirmDelete(context, ref),
            child: Icon(
              TablerIcons.trash,
              size: 18,
              color: CupertinoColors.systemRed.resolveFrom(context),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    final hasFile =
        task.status == DownloadStatus.completed &&
        File(task.localPath).existsSync();

    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: Text(context.l10n.download_deleteTitle),
        content: Text(
          hasFile
              ? context.l10n.download_deleteFileContent
              : context.l10n.download_deleteRecordContent,
        ),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: Text(context.l10n.common_cancel),
            onPressed: () => Navigator.pop(ctx),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: Text(context.l10n.common_delete),
            onPressed: () {
              Navigator.pop(ctx);
              ref
                  .read(downloadManagerProvider.notifier)
                  .deleteDownload(task.id);
            },
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final local = dt.toLocal();
    return '${local.month}/${local.day} ${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
  }
}
