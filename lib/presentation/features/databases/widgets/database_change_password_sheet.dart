import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/l10n_x.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/dto/database/database_instance_dto.dart';
import '../../../common/app_toast.dart';
import '../../../common/components/action_sheet_launcher.dart';
import '../../../common/components/action_sheet_scaffold.dart';
import '../../../common/components/frosted_dialog.dart';
import '../../../../data/repositories_impl/database_repository_impl.dart';

/// 显示改密 Sheet。
///
/// 改密成功后调用 [onSuccess]（通常用于刷新列表）。
Future<void> showDatabaseChangePasswordSheet(
  BuildContext context, {
  required DatabaseSearchItemDto database,
  required String type,
  VoidCallback? onSuccess,
}) async {
  await showActionSheet<void>(
    context: context,
    builder: (_) => _DatabaseChangePasswordSheet(
      database: database,
      type: type,
      onSuccess: onSuccess,
    ),
  );
}

class _DatabaseChangePasswordSheet extends ConsumerStatefulWidget {
  const _DatabaseChangePasswordSheet({
    required this.database,
    required this.type,
    this.onSuccess,
  });

  final DatabaseSearchItemDto database;
  final String type;
  final VoidCallback? onSuccess;

  @override
  ConsumerState<_DatabaseChangePasswordSheet> createState() =>
      _DatabaseChangePasswordSheetState();
}

class _DatabaseChangePasswordSheetState
    extends ConsumerState<_DatabaseChangePasswordSheet> {
  late final _usernameController = TextEditingController(
    text: widget.database.username,
  );
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validate(String password) {
    final l10n = context.l10n;
    if (password.isEmpty) return l10n.databases_enterNewPassword;
    if (password.contains(' ')) return l10n.databases_passwordNoSpaces;
    if (password.length < 6) return l10n.databases_passwordMinLength;
    return null;
  }

  Future<void> _submit() async {
    final password = _passwordController.text;
    final error = _validate(password);
    if (error != null) {
      showAppWarningToast(error);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final repo = await ref.read(databaseRepositoryProvider.future);

      // 1. 预检：是否有占用
      final checkResult = await repo.checkDelete(
        id: widget.database.id,
        type: widget.type,
        database: widget.database.instanceName,
      );

      if (checkResult.isNotEmpty && mounted) {
        final resourceNames = checkResult
            .map((r) => '${r.type}: ${r.name}')
            .join('\n');
        final confirmed = await showFrostedConfirmDialog(
          context,
          title: context.l10n.databases_confirmPasswordChange,
          content: context.l10n.databases_passwordChangeUsedWarning(
            resourceNames,
          ),
          icon: TablerIcons.alert_triangle,
        );
        if (confirmed != true) return;
      }

      // 2. 正式改密
      final encodedValue = base64Encode(utf8.encode(password));
      await repo.changePassword(
        id: widget.database.id,
        from: widget.database.from,
        type: widget.type,
        database: widget.database.instanceName,
        value: encodedValue,
      );

      if (mounted) {
        showAppSuccessToast(context.l10n.databases_passwordChanged);
        widget.onSuccess?.call();
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        showAppErrorToast(
          context.l10n.databases_passwordChangeFailed,
          description: '$e',
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ActionSheetScaffold(
      isAdaptive: true,
      showHandle: false,
      panelHeader: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 10, 8),
        child: Row(
          children: [
            Expanded(
              child: Text(
                context.l10n.databases_changePassword,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 用户名（只读）
          _FormItem(
            label: context.l10n.databases_username,
            icon: TablerIcons.user,
            child: SizedBox(
              height: 46,
              child: CupertinoTextField(
                controller: _usernameController,
                readOnly: true,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                textAlignVertical: TextAlignVertical.center,
                decoration: BoxDecoration(
                  color: AppColors.tertiaryBackground(context),
                  borderRadius: BorderRadius.circular(12),
                ),
                style: TextStyle(
                  fontSize: 17,
                  color: AppColors.secondaryLabel(context),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // 新密码
          _FormItem(
            label: context.l10n.databases_newPassword,
            icon: TablerIcons.key,
            child: SizedBox(
              height: 46,
              child: CupertinoTextField(
                controller: _passwordController,
                placeholder: context.l10n.databases_enterNewPassword,
                obscureText: _obscurePassword,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                textAlignVertical: TextAlignVertical.center,
                style: TextStyle(fontSize: 17, color: AppColors.label(context)),
                decoration: BoxDecoration(
                  color: AppColors.secondaryBackground(
                    context,
                  ).withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                suffix: CupertinoButton(
                  minimumSize: Size.zero,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                  child: Icon(
                    _obscurePassword ? TablerIcons.eye_off : TablerIcons.eye,
                    size: 20,
                    color: AppColors.secondaryLabel(context),
                  ),
                ),
              ),
            ),
          ),
          // 提示
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 4),
            child: Row(
              children: [
                Icon(
                  TablerIcons.info_circle,
                  size: 12,
                  color: AppColors.tertiaryLabel(context),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    context.l10n.databases_passwordChangeHint,
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.tertiaryLabel(context),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          // 提交按钮
          SizedBox(
            width: double.infinity,
            height: 50,
            child: CupertinoButton(
              padding: EdgeInsets.zero,
              color: CupertinoColors.activeBlue.resolveFrom(context),
              borderRadius: BorderRadius.circular(14),
              onPressed: _isLoading ? null : _submit,
              child: _isLoading
                  ? const CupertinoActivityIndicator(
                      color: CupertinoColors.white,
                    )
                  : Text(
                      context.l10n.databases_confirmChange,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: CupertinoColors.white,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FormItem extends StatelessWidget {
  const _FormItem({
    required this.label,
    required this.icon,
    required this.child,
  });

  final String label;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Row(
            children: [
              Icon(icon, size: 14, color: AppColors.secondaryLabel(context)),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.secondaryLabel(context),
                ),
              ),
            ],
          ),
        ),
        child,
      ],
    );
  }
}
