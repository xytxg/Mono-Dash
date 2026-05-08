import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../core/localization/l10n_x.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/api/process_api.dart';
import '../../../../core/network/dio_client_provider.dart';
import '../../../common/components/action_sheet_launcher.dart';
import '../../../common/components/action_sheet_scaffold.dart';
import '../../../common/components/action_sheet_info_card.dart';
import '../../../common/components/app_action_components.dart';
import '../../../common/components/app_confirm_sheet.dart';
import '../../../common/utils/display_utils.dart';
import '../../server_detail/providers/active_server_provider.dart';
import '../../../common/app_toast.dart';

void showProcessDetailSheet(
  BuildContext context, {
  required int pid,
  required WidgetRef ref,
  Map<String, dynamic>? summary,
}) {
  showActionSheet<void>(
    context: context,
    builder: (context) => _ProcessDetailSheet(pid: pid, summary: summary),
  );
}

class _ProcessDetailSheet extends ConsumerStatefulWidget {
  const _ProcessDetailSheet({required this.pid, this.summary});

  final int pid;
  final Map<String, dynamic>? summary;

  @override
  ConsumerState<_ProcessDetailSheet> createState() =>
      _ProcessDetailSheetState();
}

class _ProcessDetailSheetState extends ConsumerState<_ProcessDetailSheet> {
  Map<String, dynamic>? _detail;
  Object? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final serverId = ref.read(activeServerIdProvider);
      final api = ProcessApi(
        await ref.read(dioClientProvider(serverId).future),
      );
      final data = await api.getProcessByPID(widget.pid);
      if (!mounted) return;
      setState(() {
        _detail = data;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final summary = widget.summary;
    final detail = _detail;
    final name = text(detail?['name'] ?? summary?['name']);
    final status = text(detail?['status'] ?? summary?['status']);
    final pid = widget.pid;

    return ActionSheetScaffold(
      isAdaptive: true,
      showHandle: false,
      maxHeightFactor: 0.86,
      infoCard: ActionSheetInfoCard(
        leading: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: CupertinoColors.systemGreen
                .resolveFrom(context)
                .withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Icon(
              TablerIcons.cpu,
              size: 30,
              color: CupertinoColors.systemGreen.resolveFrom(context),
            ),
          ),
        ),
        title: name,
        subtitle: 'PID $pid',
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _StatusBadge(status: status),
            const SizedBox(width: 8),
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () => _stop(context),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: CupertinoColors.systemRed
                      .resolveFrom(context)
                      .withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  TablerIcons.player_stop,
                  size: 18,
                  color: CupertinoColors.systemRed.resolveFrom(context),
                ),
              ),
            ),
          ],
        ),
      ),
      child: _loading
          ? const _DetailLoading()
          : _error != null
          ? _DetailError(error: _error!, onRetry: _load)
          : _DetailContent(detail: detail!, pid: pid),
    );
  }

  Future<void> _stop(BuildContext context) async {
    final l10n = context.l10n;
    final confirmed = await showCupertinoModalPopup<bool>(
      context: context,
      builder: (_) => AppConfirmSheet(
        title: l10n.process_stopTitle,
        content: l10n.process_stopContent(widget.pid),
        confirmText: l10n.process_stopAction,
        confirmColor: CupertinoColors.systemRed,
      ),
    );
    if (confirmed != true) return;
    try {
      final serverId = ref.read(activeServerIdProvider);
      final api = ProcessApi(
        await ref.read(dioClientProvider(serverId).future),
      );
      await api.stopProcess(widget.pid);
      if (context.mounted) Navigator.pop(context);
      showAppSuccessToast(l10n.process_stopRequested);
    } catch (e) {
      showAppErrorToast(l10n.process_stopFailed, description: '$e');
    }
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      'running' => CupertinoColors.systemGreen,
      'sleep' || 'idle' => CupertinoColors.systemGrey,
      'stop' || 'zombie' => CupertinoColors.systemRed,
      _ => CupertinoColors.systemGrey,
    };
    return Container(
      height: 30,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: color.resolveFrom(context).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            TablerIcons.circle_filled,
            size: 8,
            color: color.resolveFrom(context),
          ),
          const SizedBox(width: 6),
          Text(
            status,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color.resolveFrom(context),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailLoading extends StatelessWidget {
  const _DetailLoading();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 42),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CupertinoActivityIndicator(),
            const SizedBox(height: 12),
            Text(
              context.l10n.process_readingDetail,
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
}

class _DetailError extends StatelessWidget {
  const _DetailError({required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return _InfoGroup(
      children: [
        _InfoRow(
          icon: TablerIcons.alert_circle,
          label: context.l10n.process_readFailed,
          value: error.toString(),
        ),
      ],
    );
  }
}

class _DetailContent extends StatelessWidget {
  const _DetailContent({required this.detail, required this.pid});

  final Map<String, dynamic> detail;
  final int pid;

  @override
  Widget build(BuildContext context) {
    final openFiles = (detail['openFiles'] as List?) ?? [];
    final connects = (detail['connects'] as List?) ?? [];
    final envs = (detail['envs'] as List?) ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section 1: Basic info
        AppSectionHeader(
          title: context.l10n.process_basicInfo,
          icon: TablerIcons.info_circle,
        ),
        _InfoGroup(
          children: [
            _InfoRow(icon: TablerIcons.hash, label: 'PID', value: '$pid'),
            _InfoRow(
              icon: TablerIcons.hash,
              label: 'PPID',
              value: text(detail['PPID']),
            ),
            _InfoRow(
              icon: TablerIcons.user_circle,
              label: context.l10n.process_user,
              value: text(detail['username']),
            ),
            _InfoRow(
              icon: TablerIcons.activity,
              label: context.l10n.process_status,
              value: text(detail['status']),
            ),
            _InfoRow(
              icon: TablerIcons.clock,
              label: context.l10n.process_startTime,
              value: text(detail['startTime']),
            ),
            _InfoRow(
              icon: TablerIcons.cpu,
              label: context.l10n.process_threadCount,
              value: text(detail['numThreads']),
            ),
            _InfoRow(
              icon: TablerIcons.plug,
              label: context.l10n.process_connectionCount,
              value: text(detail['numConnections']),
            ),
            _InfoRow(
              icon: TablerIcons.terminal,
              label: context.l10n.process_commandLine,
              value: text(detail['cmdLine']),
            ),
          ],
        ),

        // Section 2: CPU / Disk
        const SizedBox(height: 18),
        AppSectionHeader(
          title: context.l10n.process_cpuDisk,
          icon: TablerIcons.activity,
        ),
        _InfoGroup(
          children: [
            _InfoRow(
              icon: TablerIcons.cpu,
              label: 'CPU',
              value: text(detail['cpuPercent']),
            ),
            _InfoRow(
              icon: TablerIcons.download,
              label: context.l10n.process_diskRead,
              value: text(detail['diskRead']),
            ),
            _InfoRow(
              icon: TablerIcons.upload,
              label: context.l10n.process_diskWrite,
              value: text(detail['diskWrite']),
            ),
          ],
        ),

        // Section 3: Memory
        const SizedBox(height: 18),
        AppSectionHeader(
          title: context.l10n.process_memoryDetails,
          icon: TablerIcons.cpu_2,
        ),
        _InfoGroup(
          children: [
            _InfoRow(
              icon: TablerIcons.server,
              label: 'RSS',
              value: text(detail['rss']),
            ),
            _InfoRow(
              icon: TablerIcons.server,
              label: 'VMS',
              value: text(detail['vms']),
            ),
            _InfoRow(
              icon: TablerIcons.server,
              label: 'PSS',
              value: text(detail['pss']),
            ),
            _InfoRow(
              icon: TablerIcons.server,
              label: 'USS',
              value: text(detail['uss']),
            ),
            _InfoRow(
              icon: TablerIcons.server,
              label: 'HWM',
              value: text(detail['hwm']),
            ),
            _InfoRow(
              icon: TablerIcons.server,
              label: 'Shared',
              value: text(detail['shared']),
            ),
            _InfoRow(
              icon: TablerIcons.server,
              label: 'Swap',
              value: text(detail['swap']),
            ),
            _InfoRow(
              icon: TablerIcons.server,
              label: 'Dirty',
              value: text(detail['dirty']),
            ),
          ],
        ),

        // Section 4: Open files
        if (openFiles.isNotEmpty) ...[
          const SizedBox(height: 18),
          AppSectionHeader(
            title: context.l10n.process_openFiles,
            icon: TablerIcons.file,
          ),
          _InfoGroup(
            children: [
              for (final f in openFiles)
                _InfoRow(
                  icon: TablerIcons.file,
                  label: 'fd ${text((f as Map)['fd'])}',
                  value: text(f['path']),
                ),
            ],
          ),
        ],

        // Section 5: Network connections
        if (connects.isNotEmpty) ...[
          const SizedBox(height: 18),
          AppSectionHeader(
            title: context.l10n.process_networkConnections,
            icon: TablerIcons.network,
          ),
          _InfoGroup(
            children: [
              for (final c in connects)
                _ConnectionRow(conn: c as Map<String, dynamic>),
            ],
          ),
        ],

        // Section 6: Environment variables
        if (envs.isNotEmpty) ...[
          const SizedBox(height: 18),
          AppSectionHeader(
            title: context.l10n.process_environmentVariables,
            icon: TablerIcons.terminal,
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.secondaryBackground(
                context,
              ).withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              envs.join('\n'),
              style: TextStyle(
                fontSize: 12,
                height: 1.5,
                fontFamily: 'monospace',
                color: AppColors.secondaryLabel(context),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _ConnectionRow extends StatelessWidget {
  const _ConnectionRow({required this.conn});

  final Map<String, dynamic> conn;

  @override
  Widget build(BuildContext context) {
    final type = text(conn['type']);
    final status = text(conn['status']);
    final local = _formatAddr(conn['localaddr']);
    final remote = _formatAddr(conn['remoteaddr']);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: CupertinoColors.activeBlue
                  .resolveFrom(context)
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(
              TablerIcons.plug_connected,
              size: 16,
              color: CupertinoColors.activeBlue.resolveFrom(context),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      type,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.label(context),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      status,
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.secondaryLabel(context),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '$local → $remote',
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: 'monospace',
                    color: AppColors.secondaryLabel(context),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatAddr(dynamic addr) {
    if (addr == null) return '--';
    if (addr is Map) {
      final ip = addr['ip']?.toString() ?? '';
      final port = addr['port']?.toString() ?? '';
      if (ip.isEmpty && port.isEmpty) return '--';
      return '$ip:$port';
    }
    return addr.toString();
  }
}

class _InfoGroup extends StatelessWidget {
  const _InfoGroup({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground(context).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: children.asMap().entries.map((entry) {
          final isLast = entry.key == children.length - 1;
          return Column(
            children: [
              entry.value,
              if (!isLast)
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

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: CupertinoColors.systemGreen
                  .resolveFrom(context)
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(
              icon,
              size: 16,
              color: CupertinoColors.systemGreen.resolveFrom(context),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 30),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.secondaryLabel(context),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            flex: 2,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 30),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  value,
                  textAlign: TextAlign.right,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.label(context),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
