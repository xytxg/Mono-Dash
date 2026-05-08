import 'package:flutter/cupertino.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../core/localization/l10n_x.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/format_utils.dart';
import '../../../../data/dto/runtime/runtime_dto.dart';
import '../../../common/components/status_tag.dart';

class RuntimeCard extends StatelessWidget {
  const RuntimeCard({super.key, required this.item, required this.onTap});

  final RuntimeDto item;
  final VoidCallback onTap;

  static const _typeColors = {
    'php': CupertinoColors.systemIndigo,
    'node': CupertinoColors.systemGreen,
    'java': CupertinoColors.systemOrange,
    'go': CupertinoColors.systemTeal,
    'python': CupertinoColors.systemBlue,
    'dotnet': CupertinoColors.systemPurple,
  };

  static const _typeIcons = {
    'php': TablerIcons.brand_php,
    'node': TablerIcons.brand_nodejs,
    'java': TablerIcons.coffee,
    'go': TablerIcons.brand_golang,
    'python': TablerIcons.brand_python,
    'dotnet': TablerIcons.brand_c_sharp,
  };

  static const _statusColors = {
    'running': CupertinoColors.systemGreen,
    'starting': CupertinoColors.systemYellow,
    'stopped': CupertinoColors.systemRed,
    'building': CupertinoColors.systemOrange,
    'recreating': CupertinoColors.systemYellow,
    'error': CupertinoColors.systemRed,
  };

  Color _statusColor(String status) {
    final lower = status.toLowerCase();
    for (final entry in _statusColors.entries) {
      if (lower.contains(entry.key)) return entry.value;
    }
    return CupertinoColors.systemGrey;
  }

  String _formatTime(BuildContext context, String raw) {
    if (raw.isEmpty) return '';
    final parsed = DateTime.tryParse(raw);
    if (parsed == null) return raw;
    return formatRelativeTime(parsed, context.l10n);
  }

  @override
  Widget build(BuildContext context) {
    final color = _typeColors[item.type] ?? CupertinoColors.systemGrey;
    final icon = _typeIcons[item.type] ?? TablerIcons.server_2;
    final statusColor = _statusColor(item.status);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.secondaryBackground(
              context,
            ).withValues(alpha: 0.58),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.separator(context).withValues(alpha: 0.1),
              width: 0.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: icon + name + type + version + status
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, size: 24, color: color),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.label(context),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Text(
                              item.type.toUpperCase(),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: color,
                              ),
                            ),
                            if (item.version.isNotEmpty) ...[
                              Text(
                                ' ver.${item.version}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.secondaryLabel(context),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  StatusTag(
                    label: item.status.toUpperCase(),
                    color: statusColor,
                  ),
                ],
              ),
              // Info chips: PHP shows image + port, others show exposedPorts
              if (item.type == 'php') ...[
                if (item.image.isNotEmpty || item.port.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      if (item.image.isNotEmpty)
                        _buildInfoChip(context, TablerIcons.photo, item.image),
                      if (item.port.isNotEmpty)
                        _buildInfoChip(context, TablerIcons.plug, item.port),
                    ],
                  ),
                ],
              ] else if (item.exposedPorts.isNotEmpty) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    for (var i = 0; i < item.exposedPorts.length && i < 2; i++)
                      _buildPortChip(context, item.exposedPorts[i]),
                    if (item.exposedPorts.length > 2)
                      _PortCountChip(count: item.exposedPorts.length - 2),
                  ],
                ),
              ],
              // Bottom: remark + time
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    TablerIcons.message_2,
                    size: 12,
                    color: AppColors.tertiaryLabel(context),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      item.remark.isNotEmpty ? item.remark : '-',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.tertiaryLabel(context),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(
                    TablerIcons.clock,
                    size: 12,
                    color: AppColors.tertiaryLabel(context),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatTime(context, item.createdAt),
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.tertiaryLabel(context),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(BuildContext context, IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBlue.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: CupertinoColors.systemBlue.resolveFrom(context),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: CupertinoColors.systemBlue.resolveFrom(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPortChip(BuildContext context, ExposedPort p) {
    final label = p.hostIP.isNotEmpty
        ? '${p.hostIP}:${p.hostPort}->${p.containerPort}'
        : '${p.hostPort}->${p.containerPort}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBlue.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            TablerIcons.plug,
            size: 12,
            color: CupertinoColors.systemBlue.resolveFrom(context),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: CupertinoColors.systemBlue.resolveFrom(context),
            ),
          ),
        ],
      ),
    );
  }
}

class _PortCountChip extends StatelessWidget {
  const _PortCountChip({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.secondaryLabel(context).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '+$count',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.secondaryLabel(context),
        ),
      ),
    );
  }
}
