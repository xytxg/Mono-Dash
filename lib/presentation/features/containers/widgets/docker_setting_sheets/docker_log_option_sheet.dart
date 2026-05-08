import 'package:flutter/cupertino.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../../core/localization/l10n_x.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../common/components/action_sheet_launcher.dart';
import '../../../../common/components/action_sheet_scaffold.dart';
import '../../../../common/components/app_action_components.dart';

/// 日志切割配置结果。
class LogOptionResult {
  const LogOptionResult({required this.logMaxSize, required this.logMaxFile});

  final String logMaxSize;
  final String logMaxFile;
}

/// 显示日志切割配置 Sheet。
///
/// 返回 [LogOptionResult]；用户取消返回 `null`。
Future<LogOptionResult?> showDockerLogOptionSheet(
  BuildContext context, {
  required String currentLogMaxSize,
  required String currentLogMaxFile,
}) {
  return showActionSheet<LogOptionResult>(
    context: context,
    useRootNavigator: true,
    builder: (ctx) => _LogOptionSheet(
      initialLogMaxSize: currentLogMaxSize,
      initialLogMaxFile: currentLogMaxFile,
    ),
  );
}

class _LogOptionSheet extends StatefulWidget {
  const _LogOptionSheet({
    required this.initialLogMaxSize,
    required this.initialLogMaxFile,
  });

  final String initialLogMaxSize;
  final String initialLogMaxFile;

  @override
  State<_LogOptionSheet> createState() => _LogOptionSheetState();
}

class _LogOptionSheetState extends State<_LogOptionSheet> {
  late final TextEditingController _maxSizeController;
  late final TextEditingController _maxFileController;

  @override
  void initState() {
    super.initState();
    _maxSizeController = TextEditingController(text: widget.initialLogMaxSize);
    _maxFileController = TextEditingController(text: widget.initialLogMaxFile);
  }

  @override
  void dispose() {
    _maxSizeController.dispose();
    _maxFileController.dispose();
    super.dispose();
  }

  void _confirm() {
    Navigator.pop(
      context,
      LogOptionResult(
        logMaxSize: _maxSizeController.text.trim(),
        logMaxFile: _maxFileController.text.trim(),
      ),
    );
  }

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
                context.l10n.containers_logRotation,
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
              onPressed: _confirm,
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
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppSectionHeader(
              title: context.l10n.containers_logRotationParams,
              icon: TablerIcons.adjustments,
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.secondaryBackground(
                  context,
                ).withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFieldLabel(
                    context,
                    context.l10n.containers_logSizeLimit,
                  ),
                  const SizedBox(height: 8),
                  CupertinoTextField(
                    controller: _maxSizeController,
                    placeholder: context.l10n.containers_logSizeExample,
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 12,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.tertiaryBackground(
                        context,
                      ).withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    style: TextStyle(
                      color: AppColors.label(context),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildFieldLabel(
                    context,
                    context.l10n.containers_maxLogFiles,
                  ),
                  const SizedBox(height: 8),
                  CupertinoTextField(
                    controller: _maxFileController,
                    placeholder: context.l10n.containers_maxLogFilesExample,
                    keyboardType: TextInputType.number,
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 12,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.tertiaryBackground(
                        context,
                      ).withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    style: TextStyle(
                      color: AppColors.label(context),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                context.l10n.containers_dockerRestartApplyConfig,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.tertiaryLabel(context),
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldLabel(BuildContext context, String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.secondaryLabel(context),
      ),
    );
  }
}
