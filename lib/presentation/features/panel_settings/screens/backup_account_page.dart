import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../core/localization/l10n_x.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/repositories_impl/backup_account_repository_impl.dart';
import '../../../common/app_toast.dart';
import '../../../common/components/app_confirm_sheet.dart';
import '../../../common/components/action_sheet_launcher.dart';
import '../../../common/components/app_empty_state.dart';
import '../../../common/components/frosted_scaffold.dart';
import '../../../common/components/app_action_components.dart';
import '../../server_detail/providers/active_server_provider.dart';
import '../widgets/backup_account_form_sheet.dart';

class BackupAccountPage extends StatelessWidget {
  const BackupAccountPage({super.key, required this.serverId});

  final int serverId;

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [activeServerIdProvider.overrideWithValue(serverId)],
      child: const _BackupAccountContent(),
    );
  }
}

class _BackupAccountContent extends ConsumerStatefulWidget {
  const _BackupAccountContent();

  @override
  ConsumerState<_BackupAccountContent> createState() =>
      _BackupAccountContentState();
}

class _BackupAccountContentState extends ConsumerState<_BackupAccountContent> {
  List<Map<String, dynamic>> _accounts = [];
  bool _loading = true;

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
    return FrostedScaffold(
      title: context.l10n.panelSettings_backupAccounts,
      trailingBuilder: (isDark, isOverlapping) => CupertinoButton(
        padding: EdgeInsets.zero,
        minimumSize: const Size(32, 32),
        onPressed: () async {
          await showBackupAccountFormSheet(context);
          if (mounted) _load();
        },
        child: Icon(
          TablerIcons.plus,
          size: 22,
          color: CupertinoColors.activeBlue.resolveFrom(context),
        ),
      ),
      body: _loading
          ? const Center(child: CupertinoActivityIndicator())
          : _accounts.isEmpty
          ? _buildEmpty(context)
          : _buildList(context),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return AppEmptyState(
      icon: TablerIcons.cloud_off,
      title: context.l10n.panelSettings_noBackupAccounts,
      onAction: () async {
        await showBackupAccountFormSheet(context);
        if (mounted) _load();
      },
      actionLabel: context.l10n.panelSettings_addBackupAccount,
    );
  }

  Widget _buildList(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(
        16,
        FrostedScaffold.contentTopPadding(context) + 12,
        16,
        40,
      ),
      itemCount: _accounts.length,
      itemBuilder: (context, index) {
        final account = _accounts[index];

        // 我们将每个账号作为一个独立的 Group 或者放在一个大 Group 里
        // 考虑到备份账号可能比较多，我们每 1 个账号做一个 Group 看起来更像“卡片”
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: AppActionGroup(children: [_buildAccountRow(context, account)]),
        );
      },
    );
  }

  Widget _buildAccountRow(BuildContext context, Map<String, dynamic> account) {
    final name = (account['name'] as String?) ?? '';
    final type = (account['type'] as String?) ?? '';
    final bucket = (account['bucket'] as String?) ?? '';
    final backupPath = (account['backupPath'] as String?) ?? '';
    final id = (account['id'] as num?)?.toInt() ?? 0;

    return AppActionRow(
      icon: _typeIcon(type),
      iconColor: _typeColor(type),
      title: name,
      subtitle: Text(
        '$type${bucket.isNotEmpty ? ' · $bucket' : ''}${backupPath.isNotEmpty ? ' · $backupPath' : ''}',
      ),
      onTap: () async {
        await showBackupAccountFormSheet(context, existing: account);
        if (mounted) _load();
      },
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (type.toUpperCase() == 'ONEDRIVE' ||
              type.toUpperCase() == 'ALIYUN')
            CupertinoButton(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              onPressed: () => _refreshToken(id),
              child: Icon(
                TablerIcons.refresh,
                size: 20,
                color: CupertinoColors.activeBlue.resolveFrom(context),
              ),
            ),
          CupertinoButton(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            onPressed: () => _deleteAccount(id, name),
            child: Icon(
              TablerIcons.trash,
              size: 20,
              color: CupertinoColors.systemRed.resolveFrom(context),
            ),
          ),
          Icon(
            TablerIcons.chevron_right,
            size: 14,
            color: AppColors.tertiaryLabel(context).withValues(alpha: 0.5),
          ),
        ],
      ),
    );
  }

  Future<void> _refreshToken(int id) async {
    try {
      final repo = await ref.read(backupAccountRepositoryProvider.future);
      await repo.refreshToken(id);
      if (mounted) {
        showAppSuccessToast(context.l10n.panelSettings_tokenRefreshed);
      }
    } catch (e) {
      if (mounted) {
        showAppErrorToast(
          context.l10n.panelSettings_refreshFailed,
          description: e.toString(),
        );
      }
    }
  }

  Future<void> _deleteAccount(int id, String name) async {
    final confirmed = await showActionSheet<bool>(
      context: context,
      useRootNavigator: true,
      builder: (ctx) => AppConfirmSheet(
        title: context.l10n.panelSettings_deleteBackupAccount,
        content: context.l10n.panelSettings_deleteBackupAccountConfirm(name),
        icon: TablerIcons.trash,
        iconColor: CupertinoColors.systemRed,
        confirmText: context.l10n.panelSettings_confirmDelete,
        confirmColor: CupertinoColors.systemRed,
      ),
    );
    if (confirmed != true || !mounted) return;

    try {
      final repo = await ref.read(backupAccountRepositoryProvider.future);
      await repo.deleteAccount(id);
      if (mounted) {
        showAppSuccessToast(context.l10n.panelSettings_deleted);
        _load();
      }
    } catch (e) {
      if (mounted) {
        showAppErrorToast(
          context.l10n.panelSettings_deleteFailed,
          description: e.toString(),
        );
      }
    }
  }

  IconData _typeIcon(String type) {
    switch (type.toUpperCase()) {
      case 'OSS':
      case 'ALIYUN':
        return TablerIcons.cloud;
      case 'COS':
        return TablerIcons.cloud;
      case 'S3':
        return TablerIcons.brand_amazon;
      case 'MINIO':
        return TablerIcons.database;
      case 'SFTP':
        return TablerIcons.server;
      case 'WEBDAV':
        return TablerIcons.world;
      case 'ONEDRIVE':
        return TablerIcons.cloud;
      case 'GOOGLEDRIVE':
        return TablerIcons.brand_google;
      case 'KODO':
        return TablerIcons.cloud_upload;
      case 'UPYUN':
        return TablerIcons.cloud_upload;
      default:
        return TablerIcons.folder;
    }
  }

  Color _typeColor(String type) {
    switch (type.toUpperCase()) {
      case 'OSS':
      case 'ALIYUN':
        return CupertinoColors.systemOrange;
      case 'COS':
        return CupertinoColors.systemBlue;
      case 'S3':
        return CupertinoColors.systemYellow;
      case 'MINIO':
        return CupertinoColors.systemRed;
      case 'SFTP':
        return CupertinoColors.systemGreen;
      case 'WEBDAV':
        return CupertinoColors.systemIndigo;
      case 'ONEDRIVE':
        return CupertinoColors.systemBlue;
      case 'GOOGLEDRIVE':
        return CupertinoColors.systemGreen;
      default:
        return CupertinoColors.systemGrey;
    }
  }
}
