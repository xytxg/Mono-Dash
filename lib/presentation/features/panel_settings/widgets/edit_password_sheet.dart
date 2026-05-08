import 'package:flutter/cupertino.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../core/localization/l10n_x.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../common/components/action_sheet_launcher.dart';
import '../../../common/components/action_sheet_scaffold.dart';
import '../../../common/components/app_form_components.dart';

/// 显示修改密码的底部弹窗，返回 (oldPassword, newPassword) 或 null。
Future<(String, String)?> showEditPasswordSheet(BuildContext context) {
  return showActionSheet<(String, String)>(
    context: context,
    useRootNavigator: true,
    builder: (_) => const _EditPasswordSheet(),
  );
}

class _EditPasswordSheet extends StatefulWidget {
  const _EditPasswordSheet();

  @override
  State<_EditPasswordSheet> createState() => _EditPasswordSheetState();
}

class _EditPasswordSheetState extends State<_EditPasswordSheet> {
  final _oldController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _oldController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ActionSheetScaffold(
      isAdaptive: true,
      showHandle: false,
      isFloating: true,
      panelHeader: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 10, 8),
        child: Row(
          children: [
            Expanded(
              child: Text(
                context.l10n.panelSettings_changePassword,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.label(context),
                ),
              ),
            ),
            CupertinoButton(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              onPressed: () => Navigator.pop(context),
              child: Text(
                context.l10n.common_cancel,
                style: TextStyle(
                  color: AppColors.secondaryLabel(context),
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppFormItem(
            label: context.l10n.panelSettings_currentPassword,
            icon: TablerIcons.lock,
            child: AppFormTextField(
              controller: _oldController,
              placeholder:
                  context.l10n.panelSettings_currentPasswordPlaceholder,
              obscureText: _obscureOld,
              suffix: _buildToggleVisibility(
                visible: !_obscureOld,
                onPressed: () => setState(() => _obscureOld = !_obscureOld),
              ),
            ),
          ),
          const SizedBox(height: 16),
          AppFormItem(
            label: context.l10n.panelSettings_newPassword,
            icon: TablerIcons.lock_plus,
            child: AppFormTextField(
              controller: _newController,
              placeholder: context.l10n.panelSettings_newPasswordPlaceholder,
              obscureText: _obscureNew,
              backgroundColor: AppColors.secondaryBackground(
                context,
              ).withValues(alpha: 0.5),
              suffix: _buildToggleVisibility(
                visible: !_obscureNew,
                onPressed: () => setState(() => _obscureNew = !_obscureNew),
              ),
            ),
          ),
          const SizedBox(height: 16),
          AppFormItem(
            label: context.l10n.panelSettings_confirmNewPassword,
            icon: TablerIcons.lock_check,
            child: AppFormTextField(
              controller: _confirmController,
              placeholder:
                  context.l10n.panelSettings_confirmNewPasswordPlaceholder,
              obscureText: _obscureConfirm,
              backgroundColor: AppColors.secondaryBackground(
                context,
              ).withValues(alpha: 0.5),
              onSubmitted: (_) => _onSubmit(),
              textInputAction: TextInputAction.done,
              suffix: _buildToggleVisibility(
                visible: !_obscureConfirm,
                onPressed: () =>
                    setState(() => _obscureConfirm = !_obscureConfirm),
              ),
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: CupertinoButton.filled(
              borderRadius: BorderRadius.circular(14),
              onPressed: _onSubmit,
              child: Text(
                context.l10n.common_save,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleVisibility({
    required bool visible,
    required VoidCallback onPressed,
  }) {
    return CupertinoButton(
      minimumSize: Size.zero,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      onPressed: onPressed,
      child: Icon(
        visible ? TablerIcons.eye : TablerIcons.eye_off,
        size: 20,
        color: AppColors.secondaryLabel(context),
      ),
    );
  }

  void _onSubmit() {
    final old = _oldController.text.trim();
    final newPwd = _newController.text.trim();
    final confirm = _confirmController.text.trim();

    if (old.isEmpty || newPwd.isEmpty) {
      return;
    }
    if (newPwd != confirm) {
      return;
    }
    Navigator.of(context).pop((old, newPwd));
  }
}
