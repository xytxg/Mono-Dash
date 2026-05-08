import 'package:flutter/cupertino.dart';

import '../../../core/theme/app_theme.dart';
import 'frosted_scaffold.dart';

/// Tab 页占位组件（Phase 3 使用，后续接入真实内容时删除调用）。
class TabPlaceholder extends StatelessWidget {
  const TabPlaceholder({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
  });

  final IconData icon;
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: FrostedScaffold.contentTopPadding(context)),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: AppColors.tertiaryLabel(context)),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.label(context),
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.secondaryLabel(context),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
