import 'package:flutter/cupertino.dart';

import '../../../../core/localization/l10n_x.dart';
import '../../../../core/theme/app_theme.dart';
import 'create/website_create_proxy_page.dart';
import 'create/website_create_static_page.dart';

class WebsiteTypeSheet extends StatelessWidget {
  const WebsiteTypeSheet({super.key, required this.serverId});

  final int serverId;

  static Future<void> show(BuildContext context, int serverId) {
    return showCupertinoModalPopup(
      context: context,
      builder: (context) => WebsiteTypeSheet(serverId: serverId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 24,
        left: 24,
        right: 24,
        bottom: MediaQuery.paddingOf(context).bottom + 24,
      ),
      decoration: BoxDecoration(
        color: AppColors.background(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.l10n.websites_selectWebsiteType,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.label(context),
                ),
              ),
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () => Navigator.of(context).pop(),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.tertiaryBackground(context),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    CupertinoIcons.xmark,
                    size: 16,
                    color: AppColors.secondaryLabel(context),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildTypeCard(
            context,
            icon: CupertinoIcons.doc_text,
            title: context.l10n.websites_staticWebsiteType,
            description: context.l10n.websites_staticWebsiteTypeDescription,
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                CupertinoPageRoute(
                  builder: (context) =>
                      WebsiteCreateStaticPage(serverId: serverId),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          _buildTypeCard(
            context,
            icon: CupertinoIcons.arrow_right_arrow_left,
            title: context.l10n.websites_reverseProxyType,
            description: context.l10n.websites_reverseProxyTypeDescription,
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                CupertinoPageRoute(
                  builder: (context) =>
                      WebsiteCreateProxyPage(serverId: serverId),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTypeCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.secondaryBackground(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.separator(context), width: 0.5),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: CupertinoColors.activeBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 24, color: CupertinoColors.activeBlue),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.label(context),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.secondaryLabel(context),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              CupertinoIcons.chevron_right,
              size: 16,
              color: AppColors.tertiaryLabel(context),
            ),
          ],
        ),
      ),
    );
  }
}
