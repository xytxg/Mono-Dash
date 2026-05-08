import 'package:flutter/cupertino.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import '../../../core/localization/l10n_x.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/format_utils.dart';
import 'skeleton_item.dart';

/// Dashboard 概览页中带图标和跳转箭头的指标行。
class MetricRow extends StatelessWidget {
  const MetricRow({
    super.key,
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
    required this.onTap,
    this.detail,
    this.loading = false,
  });

  final IconData icon;
  final Color color;
  final String label;
  final String value;
  final VoidCallback onTap;
  final String? detail;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: loading ? null : onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Icon(icon, size: 24, color: color),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.label(context),
                ),
              ),
            ),
            if (loading) ...[
              const SkeletonItem.text(width: 48, height: 14),
              const SizedBox(width: 10),
              const SkeletonItem.text(width: 28, height: 18),
            ] else ...[
              if (detail != null) ...[
                Text(
                  detail!,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.secondaryLabel(context),
                  ),
                ),
                const SizedBox(width: 10),
              ],
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.label(context),
                ),
              ),
            ],
            const SizedBox(width: 6),
            Icon(
              TablerIcons.chevron_right,
              size: 14,
              color: AppColors.tertiaryLabel(context).withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }
}

/// 资源占用行，展示总量和可回收空间。
class UsageRow extends StatelessWidget {
  const UsageRow({
    super.key,
    required this.icon,
    required this.color,
    required this.label,
    required this.usage,
    required this.reclaimable,
    this.loading = false,
  });

  final IconData icon;
  final Color color;
  final String label;
  final int usage;
  final int reclaimable;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, size: 24, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.label(context),
                  ),
                ),
                const SizedBox(height: 2),
                if (loading)
                  const SkeletonItem.text(width: 80, height: 13)
                else
                  Text(
                    context.l10n.common_reclaimable(
                      reclaimable > 0 ? formatBytes(reclaimable) : '0 B',
                    ),
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.secondaryLabel(context),
                    ),
                  ),
              ],
            ),
          ),
          if (loading)
            const SkeletonItem.text(width: 48, height: 16)
          else
            Text(
              formatBytes(usage),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.label(context),
              ),
            ),
        ],
      ),
    );
  }
}

/// 键值对配置展示行。
class ConfigRow extends StatelessWidget {
  final String label;
  final String value;
  final TextAlign valueTextAlign;
  final int labelFlex;
  final int valueFlex;
  final VoidCallback? onTap;
  final Widget? valueWidget;
  final TextStyle? valueStyle;
  final bool loading;

  const ConfigRow({
    super.key,
    required this.label,
    required this.value,
    this.valueTextAlign = TextAlign.start,
    this.labelFlex = 1,
    this.valueFlex = 1,
    this.onTap,
    this.valueWidget,
    this.valueStyle,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: labelFlex,
            child: Text(
              label,
              textAlign: TextAlign.start,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.secondaryLabel(context),
              ),
            ),
          ),
          Expanded(
            flex: valueFlex,
            child: loading
                ? const Align(
                    alignment: Alignment.centerRight,
                    child: SkeletonItem.text(width: 60, height: 15),
                  )
                : valueWidget ??
                      Text(
                        value,
                        textAlign: valueTextAlign,
                        style:
                            valueStyle ??
                            TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.label(context),
                            ),
                      ),
          ),
        ],
      ),
    );

    if (onTap != null) {
      return CupertinoButton(
        padding: EdgeInsets.zero,
        minimumSize: Size.zero,
        onPressed: onTap,
        child: content,
      );
    }

    return content;
  }
}
