import 'dart:ui';
import 'package:flutter/cupertino.dart';
import '../../../core/theme/app_theme.dart';

/// ActionSheet 的背景面板，支持磨砂玻璃效果和性能优化开关。
class ActionSheetPanel extends StatelessWidget {
  const ActionSheetPanel({
    super.key,
    required this.child,
    this.enableBlur = true,
    this.backgroundAlpha,
    this.backgroundColor,
    this.borderRadius = const BorderRadius.vertical(top: Radius.circular(24)),
  });

  final Widget child;
  final bool enableBlur;
  final double? backgroundAlpha;
  final Color? backgroundColor;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    final decorated = Container(
      decoration: BoxDecoration(
        color: (backgroundColor ?? AppColors.background(context)).withValues(
          alpha: backgroundAlpha ?? (enableBlur ? 0.88 : 0.98),
        ),
        borderRadius: borderRadius,
        border: Border(
          top: BorderSide(
            color: AppColors.separator(context).withValues(alpha: 0.24),
            width: 0.5,
          ),
        ),
      ),
      child: child,
    );

    return ClipRRect(
      borderRadius: borderRadius,
      child: enableBlur
          ? BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: decorated,
            )
          : decorated,
    );
  }
}
