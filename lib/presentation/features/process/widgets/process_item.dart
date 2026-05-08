import 'package:flutter/cupertino.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../core/localization/l10n_x.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../common/components/more_info_card.dart';
import '../../../common/utils/display_utils.dart';

class ProcessItem extends StatelessWidget {
  const ProcessItem({super.key, required this.item, required this.onTap});

  final Map<String, dynamic> item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final pid = text(item['PID'] ?? item['pid']);
    final name = text(item['name'] ?? item['Name']);
    final status = text(item['status']);
    final cpuPercent = text(item['cpuPercent']);
    final rss = text(item['rss']);
    final username = text(item['username']);
    final threads = intValue(item['numThreads']);
    final connections = intValue(item['numConnections']);
    final cpuValue = doubleValue(item['cpuValue']) ?? 0;
    final rssValue = doubleValue(item['rssValue']) ?? 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: moreCardDecoration(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Row 1: status dot + name + PID + stop button
              Row(
                children: [
                  _StatusDot(status: status),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      name,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.label(context),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    'PID $pid',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.tertiaryLabel(context),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Row 2: CPU progress
              _MetricProgress(
                label: 'CPU',
                value: cpuPercent,
                progress: (cpuValue / 100).clamp(0, 1).toDouble(),
                color: CupertinoColors.systemGreen,
              ),
              const SizedBox(height: 6),
              // Row 3: Memory progress
              _MetricProgress(
                label: context.l10n.process_memory,
                value: rss,
                progress: _memoryProgress(rssValue),
                color: CupertinoColors.systemBlue,
              ),
              const SizedBox(height: 8),
              // Row 4: metadata
              Text(
                [
                  username,
                  if (threads != null) context.l10n.process_threads(threads),
                  if (connections != null)
                    context.l10n.process_connections(connections),
                ].join('  ·  '),
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.secondaryLabel(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _memoryProgress(double rssValue) {
    // rssValue is in bytes; show progress relative to 1GB
    if (rssValue <= 0) return 0;
    return (rssValue / (1024 * 1024 * 1024)).clamp(0, 1).toDouble();
  }
}

class _StatusDot extends StatelessWidget {
  const _StatusDot({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(status).resolveFrom(context);
    return Icon(TablerIcons.circle_filled, size: 8, color: color);
  }

  static CupertinoDynamicColor _statusColor(String status) {
    return switch (status) {
      'running' => CupertinoColors.systemGreen,
      'sleep' || 'idle' => CupertinoColors.systemGrey,
      'stop' || 'zombie' || 'wait' || 'lock' => CupertinoColors.systemRed,
      _ => CupertinoColors.systemGrey,
    };
  }
}

class _MetricProgress extends StatelessWidget {
  const _MetricProgress({
    required this.label,
    required this.value,
    required this.progress,
    required this.color,
  });

  final String label;
  final String value;
  final double progress;
  final CupertinoDynamicColor color;

  @override
  Widget build(BuildContext context) {
    final resolvedColor = color.resolveFrom(context);
    return Row(
      children: [
        SizedBox(
          width: 28,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.tertiaryLabel(context),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            height: 4,
            decoration: BoxDecoration(
              color: resolvedColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(3),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress.clamp(0, 1).toDouble(),
              child: Container(
                decoration: BoxDecoration(
                  color: resolvedColor,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 56,
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.secondaryLabel(context),
            ),
          ),
        ),
      ],
    );
  }
}
