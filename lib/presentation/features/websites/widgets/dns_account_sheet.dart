import 'package:flutter/cupertino.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../core/localization/l10n_x.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/dto/website/ssl_manage_dtos.dart';
import '../../../common/app_toast.dart';
import '../../../common/components/action_sheet_launcher.dart';
import '../../../common/components/action_sheet_scaffold.dart';
import '../../../common/components/app_action_components.dart';
import 'dns_account_form_sheet.dart';

/// Shows the DNS account management sheet.
Future<void> showDnsAccountSheet(
  BuildContext context, {
  required List<DnsAccountDto> accounts,
  required Future<void> Function(DnsAccountCreateReq req) onCreate,
  required Future<void> Function(int id, Map<String, dynamic> req) onUpdate,
  required Future<void> Function(int id) onDelete,
  required VoidCallback onRefresh,
}) {
  return showActionSheet<void>(
    context: context,
    builder: (ctx) => _DnsAccountSheet(
      accounts: accounts,
      onCreate: onCreate,
      onUpdate: onUpdate,
      onDelete: onDelete,
      onRefresh: onRefresh,
    ),
  );
}

class _DnsAccountSheet extends StatefulWidget {
  const _DnsAccountSheet({
    required this.accounts,
    required this.onCreate,
    required this.onUpdate,
    required this.onDelete,
    required this.onRefresh,
  });

  final List<DnsAccountDto> accounts;
  final Future<void> Function(DnsAccountCreateReq req) onCreate;
  final Future<void> Function(int id, Map<String, dynamic> req) onUpdate;
  final Future<void> Function(int id) onDelete;
  final VoidCallback onRefresh;

  @override
  State<_DnsAccountSheet> createState() => _DnsAccountSheetState();
}

class _DnsAccountSheetState extends State<_DnsAccountSheet> {
  int? _activeId;
  String? _confirmAction;

  void _resetActive() {
    if (_activeId != null) {
      setState(() {
        _activeId = null;
        _confirmAction = null;
      });
    }
  }

  Future<void> _handleDelete(int id) async {
    try {
      await widget.onDelete(id);
      _resetActive();
      widget.onRefresh();
    } catch (e) {
      if (mounted) {
        showAppErrorToast(
          context.l10n.websites_deleteFailed,
          description: e.toString(),
        );
      }
    }
  }

  Future<void> _openCreateSheet() async {
    await showDnsAccountCreateSheet(
      context,
      onSubmit: (req) async {
        await widget.onCreate(req);
        widget.onRefresh();
      },
    );
  }

  Future<void> _openEditSheet(DnsAccountDto account) async {
    _resetActive();
    await showDnsAccountEditSheet(
      context,
      account: account,
      onSubmit: (id, req) async {
        await widget.onUpdate(id, req);
        widget.onRefresh();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _resetActive,
      child: ActionSheetScaffold(
        isAdaptive: true,
        showHandle: false,
        maxHeightFactor: 0.7,
        panelHeader: Padding(
          padding: const EdgeInsets.fromLTRB(8, 4, 12, 4),
          child: Row(
            children: [
              CupertinoButton(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                onPressed: () => Navigator.pop(context),
                child: Text(
                  context.l10n.common_close,
                  style: TextStyle(
                    color: AppColors.secondaryLabel(context),
                    fontSize: 16,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  context.l10n.websites_dnsAccount,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.label(context),
                  ),
                ),
              ),
              const SizedBox(width: 64),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppSectionHeader(
              title: context.l10n.websites_accountList,
              icon: TablerIcons.list,
            ),
            if (widget.accounts.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(
                    context.l10n.websites_noDnsAccounts,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.secondaryLabel(context),
                    ),
                  ),
                ),
              )
            else
              ...widget.accounts.map(_buildAccountRow),
            const SizedBox(height: 18),
            AppActionGroup(
              children: [
                AppActionRow(
                  icon: TablerIcons.plus,
                  iconColor: CupertinoColors.systemGreen,
                  title: context.l10n.websites_createDnsAccount,
                  subtitle: Text(context.l10n.websites_addDnsProviderAccount),
                  onTap: _openCreateSheet,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountRow(DnsAccountDto account) {
    final isActive = _activeId == account.id;
    return GestureDetector(
      onTap: () {
        if (isActive) {
          _resetActive();
        } else {
          setState(() {
            _activeId = account.id;
            _confirmAction = null;
          });
        }
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.secondaryBackground(context).withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive
                ? (_confirmAction == 'delete'
                      ? CupertinoColors.systemRed.withValues(alpha: 0.3)
                      : AppColors.separator(context).withValues(alpha: 0.1))
                : AppColors.separator(context).withValues(alpha: 0.1),
            width: 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: CupertinoColors.systemTeal.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                TablerIcons.world,
                size: 24,
                color: CupertinoColors.systemTeal,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    account.name.isEmpty ? 'DNS #${account.id}' : account.name,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: isActive
                          ? (_confirmAction == 'delete'
                                ? CupertinoColors.systemRed
                                : AppColors.label(context))
                          : AppColors.label(context),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isActive
                        ? (_confirmAction == 'delete'
                              ? context.l10n.websites_clickAgainToConfirmDelete
                              : context.l10n.websites_selectOperation)
                        : account.type.isEmpty
                        ? 'DNS'
                        : account.type,
                    style: TextStyle(
                      fontSize: 12,
                      color: isActive
                          ? (_confirmAction == 'delete'
                                ? CupertinoColors.systemRed.withValues(
                                    alpha: 0.7,
                                  )
                                : AppColors.secondaryLabel(context))
                          : AppColors.secondaryLabel(context),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (!isActive)
              CupertinoButton(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                onPressed: () => setState(() {
                  _activeId = account.id;
                  _confirmAction = null;
                }),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.label(context).withValues(alpha: 0.03),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    TablerIcons.dots,
                    size: 18,
                    color: AppColors.secondaryLabel(context),
                  ),
                ),
              )
            else
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildActionButton(
                    icon: TablerIcons.pencil,
                    color: AppColors.secondaryLabel(
                      context,
                    ).withValues(alpha: 0.5),
                    bgColor: AppColors.label(context).withValues(alpha: 0.03),
                    onTap: () => _openEditSheet(account),
                  ),
                  const SizedBox(width: 10),
                  _buildActionButton(
                    icon: TablerIcons.trash,
                    color: _confirmAction == 'delete'
                        ? CupertinoColors.systemRed
                        : AppColors.secondaryLabel(
                            context,
                          ).withValues(alpha: 0.5),
                    bgColor: _confirmAction == 'delete'
                        ? CupertinoColors.systemRed.withValues(alpha: 0.1)
                        : AppColors.label(context).withValues(alpha: 0.03),
                    onTap: () {
                      if (_confirmAction == 'delete') {
                        _handleDelete(account.id);
                      } else {
                        setState(() => _confirmAction = 'delete');
                      }
                    },
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      minimumSize: Size.zero,
      onPressed: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }
}
