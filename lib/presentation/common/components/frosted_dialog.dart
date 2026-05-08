import 'package:flutter/cupertino.dart';

import '../../../core/localization/l10n_x.dart';
import '../../../core/theme/app_theme.dart';

/// 通用磨砂玻璃弹窗外壳。
///
/// 只负责统一弹窗质感和基础结构：
/// - 图标 + 标题 + 副标题
/// - 可插入任意内容区域
/// - 底部取消/确认按钮
class FrostedDialog extends StatelessWidget {
  const FrostedDialog({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    required this.child,
    this.cancelText,
    this.confirmText,
    this.onCancel,
    this.onConfirm,
    this.confirmEnabled = true,
    this.confirmColor,
    this.maxWidth = 420,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
  final Widget child;
  final String? cancelText;
  final String? confirmText;
  final VoidCallback? onCancel;
  final VoidCallback? onConfirm;
  final bool confirmEnabled;
  final Color? confirmColor;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final isDark = CupertinoTheme.brightnessOf(context) == Brightness.dark;
    final panelBg = AppColors.background(context);
    final effectiveCancelText = cancelText ?? context.l10n.common_cancel;
    final effectiveConfirmText = confirmText ?? context.l10n.common_confirm;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: panelBg,
              border: Border.all(
                color: isDark
                    ? CupertinoColors.white.withValues(alpha: 0.15)
                    : CupertinoColors.black.withValues(alpha: 0.08),
                width: 0.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: CupertinoColors.black.withValues(
                    alpha: isDark ? 0.3 : 0.1,
                  ),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: CustomPaint(
                foregroundPainter: _DialogGlowBorderPainter(isDark: isDark),
                child: Container(
                  color: panelBg,
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          if (icon != null) ...[
                            Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color:
                                    (confirmColor ?? CupertinoColors.activeBlue)
                                        .withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                icon,
                                size: 18,
                                color:
                                    confirmColor ?? CupertinoColors.activeBlue,
                              ),
                            ),
                            const SizedBox(width: 10),
                          ],
                          Expanded(
                            child: Text(
                              title,
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                color: AppColors.label(context),
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (subtitle != null && subtitle!.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          subtitle!,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.secondaryLabel(context),
                          ),
                        ),
                      ],
                      const SizedBox(height: 14),
                      child,
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.tertiaryBackground(context)
                                    .withValues(
                                      alpha:
                                          CupertinoTheme.brightnessOf(
                                                context,
                                              ) ==
                                              Brightness.dark
                                          ? 0.72
                                          : 0.92,
                                    ),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color:
                                      CupertinoTheme.brightnessOf(context) ==
                                          Brightness.dark
                                      ? CupertinoColors.white.withValues(
                                          alpha: 0.14,
                                        )
                                      : CupertinoColors.black.withValues(
                                          alpha: 0.08,
                                        ),
                                  width: 0.8,
                                ),
                              ),
                              child: CupertinoButton(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                                onPressed: onCancel,
                                borderRadius: BorderRadius.circular(10),
                                child: Text(
                                  effectiveCancelText,
                                  style: TextStyle(
                                    color: AppColors.label(context),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: CupertinoButton(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              onPressed: confirmEnabled ? onConfirm : null,
                              color: confirmColor ?? CupertinoColors.activeBlue,
                              disabledColor: CupertinoColors.systemGrey4,
                              borderRadius: BorderRadius.circular(10),
                              child: Text(
                                effectiveConfirmText,
                                style: const TextStyle(
                                  color: CupertinoColors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Future<bool?> showFrostedConfirmDialog(
  BuildContext context, {
  required String title,
  required String content,
  String? cancelText,
  String? confirmText,
  bool isDestructive = false,
  IconData? icon,
}) {
  return showCupertinoDialog<bool>(
    context: context,
    barrierDismissible: true,
    builder: (context) => FrostedDialog(
      title: title,
      icon:
          icon ?? (isDestructive ? CupertinoIcons.trash : CupertinoIcons.info),
      confirmText: confirmText,
      confirmColor: isDestructive ? CupertinoColors.systemRed : null,
      cancelText: cancelText,
      onCancel: () => Navigator.of(context).pop(false),
      onConfirm: () => Navigator.of(context).pop(true),
      child: Text(
        content,
        style: TextStyle(
          fontSize: 14,
          color: AppColors.label(context),
          height: 1.4,
        ),
      ),
    ),
  );
}

class _DialogGlowBorderPainter extends CustomPainter {
  const _DialogGlowBorderPainter({required this.isDark});

  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(
      rect,
      const Radius.circular(18),
    ).deflate(0.75);

    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        isDark
            ? const Color(0x6600E5FF)
            : CupertinoColors.activeBlue.withValues(alpha: 0.4),
        const Color(0x00000000),
        isDark
            ? const Color(0x66FF007F)
            : CupertinoColors.activeOrange.withValues(alpha: 0.25),
      ],
      stops: const [0.0, 0.5, 1.0],
    );

    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(_DialogGlowBorderPainter oldDelegate) {
    return oldDelegate.isDark != isDark;
  }
}
