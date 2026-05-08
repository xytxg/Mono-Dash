import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../core/localization/l10n_x.dart';
import '../../../../data/dto/app/app_installed_dto.dart';
import '../../../../data/repositories_impl/app_repository_impl.dart';
import '../../../common/components/app_action_components.dart';
import '../../../common/components/task_log_sheet.dart';
import '../../containers/widgets/container_log_sheet.dart';
import '../../files/screens/files_page.dart';
import '../../server_detail/providers/active_server_provider.dart';
import 'app_backup_sheet.dart';
import 'app_lifecycle_actions.dart';
import 'app_params_sheet.dart';
import 'app_terminal_action.dart';
import 'app_uninstall_flow.dart';

class AppActionList extends ConsumerWidget {
  const AppActionList({super.key, required this.app});

  final AppInstalledDto app;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isRunning = app.status.toLowerCase() == 'running';
    final l10n = context.l10n;
    final hasInstallDirectory = app.path.isNotEmpty;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppSectionHeader(
          title: l10n.appStore_appInfo,
          icon: TablerIcons.info_circle,
        ),
        AppActionGroup(
          children: [
            AppActionRow(
              icon: TablerIcons.folder_root,
              iconColor: CupertinoColors.systemOrange,
              title: l10n.appStore_installDirectory,
              subtitle: Text(
                app.path.isEmpty
                    ? l10n.appStore_directoryUnavailable
                    : app.path,
              ),
              enabled: hasInstallDirectory,
              onTap: hasInstallDirectory
                  ? () => _openInstallDirectory(context, ref, app.path)
                  : null,
            ),
          ],
        ),
        const SizedBox(height: 22),
        AppSectionHeader(
          title: l10n.appStore_backup,
          icon: TablerIcons.archive,
        ),
        AppActionGroup(
          children: [
            AppActionRow(
              icon: TablerIcons.archive,
              iconColor: CupertinoColors.systemTeal,
              title: l10n.appStore_runBackup,
              subtitle: Text(l10n.appStore_runBackupSubtitle),
              onTap: () => showAppBackupSheet(context, app),
            ),
          ],
        ),
        const SizedBox(height: 22),
        AppSectionHeader(
          title: l10n.appStore_runtimeControl,
          icon: TablerIcons.player_play,
        ),
        AppActionGroup(
          children: [
            AppActionRow(
              icon: TablerIcons.refresh,
              iconColor: CupertinoColors.systemIndigo,
              title: l10n.appStore_rebuildApp,
              subtitle: Text(l10n.appStore_rebuildSubtitle),
              onTap: () => confirmRebuildApp(context, ref, app),
            ),
            AppActionRow(
              icon: TablerIcons.rotate_clockwise,
              iconColor: CupertinoColors.systemPurple,
              title: l10n.appStore_restartApp,
              subtitle: Text(l10n.appStore_restartSubtitle),
              onTap: () => confirmRestartApp(context, ref, app),
            ),
            AppActionRow(
              icon: isRunning
                  ? TablerIcons.player_stop
                  : TablerIcons.player_play,
              iconColor: isRunning
                  ? CupertinoColors.systemRed
                  : CupertinoColors.systemGreen,
              title: isRunning
                  ? l10n.appStore_stopRunningApp
                  : l10n.appStore_enableApp,
              subtitle: Text(
                isRunning
                    ? l10n.appStore_stopRunningSubtitle
                    : l10n.appStore_startCurrentSubtitle,
              ),
              onTap: () => isRunning
                  ? confirmStopApp(context, ref, app)
                  : confirmStartApp(context, ref, app),
            ),
          ],
        ),
        const SizedBox(height: 22),
        AppSectionHeader(
          title: l10n.appStore_maintenance,
          icon: TablerIcons.tools,
        ),
        AppActionGroup(
          children: [
            AppActionRow(
              icon: TablerIcons.settings,
              iconColor: CupertinoColors.systemBlue,
              title: l10n.appStore_modifyParams,
              subtitle: Text(l10n.appStore_modifyParamsSubtitle),
              onTap: () => showAppParamsSheet(context: context, app: app),
            ),
            AppActionRow(
              icon: TablerIcons.terminal_2,
              iconColor: CupertinoColors.systemGreen,
              title: l10n.appStore_runTerminal,
              subtitle: Text(
                app.name.isEmpty ? l10n.appStore_enterContainer : app.name,
              ),
              onTap: () => openAppTerminal(context, app),
            ),
            AppActionRow(
              icon: TablerIcons.logs,
              iconColor: CupertinoColors.systemBrown,
              title: l10n.appStore_viewLogs,
              subtitle: Text(l10n.appStore_viewLogsSubtitle),
              onTap: () => showContainerLogSheet(context, app: app),
            ),
            AppActionRow(
              icon: TablerIcons.history,
              iconColor: CupertinoColors.systemTeal,
              title: l10n.appStore_installLog,
              subtitle: Text(l10n.appStore_installLogSubtitle),
              onTap: () => showTaskLogSheet(
                context,
                title: l10n.appStore_installLogTitle(app.displayName),
                taskID: '',
                reader: (_) async {
                  final repo = await ref.read(appRepositoryProvider.future);
                  return repo.getAppInstallLog(app.id);
                },
              ),
            ),
            AppActionRow(
              icon: TablerIcons.trash,
              iconColor: CupertinoColors.systemRed,
              title: l10n.appStore_uninstallApp,
              subtitle: Text(l10n.appStore_uninstallSubtitle),
              onTap: () => confirmUninstallApp(context, ref, app),
            ),
          ],
        ),
      ],
    );
  }

  void _openInstallDirectory(BuildContext context, WidgetRef ref, String path) {
    final serverId = ref.read(activeServerIdProvider);
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (_) => ProviderScope(
          overrides: [activeServerIdProvider.overrideWithValue(serverId)],
          child: StandaloneFilesPage(initialPath: path),
        ),
      ),
    );
  }
}
