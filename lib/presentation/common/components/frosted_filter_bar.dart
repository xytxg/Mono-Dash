import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_theme.dart';

/// 过滤器项数据模型
class FilterItem {
  final String label;
  final String value;
  final IconData? icon;

  const FilterItem({required this.label, required this.value, this.icon});
}

/// 磨砂玻璃风格的横向过滤器栏
///
/// 常用于列表顶部的分类筛选，支持粘性固定（结合 Stack 或 Sliver 使用）。
class FrostedFilterBar extends StatelessWidget {
  const FrostedFilterBar({
    super.key,
    required this.items,
    required this.selectedValue,
    required this.onSelected,
    this.overlaps = false,
  });

  /// 过滤器选项列表
  final List<FilterItem> items;

  /// 当前选中的值
  final String selectedValue;

  /// 选中回调
  final ValueChanged<String> onSelected;

  /// 是否有内容经过下方（控制透明度和阴影）
  final bool overlaps;

  @override
  Widget build(BuildContext context) {
    // 当内容经过下方时，降低透明度以获得更通透的毛玻璃效果
    final alpha = overlaps ? 0.45 : 0.72;

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 4, 14, 8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 46,
        decoration: BoxDecoration(
          color: AppColors.secondaryBackground(
            context,
          ).withValues(alpha: alpha),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: AppColors.separator(context).withValues(alpha: 0.16),
            width: 0.5,
          ),
          boxShadow: overlaps
              ? [
                  BoxShadow(
                    color: CupertinoColors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final selected = item.value == selectedValue;
              return _FilterButton(
                label: item.label,
                icon: item.icon,
                selected: selected,
                onPressed: () => onSelected(item.value),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  const _FilterButton({
    required this.label,
    this.icon,
    required this.selected,
    required this.onPressed,
  });

  final String label;
  final IconData? icon;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final color = selected
        ? CupertinoColors.activeBlue.resolveFrom(context)
        : AppColors.secondaryLabel(context);
    return Padding(
      padding: const EdgeInsets.only(right: 7),
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        minimumSize: Size.zero,
        onPressed: () {
          HapticFeedback.selectionClick();
          onPressed();
        },
        child: Container(
          height: 32,
          padding: EdgeInsets.only(left: icon == null ? 12 : 10, right: 12),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected
                ? color.withValues(alpha: 0.13)
                : AppColors.tertiaryBackground(context).withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: color),
                const SizedBox(width: 5),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
