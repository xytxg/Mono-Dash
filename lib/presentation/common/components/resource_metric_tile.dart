import 'package:flutter/cupertino.dart';

import '../../../core/theme/app_theme.dart';

/// 卡片内资源指标展示块（如 CPU、内存）。
///
/// 显示图标 + 标签 + 数值，常用于容器卡片底部。
class ResourceMetricTile extends StatelessWidget {
  const ResourceMetricTile({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.tertiaryBackground(context).withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppColors.secondaryLabel(context)),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: AppColors.secondaryLabel(context),
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.label(context),
            ),
          ),
        ],
      ),
    );
  }
}
