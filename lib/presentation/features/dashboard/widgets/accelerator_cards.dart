import 'package:flutter/cupertino.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../core/localization/l10n_x.dart';
import '../../../../core/utils/formatter.dart';
import '../../../../domain/entities/dashboard.dart';
import 'info_card.dart';

class DashboardGpuCard extends StatelessWidget {
  const DashboardGpuCard({
    super.key,
    required this.items,
    this.loading = false,
  });

  final List<GpuInfo> items;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return InfoCard(
      title: 'GPU',
      icon: TablerIcons.device_analytics,
      iconColor: CupertinoColors.systemOrange.resolveFrom(context),
      loading: loading,
      rows: [
        if (loading)
          (l10n.dashboard_loading, '')
        else
          for (final item in items)
            (
              '#${item.index} ${item.productName}',
              [
                l10n.dashboard_utilization(Formatter.percent(item.utilPercent)),
                if (item.memTotalBytes > 0)
                  l10n.dashboard_vram(
                    Formatter.adaptiveBytes(item.memUsedBytes),
                    Formatter.adaptiveBytes(item.memTotalBytes),
                  ),
                if (item.temperatureC > 0)
                  l10n.dashboard_temperature(
                    item.temperatureC.toStringAsFixed(0),
                  ),
              ].join(' · '),
            ),
      ],
    );
  }
}

class DashboardXpuCard extends StatelessWidget {
  const DashboardXpuCard({
    super.key,
    required this.items,
    this.loading = false,
  });

  final List<XpuInfo> items;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return InfoCard(
      title: 'XPU',
      icon: TablerIcons.device_analytics,
      iconColor: CupertinoColors.systemPink.resolveFrom(context),
      loading: loading,
      rows: [
        if (loading)
          (l10n.dashboard_loading, '')
        else
          for (final item in items)
            (
              '#${item.deviceId} ${item.deviceName}',
              [
                if (item.memoryBytes > 0)
                  l10n.dashboard_vram(
                    Formatter.adaptiveBytes(item.memoryUsedBytes),
                    Formatter.adaptiveBytes(item.memoryBytes),
                  ),
                if (item.temperatureC > 0)
                  l10n.dashboard_temperature(
                    item.temperatureC.toStringAsFixed(0),
                  ),
              ].join(' · '),
            ),
      ],
    );
  }
}
