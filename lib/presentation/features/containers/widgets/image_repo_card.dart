import 'package:flutter/cupertino.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../core/localization/l10n_x.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/format_utils.dart';
import '../../../../data/dto/container/image_dtos.dart';
import '../../../common/components/status_pill.dart';

class ImageRepoCard extends StatelessWidget {
  const ImageRepoCard({super.key, required this.item, required this.onTap});

  final ImageRepoDto item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final statusColor = switch (item.status) {
      'Success' => CupertinoColors.systemGreen.resolveFrom(context),
      'Fail' => CupertinoColors.systemRed.resolveFrom(context),
      _ => CupertinoColors.systemGrey.resolveFrom(context),
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground(context).withValues(alpha: 0.68),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.separator(context).withValues(alpha: 0.1),
          width: 0.5,
        ),
      ),
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemTeal
                          .resolveFrom(context)
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      TablerIcons.database,
                      size: 24,
                      color: CupertinoColors.systemTeal.resolveFrom(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: AppColors.label(context),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.downloadUrl,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.secondaryLabel(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (item.status.isNotEmpty)
                    StatusPill(
                      label: item.status == 'Success'
                          ? context.l10n.containers_statusNormal
                          : context.l10n.containers_statusAbnormal,
                      active: item.status == 'Success',
                      activeColor: statusColor,
                      inactiveColor: statusColor,
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _ProtocolTag(protocol: item.protocol),
                  if (item.auth) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemOrange
                            .resolveFrom(context)
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        context.l10n.containers_auth,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: CupertinoColors.systemOrange.resolveFrom(
                            context,
                          ),
                        ),
                      ),
                    ),
                  ],
                  const Spacer(),
                  Icon(
                    TablerIcons.clock,
                    size: 12,
                    color: AppColors.tertiaryLabel(context),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    formatTimeAgo(
                      DateTime.tryParse(item.createdAt),
                      context.l10n,
                      prefix: '',
                    ),
                    style: TextStyle(
                      fontSize: 12,
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
}

class _ProtocolTag extends StatelessWidget {
  const _ProtocolTag({required this.protocol});
  final String protocol;

  @override
  Widget build(BuildContext context) {
    final isHttps = protocol == 'https';
    final color = isHttps
        ? CupertinoColors.systemGreen.resolveFrom(context)
        : CupertinoColors.systemOrange.resolveFrom(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        protocol.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
