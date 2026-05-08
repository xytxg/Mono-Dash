import 'package:flutter/cupertino.dart';

import '../../../../core/localization/l10n_x.dart';
import '../../../../core/utils/formatter.dart';
import '../../../../domain/entities/dashboard.dart';
import 'info_card.dart';

class DashboardProcessSection extends StatelessWidget {
  const DashboardProcessSection({
    super.key,
    required this.current,
    this.loading = false,
  });

  final DashboardCurrent current;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final rows = <(String, String)>[
      if (loading) ...[
        (l10n.dashboard_loading, ''),
        (l10n.dashboard_loading, ''),
        (l10n.dashboard_loading, ''),
      ] else ...[
        for (final item in current.topCpuItems.take(3))
          (
            item.name.isEmpty ? 'PID ${item.pid}' : item.name,
            'CPU ${Formatter.percent(item.percent)} · ${Formatter.bytes(item.memory)}',
          ),
        for (final item in current.topMemItems.take(3))
          (
            item.name.isEmpty ? 'PID ${item.pid}' : item.name,
            'MEM ${Formatter.bytes(item.memory)} · ${item.user}',
          ),
      ],
    ];

    return InfoCard(
      title: l10n.dashboard_processes,
      rows: rows,
      loading: loading,
    );
  }
}
