import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show SelectableText;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/localization/l10n_x.dart';
import '../../../core/network/network_exceptions.dart';
import '../../../core/network/dio_client_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/api/log_api.dart';
import '../../../data/dto/common/task_log_dto.dart';
import '../../features/server_detail/providers/active_server_provider.dart';
import '../app_toast.dart';
import 'action_sheet_launcher.dart';
import 'action_sheet_scaffold.dart';

typedef TaskLogReader = Future<TaskLogDto> Function(String taskID);

Future<void> showTaskLogSheet(
  BuildContext context, {
  required String title,
  required String taskID,
  required TaskLogReader reader,
  VoidCallback? onFinished,
}) {
  return showActionSheet<void>(
    context: context,
    builder: (_) => _TaskLogSheet(
      title: title,
      taskID: taskID,
      reader: reader,
      onFinished: onFinished,
    ),
  );
}

class _TaskLogSheet extends ConsumerStatefulWidget {
  const _TaskLogSheet({
    required this.title,
    required this.taskID,
    required this.reader,
    this.onFinished,
  });

  final String title;
  final String taskID;
  final TaskLogReader reader;
  final VoidCallback? onFinished;

  @override
  ConsumerState<_TaskLogSheet> createState() => _TaskLogSheetState();
}

class _TaskLogSheetState extends ConsumerState<_TaskLogSheet> {
  Timer? _timer;
  TaskLogDto? _log;
  Object? _error;
  bool _loading = true;
  bool _exporting = false;
  bool _isExecuting = true;
  bool _finishedNotified = false;

  @override
  void initState() {
    super.initState();
    _load();
    _timer = Timer.periodic(const Duration(seconds: 2), (_) => _load());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final log = await widget.reader(widget.taskID);
      final isExecuting = await _resolveExecuting(log);
      if (!mounted) return;
      setState(() {
        _log = log;
        _isExecuting = isExecuting;
        _error = null;
        _loading = false;
      });
      if (!isExecuting) {
        _timer?.cancel();
        if (!_finishedNotified) {
          _finishedNotified = true;
          widget.onFinished?.call();
        }
      }
    } catch (error) {
      if (!mounted) return;
      _timer?.cancel();
      setState(() {
        _error = error;
        _loading = false;
        _isExecuting = false;
      });
    }
  }

  Future<bool> _resolveExecuting(TaskLogDto log) async {
    if (log.taskStatus.trim().isNotEmpty) return log.isExecuting;

    // Compatibility: 1Panel v2.0.0 omits taskStatus/isExecuting in task logs.
    // This endpoint only reports whether any task is executing, so it is a
    // coarse fallback and may be affected by unrelated tasks.
    final serverId = ref.read(activeServerIdProvider);
    final client = await ref.read(dioClientProvider(serverId).future);
    final count = await LogApi(client).getExecutingTaskCount();
    return count > 0;
  }

  @override
  Widget build(BuildContext context) {
    final log = _log;
    final busy = _loading || _isExecuting;

    return ActionSheetScaffold(
      maxHeightFactor: 0.72,
      showHandle: false,
      isAdaptive: false,
      panelHeader: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
            child: Row(
              children: [
                Icon(
                  TablerIcons.logs,
                  size: 22,
                  color: CupertinoColors.activeBlue.resolveFrom(context),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.label(context),
                    ),
                  ),
                ),
                SizedBox(
                  width: 32,
                  height: 32,
                  child: Center(
                    child: busy
                        ? const CupertinoActivityIndicator()
                        : CupertinoButton(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            onPressed: _exporting ? null : _export,
                            child: _exporting
                                ? const CupertinoActivityIndicator()
                                : Icon(
                                    TablerIcons.share_3,
                                    size: 21,
                                    color: CupertinoColors.activeBlue
                                        .resolveFrom(context),
                                  ),
                          ),
                  ),
                ),
              ],
            ),
          ),
          if (log != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
              child: Row(
                children: [
                  _StatusChip(status: _displayTaskStatus(log)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      log.path,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.secondaryLabel(context),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      child: _error != null
          ? _buildErrorState(_error!)
          : _loading
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 64),
              child: Center(child: CupertinoActivityIndicator()),
            )
          : (log == null || log.lines.isEmpty)
          ? Padding(
              padding: const EdgeInsets.symmetric(vertical: 64),
              child: Center(
                child: Text(
                  context.l10n.taskLog_emptyTitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.secondaryLabel(context),
                  ),
                ),
              ),
            )
          : Column(
              children: [
                ...log.lines.map(
                  (line) => Padding(
                    padding: const EdgeInsets.fromLTRB(18, 0, 18, 7),
                    child: SizedBox(
                      width: double.infinity,
                      child: SelectableText(
                        _stripBanner(line),
                        style: TextStyle(
                          fontSize: 12,
                          height: 1.35,
                          color: AppColors.label(context),
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  String _displayTaskStatus(TaskLogDto log) {
    if (log.taskStatus.trim().isNotEmpty) return log.taskStatus;
    return _isExecuting ? 'Executing' : 'Finished';
  }

  Widget _buildErrorState(Object error) {
    final String msg = error is AppNetworkException
        ? error.message
        : error.toString();
    final lowerMsg = msg.toLowerCase();

    final bool isRecordNotFound = lowerMsg.contains('record not found');
    final bool isFileNotFound = lowerMsg.contains('no such file or directory');

    if (isRecordNotFound || isFileNotFound) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 48),
            Icon(
              TablerIcons.file_off,
              size: 48,
              color: AppColors.tertiaryLabel(context).withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              isFileNotFound
                  ? context.l10n.taskLog_fileNotFoundTitle
                  : context.l10n.taskLog_noRecordTitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AppColors.secondaryLabel(context),
              ),
            ),
            if (isFileNotFound) ...[
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  context.l10n.taskLog_noRecordDescription,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.tertiaryLabel(context),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 48),
          ],
        ),
      );
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              TablerIcons.alert_circle,
              size: 40,
              color: CupertinoColors.systemRed.resolveFrom(context),
            ),
            const SizedBox(height: 12),
            Text(
              context.l10n.taskLog_readFailedTitle,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.label(context),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              msg,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.secondaryLabel(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _export() async {
    final lines = _log?.lines ?? const <String>[];
    final noExportableLogs = context.l10n.taskLog_noExportableLogs;
    final sharePluginMissing = context.l10n.taskLog_sharePluginMissing;
    final sharePluginMissingDescription =
        context.l10n.taskLog_sharePluginMissingDescription;
    final exportFailed = context.l10n.taskLog_exportFailed;
    if (lines.isEmpty) {
      showAppWarningToast(noExportableLogs);
      return;
    }

    setState(() => _exporting = true);
    try {
      final dir = await getTemporaryDirectory();
      final filename = _exportFilename();
      final exportFile = File('${dir.path}/$filename');
      await exportFile.writeAsString(lines.join('\n'));
      await SharePlus.instance.share(
        ShareParams(
          title: filename,
          subject: filename,
          files: [XFile(exportFile.path, mimeType: 'text/plain')],
          fileNameOverrides: [filename],
        ),
      );
    } on MissingPluginException {
      showAppErrorToast(
        sharePluginMissing,
        description: sharePluginMissingDescription,
      );
    } catch (error) {
      showAppErrorToast(exportFailed, description: '$error');
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  /// 移除日志中的横幅装饰，如 "---- text ----" → "text"
  static String _stripBanner(String line) {
    return line.replaceAllMapped(
      RegExp(r'-{3,}\s*(.+?)\s*-{3,}'),
      (m) => m.group(1)!,
    );
  }

  String _exportFilename() {
    final safeTaskID = widget.taskID.trim().replaceAll(
      RegExp(r'[^a-zA-Z0-9._-]+'),
      '_',
    );
    if (safeTaskID.isNotEmpty) return '$safeTaskID.log';
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '$timestamp.log';
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final executing = status.toLowerCase() == 'executing';
    final color = executing
        ? CupertinoColors.systemOrange.resolveFrom(context)
        : CupertinoColors.systemGreen.resolveFrom(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.isEmpty ? 'Pending' : status,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}
