import 'package:flutter/cupertino.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../core/localization/l10n_x.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/dto/website/website_acme_account_dto.dart';
import '../../../../data/dto/website/ssl_manage_dtos.dart';
import '../../../common/components/action_sheet_launcher.dart';
import '../../../common/components/action_sheet_scaffold.dart';
import '../../../common/components/app_action_components.dart';
import '../../../common/components/app_confirm_sheet.dart';
import 'acme_account_create_sheet.dart';

/// Shows the ACME account management sheet.
Future<void> showAcmeAccountSheet(
  BuildContext context, {
  required List<WebsiteAcmeAccountDto> accounts,
  required Future<void> Function(AcmeAccountCreateReq req) onCreate,
  required Future<void> Function(int id, Map<String, dynamic> req) onUpdate,
  required Future<void> Function(int id) onDelete,
  required VoidCallback onRefresh,
}) {
  return showActionSheet<void>(
    context: context,
    builder: (ctx) => _AcmeAccountSheet(
      accounts: accounts,
      onCreate: onCreate,
      onUpdate: onUpdate,
      onDelete: onDelete,
      onRefresh: onRefresh,
    ),
  );
}

class _AcmeAccountSheet extends StatelessWidget {
  const _AcmeAccountSheet({
    required this.accounts,
    required this.onCreate,
    required this.onUpdate,
    required this.onDelete,
    required this.onRefresh,
  });

  final List<WebsiteAcmeAccountDto> accounts;
  final Future<void> Function(AcmeAccountCreateReq req) onCreate;
  final Future<void> Function(int id, Map<String, dynamic> req) onUpdate;
  final Future<void> Function(int id) onDelete;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return ActionSheetScaffold(
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
                context.l10n.websites_acmeAccount,
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
          if (accounts.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  context.l10n.websites_noAcmeAccounts,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.secondaryLabel(context),
                  ),
                ),
              ),
            )
          else
            AppActionGroup(
              children: accounts.map((account) {
                return AppActionRow(
                  icon: TablerIcons.user_circle,
                  iconColor: CupertinoColors.activeBlue,
                  title: account.displayName,
                  subtitle: Text(account.type.isEmpty ? 'ACME' : account.type),
                  onTap: () {},
                  trailing: CupertinoButton(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(32, 32),
                    borderRadius: BorderRadius.circular(8),
                    onPressed: () async {
                      final confirmed = await showActionSheet<bool>(
                        context: context,
                        builder: (ctx) => AppConfirmSheet(
                          title: context.l10n.websites_deleteAcmeAccount,
                          content:
                              context.l10n.websites_deleteAcmeAccountConfirm,
                          icon: TablerIcons.trash,
                          iconColor: CupertinoColors.systemRed,
                          confirmText: context.l10n.common_delete,
                          confirmColor: CupertinoColors.systemRed,
                        ),
                      );
                      if (confirmed == true) {
                        onDelete(account.id);
                      }
                    },
                    child: Icon(
                      TablerIcons.trash,
                      size: 18,
                      color: CupertinoColors.systemRed.resolveFrom(context),
                    ),
                  ),
                );
              }).toList(),
            ),
          const SizedBox(height: 18),
          AppActionGroup(
            children: [
              AppActionRow(
                icon: TablerIcons.plus,
                iconColor: CupertinoColors.systemGreen,
                title: context.l10n.websites_createAcmeAccount,
                subtitle: Text(context.l10n.websites_addAcmeAccount),
                onTap: () {
                  showAcmeAccountCreateSheet(
                    context,
                    onSubmit: (req) async {
                      await onCreate(req);
                      onRefresh();
                    },
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
