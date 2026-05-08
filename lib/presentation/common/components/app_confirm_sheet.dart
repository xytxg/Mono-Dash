import 'package:flutter/cupertino.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import '../../../core/localization/l10n_x.dart';
import '../../../core/theme/app_theme.dart';
import 'action_sheet_scaffold.dart';

/// 通用的确认对话框面板，遵循 Apple 'Content Unavailable' 设计风格。
/// 用于需要用户确认才能继续的场景，如删除、重置等操作。
class AppConfirmSheet extends StatelessWidget {
  const AppConfirmSheet({
    super.key,
    required this.title,
    required this.content,
    this.icon = TablerIcons.alert_triangle,
    this.iconColor,
    this.cancelText,
    this.confirmText,
    this.confirmColor,
    this.onCancel,
    this.onConfirm,
  });

  final String title;
  final String content;
  final IconData icon;
  final Color? iconColor;
  final String? cancelText;
  final String? confirmText;
  final Color? confirmColor;
  final VoidCallback? onCancel;
  final VoidCallback? onConfirm;

  @override
  Widget build(BuildContext context) {
    final effectiveConfirmColor = confirmColor ?? CupertinoColors.activeBlue;
    final effectiveCancelText = cancelText ?? context.l10n.common_cancel;
    final effectiveConfirmText = confirmText ?? context.l10n.common_confirm;

    return ActionSheetScaffold(
      isAdaptive: true,
      showHandle: false,
      isFloating: true,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 48,
              color: iconColor ?? CupertinoColors.systemOrange,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.label(context),
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              content,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: AppColors.secondaryLabel(context),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 30),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: CupertinoButton(
                      color: AppColors.secondaryBackground(context),
                      borderRadius: BorderRadius.circular(14),
                      onPressed:
                          onCancel ?? () => Navigator.of(context).pop(false),
                      child: Text(
                        effectiveCancelText,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: AppColors.label(context),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: CupertinoButton(
                      color: effectiveConfirmColor,
                      borderRadius: BorderRadius.circular(14),
                      onPressed:
                          onConfirm ?? () => Navigator.of(context).pop(true),
                      child: Text(
                        effectiveConfirmText,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: CupertinoColors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
