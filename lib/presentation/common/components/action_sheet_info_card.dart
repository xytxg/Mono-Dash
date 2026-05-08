import 'package:flutter/cupertino.dart';
import '../../../core/theme/app_theme.dart';

/// ActionSheet 顶部的信息展示卡片，采用了磨砂质感的圆角卡片设计。
class ActionSheetInfoCard extends StatelessWidget {
  const ActionSheetInfoCard({
    super.key,
    required this.leading,
    required this.title,
    required this.subtitle,
    required this.trailing,
    this.chips,
  });

  final Widget leading;
  final String title;
  final String subtitle;
  final Widget trailing;
  final List<Widget>? chips;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background(context).withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.separator(context).withValues(alpha: 0.24),
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.black.withValues(alpha: 0.12),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          leading,
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    color: AppColors.label(context),
                    letterSpacing: -0.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 5),
                if (chips != null && chips!.isNotEmpty)
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: chips!,
                  )
                else
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.secondaryLabel(context),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          trailing,
        ],
      ),
    );
  }
}
