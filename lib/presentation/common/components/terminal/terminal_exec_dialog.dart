import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/l10n_x.dart';
import '../../../../core/theme/app_theme.dart';
import '../app_picker.dart';
import '../action_sheet_launcher.dart';
import '../frosted_dialog.dart';

typedef TerminalExecResult = ({String user, String command});

Future<TerminalExecResult?> showTerminalExecDialog(
  BuildContext context, {
  required String containerId,
}) {
  return showProviderDialog<TerminalExecResult>(
    context: context,
    barrierDismissible: true,
    builder: (context) => _TerminalExecDialog(containerId: containerId),
  );
}

class _TerminalExecDialog extends ConsumerStatefulWidget {
  const _TerminalExecDialog({required this.containerId});

  final String containerId;

  @override
  ConsumerState<_TerminalExecDialog> createState() =>
      _TerminalExecDialogState();
}

class _TerminalExecDialogState extends ConsumerState<_TerminalExecDialog> {
  final _userController = TextEditingController(text: 'root');
  final _commandController = TextEditingController(text: '/bin/sh');
  String _selectedCommand = '/bin/sh';

  @override
  void dispose() {
    _userController.dispose();
    _commandController.dispose();
    super.dispose();
  }

  void _onCommandSelected(String value) {
    setState(() {
      _selectedCommand = value;
      if (value != 'custom') {
        _commandController.text = value;
      } else {
        _commandController.text = '';
      }
    });
  }

  void _submit() {
    final user = _userController.text.trim();
    final command = _commandController.text.trim();
    if (command.isEmpty) return;

    Navigator.of(context).pop((user: user, command: command));
  }

  @override
  Widget build(BuildContext context) {
    final isCustomCommand = _selectedCommand == 'custom';
    final l10n = context.l10n;
    final canSubmit = isCustomCommand
        ? _commandController.text.trim().isNotEmpty
        : _selectedCommand.trim().isNotEmpty;
    return FrostedDialog(
      title: l10n.terminal_connectTitle,
      subtitle: l10n.terminal_containerSubtitle(widget.containerId),
      icon: CupertinoIcons.command,
      confirmText: l10n.terminal_connectAction,
      onCancel: () => Navigator.of(context).pop(),
      onConfirm: _submit,
      confirmEnabled: canSubmit,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildFieldLabel(l10n.terminal_execUser),
          CupertinoTextField(
            controller: _userController,
            placeholder: l10n.terminal_execUserPlaceholder,
            style: TextStyle(color: AppColors.label(context), fontSize: 14),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.secondaryBackground(
                context,
              ).withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 14),
          _buildFieldLabel(l10n.terminal_execCommand),
          AppInlinePicker<String>(
            backgroundColor: AppColors.secondaryBackground(
              context,
            ).withValues(alpha: 0.8),
            options: [
              const AppPickerOption(value: '/bin/sh', label: '/bin/sh'),
              const AppPickerOption(value: '/bin/bash', label: '/bin/bash'),
              const AppPickerOption(value: '/bin/ash', label: '/bin/ash'),
              AppPickerOption(value: 'custom', label: l10n.terminal_custom),
            ],
            value: _selectedCommand,
            onChanged: _onCommandSelected,
            selectedColor: CupertinoColors.activeBlue.resolveFrom(context),
          ),
          if (isCustomCommand) ...[
            const SizedBox(height: 8),
            CupertinoTextField(
              controller: _commandController,
              placeholder: l10n.terminal_execCommandPlaceholder,
              style: TextStyle(color: AppColors.label(context), fontSize: 14),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              onChanged: (_) => setState(() {}),
              onSubmitted: (_) => _submit(),
              decoration: BoxDecoration(
                color: AppColors.secondaryBackground(
                  context,
                ).withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, left: 2),
      child: Text(
        text,
        textAlign: TextAlign.left,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: AppColors.secondaryLabel(context),
        ),
      ),
    );
  }
}
