import 'package:flutter/cupertino.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../core/localization/l10n_x.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatter.dart';
import '../../../../domain/entities/dashboard.dart';
import '../../../common/components/info_panel.dart';
import '../../../common/components/skeleton_item.dart';
import '../../../common/components/thin_divider.dart';
import '../utils/dashboard_display_helpers.dart';
import 'dashboard_linear_meter.dart';

class DashboardResourceUsageCard extends StatelessWidget {
  const DashboardResourceUsageCard({
    super.key,
    required this.base,
    required this.current,
    required this.disk,
    this.loading = false,
  });

  final DashboardBase base;
  final DashboardCurrent current;
  final DiskUsage? disk;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return InfoPanel(
      title: l10n.dashboard_resourceUsageTitle,
      icon: TablerIcons.cpu,
      iconColor: CupertinoColors.systemGreen.resolveFrom(context),
      child: Column(
        children: [
          _ResourceMetricRow(
            icon: TablerIcons.cpu,
            label: 'CPU',
            percent: current.cpuUsedPercent,
            value: formatDashboardCpuUsage(base, current),
            color: CupertinoColors.systemGreen.resolveFrom(context),
            loading: loading,
          ),
          const ThinDivider(indent: 44),
          _ResourceMetricRow(
            icon: TablerIcons.device_sd_card,
            label: l10n.dashboard_memory,
            percent: current.memoryUsedPercent,
            value:
                '${Formatter.adaptiveBytes(current.memoryUsed)} / ${Formatter.adaptiveBytes(current.memoryTotal)}',
            color: CupertinoColors.systemPurple.resolveFrom(context),
            loading: loading,
          ),
          if (loading || current.swapMemoryTotal > 0) ...[
            const ThinDivider(indent: 44),
            _ResourceMetricRow(
              icon: TablerIcons.arrows_diagonal,
              label: 'Swap',
              percent: current.swapMemoryUsedPercent,
              value:
                  '${Formatter.adaptiveBytes(current.swapMemoryUsed)} / ${Formatter.adaptiveBytes(current.swapMemoryTotal)}',
              color: CupertinoColors.systemOrange.resolveFrom(context),
              loading: loading,
            ),
          ],
          if (loading || disk != null) ...[
            const ThinDivider(indent: 44),
            _ResourceMetricRow(
              icon: TablerIcons.database,
              label: l10n.dashboard_disk,
              percent: disk?.usedPercent ?? 0,
              value: disk == null
                  ? ''
                  : '${Formatter.adaptiveBytes(disk!.used)} / ${Formatter.adaptiveBytes(disk!.total)}',
              color: disk == null
                  ? CupertinoColors.systemBlue.resolveFrom(context)
                  : dashboardUsageColor(context, disk!.usedPercent),
              loading: loading,
            ),
          ],
        ],
      ),
    );
  }
}

class _ResourceMetricRow extends StatelessWidget {
  const _ResourceMetricRow({
    required this.icon,
    required this.label,
    required this.percent,
    required this.value,
    required this.color,
    this.loading = false,
  });

  final IconData icon;
  final String label;
  final double percent;
  final String value;
  final Color color;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final clampedPercent = percent.clamp(0.0, 100.0).toDouble();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.label(context),
                      ),
                    ),
                    if (loading)
                      const SkeletonItem.text(width: 80, height: 11)
                    else
                      Text(
                        value,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AppColors.secondaryLabel(context),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Stack(
                  children: [
                    DashboardLinearMeter(
                      percent: 100,
                      color: AppColors.separator(
                        context,
                      ).withValues(alpha: 0.05),
                    ),
                    if (!loading)
                      DashboardLinearMeter(
                        percent: clampedPercent,
                        color: color,
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 38,
            child: loading
                ? const Align(
                    alignment: Alignment.centerRight,
                    child: SkeletonItem.text(width: 28, height: 13),
                  )
                : Text(
                    '${clampedPercent.toStringAsFixed(0)}%',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.label(context),
                      letterSpacing: -0.2,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
