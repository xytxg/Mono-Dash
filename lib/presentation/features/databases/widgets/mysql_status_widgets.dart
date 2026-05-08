import 'package:flutter/cupertino.dart';

import '../../../../core/localization/l10n_x.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/format_utils.dart';
import '../../../common/components/info_panel.dart';
import '../../../common/components/info_rows.dart';
import '../../../common/components/skeleton_item.dart';
import '../../../common/components/status_pill.dart';
import '../../../common/components/thin_divider.dart';
import '../models/database_state.dart';
import '../widgets/database_type_icon.dart';

/// MySQL 实例信息卡片（版本、安装路径、状态、端口）。
class MysqlInfoCard extends StatelessWidget {
  const MysqlInfoCard({
    super.key,
    required this.state,
    required this.type,
    this.loading = false,
  });

  final DatabaseManagementState state;
  final String type;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final check = state.checkResult;
    if (!loading && check == null) return const SizedBox.shrink();

    return InfoPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              DatabaseTypeIcon(type: type, size: 34),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      check?.app ??
                          (type.contains('mariadb')
                              ? 'MariaDB'
                              : type.contains('postgresql')
                              ? 'PostgreSQL'
                              : type.contains('redis')
                              ? 'Redis'
                              : 'MySQL'),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.label(context),
                      ),
                    ),
                    const SizedBox(height: 2),
                    if (loading)
                      const SkeletonItem.text(width: 80, height: 16)
                    else
                      Text(
                        context.l10n.databases_versionValue(
                          check?.version ?? '--',
                        ),
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.secondaryLabel(context),
                        ),
                      ),
                  ],
                ),
              ),
              if (loading)
                const SkeletonItem.text(width: 48, height: 20, borderRadius: 10)
              else
                StatusPill(
                  label: check?.status ?? context.l10n.common_unknown,
                  active: check?.status == 'Running',
                ),
            ],
          ),
          const SizedBox(height: 12),
          const ThinDivider(),
          if (loading) ...[
            ConfigRow(
              label: context.l10n.databases_installPath,
              value: '',
              loading: true,
              valueFlex: 2,
            ),
            const ThinDivider(),
            ConfigRow(
              label: context.l10n.databases_port,
              value: '',
              loading: true,
            ),
            const ThinDivider(),
            ConfigRow(
              label: context.l10n.databases_container,
              value: '',
              loading: true,
            ),
          ] else if (check != null) ...[
            ConfigRow(
              label: context.l10n.databases_installPath,
              value: check.installPath.isEmpty ? '--' : check.installPath,
              valueTextAlign: TextAlign.end,
              valueFlex: 2,
            ),
            const ThinDivider(),
            ConfigRow(
              label: context.l10n.databases_port,
              value: check.httpPort > 0 ? '${check.httpPort}' : '--',
              valueTextAlign: TextAlign.end,
            ),
            const ThinDivider(),
            ConfigRow(
              label: context.l10n.databases_container,
              value: check.containerName.isEmpty ? '--' : check.containerName,
              valueTextAlign: TextAlign.end,
            ),
          ],
        ],
      ),
    );
  }
}

/// MySQL 基础参数卡片。
class MysqlBasicStatsCard extends StatelessWidget {
  const MysqlBasicStatsCard({
    super.key,
    required this.status,
    this.loading = false,
  });

  final Map<String, String> status;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    if (!loading && status.isEmpty) return const SizedBox.shrink();

    final uptime = status['Run'] ?? '--';
    final connections = status['Connections'] ?? '0';
    final bytesSent = status['Bytes_sent'] ?? '0';
    final bytesReceived = status['Bytes_received'] ?? '0';
    final questions = status['Questions'] ?? '0';
    final uptimeSeconds = int.tryParse(status['Uptime'] ?? '0') ?? 1;
    final qps = uptimeSeconds > 0
        ? (int.tryParse(questions) ?? 0) / uptimeSeconds
        : 0.0;
    final comCommit = status['Com_commit'] ?? '0';
    final comRollback = status['Com_rollback'] ?? '0';
    final tps = uptimeSeconds > 0
        ? ((int.tryParse(comCommit) ?? 0) + (int.tryParse(comRollback) ?? 0)) /
              uptimeSeconds
        : 0.0;

    return InfoPanel(
      title: context.l10n.databases_basicParams,
      child: Column(
        children: loading
            ? _buildSkeleton(context)
            : [
                ConfigRow(
                  label: context.l10n.databases_startTime,
                  value: uptime,
                  valueTextAlign: TextAlign.end,
                ),
                const ThinDivider(),
                ConfigRow(
                  label: context.l10n.databases_totalConnections,
                  value: connections,
                  valueTextAlign: TextAlign.end,
                ),
                const ThinDivider(),
                ConfigRow(
                  label: context.l10n.databases_sent,
                  value: formatBytes(int.tryParse(bytesSent) ?? 0),
                  valueTextAlign: TextAlign.end,
                ),
                const ThinDivider(),
                ConfigRow(
                  label: context.l10n.databases_received,
                  value: formatBytes(int.tryParse(bytesReceived) ?? 0),
                  valueTextAlign: TextAlign.end,
                ),
                const ThinDivider(),
                ConfigRow(
                  label: context.l10n.databases_queriesPerSecond,
                  value: qps.toStringAsFixed(2),
                  valueTextAlign: TextAlign.end,
                ),
                const ThinDivider(),
                ConfigRow(
                  label: context.l10n.databases_transactionsPerSecond,
                  value: tps.toStringAsFixed(2),
                  valueTextAlign: TextAlign.end,
                ),
                const ThinDivider(),
                ConfigRow(
                  label: 'File',
                  value: status['File'] ?? '--',
                  valueTextAlign: TextAlign.end,
                ),
                const ThinDivider(),
                ConfigRow(
                  label: 'Position',
                  value: status['Position'] ?? '--',
                  valueTextAlign: TextAlign.end,
                ),
              ],
      ),
    );
  }

  List<Widget> _buildSkeleton(BuildContext context) {
    return [
      ConfigRow(
        label: context.l10n.databases_startTime,
        value: '',
        loading: true,
      ),
      const ThinDivider(),
      ConfigRow(
        label: context.l10n.databases_totalConnections,
        value: '',
        loading: true,
      ),
      const ThinDivider(),
      ConfigRow(label: context.l10n.databases_sent, value: '', loading: true),
      const ThinDivider(),
      ConfigRow(
        label: context.l10n.databases_received,
        value: '',
        loading: true,
      ),
      const ThinDivider(),
      ConfigRow(
        label: context.l10n.databases_queriesPerSecond,
        value: '',
        loading: true,
      ),
      const ThinDivider(),
      ConfigRow(
        label: context.l10n.databases_transactionsPerSecond,
        value: '',
        loading: true,
      ),
      const ThinDivider(),
      const ConfigRow(label: 'File', value: '', loading: true),
      const ThinDivider(),
      const ConfigRow(label: 'Position', value: '', loading: true),
    ];
  }
}

/// MySQL 性能参数卡片。
class MysqlPerformanceCard extends StatelessWidget {
  const MysqlPerformanceCard({
    super.key,
    required this.status,
    this.loading = false,
  });

  final Map<String, String> status;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    if (!loading && status.isEmpty) return const SizedBox.shrink();

    final uptimeSeconds = int.tryParse(status['Uptime'] ?? '0') ?? 1;
    final questions = int.tryParse(status['Questions'] ?? '0') ?? 0;
    final qps = uptimeSeconds > 0 ? questions / uptimeSeconds : 0.0;

    final threadsCreated = int.tryParse(status['Threads_created'] ?? '0') ?? 0;
    final connections = int.tryParse(status['Connections'] ?? '0') ?? 0;
    final threadCacheHit = connections > 0
        ? ((connections - threadsCreated) / connections * 100)
        : 0.0;

    final keyReadRequests =
        int.tryParse(status['Key_read_requests'] ?? '0') ?? 0;
    final keyReads = int.tryParse(status['Key_reads'] ?? '0') ?? 0;
    final keyBufferHit = keyReadRequests > 0
        ? ((keyReadRequests - keyReads) / keyReadRequests * 100)
        : 0.0;

    final innodbReadRequests =
        int.tryParse(status['Innodb_buffer_pool_read_requests'] ?? '0') ?? 0;
    final innodbReads =
        int.tryParse(status['Innodb_buffer_pool_reads'] ?? '0') ?? 0;
    final innodbHit = innodbReadRequests > 0
        ? ((innodbReadRequests - innodbReads) / innodbReadRequests * 100)
        : 0.0;

    final qcacheHits = status['Qcache_hits'];
    final qcacheInserts = status['Qcache_inserts'];
    final qcacheHitRate = (qcacheHits == null || qcacheHits.isEmpty)
        ? 'OFF'
        : _qcacheRate(qcacheHits, qcacheInserts);

    final tmpDiskTables = status['Created_tmp_disk_tables'] ?? '0';
    final openTables = status['Open_tables'] ?? '0';
    final selectFullJoin = status['Select_full_join'] ?? '0';
    final selectRangeCheck = status['Select_range_check'] ?? '0';
    final sortMergePasses = status['Sort_merge_passes'] ?? '0';
    final tableLocksWaited = status['Table_locks_waited'] ?? '0';

    return InfoPanel(
      title: context.l10n.databases_performanceParams,
      child: Column(
        children: loading
            ? _buildSkeleton()
            : [
                _PerfRow(
                  label: context.l10n.databases_queriesPerSecond,
                  value: qps.toStringAsFixed(2),
                  hint: context.l10n.databases_qpsHighHint,
                ),
                const ThinDivider(),
                _PerfRow(
                  label: context.l10n.databases_threadCacheHitRate,
                  value: '${threadCacheHit.toStringAsFixed(2)}%',
                  hint: context.l10n.databases_threadCacheLowHint,
                ),
                const ThinDivider(),
                _PerfRow(
                  label: context.l10n.databases_indexHitRate,
                  value: '${keyBufferHit.toStringAsFixed(2)}%',
                  hint: context.l10n.databases_keyBufferLowHint,
                ),
                const ThinDivider(),
                _PerfRow(
                  label: context.l10n.databases_innodbIndexHitRate,
                  value: '${innodbHit.toStringAsFixed(2)}%',
                  hint: context.l10n.databases_innodbBufferLowHint,
                ),
                const ThinDivider(),
                _PerfRow(
                  label: context.l10n.databases_queryCacheHitRate,
                  value: qcacheHitRate,
                  hint: context.l10n.databases_queryCacheLowHint,
                ),
                const ThinDivider(),
                _PerfRow(
                  label: context.l10n.databases_tmpDiskTables,
                  value: tmpDiskTables,
                  hint: context.l10n.databases_tmpDiskTablesHighHint,
                ),
                const ThinDivider(),
                _PerfRow(
                  label: context.l10n.databases_openTables,
                  value: openTables,
                  hint: context.l10n.databases_tableOpenCacheHint,
                ),
                const ThinDivider(),
                _PerfRow(
                  label: context.l10n.databases_noIndexUsage,
                  value: selectFullJoin,
                  hint: context.l10n.databases_indexCheckHint,
                ),
                const ThinDivider(),
                _PerfRow(
                  label: context.l10n.databases_noIndexJoin,
                  value: selectRangeCheck,
                  hint: context.l10n.databases_indexCheckHint,
                ),
                const ThinDivider(),
                _PerfRow(
                  label: context.l10n.databases_sortMergePasses,
                  value: sortMergePasses,
                  hint: context.l10n.databases_sortBufferHighHint,
                ),
                const ThinDivider(),
                _PerfRow(
                  label: context.l10n.databases_tableLocks,
                  value: tableLocksWaited,
                  hint: context.l10n.databases_tableLocksHighHint,
                ),
              ],
      ),
    );
  }

  static String _qcacheRate(String hits, String? inserts) {
    final h = int.tryParse(hits) ?? 0;
    final i = int.tryParse(inserts ?? '0') ?? 0;
    if (h + i == 0) return '0';
    return '${(h / (h + i) * 100).toStringAsFixed(2)}%';
  }

  List<Widget> _buildSkeleton() {
    return const [
      _PerfRowSkeleton(),
      ThinDivider(),
      _PerfRowSkeleton(),
      ThinDivider(),
      _PerfRowSkeleton(),
      ThinDivider(),
      _PerfRowSkeleton(),
      ThinDivider(),
      _PerfRowSkeleton(),
      ThinDivider(),
      _PerfRowSkeleton(),
      ThinDivider(),
      _PerfRowSkeleton(),
      ThinDivider(),
      _PerfRowSkeleton(),
    ];
  }
}

/// 性能参数行骨架。
class _PerfRowSkeleton extends StatelessWidget {
  const _PerfRowSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 9),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonItem.text(width: 60, height: 14),
                SizedBox(height: 5),
                SkeletonItem.text(width: 120, height: 12),
              ],
            ),
          ),
          SizedBox(width: 12),
          SkeletonItem.text(width: 40, height: 16),
        ],
      ),
    );
  }
}

/// 性能参数行，带提示文字。
class _PerfRow extends StatelessWidget {
  const _PerfRow({
    required this.label,
    required this.value,
    required this.hint,
  });

  final String label;
  final String value;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.secondaryLabel(context),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  hint,
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.tertiaryLabel(context),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.label(context),
            ),
          ),
        ],
      ),
    );
  }
}

/// PostgreSQL 状态卡片，渲染 PG status API 返回的原始 key-value 对。
class PgStatusCard extends StatelessWidget {
  const PgStatusCard({super.key, required this.status, this.loading = false});

  final Map<String, String> status;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    if (!loading && status.isEmpty) return const SizedBox.shrink();

    return InfoPanel(
      title: context.l10n.databases_runningStatus,
      child: Column(
        children: loading
            ? _buildSkeleton()
            : status.entries
                  .map(
                    (e) => ConfigRow(
                      label: e.key,
                      value: e.value.isEmpty ? '--' : e.value,
                      valueTextAlign: TextAlign.end,
                    ),
                  )
                  .toList(),
      ),
    );
  }

  List<Widget> _buildSkeleton() {
    return const [
      ConfigRow(label: '', value: '', loading: true),
      ThinDivider(),
      ConfigRow(label: '', value: '', loading: true),
      ThinDivider(),
      ConfigRow(label: '', value: '', loading: true),
    ];
  }
}

/// Redis 基础参数卡片。
class RedisBasicStatsCard extends StatelessWidget {
  const RedisBasicStatsCard({
    super.key,
    required this.status,
    this.loading = false,
  });

  final Map<String, String> status;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    if (!loading && status.isEmpty) return const SizedBox.shrink();

    return InfoPanel(
      title: context.l10n.databases_basicParams,
      child: Column(
        children: loading
            ? _buildSkeleton(context)
            : [
                ConfigRow(
                  label: context.l10n.databases_runningDays,
                  value: context.l10n.databases_daysValue(
                    status['uptime_in_days'] ?? '--',
                  ),
                  valueTextAlign: TextAlign.end,
                ),
                const ThinDivider(),
                ConfigRow(
                  label: context.l10n.databases_listeningPort,
                  value: status['tcp_port'] ?? '--',
                  valueTextAlign: TextAlign.end,
                ),
                const ThinDivider(),
                ConfigRow(
                  label: context.l10n.databases_connectedClients,
                  value: status['connected_clients'] ?? '--',
                  valueTextAlign: TextAlign.end,
                ),
              ],
      ),
    );
  }

  List<Widget> _buildSkeleton(BuildContext context) {
    return [
      ConfigRow(
        label: context.l10n.databases_runningDays,
        value: '',
        loading: true,
      ),
      const ThinDivider(),
      ConfigRow(
        label: context.l10n.databases_listeningPort,
        value: '',
        loading: true,
      ),
      const ThinDivider(),
      ConfigRow(
        label: context.l10n.databases_connectedClients,
        value: '',
        loading: true,
      ),
    ];
  }
}

/// Redis 性能参数卡片。
class RedisPerformanceCard extends StatelessWidget {
  const RedisPerformanceCard({
    super.key,
    required this.status,
    this.loading = false,
  });

  final Map<String, String> status;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    if (!loading && status.isEmpty) return const SizedBox.shrink();

    final usedMemoryRss = status['used_memory_rss'] ?? '0';
    final usedMemory = status['used_memory'] ?? '0';
    final usedMemoryPeak = status['used_memory_peak'] ?? '0';
    final hitRate = _calcHitRate();

    return InfoPanel(
      title: context.l10n.databases_performanceParams,
      child: Column(
        children: loading
            ? _buildSkeleton()
            : [
                _RedisPerfRow(
                  label: context.l10n.databases_memoryRss,
                  value: formatBytes(int.tryParse(usedMemoryRss) ?? 0),
                  hint: context.l10n.databases_memoryRssHint,
                ),
                const ThinDivider(),
                _RedisPerfRow(
                  label: context.l10n.databases_memoryUsed,
                  value: formatBytes(int.tryParse(usedMemory) ?? 0),
                  hint: context.l10n.databases_memoryUsedHint,
                ),
                const ThinDivider(),
                _RedisPerfRow(
                  label: context.l10n.databases_memoryPeak,
                  value: formatBytes(int.tryParse(usedMemoryPeak) ?? 0),
                  hint: context.l10n.databases_memoryPeakHint,
                ),
                const ThinDivider(),
                _RedisPerfRow(
                  label: context.l10n.databases_fragmentationRatio,
                  value: status['mem_fragmentation_ratio'] ?? '--',
                  hint: context.l10n.databases_fragmentationRatioHint,
                ),
                const ThinDivider(),
                _RedisPerfRow(
                  label: context.l10n.databases_totalConnections,
                  value: status['total_connections_received'] ?? '--',
                  hint: context.l10n.databases_totalConnectionsHint,
                ),
                const ThinDivider(),
                _RedisPerfRow(
                  label: context.l10n.databases_totalCommands,
                  value: status['total_commands_processed'] ?? '--',
                  hint: context.l10n.databases_totalCommandsHint,
                ),
                const ThinDivider(),
                _RedisPerfRow(
                  label: context.l10n.databases_opsPerSecond,
                  value: status['instantaneous_ops_per_sec'] ?? '--',
                  hint: context.l10n.databases_opsPerSecondHint,
                ),
                const ThinDivider(),
                _RedisPerfRow(
                  label: context.l10n.databases_hits,
                  value: status['keyspace_hits'] ?? '--',
                  hint: context.l10n.databases_hitsHint,
                ),
                const ThinDivider(),
                _RedisPerfRow(
                  label: context.l10n.databases_misses,
                  value: status['keyspace_misses'] ?? '--',
                  hint: context.l10n.databases_missesHint,
                ),
                const ThinDivider(),
                _RedisPerfRow(
                  label: context.l10n.databases_hitRate,
                  value: hitRate,
                  hint: context.l10n.databases_hitRateHint,
                ),
                const ThinDivider(),
                _RedisPerfRow(
                  label: context.l10n.databases_latestForkTime,
                  value: '${status['latest_fork_usec'] ?? '--'} μs',
                  hint: context.l10n.databases_latestForkTimeHint,
                ),
              ],
      ),
    );
  }

  String _calcHitRate() {
    final hits = int.tryParse(status['keyspace_hits'] ?? '0') ?? 0;
    final misses = int.tryParse(status['keyspace_misses'] ?? '0') ?? 0;
    final total = hits + misses;
    if (total == 0) return 'NaN';
    return '${(hits / total * 100).toStringAsFixed(2)}%';
  }

  List<Widget> _buildSkeleton() {
    return const [
      _RedisPerfRowSkeleton(),
      ThinDivider(),
      _RedisPerfRowSkeleton(),
      ThinDivider(),
      _RedisPerfRowSkeleton(),
      ThinDivider(),
      _RedisPerfRowSkeleton(),
      ThinDivider(),
      _RedisPerfRowSkeleton(),
      ThinDivider(),
      _RedisPerfRowSkeleton(),
    ];
  }
}

/// Redis 性能参数行，带中文标签和描述。
class _RedisPerfRow extends StatelessWidget {
  const _RedisPerfRow({
    required this.label,
    required this.value,
    required this.hint,
  });

  final String label;
  final String value;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.secondaryLabel(context),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  hint,
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.tertiaryLabel(context),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.label(context),
            ),
          ),
        ],
      ),
    );
  }
}

/// Redis 性能参数行骨架。
class _RedisPerfRowSkeleton extends StatelessWidget {
  const _RedisPerfRowSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 9),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonItem.text(width: 60, height: 14),
                SizedBox(height: 5),
                SkeletonItem.text(width: 120, height: 12),
              ],
            ),
          ),
          SizedBox(width: 12),
          SkeletonItem.text(width: 40, height: 16),
        ],
      ),
    );
  }
}
