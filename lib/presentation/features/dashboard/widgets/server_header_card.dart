import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../core/localization/l10n_x.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../domain/entities/dashboard.dart';
import '../../../common/components/skeleton_item.dart';
import '../../../common/components/thin_divider.dart';
import '../utils/dashboard_display_helpers.dart';

class DashboardServerHeaderCard extends StatelessWidget {
  const DashboardServerHeaderCard({
    super.key,
    required this.base,
    required this.current,
    required this.lastFetchMs,
    this.displayName,
    this.loading = false,
  });

  final DashboardBase base;
  final DashboardCurrent current;
  final int lastFetchMs;
  final String? displayName;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final distro = firstNotEmpty(base.prettyDistro, base.os);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground(context).withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.separator(context).withValues(alpha: 0.12),
          width: 0.5,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              if (loading)
                const SkeletonItem(width: 44, height: 44, isCircle: true)
              else
                _OsBadge(base: base),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (loading)
                      const SkeletonItem.text(width: 120, height: 17)
                    else
                      Text(
                        (displayName != null && displayName!.isNotEmpty)
                            ? displayName!
                            : (base.hostname.isEmpty
                                  ? l10n.dashboard_serverFallback
                                  : base.hostname),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: AppColors.label(context),
                          letterSpacing: -0.3,
                        ),
                      ),
                    const SizedBox(height: 4),
                    if (loading)
                      const SkeletonItem.text(width: 80, height: 12)
                    else
                      Text(
                        distro,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: AppColors.secondaryLabel(context),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (loading)
                const SkeletonItem(width: 68, height: 24, borderRadius: 6)
              else
                _StatusPill(ms: lastFetchMs),
            ],
          ),
          const SizedBox(height: 16),
          const ThinDivider(),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _HeaderMetric(
                label: l10n.dashboard_uptime,
                value: formatDashboardUptime(current.uptimeSeconds, l10n),
                icon: TablerIcons.clock,
                loading: loading,
              ),
              _HeaderMetric(
                label: l10n.dashboard_load,
                value:
                    '${current.load1.toStringAsFixed(2)}/${current.load5.toStringAsFixed(2)}/${current.load15.toStringAsFixed(2)}',
                icon: TablerIcons.activity,
                alignment: CrossAxisAlignment.center,
                loading: loading,
              ),
              _HeaderMetric(
                label: l10n.dashboard_processes,
                value: '${current.procs}',
                icon: TablerIcons.cpu,
                alignment: CrossAxisAlignment.center,
                loading: loading,
              ),
              _HeaderMetric(
                label: l10n.dashboard_arch,
                value: base.kernelArch,
                icon: TablerIcons.binary,
                alignment: CrossAxisAlignment.end,
                loading: loading,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeaderMetric extends StatelessWidget {
  const _HeaderMetric({
    required this.label,
    required this.value,
    required this.icon,
    this.alignment = CrossAxisAlignment.start,
    this.loading = false,
  });

  final String label;
  final String value;
  final IconData icon;
  final CrossAxisAlignment alignment;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignment,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 10,
              color: AppColors.secondaryLabel(context).withValues(alpha: 0.6),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: AppColors.secondaryLabel(context),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        if (loading)
          const SkeletonItem.text(width: 50, height: 13)
        else
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.label(context),
              height: 1.2,
            ),
          ),
      ],
    );
  }
}

class _OsBadge extends StatelessWidget {
  const _OsBadge({required this.base});

  final DashboardBase base;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.background(context),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            spreadRadius: 0,
          ),
        ],
      ),
      child: SvgPicture.asset(dashboardOsAsset(base), fit: BoxFit.contain),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.ms});

  final int ms;

  @override
  Widget build(BuildContext context) {
    final isSlow = ms > 500;
    final color = isSlow
        ? CupertinoColors.systemOrange.resolveFrom(context)
        : CupertinoColors.systemGreen.resolveFrom(context);

    return Container(
      width: 68,
      height: 24,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.1), width: 0.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(TablerIcons.activity_heartbeat, size: 11, color: color),
          const SizedBox(width: 3),
          Text(
            '${ms}ms',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: color,
              height: 1,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }
}
