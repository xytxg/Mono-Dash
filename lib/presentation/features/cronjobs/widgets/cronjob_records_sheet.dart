import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../core/localization/l10n_x.dart';
import '../../../../core/network/dio_client_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/format_utils.dart';
import '../../../../data/api/file_api.dart';
import '../../../../data/dto/common/task_log_dto.dart';
import '../../../../data/dto/cronjob/cronjob_dto.dart';
import '../../../../data/repositories_impl/cronjob_repository_impl.dart';
import '../../../common/components/action_sheet_launcher.dart';
import '../../../common/components/action_sheet_scaffold.dart';
import '../../../common/components/app_action_components.dart';
import '../../../common/components/app_empty_state.dart';
import '../../../common/components/skeleton_item.dart';
import '../../../common/components/status_pill.dart';
import '../../../common/components/task_log_sheet.dart';
import '../../server_detail/providers/active_server_provider.dart';

/// 查看执行记录。
Future<void> showCronjobRecordsSheet(
  BuildContext context, {
  required CronjobDto item,
}) {
  return showActionSheet<void>(
    context: context,
    builder: (ctx) => _CronjobRecordsSheet(item: item),
  );
}

class _CronjobRecordsSheet extends ConsumerStatefulWidget {
  const _CronjobRecordsSheet({required this.item});

  final CronjobDto item;

  @override
  ConsumerState<_CronjobRecordsSheet> createState() =>
      _CronjobRecordsSheetState();
}

class _CronjobRecordsSheetState extends ConsumerState<_CronjobRecordsSheet> {
  List<CronjobRecordDto> _records = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  int _page = 1;
  static const int _pageSize = 20;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  Future<void> _loadRecords({bool isRefresh = false}) async {
    if (isRefresh) {
      _page = 1;
      _hasMore = true;
    }

    if (!_hasMore || (isRefresh ? false : _isLoadingMore)) return;

    if (!isRefresh && _records.isNotEmpty) {
      setState(() => _isLoadingMore = true);
    }

    try {
      final repo = await ref.read(cronjobRepositoryProvider.future);
      final now = DateTime.now();
      final startTime = now.subtract(const Duration(days: 30));
      final data = await repo.searchRecords({
        'page': _page,
        'pageSize': _pageSize,
        'cronjobID': widget.item.id,
        'startTime': startTime.toUtc().toIso8601String(),
        'endTime': now.toUtc().toIso8601String(),
        'status': '',
      });
      if (mounted) {
        setState(() {
          if (isRefresh) {
            _records = data.items;
          } else {
            _records.addAll(data.items);
          }
          _isLoading = false;
          _isLoadingMore = false;
          _hasMore = _records.length < data.total;
          if (data.items.isNotEmpty) _page++;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
          _isLoadingMore = false;
        });
      }
    }
  }

  bool _onScrollNotification(ScrollNotification notification) {
    if (notification is ScrollEndNotification &&
        notification.metrics.pixels >=
            notification.metrics.maxScrollExtent - 100) {
      _loadRecords();
    }
    return false;
  }

  String _formatTime(String raw) {
    return formatLocalDateTime(raw);
  }

  String _statusLabel(BuildContext context, String status) {
    final l10n = context.l10n;
    final s = status.toLowerCase();
    switch (s) {
      case 'success':
        return l10n.cronjobs_statusSuccess;
      case 'failed':
        return l10n.cronjobs_statusFailed;
      case 'waiting':
        return l10n.cronjobs_statusWaiting;
      case 'unexecuted':
        return l10n.cronjobs_statusUnexecuted;
      default:
        return status;
    }
  }

  Color _statusColor(String status) {
    final s = status.toLowerCase();
    switch (s) {
      case 'success':
        return CupertinoColors.systemGreen;
      case 'failed':
        return CupertinoColors.systemRed;
      case 'waiting':
        return CupertinoColors.systemYellow;
      case 'unexecuted':
        return CupertinoColors.systemGrey;
      default:
        return CupertinoColors.systemGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: _onScrollNotification,
      child: ActionSheetScaffold(
        isAdaptive: true,
        showHandle: true,
        maxHeightFactor: 0.8,
        title: context.l10n.cronjobs_recordsTitle(widget.item.name),
        child: _isLoading
            ? Column(
                children: List.generate(
                  5,
                  (i) => const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: SkeletonItem(width: double.infinity, height: 72),
                  ),
                ),
              )
            : _error != null
            ? AppEmptyState(
                icon: TablerIcons.alert_triangle,
                title: context.l10n.common_loadingFailed,
                subtitle: _error,
                actionLabel: context.l10n.common_retry,
                onAction: () {
                  setState(() {
                    _isLoading = true;
                    _error = null;
                  });
                  _loadRecords(isRefresh: true);
                },
              )
            : _records.isEmpty
            ? AppEmptyState(
                icon: TablerIcons.notes,
                title: context.l10n.cronjobs_noRecordsTitle,
                subtitle: context.l10n.cronjobs_noRecordsSubtitle,
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppActionGroup(
                    dividerPadding: EdgeInsets.zero,
                    children: [
                      for (final record in _records)
                        _buildRecordItem(context, record),
                    ],
                  ),
                  if (_isLoadingMore)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: CupertinoActivityIndicator(),
                    ),
                  const SizedBox(height: 24),
                ],
              ),
      ),
    );
  }

  Widget _buildRecordItem(BuildContext context, CronjobRecordDto record) {
    final statusColor = _statusColor(record.status);
    final s = record.status.toLowerCase();

    return AppActionRow(
      title: _formatTime(record.startTime),
      subtitle: record.message.isNotEmpty
          ? Text(record.message)
          : Text(
              s == 'success'
                  ? context.l10n.cronjobs_taskRunSuccess
                  : context.l10n.cronjobs_noDetails,
            ),
      onTap: record.taskID.isNotEmpty ? () => _viewLog(record) : () {},
      enabled: record.taskID.isNotEmpty,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          StatusPill(
            label: _statusLabel(context, record.status),
            active: s == 'success',
            activeColor: statusColor,
            inactiveColor: statusColor,
          ),
          if (record.taskID.isNotEmpty) ...[
            const SizedBox(width: 8),
            Icon(
              TablerIcons.chevron_right,
              size: 14,
              color: AppColors.tertiaryLabel(context).withValues(alpha: 0.5),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _viewLog(CronjobRecordDto record) async {
    showTaskLogSheet(
      context,
      title: context.l10n.cronjobs_executionLog,
      taskID: record.taskID,
      reader: (_) async {
        final serverId = ref.read(activeServerIdProvider);
        final client = await ref.read(dioClientProvider(serverId).future);
        final api = FileApi(client);
        return await api.readFile<TaskLogDto>(
          type: 'task',
          taskID: record.taskID,
          fromJson: TaskLogDto.fromJson,
          page: 1,
          pageSize: 500,
          latest: true,
        );
      },
    );
  }
}
