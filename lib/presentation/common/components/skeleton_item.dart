import 'package:flutter/cupertino.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';

class SkeletonItem extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;
  final bool isCircle;

  const SkeletonItem({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8.0,
    this.isCircle = false,
  });

  /// 创建一个文本行高度的骨架条
  const SkeletonItem.text({
    super.key,
    this.width = 60,
    this.height = 14,
    this.borderRadius = 6.0,
    this.isCircle = false,
  });

  @override
  Widget build(BuildContext context) {
    final baseColor = AppColors.tertiaryBackground(context).withValues(alpha: 0.6);
    final highlightColor = AppColors.label(context).withValues(alpha: 0.05);

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: baseColor,
        borderRadius: isCircle ? null : BorderRadius.circular(borderRadius),
        shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
      ),
    )
    .animate(onPlay: (controller) => controller.repeat())
    .shimmer(
      duration: 1500.ms,
      color: highlightColor,
    );
  }
}
