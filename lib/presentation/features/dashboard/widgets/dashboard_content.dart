import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

import '../providers/dashboard_provider.dart';
import '../utils/dashboard_display_helpers.dart';
import 'accelerator_cards.dart';
import 'disk_io_rate_card.dart';
import 'disk_usage_list_card.dart';
import 'host_details_card.dart';
import 'network_traffic_card.dart';
import 'process_section.dart';
import 'resource_usage_card.dart';
import 'server_header_card.dart';
import 'speed_chart_binding.dart';

class DashboardContent extends StatelessWidget {
  const DashboardContent({
    super.key,
    required this.state,
    required this.nowNotifier,
    this.displayName,
    this.loading = false,
  });

  final DashboardViewState state;
  final ValueListenable<DateTime> nowNotifier;
  final String? displayName;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final data = state.dashboard;
    final base = data.base;
    final cur = data.current;
    final disks = visibleDashboardDisks(cur.disks);
    final primaryDisk = primaryDashboardDisk(cur.disks);

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 132),
      sliver: SliverList.list(
        children: [
          DashboardServerHeaderCard(
            base: base,
            current: cur,
            lastFetchMs: state.lastFetchMs,
            displayName: displayName,
            loading: loading,
          ),
          const SizedBox(height: 12),
          DashboardResourceUsageCard(
            base: base,
            current: cur,
            disk: primaryDisk,
            loading: loading,
          ),
          const SizedBox(height: 12),
          DashboardNetworkTrafficCard(current: cur, loading: loading),
          const SizedBox(height: 12),
          SpeedChartBinding(
            downloadHistory: state.downloadHistory,
            uploadHistory: state.uploadHistory,
            nowNotifier: nowNotifier,
            loading: loading,
          ),
          const SizedBox(height: 12),
          DashboardDiskIoRateCard(rate: state.ioRate, loading: loading),
          if (loading || disks.isNotEmpty) ...[
            const SizedBox(height: 12),
            DashboardDiskUsageListCard(disks: disks, loading: loading),
          ],
          const SizedBox(height: 12),
          DashboardHostDetailsCard(base: base, loading: loading),
          if (loading || cur.topCpuItems.isNotEmpty || cur.topMemItems.isNotEmpty) ...[
            const SizedBox(height: 12),
            DashboardProcessSection(current: cur, loading: loading),
          ],
          if (loading || cur.gpus.isNotEmpty) ...[
            const SizedBox(height: 12),
            DashboardGpuCard(items: cur.gpus, loading: loading),
          ],
          if (loading || cur.xpus.isNotEmpty) ...[
            const SizedBox(height: 12),
            DashboardXpuCard(items: cur.xpus, loading: loading),
          ],
        ],
      ),
    );
  }
}
