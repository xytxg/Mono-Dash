import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/localization/l10n_x.dart';
import '../../../../data/dto/container/container_search_dto.dart';
import '../../../common/components/app_action_components.dart';
import '../../../common/app_toast.dart';
import '../../../common/components/action_sheet_launcher.dart';
import '../../../common/components/action_sheet_scaffold.dart';
import '../../../common/components/action_sheet_info_card.dart';
import '../../../common/components/status_pill.dart';
import 'container_terminal_action.dart';
import 'container_log_sheet.dart';
import 'container_backup_sheet.dart';
import 'container_monitor_sheet.dart';
import 'container_commit_dialog.dart';
import 'container_edit_sheet.dart';
import 'container_upgrade_dialog.dart';
import '../../../common/components/frosted_dialog.dart';
import '../../../common/components/task_log_sheet.dart';
import '../../../../data/repositories_impl/container_repository_impl.dart';

/// 显示容器操作菜单
Future<void> showContainerActionSheet(
  BuildContext context,
  WidgetRef ref,
  ContainerItemDto container,
) async {
  await showActionSheet(
    context: context,
    builder: (context) => _ContainerActionSheet(container: container),
  );
}

class _ContainerActionSheet extends StatelessWidget {
  const _ContainerActionSheet({required this.container});

  final ContainerItemDto container;

  @override
  Widget build(BuildContext context) {
    final isRunning = container.state.toLowerCase() == 'running';
    final isPaused = container.state.toLowerCase() == 'paused';

    final statusColor = isRunning
        ? CupertinoColors.systemGreen.resolveFrom(context)
        : isPaused
        ? CupertinoColors.systemYellow.resolveFrom(context)
        : CupertinoColors.systemRed.resolveFrom(context);

    return ActionSheetScaffold(
      infoCard: ActionSheetInfoCard(
        leading: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            container.isFromApp ? TablerIcons.brand_appstore : TablerIcons.box,
            size: 28,
            color: statusColor,
          ),
        ),
        title: container.name,
        subtitle: container.imageName,
        trailing: StatusPill(
          label: container.state.toUpperCase(),
          active: isRunning,
          activeColor: isRunning ? statusColor : null,
          inactiveColor: !isRunning ? statusColor : null,
        ),
      ),
      child: _ContainerActionList(container: container),
    );
  }
}

class _ContainerActionList extends ConsumerWidget {
  const _ContainerActionList({required this.container});

  final ContainerItemDto container;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isRunning = container.state.toLowerCase() == 'running';
    final isPaused = container.state.toLowerCase() == 'paused';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppSectionHeader(
          title: context.l10n.containers_maintenance,
          icon: TablerIcons.settings_automation,
        ),
        AppActionGroup(
          children: [
            AppActionRow(
              icon: TablerIcons.terminal_2,
              iconColor: CupertinoColors.systemGreen,
              title: context.l10n.containers_runTerminal,
              subtitle: Text(context.l10n.containers_runTerminalSubtitle),
              onTap: () => openContainerTerminal(context, container),
            ),
            AppActionRow(
              icon: TablerIcons.logs,
              iconColor: CupertinoColors.systemBrown,
              title: context.l10n.containers_viewLogs,
              subtitle: Text(context.l10n.containers_viewLogsSubtitle),
              onTap: () =>
                  showContainerLogSheet(context, containerItem: container),
            ),
            AppActionRow(
              icon: TablerIcons.chart_area_line,
              iconColor: CupertinoColors.systemIndigo,
              title: context.l10n.containers_realtimeMonitor,
              subtitle: Text(context.l10n.containers_realtimeMonitorSubtitle),
              onTap: () => showContainerMonitorSheet(context, ref, container),
            ),
            // AppActionRow(
            //   icon: TablerIcons.folder_root,
            //   iconColor: CupertinoColors.systemOrange,
            //   title: 'File Directory',
            //   subtitle: const Text('Browse host directories mapped to the container'),
            //   onTap: () => showAppTodoToast('File Directory'),
            // ),
          ],
        ),
        const SizedBox(height: 22),
        AppSectionHeader(
          title: context.l10n.containers_lifecycle,
          icon: TablerIcons.heart_rate_monitor,
        ),
        AppActionGroup(
          children: [
            AppActionRow(
              icon: TablerIcons.player_play,
              iconColor: CupertinoColors.systemGreen,
              title: isPaused
                  ? context.l10n.containers_restoreContainer
                  : context.l10n.containers_startContainer,
              subtitle: Text(
                isPaused
                    ? context.l10n.containers_restoreContainerSubtitle
                    : context.l10n.containers_startContainerSubtitle,
              ),
              enabled: !isRunning || isPaused,
              onTap: () => _operateContainer(
                context: context,
                ref: ref,
                container: container,
                operation: isPaused ? 'unpause' : 'start',
                title: isPaused
                    ? context.l10n.containers_restoreContainer
                    : context.l10n.containers_startContainer,
              ),
            ),
            AppActionRow(
              icon: TablerIcons.player_stop,
              iconColor: CupertinoColors.systemRed,
              title: context.l10n.containers_stopContainer,
              subtitle: Text(context.l10n.containers_stopContainerSubtitle),
              enabled: isRunning && !isPaused,
              onTap: () => _operateContainer(
                context: context,
                ref: ref,
                container: container,
                operation: 'stop',
                title: context.l10n.containers_stopContainer,
              ),
            ),
            AppActionRow(
              icon: TablerIcons.refresh,
              iconColor: CupertinoColors.systemBlue,
              title: context.l10n.containers_restartContainer,
              subtitle: Text(context.l10n.containers_restartContainerSubtitle),
              enabled: isRunning,
              onTap: () => _operateContainer(
                context: context,
                ref: ref,
                container: container,
                operation: 'restart',
                title: context.l10n.containers_restartContainer,
              ),
            ),
            AppActionRow(
              icon: TablerIcons.player_pause,
              iconColor: CupertinoColors.systemYellow,
              title: context.l10n.containers_pause,
              subtitle: Text(context.l10n.containers_pauseContainerSubtitle),
              onTap: () => _operateContainer(
                context: context,
                ref: ref,
                container: container,
                operation: 'pause',
                title: context.l10n.containers_pauseContainer,
              ),
            ),
            AppActionRow(
              icon: TablerIcons.bolt,
              iconColor: CupertinoColors.systemOrange,
              title: context.l10n.containers_forceStop,
              subtitle: Text(
                context.l10n.containers_forceStopContainerSubtitle,
              ),
              onTap: () => _operateContainer(
                context: context,
                ref: ref,
                container: container,
                operation: 'kill',
                title: context.l10n.containers_forceStopContainer,
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),
        AppSectionHeader(
          title: context.l10n.containers_configAndUpdates,
          icon: TablerIcons.adjustments,
        ),
        AppActionGroup(
          children: [
            AppActionRow(
              icon: TablerIcons.edit,
              iconColor: CupertinoColors.systemBlue,
              title: context.l10n.containers_editConfig,
              subtitle: Text(context.l10n.containers_editConfigSubtitle),
              onTap: () {
                Navigator.pop(context);
                showContainerEditSheet(context: context, container: container);
              },
            ),
            AppActionRow(
              icon: TablerIcons.arrow_up_circle,
              iconColor: CupertinoColors.systemIndigo,
              title: context.l10n.containers_upgradeContainer,
              subtitle: Text(context.l10n.containers_upgradeContainerSubtitle),
              onTap: () => openContainerUpgradeDialog(context, ref, container),
            ),
          ],
        ),
        const SizedBox(height: 22),
        AppSectionHeader(
          title: context.l10n.containers_dataAndImages,
          icon: TablerIcons.database_export,
        ),
        AppActionGroup(
          children: [
            AppActionRow(
              icon: TablerIcons.archive,
              iconColor: CupertinoColors.systemTeal,
              title: context.l10n.containers_containerBackup,
              subtitle: Text(context.l10n.containers_containerBackupSubtitle),
              onTap: () => showContainerBackupSheet(context, container),
            ),
            AppActionRow(
              icon: TablerIcons.photo_up,
              iconColor: CupertinoColors.systemIndigo,
              title: context.l10n.containers_commitImage,
              subtitle: Text(context.l10n.containers_commitImageSubtitle),
              onTap: () => showContainerCommitSheet(context, ref, container),
            ),
          ],
        ),
        const SizedBox(height: 22),
        AppSectionHeader(
          title: context.l10n.containers_dangerZone,
          icon: TablerIcons.alert_triangle,
        ),
        AppActionGroup(
          children: [
            AppActionRow(
              icon: TablerIcons.trash,
              iconColor: CupertinoColors.systemRed,
              title: context.l10n.common_delete,
              subtitle: Text(context.l10n.containers_deleteContainerSubtitle),
              onTap: () => _operateContainer(
                context: context,
                ref: ref,
                container: container,
                operation: 'remove',
                title: context.l10n.containers_deleteContainer,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

Future<void> _operateContainer({
  required BuildContext context,
  required WidgetRef ref,
  required ContainerItemDto container,
  required String operation,
  required String title,
}) async {
  final confirmed = await showFrostedConfirmDialog(
    context,
    title: title,
    icon: _getOperationIcon(operation),
    content: context.l10n.containers_operationConfirm(
      _getOperationName(context, operation),
      container.name,
    ),
    isDestructive: operation == 'remove' || operation == 'kill',
  );

  if (confirmed != true || !context.mounted) return;

  final taskID = const Uuid().v4();
  final providerContainer = ProviderScope.containerOf(context);

  try {
    final repo = await providerContainer.read(
      containerRepositoryProvider.future,
    );
    await repo.operateContainer(
      names: [container.name],
      operation: operation,
      taskID: taskID,
    );

    if (context.mounted) {
      Navigator.of(context).pop();

      showTaskLogSheet(
        context,
        title: '$title: ${container.name}',
        taskID: taskID,
        reader: repo.readTaskLog,
      );
    }
  } catch (e) {
    if (!context.mounted) return;
    showAppErrorToast(
      context.l10n.containers_operationFailed,
      description: e.toString(),
    );
  }
}

IconData _getOperationIcon(String op) {
  switch (op) {
    case 'start':
      return TablerIcons.player_play;
    case 'stop':
      return TablerIcons.player_stop;
    case 'restart':
      return TablerIcons.refresh;
    case 'pause':
      return TablerIcons.player_pause;
    case 'unpause':
      return TablerIcons.player_play;
    case 'kill':
      return TablerIcons.bolt;
    case 'remove':
      return TablerIcons.trash;
    default:
      return TablerIcons.box;
  }
}

String _getOperationName(BuildContext context, String op) {
  switch (op) {
    case 'start':
      return context.l10n.containers_start;
    case 'stop':
      return context.l10n.containers_stop;
    case 'restart':
      return context.l10n.containers_restart;
    case 'pause':
      return context.l10n.containers_pause;
    case 'unpause':
      return context.l10n.containers_restoreContainer;
    case 'kill':
      return context.l10n.containers_forceStop;
    case 'remove':
      return context.l10n.common_delete;
    default:
      return context.l10n.containers_operationGeneric;
  }
}

Future<void> showContainerCommitSheet(
  BuildContext context,
  WidgetRef ref,
  ContainerItemDto container,
) async {
  final taskID = await showProviderDialog<String>(
    context: context,
    barrierDismissible: true,
    builder: (context) => ContainerCommitDialog(container: container),
  );

  if (taskID != null && context.mounted) {
    Navigator.of(context).pop();

    showTaskLogSheet(
      context,
      title: context.l10n.containers_commitImageTask(container.name),
      taskID: taskID,
      reader: (id) => ref
          .read(containerRepositoryProvider.future)
          .then((r) => r.readTaskLog(id)),
    );
  }
}

Future<void> openContainerUpgradeDialog(
  BuildContext context,
  WidgetRef ref,
  ContainerItemDto container,
) async {
  final taskID = await showProviderDialog<String>(
    context: context,
    barrierDismissible: true,
    builder: (context) => ContainerUpgradeDialog(container: container),
  );

  if (taskID != null && context.mounted) {
    Navigator.of(context).pop();

    showTaskLogSheet(
      context,
      title: context.l10n.containers_upgradeContainerTask(container.name),
      taskID: taskID,
      reader: (id) => ref
          .read(containerRepositoryProvider.future)
          .then((r) => r.readTaskLog(id)),
    );
  }
}
