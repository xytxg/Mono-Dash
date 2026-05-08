import 'package:flutter/cupertino.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../core/localization/l10n_x.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatter.dart';
import '../../../../domain/entities/dashboard.dart';
import '../../../common/components/info_panel.dart';
import '../../../common/components/skeleton_item.dart';
import '../../../common/components/thin_divider.dart';

class DashboardNetworkTrafficCard extends StatelessWidget {
  const DashboardNetworkTrafficCard({
    super.key,
    required this.current,
    this.loading = false,
  });

  final DashboardCurrent current;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return InfoPanel(
      title: l10n.dashboard_networkTrafficTitle,
      icon: TablerIcons.activity,
      iconColor: CupertinoColors.activeBlue.resolveFrom(context),
      child: Column(
        children: [
          _TrafficRow(
            label: l10n.dashboard_trafficUp,
            value: Formatter.adaptiveBytes(current.netBytesSent),
            icon: TablerIcons.arrow_up_right,
            color: CupertinoColors.systemGreen.resolveFrom(context),
            loading: loading,
          ),
          const ThinDivider(indent: 44),
          _TrafficRow(
            label: l10n.dashboard_trafficDown,
            value: Formatter.adaptiveBytes(current.netBytesRecv),
            icon: TablerIcons.arrow_down_left,
            color: CupertinoColors.systemBlue.resolveFrom(context),
            loading: loading,
          ),
        ],
      ),
    );
  }
}

class _TrafficRow extends StatelessWidget {
  const _TrafficRow({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.loading = false,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
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
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.label(context),
              height: 1.1,
            ),
          ),
          const Spacer(),
          if (loading)
            const SkeletonItem.text(width: 80, height: 14)
          else
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.label(context),
                height: 1.1,
                letterSpacing: -0.2,
              ),
            ),
        ],
      ),
    );
  }
}
