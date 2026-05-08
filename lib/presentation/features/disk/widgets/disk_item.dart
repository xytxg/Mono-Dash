import 'package:flutter/cupertino.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../core/localization/l10n_x.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../common/components/more_info_card.dart';
import '../../../common/components/mini_button.dart';
import '../../../common/components/status_pill.dart';
import '../../../common/utils/display_utils.dart';

class DiskItem extends StatelessWidget {
  const DiskItem({super.key, required this.disk, this.onUnmount});

  final Map<String, dynamic> disk;
  final VoidCallback? onUnmount;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final partitions = ((disk['partitions'] as List?) ?? const [])
        .whereType<Map>()
        .map((e) => e.cast<String, dynamic>())
        .toList(growable: false);
    final canUnmount =
        onUnmount != null &&
        disk['isMounted'] == true &&
        disk['isSystem'] != true;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: moreCardDecoration(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    text(disk['device']),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.label(context),
                    ),
                  ),
                ),
                StatusPill(
                  label: disk['isMounted'] == true
                      ? l10n.disk_mounted
                      : l10n.disk_unmounted,
                  active: disk['isMounted'] == true,
                ),
              ],
            ),
            const SizedBox(height: 8),
            MoreProgressLine(percent: doubleValue(disk['usePercent']) ?? 0),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 6,
              children: [
                MoreChipText(l10n.disk_size(text(disk['size']))),
                MoreChipText(l10n.disk_used(text(disk['used']))),
                MoreChipText(l10n.disk_available(text(disk['avail']))),
                MoreChipText(l10n.disk_mountPoint(text(disk['mountPoint']))),
                MoreChipText(l10n.disk_filesystem(text(disk['filesystem']))),
              ],
            ),
            if (canUnmount) ...[
              const SizedBox(height: 10),
              MiniButton(
                label: l10n.disk_unmountAction,
                icon: TablerIcons.plug_x,
                color: CupertinoColors.systemRed,
                onTap: onUnmount!,
              ),
            ],
            if (partitions.isNotEmpty) ...[
              const SizedBox(height: 10),
              for (final part in partitions)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: _DiskPartitionLine(part: part),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DiskPartitionLine extends StatelessWidget {
  const _DiskPartitionLine({required this.part});

  final Map<String, dynamic> part;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.tertiaryBackground(context).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            text(part['device']),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.label(context),
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 10,
            runSpacing: 4,
            children: [
              MoreChipText(text(part['size'])),
              MoreChipText(text(part['filesystem'])),
              MoreChipText(text(part['mountPoint'])),
            ],
          ),
        ],
      ),
    );
  }
}
