import 'package:flutter/cupertino.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../core/theme/app_theme.dart';

/// 设置页分组标题。
class SettingsSectionHeader extends StatelessWidget {
  const SettingsSectionHeader({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: AppColors.secondaryLabel(context),
        ),
      ),
    );
  }
}

/// 设置页分组容器，自动在子项之间添加分割线。
class SettingsGroupedBox extends StatelessWidget {
  const SettingsGroupedBox({
    super.key,
    required this.children,
    this.margin = const EdgeInsets.symmetric(horizontal: 16),
    this.dividerLeftPadding = 62,
  });

  final List<Widget> children;
  final EdgeInsetsGeometry margin;
  final double dividerLeftPadding;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground(context).withValues(alpha: 0.68),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.separator(context).withValues(alpha: 0.16),
          width: 0.5,
        ),
      ),
      child: Column(
        children: children.asMap().entries.map((entry) {
          final index = entry.key;
          final child = entry.value;
          if (index == children.length - 1) return child;
          return Column(
            children: [
              child,
              Padding(
                padding: EdgeInsets.only(left: dividerLeftPadding),
                child: Container(
                  height: 0.5,
                  color: AppColors.separator(context).withValues(alpha: 0.24),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

/// 设置页单行条目，带图标、标题、副标题和可选的右侧箭头。
class SettingsTile extends StatelessWidget {
  const SettingsTile({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = CupertinoDynamicColor.resolve(iconColor, context);
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 19, color: color),
            ),
            const SizedBox(width: 12),
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
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
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
            if (onTap != null)
              Icon(
                TablerIcons.chevron_right,
                size: 15,
                color: AppColors.tertiaryLabel(context),
              ),
          ],
        ),
      ),
    );
  }
}
