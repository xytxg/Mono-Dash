import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/localization/l10n_x.dart';
import '../../../../core/utils/format_utils.dart';
import '../../../../data/dto/app/app_installed_dto.dart';
import '../../../../data/dto/backup/backup_record_dto.dart';
import '../../../common/app_toast.dart';
import '../../../common/components/action_sheet_launcher.dart';
import '../../../common/components/action_sheet_scaffold.dart';
import '../../../common/components/app_empty_state.dart';
import '../../../common/components/backup_components.dart';
import '../../../common/components/frosted_dialog.dart';
import '../../../common/components/task_log_sheet.dart';
import '../providers/app_backup_provider.dart';

void showAppBackupSheet(BuildContext context, AppInstalledDto app) {
  showActionSheet<void>(
    context: context,
    builder: (_) => _AppBackupSheet(app: app),
  );
}

class _AppBackupSheet extends ConsumerStatefulWidget {
  const _AppBackupSheet({required this.app});

  final AppInstalledDto app;

  @override
  ConsumerState<_AppBackupSheet> createState() => _AppBackupSheetState();
}

class _AppBackupSheetState extends ConsumerState<_AppBackupSheet> {
  final _scrollController = ScrollController();

  String get _appName => widget.app.name;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 120) {
      ref.read(appBackupControllerProvider(_appName).notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncState = ref.watch(appBackupControllerProvider(_appName));
    final l10n = context.l10n;

    return ActionSheetScaffold(
      maxHeightFactor: 0.82,
      minBodyHeightFactor: 0.6,
      panelHeader: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 12, 8),
        child: Row(
          children: [
            Icon(
              TablerIcons.archive,
              size: 22,
              color: CupertinoColors.systemTeal.resolveFrom(context),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                l10n.appStore_backupSheetTitle(widget.app.displayName),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.label(context),
                ),
              ),
            ),
            CupertinoButton(
              padding: EdgeInsets.zero,
              minimumSize: const Size(32, 32),
              onPressed: _createBackup,
              child: Icon(
                TablerIcons.plus,
                size: 22,
                color: CupertinoColors.activeBlue.resolveFrom(context),
              ),
            ),
          ],
        ),
      ),
      child: asyncState.when(
        data: (state) {
          if (state.records.isEmpty) {
            return const BackupEmptyState();
          }
          return ListView.builder(
            controller: _scrollController,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: state.records.length + (state.isLoadingMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == state.records.length) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Center(child: CupertinoActivityIndicator()),
                );
              }
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _BackupRecordCard(
                  appName: _appName,
                  record: state.records[index],
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CupertinoActivityIndicator()),
        error: (error, _) => AppErrorState(
          title: l10n.appStore_loadBackupsFailed,
          error: error,
          onRetry: () => ref
              .read(appBackupControllerProvider(_appName).notifier)
              .refresh(),
        ),
      ),
    );
  }

  Future<void> _createBackup() async {
    final l10n = context.l10n;
    final input = await _showBackupInputDialog(context);
    if (input == null || !mounted) return;
    try {
      final notifier = ref.read(appBackupControllerProvider(_appName).notifier);
      final taskID = await notifier.backup(
        secret: input.secret,
        description: input.description,
      );
      if (!mounted) return;
      await showTaskLogSheet(
        context,
        title: l10n.appStore_runBackup,
        taskID: taskID,
        reader: (taskID) => notifier.readTaskLog(taskID, latest: false),
        onFinished: notifier.refresh,
      );
    } catch (error) {
      showAppErrorToast(
        l10n.appStore_createBackupFailed,
        description: '$error',
      );
    }
  }
}

class _BackupRecordCard extends ConsumerWidget {
  const _BackupRecordCard({required this.appName, required this.record});

  final String appName;
  final BackupRecordDto record;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final ok = record.status.toLowerCase() == 'success';
    final statusColor = ok
        ? CupertinoColors.systemGreen.resolveFrom(context)
        : CupertinoColors.systemOrange.resolveFrom(context);
    final statusIcon = ok ? TablerIcons.circle_check : TablerIcons.alert_circle;
    final secondary = AppColors.secondaryLabel(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground(context).withValues(alpha: 0.68),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.separator(context).withValues(alpha: 0.16),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            record.fileName,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.label(context),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 5),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(TablerIcons.note, size: 14, color: secondary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  record.description.trim().isEmpty
                      ? l10n.appStore_noRemark
                      : record.description.trim(),
                  style: TextStyle(
                    fontSize: 12,
                    color: secondary,
                    height: 1.25,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: BackupInlineMeta(
                    icon: TablerIcons.file_zip,
                    text: formatBytes(record.size),
                    color: secondary,
                  ),
                ),
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: BackupInlineMeta(
                    icon: TablerIcons.clock,
                    text: formatTimeAgo(record.createdAt, l10n),
                    color: secondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: BackupStatusMeta(
                    alignEnd: false,
                    statusIcon: statusIcon,
                    statusColor: statusColor,
                    statusText: record.status.isEmpty ? '--' : record.status,
                  ),
                ),
              ),
              Expanded(
                child: CupertinoButton(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  onPressed: () => showAppToast(
                    l10n.appStore_runDirectory,
                    description: record.fileDir,
                  ),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: BackupInlineMeta(
                      icon: TablerIcons.folder,
                      text: record.fileDir,
                      color: secondary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: BackupTextAction(
                  icon: TablerIcons.restore,
                  label: l10n.appStore_restore,
                  color: CupertinoColors.activeBlue.resolveFrom(context),
                  onTap: () => _recover(context, ref),
                ),
              ),
              Expanded(
                child: BackupTextAction(
                  icon: TablerIcons.trash,
                  label: context.l10n.common_delete,
                  color: CupertinoColors.systemRed.resolveFrom(context),
                  onTap: () => _delete(context, ref),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _recover(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final notifier = ref.read(appBackupControllerProvider(appName).notifier);
    final secret = await _showRecoverSecretDialog(context);
    if (secret == null) return;
    try {
      final taskID = await notifier.recover(record, secret: secret);
      if (!context.mounted) return;
      await showTaskLogSheet(
        context,
        title: l10n.appStore_restoreBackup,
        taskID: taskID,
        reader: (taskID) => notifier.readTaskLog(taskID, latest: true),
        onFinished: notifier.refresh,
      );
    } catch (error) {
      showAppErrorToast(
        l10n.appStore_restoreBackupFailed,
        description: '$error',
      );
    }
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final confirmed = await showFrostedConfirmDialog(
      context,
      title: l10n.appStore_deleteBackup,
      content: l10n.appStore_deleteBackupConfirm(record.fileName),
      confirmText: l10n.common_delete,
      isDestructive: true,
    );
    if (confirmed != true) return;
    try {
      await ref
          .read(appBackupControllerProvider(appName).notifier)
          .delete(record);
      showAppSuccessToast(l10n.appStore_deletedBackup);
    } catch (error) {
      showAppErrorToast(
        l10n.appStore_deleteBackupFailed,
        description: '$error',
      );
    }
  }
}

class _BackupInput {
  const _BackupInput({required this.secret, required this.description});

  final String secret;
  final String description;
}

Future<_BackupInput?> _showBackupInputDialog(BuildContext context) {
  final secretController = TextEditingController();
  final descController = TextEditingController();
  return showCupertinoDialog<_BackupInput>(
    context: context,
    builder: (context) => FrostedDialog(
      title: context.l10n.appStore_runBackup,
      icon: TablerIcons.archive,
      confirmText: context.l10n.appStore_startBackup,
      onCancel: () => Navigator.of(context).pop(),
      onConfirm: () => Navigator.of(context).pop(
        _BackupInput(
          secret: secretController.text.trim(),
          description: descController.text.trim(),
        ),
      ),
      child: Column(
        children: [
          CupertinoTextField(
            controller: secretController,
            placeholder: context.l10n.appStore_compressionPasswordOptional,
            autocorrect: false,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.secondaryBackground(
                context,
              ).withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 10),
          CupertinoTextField(
            controller: descController,
            placeholder: context.l10n.appStore_descriptionOptional,
            autocorrect: false,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.secondaryBackground(
                context,
              ).withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ],
      ),
    ),
  ).whenComplete(() {
    secretController.dispose();
    descController.dispose();
  });
}

Future<String?> _showRecoverSecretDialog(BuildContext context) {
  final secretController = TextEditingController();
  return showCupertinoDialog<String>(
    context: context,
    builder: (context) => FrostedDialog(
      title: context.l10n.appStore_restoreBackup,
      icon: TablerIcons.restore,
      confirmText: context.l10n.appStore_startRestore,
      onCancel: () => Navigator.of(context).pop(),
      onConfirm: () => Navigator.of(context).pop(secretController.text.trim()),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            context.l10n.appStore_restorePasswordHint,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.secondaryLabel(context),
            ),
          ),
          const SizedBox(height: 12),
          CupertinoTextField(
            controller: secretController,
            placeholder: context.l10n.appStore_restorePasswordOptional,
            autocorrect: false,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.secondaryBackground(
                context,
              ).withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ],
      ),
    ),
  ).whenComplete(secretController.dispose);
}
