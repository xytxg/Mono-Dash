import 'package:flutter/cupertino.dart';
import '../../../core/theme/app_theme.dart';

/// 一个带有标题和圆角背景的展示面板，常用于 Dashboard 概览页。
class InfoPanel extends StatelessWidget {
  const InfoPanel({
    super.key,
    this.title,
    this.icon,
    this.iconColor,
    this.trailing,
    required this.child,
  });

  final String? title;
  final IconData? icon;
  final Color? iconColor;
  final Widget? trailing;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground(context).withValues(alpha: 0.58),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.separator(context).withValues(alpha: 0.14),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Row(
              children: [
                if (icon != null) ...[
                  Icon(
                    icon,
                    size: 16,
                    color: iconColor ?? AppColors.label(context),
                  ),
                  const SizedBox(width: 8),
                ],
                Text(
                  title!,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.label(context),
                    letterSpacing: -0.2,
                  ),
                ),
                if (trailing != null) ...[
                  const Spacer(),
                  trailing!,
                ],
              ],
            ),
            const SizedBox(height: 14),
          ],
          child,
        ],
      ),
    );
  }
}

/// InfoPanel 的头部组件，带有图标和副标题。
class InfoPanelHeader extends StatelessWidget {
  const InfoPanelHeader({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.label(context),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.secondaryLabel(context),
                ),
              ),
            ],
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: 10),
          trailing!,
        ],
      ],
    );
  }
}
