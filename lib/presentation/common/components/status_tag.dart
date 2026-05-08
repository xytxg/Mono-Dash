import 'package:flutter/cupertino.dart';

/// 通用彩色标签芯片，用于卡片内的状态 / 信息标记。
///
/// 默认样式与原容器/镜像卡片中的 `_StatusTag` 完全一致。
/// 通过可选参数可适配不同场景（如网络卡片的 `_InfoTag`）。
class StatusTag extends StatelessWidget {
  const StatusTag({
    super.key,
    required this.label,
    required this.color,
    this.padding = const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    this.borderRadius = 4.0,
    this.fontSize = 10.0,
    this.fontWeight = FontWeight.w800,
  });

  final String label;
  final Color color;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final double fontSize;
  final FontWeight fontWeight;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
        ),
      ),
    );
  }
}
