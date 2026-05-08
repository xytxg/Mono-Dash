import 'package:flutter/cupertino.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../common/components/more_info_card.dart';
import '../../../common/utils/display_utils.dart';

class NetworkItem extends StatelessWidget {
  const NetworkItem({
    super.key,
    required this.item,
    required this.onTap,
  });

  final Map<String, dynamic> item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final pid = intValue(item['PID'] ?? item['pid']);
    final name = text(item['name'] ?? item['Name']);
    final type = text(item['type']);
    final status = text(item['status']);
    final local = _formatAddr(item['localaddr']);
    final remote = _formatAddr(item['remoteaddr']);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: moreCardDecoration(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Row 1: type pill + status pill + PID
              Row(
                children: [
                  _TypePill(type: type),
                  const SizedBox(width: 8),
                  _StatusPill(status: status),
                  const Spacer(),
                  if (pid != null)
                    Text(
                      'PID $pid',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.tertiaryLabel(context),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              // Row 2: local → remote
              Row(
                children: [
                  Expanded(
                    child: Text(
                      local,
                      style: TextStyle(
                        fontSize: 13,
                        fontFamily: 'monospace',
                        color: AppColors.label(context),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Icon(
                      TablerIcons.arrow_right,
                      size: 14,
                      color: AppColors.tertiaryLabel(context),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      remote,
                      style: TextStyle(
                        fontSize: 13,
                        fontFamily: 'monospace',
                        color: AppColors.label(context),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
              // Row 3: process name
              if (name != '--') ...[
                const SizedBox(height: 6),
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.secondaryLabel(context),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatAddr(dynamic addr) {
    if (addr == null) return '--';
    if (addr is Map) {
      final ip = addr['ip']?.toString() ?? '';
      final port = addr['port']?.toString() ?? '';
      if (ip.isEmpty && port.isEmpty) return '--';
      return '$ip:$port';
    }
    return addr.toString();
  }
}

class _TypePill extends StatelessWidget {
  const _TypePill({required this.type});

  final String type;

  @override
  Widget build(BuildContext context) {
    final color = switch (type) {
      'tcp' || 'tcp4' => CupertinoColors.systemBlue,
      'tcp6' => CupertinoColors.systemPurple,
      'udp' || 'udp4' => CupertinoColors.systemOrange,
      'udp6' => CupertinoColors.systemPink,
      _ => CupertinoColors.systemGrey,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.resolveFrom(context).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        type,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color.resolveFrom(context),
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      'LISTEN' => CupertinoColors.systemGreen,
      'ESTABLISHED' => CupertinoColors.activeBlue,
      'TIME_WAIT' => CupertinoColors.systemGrey,
      'CLOSE_WAIT' || 'NONE' => CupertinoColors.systemRed,
      _ => CupertinoColors.systemGrey,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.resolveFrom(context).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color.resolveFrom(context),
        ),
      ),
    );
  }
}
