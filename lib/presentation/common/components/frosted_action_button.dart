import 'dart:ui';

import 'package:flutter/cupertino.dart';

import '../../../../core/theme/app_theme.dart';

/// 磨砂玻璃风格的单一操作按钮。
///
/// 与 [FrostedHeader] 的按钮视觉保持一致，适合用作
/// `FrostedHeader.trailingBuilder` / `FrostedScaffold.trailingBuilder`。
class FrostedActionButton extends StatelessWidget {
  const FrostedActionButton({
    super.key,
    required this.text,
    this.icon,
    this.onTap,
    this.isDark = false,
    this.isOverlapping = false,
    this.isLoading = false,
    this.showBlur = true,
    this.foregroundColor,
  });

  final String text;
  final IconData? icon;
  final VoidCallback? onTap;
  final bool isDark;
  final bool isOverlapping;
  final bool isLoading;
  final bool showBlur;
  final Color? foregroundColor;

  bool get _isEnabled => onTap != null && !isLoading;

  @override
  Widget build(BuildContext context) {
    final color = foregroundColor ?? (_isEnabled
        ? AppColors.label(context)
        : AppColors.tertiaryLabel(context));

    final glowShadows = isOverlapping
        ? [
            BoxShadow(
              color: isDark
                  ? CupertinoColors.white.withValues(alpha: 0.5)
                  : CupertinoColors.black.withValues(alpha: 0.15),
              blurRadius: 12,
            ),
          ]
        : null;

    final containerColor = isDark
        ? CupertinoColors.systemGrey6.darkColor.withValues(
            alpha: isOverlapping ? 0.6 : 0.35,
          )
        : CupertinoColors.systemGrey6.color.withValues(
            alpha: isOverlapping ? 0.7 : 0.5,
          );

    return GestureDetector(
      onTap: _isEnabled ? onTap : null,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          boxShadow: glowShadows,
        ),
        child: showBlur 
          ? ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 35, sigmaY: 35),
                child: _buildBody(context, containerColor, color),
              ),
            )
          : _buildBody(context, containerColor, color),
      ),
    );
  }

  Widget _buildBody(BuildContext context, Color containerColor, Color color) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: containerColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark
              ? CupertinoColors.white.withValues(
                  alpha: isOverlapping ? 0.3 : 0.15,
                )
              : CupertinoColors.black.withValues(
                  alpha: isOverlapping ? 0.15 : 0.05,
                ),
          width: 0.5,
        ),
      ),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: _isEnabled ? 1 : 0.5,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isLoading)
              const CupertinoActivityIndicator(radius: 8)
            else ...[
              if (icon != null) ...[
                Icon(icon, size: 16, color: color),
                if (text.isNotEmpty) const SizedBox(width: 4),
              ],
              if (text.isNotEmpty)
                Text(
                  text,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    letterSpacing: -0.2,
                    color: color,
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
