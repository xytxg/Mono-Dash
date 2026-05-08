import 'package:flutter/cupertino.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import '../../../core/localization/l10n_x.dart';
import '../../../core/theme/app_theme.dart';
import 'action_sheet_scaffold.dart';

/// 一个通用的通知/状态展示面板，遵循 Apple 'Content Unavailable' 设计风格。
/// 可用于版本不支持、功能锁定、操作成功等多种场景。
class AppNoticeSheet extends StatelessWidget {
  const AppNoticeSheet({
    super.key,
    required this.title,
    required this.content,
    this.icon = TablerIcons.info_circle,
    this.iconColor,
    this.confirmText,
    this.onConfirm,
  });

  final String title;
  final String content;
  final IconData icon;
  final Color? iconColor;
  final String? confirmText;
  final VoidCallback? onConfirm;

  @override
  Widget build(BuildContext context) {
    final effectiveConfirmText = confirmText ?? context.l10n.common_gotIt;

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
              color: iconColor ?? CupertinoColors.systemBlue,
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
            SizedBox(
              width: double.infinity,
              height: 52,
              child: CupertinoButton(
                color: CupertinoColors.activeBlue,
                borderRadius: BorderRadius.circular(14),
                onPressed: onConfirm ?? () => Navigator.of(context).pop(),
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
          ],
        ),
      ),
    );
  }
}
