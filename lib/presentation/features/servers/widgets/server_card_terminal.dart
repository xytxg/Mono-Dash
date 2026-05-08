import 'package:flutter/cupertino.dart';

import '../../../../domain/entities/dashboard.dart';
import '../../../../domain/entities/server.dart';
import '../../../common/components/skeleton_item.dart';
import 'server_card_shared.dart';

class TerminalServerCard extends StatelessWidget {
  const TerminalServerCard({
    super.key,
    required this.server,
    required this.dashboard,
    required this.status,
    required this.onTap,
    required this.isSelected,
    this.loading = false,
  });

  final Server server;
  final Dashboard? dashboard;
  final ServerCardStatus status;
  final VoidCallback? onTap;
  final bool isSelected;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final data = dashboard;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: _TerminalCardColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isSelected
              ? _TerminalCardColors.selectedBorder
              : _TerminalCardColors.border,
          width: isSelected ? 1.1 : 0.8,
        ),
      ),
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        borderRadius: BorderRadius.circular(14),
        onPressed: loading ? null : onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 13, 14, 12),
          child: data == null || loading
              ? _FallbackCardContent(
                  server: server,
                  status: status,
                  loading: loading,
                )
              : _DashboardCardContent(
                  server: server,
                  dashboard: data,
                  status: status,
                ),
        ),
      ),
    );
  }
}

class _DashboardCardContent extends StatelessWidget {
  const _DashboardCardContent({
    required this.server,
    required this.dashboard,
    required this.status,
  });

  final Server server;
  final Dashboard dashboard;
  final ServerCardStatus status;

  @override
  Widget build(BuildContext context) {
    final base = dashboard.base;
    final current = dashboard.current;
    final disk = primaryDisk(current.disks);
    final title = server.name?.isNotEmpty == true
        ? server.name!
        : (base.hostname.isNotEmpty ? base.hostname : server.displayName);
    final subtitle = serverSubtitle(
      distro: base.prettyDistro,
      ip: base.ipV4Addr,
      fallback: base.platform,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _HeaderLine(title: title, status: status),
        const SizedBox(height: 9),
        _SubtitleLine(text: subtitle),
        const SizedBox(height: 16),
        _MetricsRow(
          items: [
            _MetricData(
              label: 'cpu',
              value: formatPercent(current.cpuUsedPercent),
            ),
            _MetricData(
              label: 'mem',
              value: formatPercent(current.memoryUsedPercent),
            ),
            _MetricData(
              label: 'disk',
              value: disk == null ? '--' : formatPercent(disk.usedPercent),
              isWarning: disk != null && disk.usedPercent >= 90,
            ),
            _MetricData(label: 'procs', value: '${current.procs}'),
          ],
        ),
        const SizedBox(height: 12),
        const _Divider(),
        const SizedBox(height: 12),
        _FooterLine(uptime: formatUptime(current.uptimeSeconds)),
      ],
    );
  }
}

class _FallbackCardContent extends StatelessWidget {
  const _FallbackCardContent({
    required this.server,
    required this.status,
    this.loading = false,
  });

  final Server server;
  final ServerCardStatus status;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _HeaderLine(
          title: server.displayName,
          status: status,
          loading: loading,
        ),
        const SizedBox(height: 9),
        _SubtitleLine(
          text:
              '${server.isHttps ? 'https' : 'http'}://${server.host}:${server.port}',
          loading: loading,
        ),
        const SizedBox(height: 16),
        _MetricsRow(
          loading: loading,
          items: const [
            _MetricData(label: 'cpu', value: '--'),
            _MetricData(label: 'mem', value: '--'),
            _MetricData(label: 'disk', value: '--'),
            _MetricData(label: 'procs', value: '--'),
          ],
        ),
        const SizedBox(height: 12),
        const _Divider(),
        const SizedBox(height: 12),
        _FooterLine(
          uptime: loading ? '' : 'reading',
          loading: loading,
        ),
      ],
    );
  }
}

class _HeaderLine extends StatelessWidget {
  const _HeaderLine({
    required this.title,
    required this.status,
    this.loading = false,
  });

  final String title;
  final ServerCardStatus status;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text(
          r'$',
          style: TextStyle(
            fontFamily: 'Menlo',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: _TerminalCardColors.green,
            height: 1,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: loading
              ? const SkeletonItem.text(width: 100, height: 16)
              : Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Menlo',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: _TerminalCardColors.green,
                    height: 1.18,
                  ),
                ),
        ),
        const SizedBox(width: 10),
        if (loading)
          const SkeletonItem(width: 48, height: 12, borderRadius: 999)
        else
          _StatusLabel(status: status),
      ],
    );
  }
}

class _SubtitleLine extends StatelessWidget {
  const _SubtitleLine({required this.text, this.loading = false});

  final String text;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    if (loading) return const SkeletonItem.text(width: 160, height: 13);
    return Text(
      text.isEmpty ? '--' : text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        fontFamily: 'Menlo',
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: _TerminalCardColors.muted,
        height: 1.25,
      ),
    );
  }
}

class _StatusLabel extends StatelessWidget {
  const _StatusLabel({required this.status});

  final ServerCardStatus status;

  @override
  Widget build(BuildContext context) {
    if (status.isLoading) {
      return const CupertinoActivityIndicator(radius: 7);
    }

    final color = status.hasData
        ? _TerminalCardColors.green
        : _TerminalCardColors.orange;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          status.terminalLabel,
          style: TextStyle(
            fontFamily: 'Menlo',
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: color,
            height: 1,
          ),
        ),
      ],
    );
  }
}

class _MetricsRow extends StatelessWidget {
  const _MetricsRow({required this.items, this.loading = false});

  final List<_MetricData> items;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 12.0;
        final isCompact = constraints.maxWidth < 320;
        final columns = isCompact ? 2 : items.length;
        final itemWidth =
            (constraints.maxWidth - gap * (columns - 1)) / columns;

        return Wrap(
          spacing: gap,
          runSpacing: 10,
          children: [
            for (final item in items)
              SizedBox(
                width: itemWidth,
                child: _MetricItem(data: item, loading: loading),
              ),
          ],
        );
      },
    );
  }
}

class _MetricItem extends StatelessWidget {
  const _MetricItem({required this.data, this.loading = false});

  final _MetricData data;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final valueColor = data.isWarning
        ? _TerminalCardColors.red
        : _TerminalCardColors.text;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
            data.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Menlo',
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: _TerminalCardColors.green,
              height: 1,
            ),
          ),
        ),
        const SizedBox(width: 8),
        if (loading)
          const SkeletonItem.text(width: 32, height: 13)
        else
          Text(
            data.value,
            maxLines: 1,
            overflow: TextOverflow.fade,
            softWrap: false,
            style: TextStyle(
              fontFamily: 'Menlo',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: valueColor,
              height: 1,
            ),
          ),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Container(height: 1, color: _TerminalCardColors.divider);
  }
}

class _FooterLine extends StatelessWidget {
  const _FooterLine({required this.uptime, this.loading = false});

  final String uptime;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text(
          'uptime',
          style: TextStyle(
            fontFamily: 'Menlo',
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: _TerminalCardColors.green,
            height: 1,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: loading
              ? const SkeletonItem.text(width: 60, height: 13)
              : Text(
                  uptime,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Menlo',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _TerminalCardColors.text,
                    height: 1,
                  ),
                ),
        ),
        const SizedBox(width: 10),
        const Text(
          'more >',
          style: TextStyle(
            fontFamily: 'Menlo',
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: _TerminalCardColors.green,
            height: 1,
          ),
        ),
      ],
    );
  }
}

class _MetricData {
  const _MetricData({
    required this.label,
    required this.value,
    this.isWarning = false,
  });

  final String label;
  final String value;
  final bool isWarning;
}

class _TerminalCardColors {
  static const background = Color(0xFFFFFFFF);
  static const border = Color(0xFFE5E7EB);
  static const selectedBorder = Color(0xFF8FD3AA);
  static const divider = Color(0xFFEEF0F2);
  static const green = Color(0xFF16803A);
  static const text = Color(0xFF20242A);
  static const muted = Color(0xFF667085);
  static const red = Color(0xFFB42318);
  static const orange = Color(0xFFB54708);
}
