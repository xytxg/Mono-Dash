import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../../core/localization/l10n_x.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/dto/container/container_search_dto.dart';
import '../../../../data/dto/container/container_stats_dto.dart';
import '../../../common/components/app_picker.dart';
import '../../../common/components/action_sheet_launcher.dart';
import '../../../common/components/sheet_panel.dart';
import '../../../common/components/sheet_handle.dart';
import '../providers/container_monitor_provider.dart';

void showContainerMonitorSheet(
  BuildContext context,
  WidgetRef ref,
  ContainerItemDto container,
) {
  showActionSheet(
    context: context,
    builder: (context) => _ContainerMonitorSheet(container: container),
  );
}

class _ContainerMonitorSheet extends ConsumerWidget {
  const _ContainerMonitorSheet({required this.container});

  final ContainerItemDto container;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(containerMonitorProvider(container.containerID));
    final controller = ref.read(
      containerMonitorProvider(container.containerID).notifier,
    );

    return ActionSheetPanel(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const ActionSheetHandle(),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n.containers_realtimeMonitor,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.label(context),
                        ),
                      ),
                      Text(
                        container.name,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.secondaryLabel(context),
                        ),
                      ),
                    ],
                  ),
                ),
                AppOverlayPicker<int>(
                  width: 100,
                  options: [
                    AppPickerOption(
                      value: 1,
                      label: context.l10n.containers_intervalSeconds(1),
                    ),
                    AppPickerOption(
                      value: 2,
                      label: context.l10n.containers_intervalSeconds(2),
                    ),
                    AppPickerOption(
                      value: 5,
                      label: context.l10n.containers_intervalSeconds(5),
                    ),
                    AppPickerOption(
                      value: 10,
                      label: context.l10n.containers_intervalSeconds(10),
                    ),
                  ],
                  value: state.intervalSeconds,
                  onChanged: controller.setInterval,
                ),
              ],
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                16,
                0,
                16,
                MediaQuery.paddingOf(context).bottom + 24,
              ),
              child: state.isLoading && state.history.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(48),
                      child: Center(child: CupertinoActivityIndicator()),
                    )
                  : Column(
                      children: [
                        _StatCard(
                          title: context.l10n.containers_cpuUsage,
                          icon: TablerIcons.cpu,
                          color: CupertinoColors.systemBlue,
                          value:
                              '${state.history.lastOrNull?.cpuPercent.toStringAsFixed(2) ?? '0.00'}%',
                          child: _MonitorChart(
                            data: state.history
                                .map((e) => e.cpuPercent)
                                .toList(),
                            totalCount: state.totalPointsCount,
                            color: CupertinoColors.systemBlue,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _StatCard(
                          title: context.l10n.containers_memoryUsage,
                          icon: TablerIcons.device_sd_card,
                          color: CupertinoColors.systemGreen,
                          value:
                              '${state.history.lastOrNull?.memory.toStringAsFixed(1) ?? '0.0'} MB',
                          child: _MonitorChart(
                            data: state.history.map((e) => e.memory).toList(),
                            totalCount: state.totalPointsCount,
                            color: CupertinoColors.systemGreen,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _StatCard(
                          title: context.l10n.containers_networkTraffic,
                          icon: TablerIcons.arrows_up_down,
                          color: CupertinoColors.systemOrange,
                          value:
                              '${state.history.lastOrNull?.networkRX.toStringAsFixed(1) ?? '0.0'} / ${state.history.lastOrNull?.networkTX.toStringAsFixed(1) ?? '0.0'} KB',
                          child: _MonitorChart(
                            data: state.history
                                .map((e) => e.networkRX)
                                .toList(),
                            data2: state.history
                                .map((e) => e.networkTX)
                                .toList(),
                            totalCount: state.totalPointsCount,
                            color: CupertinoColors.systemOrange,
                            color2: CupertinoColors.systemOrange.withValues(
                              alpha: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _StatCard(
                          title: context.l10n.containers_diskIo,
                          icon: TablerIcons.database,
                          color: CupertinoColors.systemPurple,
                          value:
                              '${state.history.lastOrNull?.ioRead.toStringAsFixed(2) ?? '0.00'} / ${state.history.lastOrNull?.ioWrite.toStringAsFixed(2) ?? '0.00'} MB',
                          child: _MonitorChart(
                            data: state.history.map((e) => e.ioRead).toList(),
                            data2: state.history.map((e) => e.ioWrite).toList(),
                            totalCount: state.totalPointsCount,
                            color: CupertinoColors.systemPurple,
                            color2: CupertinoColors.systemPurple.withValues(
                              alpha: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.value,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Color color;
  final String value;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground(context).withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.separator(context).withValues(alpha: 0.1),
          width: 0.5,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: color),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.label(context),
                ),
              ),
              const Spacer(),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: color,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(height: 100, child: child),
        ],
      ),
    );
  }
}

(double, double) _dynamicYRange(
  List<double> series1,
  List<double>? series2, {
  required int skipLeading,
}) {
  final vals = <double>[];
  void collect(List<double> s) {
    final start = skipLeading.clamp(0, s.length);
    for (var i = start; i < s.length; i++) {
      vals.add(s[i]);
    }
  }

  collect(series1);
  if (series2 != null) collect(series2);

  if (vals.isEmpty) return (0.0, 10.0);

  var lo = vals.first;
  var hi = vals.first;
  for (final v in vals) {
    if (v < lo) lo = v;
    if (v > hi) hi = v;
  }

  if (hi <= lo) {
    if (hi == 0 && lo == 0) return (0.0, 10.0);
    final pad = (hi.abs() * 0.06 + 0.001).clamp(0.01, 1e9);
    var minY = lo - pad;
    var maxY = hi + pad;
    if (lo >= 0 && minY < 0) minY = 0;
    if (maxY <= minY) maxY = minY + 0.1;
    return (minY, maxY);
  }

  final margin = (hi - lo) * 0.12;
  var minY = lo - margin;
  var maxY = hi + margin;
  if (lo >= 0 && minY < 0) minY = 0;
  if (maxY <= minY) maxY = minY + (hi - lo) * 0.1 + 0.1;
  return (minY, maxY);
}

class _MonitorChart extends StatelessWidget {
  const _MonitorChart({
    required this.data,
    this.data2,
    required this.totalCount,
    required this.color,
    this.color2,
  });

  final List<double> data;
  final List<double>? data2;
  final int totalCount;
  final Color color;
  final Color? color2;

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const SizedBox.shrink();

    final maxX = (totalCount - 1).toDouble();
    final minX = maxX - 29;

    final (minY, maxY) = _dynamicYRange(data, data2, skipLeading: 0);

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        minX: minX,
        maxX: maxX,
        minY: minY,
        maxY: maxY,
        clipData: const FlClipData.all(),
        lineBarsData: [
          _buildLine(data, color, totalCount - data.length),
          if (data2 != null)
            _buildLine(data2!, color2 ?? color, totalCount - data2!.length),
        ],
        lineTouchData: const LineTouchData(enabled: false),
      ),
      duration: const Duration(milliseconds: 300),
    );
  }

  LineChartBarData _buildLine(
    List<double> points,
    Color lineColor,
    int startX,
  ) {
    return LineChartBarData(
      spots: points.asMap().entries.map((e) {
        return FlSpot((startX + e.key).toDouble(), e.value);
      }).toList(),
      isCurved: true,
      color: lineColor,
      barWidth: 2,
      isStrokeCapRound: true,
      dotData: const FlDotData(show: false),
      belowBarData: BarAreaData(
        show: true,
        color: lineColor.withValues(alpha: 0.1),
      ),
    );
  }
}

extension on List<ContainerStatsDto> {
  ContainerStatsDto? get lastOrNull => isEmpty ? null : last;
}
