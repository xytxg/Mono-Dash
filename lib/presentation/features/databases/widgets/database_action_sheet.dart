import 'package:flutter/cupertino.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../core/localization/l10n_x.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/dto/database/database_instance_dto.dart';
import '../../../common/components/action_sheet_launcher.dart';
import '../../../common/components/action_sheet_scaffold.dart';
import '../../../common/components/app_action_components.dart';
import 'database_backup_sheet.dart';
import 'database_change_access_sheet.dart';
import 'database_change_password_sheet.dart';
import 'database_delete_sheet.dart';
import 'database_import_backup_sheet.dart';
import 'database_type_icon.dart';

/// 显示数据库操作菜单。
Future<void> showDatabaseActionSheet(
  BuildContext context,
  DatabaseSearchItemDto database,
  String type, {
  VoidCallback? onRefresh,
}) async {
  await showActionSheet(
    context: context,
    builder: (context) => _DatabaseActionSheet(
      database: database,
      type: type,
      onRefresh: onRefresh,
    ),
  );
}

class _DatabaseActionSheet extends StatelessWidget {
  const _DatabaseActionSheet({
    required this.database,
    required this.type,
    this.onRefresh,
  });

  final DatabaseSearchItemDto database;
  final String type;
  final VoidCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    return ActionSheetScaffold(
      isAdaptive: true,
      showHandle: true,
      panelHeader: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Row(
          children: [
            DatabaseTypeIcon(type: type, size: 32),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                database.name,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.label(context),
                  letterSpacing: -0.5,
                ),
              ),
            ),
          ],
        ),
      ),
      child: _DatabaseActionList(
        database: database,
        type: type,
        onRefresh: onRefresh,
      ),
    );
  }
}

class _DatabaseActionList extends StatelessWidget {
  const _DatabaseActionList({
    required this.database,
    required this.type,
    this.onRefresh,
  });

  final DatabaseSearchItemDto database;
  final String type;
  final VoidCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppSectionHeader(
          title: context.l10n.databases_management,
          icon: TablerIcons.settings,
        ),
        AppActionGroup(
          children: [
            AppActionRow(
              icon: TablerIcons.key,
              iconColor: CupertinoColors.systemOrange,
              title: context.l10n.databases_changePassword,
              subtitle: Text(context.l10n.databases_changePasswordSubtitle),
              onTap: () {
                Navigator.pop(context);
                showDatabaseChangePasswordSheet(
                  context,
                  database: database,
                  type: type,
                  onSuccess: onRefresh,
                );
              },
            ),
            if (!type.contains('postgresql'))
              AppActionRow(
                icon: TablerIcons.shield_lock,
                iconColor: CupertinoColors.systemBlue,
                title: context.l10n.databases_access,
                subtitle: Text(context.l10n.databases_accessSubtitle),
                onTap: () {
                  Navigator.pop(context);
                  showDatabaseChangeAccessSheet(
                    context,
                    database: database,
                    type: type,
                    onSuccess: onRefresh,
                  );
                },
              ),
            AppActionRow(
              icon: TablerIcons.archive,
              iconColor: CupertinoColors.systemTeal,
              title: context.l10n.databases_backupList,
              subtitle: Text(context.l10n.databases_backupListSubtitle),
              onTap: () {
                Navigator.pop(context);
                showDatabaseBackupSheet(
                  context,
                  type: type,
                  name: database.instanceName,
                  dbName: database.name,
                );
              },
            ),
            AppActionRow(
              icon: TablerIcons.file_import,
              iconColor: CupertinoColors.systemIndigo,
              title: context.l10n.databases_importBackup,
              subtitle: Text(context.l10n.databases_importBackupSubtitle),
              onTap: () {
                Navigator.pop(context);
                showDatabaseImportBackupSheet(
                  context,
                  type: type,
                  name: database.instanceName,
                  dbName: database.name,
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 22),
        AppSectionHeader(
          title: context.l10n.databases_dangerZone,
          icon: TablerIcons.alert_triangle,
        ),
        AppActionGroup(
          children: [
            AppActionRow(
              icon: TablerIcons.trash,
              iconColor: CupertinoColors.systemRed,
              title: context.l10n.common_delete,
              subtitle: Text(context.l10n.databases_deleteSubtitle),
              isDestructive: true,
              onTap: () {
                Navigator.pop(context);
                showDatabaseDeleteSheet(
                  context,
                  database: database,
                  type: type,
                  onDeleted: onRefresh,
                );
              },
            ),
          ],
        ),
      ],
    );
  }
}
