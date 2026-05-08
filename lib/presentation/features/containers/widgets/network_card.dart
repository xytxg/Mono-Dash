import 'package:flutter/cupertino.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../core/localization/l10n_x.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/format_utils.dart';
import '../../../../data/dto/container/network_dtos.dart';
import '../../../common/components/status_tag.dart';
import 'network_visuals.dart';

class NetworkCard extends StatelessWidget {
  const NetworkCard({super.key, required this.item, required this.onTap});

  final NetworkDto item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final visual = networkVisualFor(context, item.name);

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
                      color: visual.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(visual.icon, size: 24, color: visual.color),
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
                          item.driver.isEmpty
                              ? context.l10n.containers_defaultDriver
                              : item.driver,
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
                  if (item.isSystem)
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemGrey
                            .resolveFrom(context)
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        TablerIcons.cpu,
                        size: 15,
                        color: CupertinoColors.systemGrey.resolveFrom(context),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  if (item.subnet.isNotEmpty) ...[
                    StatusTag(
                      label: item.subnet,
                      color: CupertinoColors.systemGreen.resolveFrom(context),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 1,
                      ),
                      borderRadius: 6,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    const SizedBox(width: 8),
                  ],
                  if (item.driver.isNotEmpty)
                    StatusTag(
                      label: item.driver.toUpperCase(),
                      color: CupertinoColors.systemGreen.resolveFrom(context),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 1,
                      ),
                      borderRadius: 6,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
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
