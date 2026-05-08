import 'package:flutter/cupertino.dart';

/// 带有圆角的标签芯片，常用于展示分类、标签或状态。
class AppMetaChip extends StatelessWidget {
  const AppMetaChip({
    super.key,
    this.icon,
    required this.label,
    required this.color,
    this.height = 22,
    this.fontSize = 11,
    this.iconSize = 11,
    this.horizontalPadding = 7,
  });

  final IconData? icon;
  final String label;
  final Color color;
  final double height;
  final double fontSize;
  final double iconSize;
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.14), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, size: iconSize, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              color: color,
              letterSpacing: -0.1,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}
