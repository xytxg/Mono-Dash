import 'dart:ui';

import 'package:flutter/cupertino.dart';

import '../../../../core/theme/app_theme.dart';
import 'frosted_overlay_menu.dart';

/// 通用磨砂玻璃动作浮层菜单。
class FrostedActionPopupMenu extends StatefulWidget {
  const FrostedActionPopupMenu({
    super.key,
    required this.width,
    required this.items,
    required this.alignment,
    required this.onSelect,
  });

  final double width;
  final List<FrostedMenuItem> items;
  final Alignment alignment;
  final Function(VoidCallback) onSelect;

  @override
  State<FrostedActionPopupMenu> createState() => _FrostedActionPopupMenuState();
}

class _FrostedActionPopupMenuState extends State<FrostedActionPopupMenu>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _contentScaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
    _contentScaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.97,
          end: 1.015,
        ).chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 70,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.015,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 30,
      ),
    ]).animate(_controller);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = CupertinoTheme.brightnessOf(context) == Brightness.dark;
    final glassColor = CupertinoDynamicColor.resolve(
      CupertinoColors.systemGrey6,
      context,
    ).withValues(alpha: isDark ? 0.5 : 0.34);
    final borderColor = AppColors.separator(
      context,
    ).withValues(alpha: isDark ? 0.22 : 0.16);

    return Container(
      width: widget.width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 36, sigmaY: 36),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: glassColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: borderColor, width: 0.5),
            ),
            child: ScaleTransition(
              scale: _contentScaleAnimation,
              alignment: widget.alignment,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (int i = 0; i < widget.items.length; i++) ...[
                    CupertinoButton(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      onPressed: () => widget.onSelect(widget.items[i].action),
                      child: Row(
                        children: [
                          widget.items[i].iconWidget ??
                              Icon(
                                widget.items[i].icon,
                                size: 18,
                                color: AppColors.label(context),
                              ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              widget.items[i].text,
                              style: TextStyle(
                                fontSize: 15,
                                color: AppColors.label(context),
                                fontWeight: FontWeight.w400,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (i < widget.items.length - 1)
                      Container(
                        height: 0.5,
                        margin: const EdgeInsets.only(left: 46),
                        color: AppColors.separator(
                          context,
                        ).withValues(alpha: 0.1),
                      ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
