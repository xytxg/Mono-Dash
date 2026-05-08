import 'package:flutter/cupertino.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../../core/localization/l10n_x.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../data/dto/website/website_detail_dto.dart';
import 'domain_components.dart';

class DomainCard extends StatelessWidget {
  const DomainCard({
    super.key,
    required this.domain,
    required this.canDelete,
    required this.onVisit,
    required this.onSslChanged,
    required this.onDelete,
  });

  final WebsiteDomainDto domain;
  final bool canDelete;
  final VoidCallback onVisit;
  final ValueChanged<bool> onSslChanged;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final schemeColor = domainProtocolColor(context, domain.ssl);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground(context).withValues(alpha: 0.68),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.separator(context).withValues(alpha: 0.16),
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.black.withValues(alpha: 0.035),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              DomainProtocolBadge(
                label: domainProtocolLabel(domain.ssl),
                icon: domainProtocolIcon(domain.ssl),
                color: schemeColor,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      domain.domain,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.label(context),
                        letterSpacing: -0.25,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 1),
                    Text(
                      context.l10n.websites_portValue(domain.port),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.secondaryLabel(context),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              CupertinoButton(
                padding: EdgeInsets.zero,
                minimumSize: const Size.square(34),
                onPressed: onVisit,
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: CupertinoColors.activeBlue
                        .resolveFrom(context)
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    TablerIcons.external_link,
                    size: 17,
                    color: CupertinoColors.activeBlue.resolveFrom(context),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: DomainActionButton(
                  icon: domain.ssl ? TablerIcons.shield_off : TablerIcons.lock,
                  label: domain.ssl
                      ? context.l10n.websites_disableHttps
                      : context.l10n.websites_enableHttps,
                  color: schemeColor,
                  onPressed: () => onSslChanged(!domain.ssl),
                ),
              ),
              const SizedBox(width: 8),
              DomainIconActionButton(
                icon: TablerIcons.trash,
                color: CupertinoColors.systemRed.resolveFrom(context),
                onPressed: canDelete ? onDelete : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
