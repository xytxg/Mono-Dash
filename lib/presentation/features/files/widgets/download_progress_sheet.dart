import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../core/localization/l10n_x.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/format_utils.dart';
import '../../../common/components/action_sheet_launcher.dart';
import '../../../common/components/action_sheet_scaffold.dart';
import '../../../common/components/wave_progress_item.dart';
import '../models/download_task.dart';
import '../providers/download_manager_provider.dart';
import '../screens/download_manager_page.dart';

Future<void> showDownloadProgressSheet(
  BuildContext context,
  List<String> taskIds,
) {
  return showActionSheet(
    context: context,
    builder: (context) => _DownloadProgressSheet(taskIds: taskIds),
  );
}

class _DownloadProgressSheet extends ConsumerWidget {
  const _DownloadProgressSheet({required this.taskIds});
  final List<String> taskIds;

  void _openDownloadManager(BuildContext context) {
    final navigator = Navigator.of(context);
    final container = ProviderScope.containerOf(context);
    navigator.pop();
    navigator.push(
      CupertinoPageRoute<void>(
        builder: (ctx) => UncontrolledProviderScope(
          container: container,
          child: const DownloadManagerPage(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allTasks = ref.watch(downloadManagerProvider);
    final tasks = allTasks.where((t) => taskIds.contains(t.id)).toList();

    if (tasks.isEmpty) {
      return ActionSheetScaffold(
        showHandle: false,
        isAdaptive: true,
        isFloating: false,
        hasHorizontalPadding: true,
        backgroundColor: AppColors.secondaryBackground(context),
        backgroundAlpha: 1.0,
        contentPadding: const EdgeInsets.only(bottom: 30),
        child: Center(child: Text(context.l10n.download_taskMissing)),
      );
    }

    final manager = ref.read(downloadManagerProvider.notifier);
    final allDone = tasks.every((t) => t.isDone);
    final anyCompleted = tasks.any((t) => t.status == DownloadStatus.completed);
    final isBatch = taskIds.length > 1;

    return ActionSheetScaffold(
      showHandle: false,
      isAdaptive: true,
      isFloating: false,
      hasHorizontalPadding: true,
      backgroundColor: AppColors.secondaryBackground(context),
      backgroundAlpha: 1.0,
      contentPadding: const EdgeInsets.only(bottom: 30),
      panelHeader: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              isBatch ? TablerIcons.copy : TablerIcons.device_tablet_down,
              size: 32,
              color: CupertinoColors.activeBlue.resolveFrom(context),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isBatch
                        ? context.l10n.download_batchTitle
                        : context.l10n.download_fileTitle,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: AppColors.label(context),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isBatch
                        ? context.l10n.download_taskCount(tasks.length)
                        : tasks.first.remotePath,
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
            const SizedBox(width: 8),
            if (allDone)
              CupertinoButton(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  context.l10n.common_done,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: CupertinoColors.activeBlue,
                  ),
                ),
              )
            else
              const CupertinoActivityIndicator(radius: 9),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.45,
            ),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  ...tasks.map(
                    (task) => _DownloadTaskRow(task: task, manager: manager),
                  ),
                  Container(
                    height: 0.5,
                    color: AppColors.separator(context).withValues(alpha: 0.15),
                  ),
                  _buildDownloadManagerEntry(context),
                  const SizedBox(height: 12),
                  Center(
                    child: Text(
                      allDone
                          ? (anyCompleted
                                ? context.l10n.download_completedHint
                                : context.l10n.download_finishedHint)
                          : context.l10n.download_backgroundHint,
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.tertiaryLabel(
                          context,
                        ).withValues(alpha: 0.4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 与上传 Sheet 底部「添加文件」同构，进入下载管理页
  Widget _buildDownloadManagerEntry(BuildContext context) {
    const accentColor = CupertinoColors.activeBlue;
    return GestureDetector(
      onTap: () => _openDownloadManager(context),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.only(
          left: 12,
          right: 12,
          top: 12,
          bottom: 12,
        ),
        child: Row(
          children: [
            Stack(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: CupertinoDynamicColor.resolve(
                      accentColor,
                      context,
                    ).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: CupertinoDynamicColor.resolve(
                        accentColor,
                        context,
                      ).withValues(alpha: 0.2),
                    ),
                  ),
                ),
                SizedBox(
                  width: 42,
                  height: 42,
                  child: Center(
                    child: Icon(
                      TablerIcons.download,
                      color: CupertinoDynamicColor.resolve(
                        accentColor,
                        context,
                      ),
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    context.l10n.download_managerEntryTitle,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: CupertinoDynamicColor.resolve(
                        accentColor,
                        context,
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    context.l10n.download_managerEntrySubtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.secondaryLabel(context),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 0, 8),
              child: Icon(
                CupertinoIcons.chevron_right,
                size: 14,
                color: CupertinoDynamicColor.resolve(accentColor, context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 单条下载任务行，布局对齐 [FileUploadSheet] 的 `_buildTaskItem`
class _DownloadTaskRow extends StatelessWidget {
  const _DownloadTaskRow({required this.task, required this.manager});

  final DownloadTask task;
  final DownloadManager manager;

  @override
  Widget build(BuildContext context) {
    final showWave =
        task.status == DownloadStatus.downloading ||
        task.status == DownloadStatus.pending;
    final accentColor = CupertinoColors.systemGreen.resolveFrom(context);

    return Column(
      children: [
        Stack(
          children: [
            Positioned.fill(
              child: Container(
                color: AppColors.secondaryBackground(
                  context,
                ).withValues(alpha: 0.5),
              ),
            ),
            if (showWave)
              Positioned.fill(
                child: WaveProgressLayer(
                  progress: task.progress.clamp(0.0, 1.0),
                  color: accentColor.withValues(alpha: 0.12),
                ),
              ),
            Container(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.label(context).withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: _buildFileIcon(task.fileName),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.fileName,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: AppColors.label(context),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        _buildTaskMetadata(context, task),
                      ],
                    ),
                  ),
                  const SizedBox(width: 4),
                  _buildActionButton(context, task),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  static Widget _buildFileIcon(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    IconData icon;
    Color color;

    if (['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(ext)) {
      icon = CupertinoIcons.photo;
      color = CupertinoColors.systemPurple;
    } else if (['mp4', 'mov', 'avi'].contains(ext)) {
      icon = CupertinoIcons.video_camera;
      color = CupertinoColors.systemPink;
    } else if (['zip', 'gz', 'tar', '7z'].contains(ext)) {
      icon = TablerIcons.file_zip;
      color = CupertinoColors.systemOrange;
    } else {
      icon = CupertinoIcons.doc;
      color = CupertinoColors.systemBlue;
    }

    return Icon(icon, color: color, size: 24);
  }

  static Widget _buildTaskMetadata(BuildContext context, DownloadTask task) {
    String text;
    Color? textColor;

    final ext = task.fileName.contains('.')
        ? task.fileName.split('.').last.toUpperCase()
        : 'FILE';

    switch (task.status) {
      case DownloadStatus.pending:
        text = context.l10n.download_pendingMetadata(
          ext,
          formatBytes(task.fileSize),
        );
        break;
      case DownloadStatus.packaging:
        text = context.l10n.download_packagingMetadata(ext);
        break;
      case DownloadStatus.downloading:
        final speedText = task.speed > 0
            ? formatByteRate(task.speed.toInt())
            : '--';
        text =
            '${(task.progress * 100).toStringAsFixed(0)}%  •  $speedText  •  $ext  •  ${formatBytes(task.fileSize)}';
        break;
      case DownloadStatus.failed:
        text = task.errorMessage ?? context.l10n.download_failed;
        textColor = CupertinoColors.systemRed;
        break;
      case DownloadStatus.cancelled:
        text = context.l10n.download_cancelled;
        break;
      case DownloadStatus.completed:
        text = context.l10n.download_completedMetadata(
          ext,
          formatBytes(task.fileSize),
        );
        break;
    }

    return Text(
      text,
      style: TextStyle(
        fontSize: 12,
        color: textColor ?? AppColors.secondaryLabel(context),
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildActionButton(BuildContext context, DownloadTask task) {
    switch (task.status) {
      case DownloadStatus.pending:
      case DownloadStatus.packaging:
      case DownloadStatus.downloading:
        return CupertinoButton(
          padding: const EdgeInsets.all(6),
          minimumSize: Size.zero,
          onPressed: () => manager.cancelDownload(task.id),
          child: Icon(
            TablerIcons.x,
            size: 16,
            color: AppColors.secondaryLabel(context),
          ),
        );
      case DownloadStatus.failed:
      case DownloadStatus.cancelled:
        return CupertinoButton(
          padding: const EdgeInsets.all(6),
          minimumSize: Size.zero,
          onPressed: () => manager.retryDownload(task.id),
          child: const Icon(
            TablerIcons.refresh,
            size: 16,
            color: CupertinoColors.activeBlue,
          ),
        );
      case DownloadStatus.completed:
        return CupertinoButton(
          padding: const EdgeInsets.all(6),
          minimumSize: Size.zero,
          onPressed: () => manager.shareFile(task.id),
          child: const Icon(
            TablerIcons.share_2,
            size: 18,
            color: CupertinoColors.systemGrey,
          ),
        );
    }
  }
}
