import 'package:flutter/cupertino.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../core/localization/l10n_x.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/dto/website/ssl_manage_dtos.dart';
import '../../../common/components/status_tag.dart';
import '../utils/ssl_ui_helper.dart';

class SslManageCard extends StatelessWidget {
  const SslManageCard({super.key, required this.item, required this.onTap});

  final SslManageDto item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final statusColor = SslUIHelper.getStatusColor(context, item.status);
    final statusLabel = SslUIHelper.getStatusLabel(context, item.status);

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
                      color: CupertinoColors.systemGreen
                          .resolveFrom(context)
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      TablerIcons.certificate,
                      size: 24,
                      color: CupertinoColors.systemGreen.resolveFrom(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.primaryDomain.isEmpty
                              ? context.l10n.websites_certificateNumber(item.id)
                              : item.primaryDomain,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: AppColors.label(context),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          SslUIHelper.getProviderLabel(
                            context,
                            item.provider,
                            item.type,
                          ),
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
                  StatusTag(
                    label: statusLabel,
                    color: statusColor,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 1,
                    ),
                    borderRadius: 6,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  if (item.autoRenew) ...[
                    Icon(
                      TablerIcons.refresh,
                      size: 13,
                      color: CupertinoColors.systemGreen.resolveFrom(context),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      context.l10n.websites_autoRenew,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: CupertinoColors.systemGreen.resolveFrom(context),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  if (item.organization.isNotEmpty) ...[
                    StatusTag(
                      label: item.organization,
                      color: CupertinoColors.systemBlue.resolveFrom(context),
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
                  const Spacer(),
                  if (item.expireDate.isNotEmpty) ...[
                    Icon(
                      TablerIcons.clock,
                      size: 12,
                      color: AppColors.tertiaryLabel(context),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      SslUIHelper.getExpireText(context, item.expireDate),
                      style: TextStyle(
                        fontSize: 12,
                        color: SslUIHelper.getExpireColor(
                          context,
                          item.expireDate,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
