import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../core/localization/l10n_x.dart';
import '../../../../data/dto/runtime/runtime_dto.dart';
import '../../../common/components/action_sheet_launcher.dart';
import '../../../common/components/action_sheet_scaffold.dart';
import '../../../common/components/app_action_components.dart';
import '../../../common/components/app_confirm_sheet.dart';
import '../../containers/widgets/container_terminal_action.dart';
import '../../files/screens/files_page.dart';
import '../../server_detail/providers/active_server_provider.dart';

Future<void> showRuntimeActionSheet(
  BuildContext context, {
  required RuntimeDto item,
  required Future<void> Function(int id, String operate) onOperate,
  required Future<void> Function(int id, String name) onDelete,
  required VoidCallback onEdit,
  required VoidCallback onShowLog,
  required VoidCallback onShowBuildLog,
}) {
  return showActionSheet<void>(
    context: context,
    builder: (ctx) => _RuntimeActionSheet(
      item: item,
      onOperate: onOperate,
      onDelete: onDelete,
      onEdit: onEdit,
      onShowLog: onShowLog,
      onShowBuildLog: onShowBuildLog,
    ),
  );
}

class _RuntimeActionSheet extends ConsumerWidget {
  const _RuntimeActionSheet({
    required this.item,
    required this.onOperate,
    required this.onDelete,
    required this.onEdit,
    required this.onShowLog,
    required this.onShowBuildLog,
  });

  final RuntimeDto item;
  final Future<void> Function(int id, String operate) onOperate;
  final Future<void> Function(int id, String name) onDelete;
  final VoidCallback onEdit;
  final VoidCallback onShowLog;
  final VoidCallback onShowBuildLog;

  bool get _isRunning => item.status.toLowerCase().contains('running');
  bool get _isStopped => item.status.toLowerCase().contains('stopped');
  bool get _isBuilding => item.status.toLowerCase().contains('building');
  bool get _isLocal => item.resource == 'local';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ActionSheetScaffold(
      isAdaptive: true,
      showHandle: true,
      maxHeightFactor: 0.7,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSectionHeader(
            title: context.l10n.runtime_serviceManagement,
            icon: TablerIcons.server,
          ),
          AppActionGroup(
            children: [
              AppActionRow(
                icon: TablerIcons.player_play,
                iconColor: CupertinoColors.systemGreen,
                title: context.l10n.runtime_start,
                subtitle: Text(context.l10n.runtime_startDescription),
                enabled: !_isRunning && !_isBuilding && !_isLocal,
                onTap: () {
                  Navigator.pop(context);
                  onOperate(item.id, 'up');
                },
              ),
              AppActionRow(
                icon: TablerIcons.player_stop,
                iconColor: CupertinoColors.systemRed,
                title: context.l10n.runtime_stop,
                subtitle: Text(context.l10n.runtime_stopDescription),
                enabled: !_isStopped && !_isBuilding && !_isLocal,
                onTap: () {
                  Navigator.pop(context);
                  onOperate(item.id, 'down');
                },
              ),
              AppActionRow(
                icon: TablerIcons.refresh,
                iconColor: CupertinoColors.systemOrange,
                title: context.l10n.runtime_restart,
                subtitle: Text(context.l10n.runtime_restartDescription),
                enabled: !_isBuilding && !_isLocal,
                onTap: () {
                  Navigator.pop(context);
                  onOperate(item.id, 'restart');
                },
              ),
            ],
          ),
          const SizedBox(height: 18),
          AppSectionHeader(
            title: context.l10n.runtime_appTools,
            icon: TablerIcons.tools,
          ),
          AppActionGroup(
            children: [
              if (item.codeDir.trim().isNotEmpty)
                AppActionRow(
                  icon: TablerIcons.folder_open,
                  iconColor: CupertinoColors.systemIndigo,
                  title: context.l10n.runtime_projectDirectory,
                  subtitle: Text(item.codeDir),
                  onTap: () {
                    Navigator.pop(context);
                    _openDirectory(context, ref, item.codeDir);
                  },
                ),
              if (item.path.trim().isNotEmpty)
                AppActionRow(
                  icon: TablerIcons.folder_cog,
                  iconColor: CupertinoColors.systemGrey,
                  title: context.l10n.runtime_configDirectory,
                  subtitle: Text(item.path),
                  onTap: () {
                    Navigator.pop(context);
                    _openDirectory(context, ref, item.path);
                  },
                ),
              AppActionRow(
                icon: TablerIcons.terminal_2,
                iconColor: CupertinoColors.systemGreen,
                title: context.l10n.runtime_terminal,
                subtitle: Text(context.l10n.runtime_terminalDescription),
                enabled: _isRunning,
                onTap: () => openTerminalById(context, item.containerName),
              ),
              AppActionRow(
                icon: TablerIcons.edit,
                iconColor: CupertinoColors.activeBlue,
                title: context.l10n.common_edit,
                subtitle: Text(context.l10n.runtime_editDescription),
                enabled: !_isBuilding,
                onTap: () {
                  Navigator.pop(context);
                  onEdit();
                },
              ),
            ],
          ),
          const SizedBox(height: 18),
          AppSectionHeader(
            title: context.l10n.runtime_logs,
            icon: TablerIcons.notes,
          ),
          AppActionGroup(
            children: [
              AppActionRow(
                icon: TablerIcons.logs,
                iconColor: CupertinoColors.systemBrown,
                title: context.l10n.runtime_runLogs,
                subtitle: Text(context.l10n.runtime_runLogsDescription),
                onTap: () {
                  Navigator.pop(context);
                  onShowLog();
                },
              ),
              AppActionRow(
                icon: TablerIcons.file_text,
                iconColor: CupertinoColors.systemTeal,
                title: context.l10n.runtime_buildLogs,
                subtitle: Text(context.l10n.runtime_buildLogsDescription),
                onTap: () {
                  Navigator.pop(context);
                  onShowBuildLog();
                },
              ),
            ],
          ),
          const SizedBox(height: 18),
          AppSectionHeader(
            title: context.l10n.runtime_dangerZone,
            icon: TablerIcons.alert_triangle,
          ),
          AppActionGroup(
            children: [
              AppActionRow(
                icon: TablerIcons.trash,
                iconColor: CupertinoColors.destructiveRed,
                title: context.l10n.common_delete,
                subtitle: Text(context.l10n.runtime_deleteDescription),
                isDestructive: true,
                onTap: () {
                  Navigator.pop(context);
                  showActionSheet(
                    context: context,
                    builder: (context) => AppConfirmSheet(
                      title: context.l10n.runtime_deleteTitle,
                      content: context.l10n.runtime_deleteConfirm(item.name),
                      confirmText: context.l10n.common_delete,
                      confirmColor: CupertinoColors.destructiveRed,
                      onConfirm: () {
                        Navigator.pop(context);
                        onDelete(item.id, item.name);
                      },
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _openDirectory(BuildContext context, WidgetRef ref, String path) {
    final targetPath = path.trim();
    if (targetPath.isEmpty) return;

    final serverId = ref.read(activeServerIdProvider);
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (_) => ProviderScope(
          overrides: [activeServerIdProvider.overrideWithValue(serverId)],
          child: StandaloneFilesPage(initialPath: targetPath),
        ),
      ),
    );
  }
}
