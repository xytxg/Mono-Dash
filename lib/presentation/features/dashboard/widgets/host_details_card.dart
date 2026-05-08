import 'package:flutter/cupertino.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../core/localization/l10n_x.dart';
import '../../../../domain/entities/dashboard.dart';
import '../utils/dashboard_display_helpers.dart';
import 'info_card.dart';

class DashboardHostDetailsCard extends StatelessWidget {
  const DashboardHostDetailsCard({
    super.key,
    required this.base,
    this.loading = false,
  });

  final DashboardBase base;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return InfoCard(
      title: l10n.dashboard_hostDetailsTitle,
      icon: TablerIcons.server,
      iconColor: CupertinoColors.systemGrey.resolveFrom(context),
      loading: loading,
      rows: [
        (l10n.dashboard_system, firstNotEmpty(base.prettyDistro, base.os)),
        if (loading || base.ipV4Addr.isNotEmpty) ('IPv4', base.ipV4Addr),
        if (loading || base.kernelVersion.isNotEmpty)
          (l10n.dashboard_kernel, '${base.kernelVersion} (${base.kernelArch})'),
        if (loading || base.cpuModelName.isNotEmpty) ('CPU', base.cpuModelName),
        (
          l10n.dashboard_cpuCores,
          l10n.dashboard_cpuCoreSummary(base.cpuCores, base.cpuLogicalCores),
        ),
      ],
    );
  }
}
