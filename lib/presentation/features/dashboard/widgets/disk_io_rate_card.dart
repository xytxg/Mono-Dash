import 'package:flutter/cupertino.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../core/localization/l10n_x.dart';
import '../../../../core/utils/formatter.dart';
import '../models/disk_io_rate.dart';
import 'info_card.dart';

class DashboardDiskIoRateCard extends StatelessWidget {
  const DashboardDiskIoRateCard({
    super.key,
    required this.rate,
    this.loading = false,
  });

  final DiskIoRate rate;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return InfoCard(
      title: l10n.dashboard_diskIoTitle,
      icon: TablerIcons.arrows_down_up,
      iconColor: CupertinoColors.systemOrange.resolveFrom(context),
      loading: loading,
      rows: [
        (l10n.dashboard_read, Formatter.speed(rate.readBytesPerSecond)),
        (l10n.dashboard_write, Formatter.speed(rate.writeBytesPerSecond)),
        (l10n.dashboard_latency, '${rate.latencyMs.toStringAsFixed(2)} ms/op'),
      ],
    );
  }
}
