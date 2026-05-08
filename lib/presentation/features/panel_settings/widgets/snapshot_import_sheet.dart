import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../core/localization/l10n_x.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/repositories_impl/backup_account_repository_impl.dart';
import '../../../../data/repositories_impl/setting_repository_impl.dart';
import '../../../common/app_toast.dart';
import '../../../common/components/action_sheet_launcher.dart';
import '../../../common/components/action_sheet_scaffold.dart';

/// 显示同步快照弹窗。
Future<void> showSnapshotImportSheet(BuildContext context) {
  return showActionSheet<void>(
    context: context,
    useRootNavigator: true,
    builder: (_) => const _SnapshotImportSheet(),
  );
}

class _SnapshotImportSheet extends ConsumerStatefulWidget {
  const _SnapshotImportSheet();

  @override
  ConsumerState<_SnapshotImportSheet> createState() =>
      _SnapshotImportSheetState();
}

class _SnapshotImportSheetState extends ConsumerState<_SnapshotImportSheet> {
  List<Map<String, dynamic>> _accounts = [];
  int _selectedAccountId = 0;
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final repo = await ref.read(backupAccountRepositoryProvider.future);
      final result = await repo.searchAccounts(page: 1, pageSize: 100);
      if (!mounted) return;
      final items = result['items'];
      setState(() {
        _accounts = items is List
            ? items.whereType<Map<String, dynamic>>().toList()
            : [];
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ActionSheetScaffold(
      isAdaptive: true,
      showHandle: false,
      isFloating: true,
      panelHeader: Padding(
        padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
        child: Row(
          children: [
            CupertinoButton(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                context.l10n.common_cancel,
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.secondaryLabel(context),
                ),
              ),
            ),
            Expanded(
              child: Text(
                context.l10n.panelSettings_syncSnapshot,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.4,
                ),
              ),
            ),
            const SizedBox(width: 60),
          ],
        ),
      ),
      child: _loading
          ? const Padding(
              padding: EdgeInsets.all(40),
              child: Center(child: CupertinoActivityIndicator()),
            )
          : Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Warning
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemOrange
                          .resolveFrom(context)
                          .withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: CupertinoColors.systemOrange
                            .resolveFrom(context)
                            .withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          TablerIcons.info_circle,
                          size: 18,
                          color: CupertinoColors.systemOrange.resolveFrom(
                            context,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            context.l10n.panelSettings_importSnapshotHelp,
                            style: TextStyle(
                              fontSize: 13,
                              color: CupertinoColors.systemOrange.resolveFrom(
                                context,
                              ),
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Account picker
                  if (_accounts.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        context.l10n.panelSettings_noBackupAccountsAddFirst,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.tertiaryLabel(context),
                        ),
                      ),
                    )
                  else
                    _buildAccountPicker(),

                  const SizedBox(height: 20),

                  // Import button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: CupertinoButton.filled(
                      borderRadius: BorderRadius.circular(14),
                      onPressed: _saving || _selectedAccountId == 0
                          ? null
                          : _onImport,
                      child: _saving
                          ? const CupertinoActivityIndicator(
                              color: CupertinoColors.white,
                            )
                          : Text(
                              context.l10n.panelSettings_sync,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildAccountPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.panelSettings_selectBackupAccount,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.label(context),
          ),
        ),
        const SizedBox(height: 8),
        ..._accounts.map((acc) {
          final id = (acc['id'] as num?)?.toInt() ?? 0;
          final name = (acc['name'] as String?) ?? '';
          final type = (acc['type'] as String?) ?? '';
          final selected = _selectedAccountId == id;
          return GestureDetector(
            onTap: () => setState(() => _selectedAccountId = id),
            behavior: HitTestBehavior.opaque,
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: selected
                    ? CupertinoColors.activeBlue
                          .resolveFrom(context)
                          .withValues(alpha: 0.1)
                    : AppColors.secondaryBackground(
                        context,
                      ).withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: selected
                      ? CupertinoColors.activeBlue.resolveFrom(context)
                      : AppColors.separator(context).withValues(alpha: 0.2),
                  width: selected ? 1.5 : 0.5,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    selected
                        ? TablerIcons.circle_check_filled
                        : TablerIcons.circle,
                    size: 20,
                    color: selected
                        ? CupertinoColors.activeBlue.resolveFrom(context)
                        : AppColors.tertiaryLabel(context),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      name,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: selected
                            ? FontWeight.w600
                            : FontWeight.normal,
                        color: AppColors.label(context),
                      ),
                    ),
                  ),
                  Text(
                    type,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.tertiaryLabel(context),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Future<void> _onImport() async {
    setState(() => _saving = true);
    try {
      final repo = await ref.read(settingRepositoryProvider.future);
      await repo.importSnapshot({'backupAccountID': _selectedAccountId});
      if (mounted) {
        showAppSuccessToast(context.l10n.panelSettings_syncStarted);
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        showAppErrorToast(
          context.l10n.panelSettings_syncFailed,
          description: e.toString(),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
