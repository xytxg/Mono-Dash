import 'package:flutter/cupertino.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/l10n_x.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/repositories_impl/database_repository_impl.dart';
import '../../../common/app_toast.dart';
import '../../../common/components/app_code_editor.dart';
import '../../../common/components/frosted_header.dart';
import '../../server_detail/providers/active_server_provider.dart';
import '../models/database_state.dart';
import '../screens/database_port_page.dart';
import '../screens/redis_performance_page.dart';
import '../screens/redis_persistence_page.dart';
import '../widgets/database_backup_sheet.dart';
import '../widgets/database_placeholders.dart';
import '../widgets/settings_components.dart';

/// Redis 设置 Tab。
class RedisSettingsTab extends ConsumerWidget {
  const RedisSettingsTab({
    super.key,
    required this.dbType,
    required this.dbName,
    required this.checkState,
  });

  final String dbType;
  final String dbName;
  final AsyncValue<DatabaseManagementState> checkState;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return checkState.when(
      loading: () => const Center(child: CupertinoActivityIndicator()),
      error: (e, _) => Center(
        child: Text(
          context.l10n.databases_loadFailedWithError(e),
          style: TextStyle(
            fontSize: 14,
            color: AppColors.secondaryLabel(context),
          ),
        ),
      ),
      data: (data) {
        if (!data.isRunning) {
          return DatabaseNotRunningPlaceholder(
            icon: TablerIcons.settings,
            iconColor: CupertinoColors.systemGrey
                .resolveFrom(context)
                .withValues(alpha: 0.5),
            title: context.l10n.databases_notRunning,
          );
        }
        return _buildContent(context, ref, data);
      },
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    DatabaseManagementState data,
  ) {
    final topPadding =
        FrostedHeader.headerHeight + MediaQuery.paddingOf(context).top + 8;
    return ListView(
      padding: EdgeInsets.fromLTRB(0, topPadding, 0, 100),
      children: [
        SettingsSectionHeader(title: context.l10n.databases_config),
        SettingsGroupedBox(
          children: [
            SettingsTile(
              icon: TablerIcons.file_code,
              iconColor: CupertinoColors.systemIndigo,
              title: context.l10n.databases_configFile,
              subtitle: context.l10n.databases_redisConfigFileSubtitle,
              onTap: () => _openConfigEditor(context, ref),
            ),
          ],
        ),
        const SizedBox(height: 24),
        SettingsSectionHeader(title: context.l10n.databases_performance),
        SettingsGroupedBox(
          children: [
            SettingsTile(
              icon: TablerIcons.gauge,
              iconColor: CupertinoColors.systemOrange,
              title: context.l10n.databases_performanceTuning,
              subtitle: 'timeout / maxclients / maxmemory',
              onTap: () => _pushScoped(
                context,
                ref,
                () => RedisPerformancePage(dbType: dbType, dbName: dbName),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        SettingsSectionHeader(title: context.l10n.databases_persistence),
        SettingsGroupedBox(
          children: [
            SettingsTile(
              icon: TablerIcons.database,
              iconColor: CupertinoColors.systemTeal,
              title: context.l10n.databases_persistenceConfig,
              subtitle: context.l10n.databases_persistenceConfigSubtitle,
              onTap: () => _pushScoped(
                context,
                ref,
                () => RedisPersistencePage(dbType: dbType, dbName: dbName),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        SettingsSectionHeader(title: context.l10n.databases_backup),
        SettingsGroupedBox(
          children: [
            SettingsTile(
              icon: TablerIcons.archive,
              iconColor: CupertinoColors.systemBrown,
              title: context.l10n.databases_backupList,
              subtitle: context.l10n.databases_redisBackupListSubtitle,
              onTap: () => showDatabaseBackupSheet(
                context,
                type: dbType,
                name: dbName,
                dbName: '',
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        SettingsSectionHeader(title: context.l10n.databases_network),
        SettingsGroupedBox(
          children: [
            SettingsTile(
              icon: TablerIcons.network,
              iconColor: CupertinoColors.systemBlue,
              title: context.l10n.databases_databasePort,
              subtitle: context.l10n.databases_currentListeningPort(
                data.checkResult?.httpPort ?? '-',
              ),
              onTap: () => _pushScoped(
                context,
                ref,
                () => DatabasePortPage(
                  dbType: dbType,
                  dbName: dbName,
                  currentPort: data.checkResult?.httpPort ?? 0,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _pushScoped(
    BuildContext context,
    WidgetRef ref,
    Widget Function() builder,
  ) {
    final serverId = ref.read(activeServerIdProvider);
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (_) => ProviderScope(
          overrides: [activeServerIdProvider.overrideWithValue(serverId)],
          child: builder(),
        ),
      ),
    );
  }

  Future<void> _openConfigEditor(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    try {
      final repo = await ref.read(databaseRepositoryProvider.future);
      final content = await repo.loadConfigFile(
        type: 'redis-conf',
        name: dbName,
      );
      if (!context.mounted) return;
      await showAppCodeEditorSheet(
        context,
        title: 'redis.conf',
        subtitle: dbName,
        initialContent: content,
        language: 'ini',
        onSave: (newContent) async {
          try {
            await repo.updateConfigFile(
              type: dbType,
              database: dbName,
              file: newContent,
            );
            showAppSuccessToast(l10n.databases_configSaved);
            return true;
          } catch (e) {
            showAppErrorToast(l10n.databases_saveFailed, description: '$e');
            return false;
          }
        },
      );
    } catch (e) {
      showAppErrorToast(l10n.common_loadingFailed, description: '$e');
    }
  }
}
