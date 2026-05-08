import 'package:flutter/cupertino.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/l10n_x.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/repositories_impl/database_repository_impl.dart';
import '../../../common/app_toast.dart';
import '../../../common/components/app_code_editor.dart';
import '../../../common/components/frosted_header.dart';
import '../../../features/containers/widgets/container_log_sheet.dart';
import '../../server_detail/providers/active_server_provider.dart';
import '../models/database_state.dart';
import '../screens/database_performance_page.dart';
import '../screens/database_port_page.dart';
import '../screens/database_slow_log_page.dart';
import '../widgets/database_placeholders.dart';
import '../widgets/database_remote_edit_sheet.dart';
import '../widgets/settings_components.dart';
import '../widgets/database_unbind_sheet.dart';

/// 设置 Tab。
class SettingsTab extends ConsumerWidget {
  const SettingsTab({
    super.key,
    required this.dbType,
    required this.dbName,
    required this.checkState,
    this.isRemote = false,
    this.dbId = 0,
  });

  final String dbType;
  final String dbName;
  final AsyncValue<DatabaseManagementState> checkState;
  final bool isRemote;
  final int dbId;

  bool get _isPg => dbType.contains('postgresql');

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
        if (isRemote) {
          return _buildRemoteContent(context, ref);
        }
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

  Widget _buildRemoteContent(BuildContext context, WidgetRef ref) {
    final topPadding =
        FrostedHeader.headerHeight + MediaQuery.paddingOf(context).top + 8;
    return ListView(
      padding: EdgeInsets.fromLTRB(0, topPadding, 0, 100),
      children: [
        SettingsSectionHeader(
          title: context.l10n.databases_connectionManagement,
        ),
        SettingsGroupedBox(
          children: [
            SettingsTile(
              icon: TablerIcons.edit,
              iconColor: CupertinoColors.systemIndigo,
              title: context.l10n.databases_editConnection,
              subtitle: context.l10n.databases_editConnectionSubtitle,
              onTap: () => showDatabaseRemoteEditSheet(
                context,
                dbId: dbId,
                dbName: dbName,
                dbType: dbType,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        SettingsSectionHeader(title: context.l10n.databases_operations),
        SettingsGroupedBox(
          children: [
            SettingsTile(
              icon: TablerIcons.plug_connected,
              iconColor: CupertinoColors.systemRed,
              title: context.l10n.databases_unbind,
              subtitle: context.l10n.databases_unbindRemoteDatabase,
              onTap: () => showDatabaseUnbindSheet(
                context,
                dbId: dbId,
                dbName: dbName,
                onUnbound: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ],
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
              subtitle: context.l10n.databases_configFileSubtitle,
              onTap: () => _openConfigEditor(context, ref),
            ),
          ],
        ),
        if (!_isPg) ...[
          const SizedBox(height: 24),
          SettingsSectionHeader(title: context.l10n.databases_performance),
          SettingsGroupedBox(
            children: [
              SettingsTile(
                icon: TablerIcons.gauge,
                iconColor: CupertinoColors.systemOrange,
                title: context.l10n.databases_performanceTuning,
                subtitle: context.l10n.databases_globalVariablesTuning(
                  dbType == 'mariadb' ? 'MariaDB' : 'MySQL',
                ),
                onTap: () => _pushScoped(
                  context,
                  ref,
                  () => DatabasePerformancePage(dbType: dbType, dbName: dbName),
                ),
              ),
              SettingsTile(
                icon: TablerIcons.clock,
                iconColor: CupertinoColors.systemTeal,
                title: context.l10n.databases_slowLog,
                subtitle: context.l10n.databases_slowLogSubtitle,
                onTap: () => _pushScoped(
                  context,
                  ref,
                  () => DatabaseSlowLogPage(dbType: dbType, dbName: dbName),
                ),
              ),
            ],
          ),
        ],
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
        const SizedBox(height: 24),
        SettingsSectionHeader(title: context.l10n.databases_maintenance),
        SettingsGroupedBox(
          children: [
            SettingsTile(
              icon: TablerIcons.logs,
              iconColor: CupertinoColors.systemBrown,
              title: context.l10n.databases_containerLogs,
              subtitle: context.l10n.databases_containerLogsSubtitle,
              onTap: () {
                final containerName = data.checkResult?.containerName ?? '';
                if (containerName.isEmpty) {
                  showAppWarningToast(
                    context.l10n.databases_containerNameUnavailable,
                  );
                  return;
                }
                showContainerLogSheet(context, containerName: containerName);
              },
            ),
          ],
        ),
      ],
    );
  }

  /// 推入带 activeServerIdProvider override 的二级页面。
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
        type: '$dbType-conf',
        name: dbName,
      );
      if (!context.mounted) return;
      await showAppCodeEditorSheet(
        context,
        title: _isPg ? 'postgresql.conf' : 'my.cnf',
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
