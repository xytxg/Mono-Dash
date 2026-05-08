import 'package:flutter/cupertino.dart';

import '../../../../../core/localization/l10n_x.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../common/components/action_sheet_launcher.dart';
import '../../../../common/components/action_sheet_scaffold.dart';

/// 通用单值编辑子 Sheet。
///
/// 返回编辑后的字符串；用户取消返回 `null`。
Future<String?> showDockerEditValueSheet(
  BuildContext context, {
  required String title,
  required String initialValue,
  String? placeholder,
  bool multiline = false,
}) {
  final controller = TextEditingController(text: initialValue);
  return showActionSheet<String>(
    context: context,
    useRootNavigator: true,
    builder: (ctx) => _EditValueSheet(
      title: title,
      controller: controller,
      placeholder: placeholder,
      multiline: multiline,
    ),
  );
}

class _EditValueSheet extends StatelessWidget {
  const _EditValueSheet({
    required this.title,
    required this.controller,
    this.placeholder,
    this.multiline = false,
  });

  final String title;
  final TextEditingController controller;
  final String? placeholder;
  final bool multiline;

  @override
  Widget build(BuildContext context) {
    return ActionSheetScaffold(
      isAdaptive: true,
      maxHeightFactor: 0.5,
      showHandle: false,
      contentPadding: EdgeInsets.zero,
      panelHeader: Padding(
        padding: const EdgeInsets.fromLTRB(8, 4, 12, 4),
        child: Row(
          children: [
            CupertinoButton(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              onPressed: () => Navigator.pop(context),
              child: Text(
                context.l10n.common_cancel,
                style: TextStyle(
                  color: AppColors.secondaryLabel(context),
                  fontSize: 16,
                ),
              ),
            ),
            Expanded(
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.label(context),
                ),
              ),
            ),
            CupertinoButton(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              onPressed: () => Navigator.pop(context, controller.text.trim()),
              child: Text(
                context.l10n.common_confirm,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: CupertinoTextField(
          controller: controller,
          placeholder: placeholder,
          maxLines: multiline ? 12 : 1,
          minLines: multiline ? 6 : 1,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
          decoration: BoxDecoration(
            color: AppColors.tertiaryBackground(context).withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          style: TextStyle(
            color: AppColors.label(context),
            fontSize: 14,
            fontFamily: multiline ? 'monospace' : null,
          ),
        ),
      ),
    );
  }
}
