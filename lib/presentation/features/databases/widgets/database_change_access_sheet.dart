import 'package:flutter/cupertino.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/l10n_x.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/dto/database/database_instance_dto.dart';
import '../../../common/app_toast.dart';
import '../../../common/components/action_sheet_launcher.dart';
import '../../../common/components/action_sheet_scaffold.dart';
import '../../../common/components/app_picker.dart';
import '../../../../data/repositories_impl/database_repository_impl.dart';

enum _AccessScope { any, local, ip }

/// 显示权限修改 Sheet。
///
/// 修改成功后调用 [onSuccess]（通常用于刷新列表）。
Future<void> showDatabaseChangeAccessSheet(
  BuildContext context, {
  required DatabaseSearchItemDto database,
  required String type,
  VoidCallback? onSuccess,
}) async {
  await showActionSheet<void>(
    context: context,
    builder: (_) => _DatabaseChangeAccessSheet(
      database: database,
      type: type,
      onSuccess: onSuccess,
    ),
  );
}

class _DatabaseChangeAccessSheet extends ConsumerStatefulWidget {
  const _DatabaseChangeAccessSheet({
    required this.database,
    required this.type,
    this.onSuccess,
  });

  final DatabaseSearchItemDto database;
  final String type;
  final VoidCallback? onSuccess;

  @override
  ConsumerState<_DatabaseChangeAccessSheet> createState() =>
      _DatabaseChangeAccessSheetState();
}

class _DatabaseChangeAccessSheetState
    extends ConsumerState<_DatabaseChangeAccessSheet> {
  late _AccessScope _scope;
  final _ipController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _scope = _parseScope(widget.database.permission);
    if (_scope == _AccessScope.ip) {
      _ipController.text = widget.database.permission;
    }
  }

  @override
  void dispose() {
    _ipController.dispose();
    super.dispose();
  }

  static _AccessScope _parseScope(String permission) {
    if (permission == '%') return _AccessScope.any;
    if (permission == 'localhost') return _AccessScope.local;
    return _AccessScope.ip;
  }

  String _currentPermissionLabel(BuildContext context) {
    final p = widget.database.permission;
    if (p == '%') return context.l10n.databases_anyHost;
    if (p == 'localhost') return context.l10n.databases_localhostOnly;
    if (p.isEmpty) return context.l10n.databases_unset;
    return context.l10n.databases_specificIpValue(p);
  }

  String get _resolvedValue {
    switch (_scope) {
      case _AccessScope.any:
        return '%';
      case _AccessScope.local:
        return 'localhost';
      case _AccessScope.ip:
        return _ipController.text.trim();
    }
  }

  bool get _isUnchanged => _resolvedValue == widget.database.permission;

  String? _validate() {
    if (_scope != _AccessScope.ip) return null;
    final ip = _ipController.text.trim();
    if (ip.isEmpty) return context.l10n.databases_enterIpOrCidr;
    if (ip.contains(' ')) return context.l10n.databases_ipNoSpaces;
    return null;
  }

  Future<void> _submit() async {
    if (_isUnchanged) {
      Navigator.pop(context);
      return;
    }

    final error = _validate();
    if (error != null) {
      showAppWarningToast(error);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final repo = await ref.read(databaseRepositoryProvider.future);
      await repo.changeAccess(
        id: widget.database.id,
        from: widget.database.from,
        type: widget.type,
        database: widget.database.instanceName,
        value: _resolvedValue,
      );

      if (mounted) {
        showAppSuccessToast(context.l10n.databases_accessChanged);
        widget.onSuccess?.call();
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        showAppErrorToast(
          context.l10n.databases_accessChangeFailed,
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
                context.l10n.databases_accessPermissions,
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
          // 当前权限（只读）
          _FormItem(
            label: context.l10n.databases_currentPermission,
            icon: TablerIcons.shield,
            child: SizedBox(
              height: 46,
              child: Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: AppColors.tertiaryBackground(context),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _currentPermissionLabel(context),
                  style: TextStyle(
                    fontSize: 17,
                    color: AppColors.secondaryLabel(context),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          // 权限类型选择
          _FormItem(
            label: context.l10n.databases_grantScope,
            icon: TablerIcons.world,
            child: AppInlinePicker<_AccessScope>(
              value: _scope,
              anchorHeight: 46,
              backgroundColor: AppColors.tertiaryBackground(context),
              options: [
                AppPickerOption(
                  value: _AccessScope.any,
                  label: context.l10n.databases_anyHostShort,
                ),
                AppPickerOption(
                  value: _AccessScope.local,
                  label: context.l10n.databases_localhostOnlyShort,
                ),
                AppPickerOption(
                  value: _AccessScope.ip,
                  label: context.l10n.databases_specifiedIp,
                ),
              ],
              onChanged: (v) => setState(() => _scope = v),
            ),
          ),
          // IP 输入框
          if (_scope == _AccessScope.ip) ...[
            const SizedBox(height: 12),
            SizedBox(
              height: 46,
              child: CupertinoTextField(
                controller: _ipController,
                placeholder: context.l10n.databases_ipExample,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                textAlignVertical: TextAlignVertical.center,
                style: TextStyle(fontSize: 17, color: AppColors.label(context)),
                decoration: BoxDecoration(
                  color: AppColors.tertiaryBackground(context),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8, left: 4),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        TablerIcons.info_circle,
                        size: 12,
                        color: AppColors.tertiaryLabel(context),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          context.l10n.databases_ipCidrHint,
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.tertiaryLabel(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        TablerIcons.info_circle,
                        size: 12,
                        color: AppColors.tertiaryLabel(context),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          context.l10n.databases_multipleIpHint,
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.tertiaryLabel(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
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
