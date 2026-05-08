import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../core/localization/l10n_x.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/format_utils.dart';
import '../../../../data/dto/backup/backup_record_dto.dart';
import '../../../common/app_toast.dart';
import '../../../common/components/action_sheet_launcher.dart';
import '../../../common/components/action_sheet_scaffold.dart';
import '../../../common/components/app_empty_state.dart';
import '../../../common/components/backup_components.dart';
import '../../../common/components/frosted_dialog.dart';
import '../../../common/components/task_log_sheet.dart';
import '../../files/screens/files_page.dart';
import '../../server_detail/providers/active_server_provider.dart';
import '../providers/database_backup_provider.dart';

/// 显示数据库备份列表 Sheet。
void showDatabaseBackupSheet(
  BuildContext context, {
  required String type,
  required String name,
  required String dbName,
}) {
  showActionSheet<void>(
    context: context,
    builder: (_) =>
        _DatabaseBackupSheet(type: type, name: name, dbName: dbName),
  );
}

class _DatabaseBackupSheet extends ConsumerStatefulWidget {
  const _DatabaseBackupSheet({
    required this.type,
    required this.name,
    required this.dbName,
  });

  final String type;
  final String name;
  final String dbName;

  @override
  ConsumerState<_DatabaseBackupSheet> createState() =>
      _DatabaseBackupSheetState();
}

class _DatabaseBackupSheetState extends ConsumerState<_DatabaseBackupSheet> {
  final _scrollController = ScrollController();

  ({String type, String name, String dbName}) get _key =>
      (type: widget.type, name: widget.name, dbName: widget.dbName);

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
      ref.read(databaseBackupControllerProvider(_key).notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncState = ref.watch(databaseBackupControllerProvider(_key));

    return ActionSheetScaffold(
      maxHeightFactor: 0.85,
      isAdaptive: false,
      showHandle: false,
      panelHeader: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 10, 8),
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
                context.l10n.databases_backupSheetTitle(widget.dbName),
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
                  key: ValueKey(state.records[index].id),
                  dbKey: _key,
                  record: state.records[index],
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CupertinoActivityIndicator()),
        error: (error, _) => AppErrorState(
          title: context.l10n.databases_loadBackupsFailed,
          error: error,
          onRetry: () => ref
              .read(databaseBackupControllerProvider(_key).notifier)
              .refresh(),
        ),
      ),
    );
  }

  Future<void> _createBackup() async {
    final l10n = context.l10n;
    final isMysql =
        widget.type == 'mysql' ||
        widget.type == 'mariadb' ||
        widget.type == 'mysql-cluster';
    try {
      await _showDatabaseBackupInputSheet(
        context,
        isMysql: isMysql,
        onConfirm: (input) async {
          final notifier = ref.read(
            databaseBackupControllerProvider(_key).notifier,
          );
          final taskID = await notifier.backup(
            secret: input.secret,
            description: input.description,
            args: input.args,
          );
          if (!mounted) return;
          await showTaskLogSheet(
            context,
            title: l10n.databases_runBackup,
            taskID: taskID,
            reader: (taskID) => notifier.readTaskLog(taskID, latest: false),
            onFinished: notifier.refresh,
          );
        },
      );
    } catch (error) {
      showAppErrorToast(
        l10n.databases_createBackupFailed,
        description: '$error',
      );
    }
  }
}

class _BackupRecordCard extends ConsumerWidget {
  const _BackupRecordCard({
    super.key,
    required this.dbKey,
    required this.record,
  });

  final ({String type, String name, String dbName}) dbKey;
  final BackupRecordDto record;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final ok = record.status.toLowerCase() == 'success';
    final statusColor = ok
        ? CupertinoColors.systemGreen.resolveFrom(context)
        : CupertinoColors.systemOrange.resolveFrom(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground(context).withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.separator(context).withValues(alpha: 0.1),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        truncateMiddle(record.fileName, 32),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.label(context),
                        ),
                        maxLines: 1,
                        overflow:
                            TextOverflow.visible, // truncateMiddle handles it
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Icon(
                            TablerIcons.database,
                            size: 11,
                            color: AppColors.tertiaryLabel(context),
                          ),
                          const SizedBox(width: 4),
                          _MetaText(formatBytes(record.size)),
                          const SizedBox(width: 10),
                          _Dot(),
                          const SizedBox(width: 10),
                          Icon(
                            TablerIcons.calendar_time,
                            size: 11,
                            color: AppColors.tertiaryLabel(context),
                          ),
                          const SizedBox(width: 4),
                          _MetaText(
                            formatTimeAgo(record.createdAt, context.l10n),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _StatusBadge(status: record.status, color: statusColor),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Text(
              record.description.trim().isEmpty
                  ? l10n.databases_noRemark
                  : record.description,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.secondaryLabel(context),
                height: 1.3,
              ),
            ),
          ),
          Container(
            height: 0.5,
            color: AppColors.separator(context).withValues(alpha: 0.1),
          ),
          Row(
            children: [
              Expanded(
                child: _CompactAction(
                  icon: TablerIcons.download,
                  label: l10n.databases_download,
                  color: CupertinoColors.systemGreen.resolveFrom(context),
                  onTap: () => _download(context, ref),
                ),
              ),
              Container(
                width: 0.5,
                height: 20,
                color: AppColors.separator(context).withValues(alpha: 0.1),
              ),
              Expanded(
                child: _CompactAction(
                  icon: TablerIcons.restore,
                  label: l10n.databases_restore,
                  color: CupertinoColors.activeBlue.resolveFrom(context),
                  onTap: () => _recover(context, ref),
                ),
              ),
              Container(
                width: 0.5,
                height: 20,
                color: AppColors.separator(context).withValues(alpha: 0.1),
              ),
              Expanded(
                child: _CompactAction(
                  icon: TablerIcons.trash,
                  label: l10n.common_delete,
                  color: CupertinoColors.systemRed.resolveFrom(context),
                  onTap: () => _delete(context, ref),
                ),
              ),
              Container(
                width: 0.5,
                height: 20,
                color: AppColors.separator(context).withValues(alpha: 0.1),
              ),
              Expanded(
                child: _CompactAction(
                  icon: TablerIcons.folder,
                  label: l10n.databases_directory,
                  color: AppColors.secondaryLabel(context),
                  onTap: () => _openFileDir(context, ref),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _download(BuildContext context, WidgetRef ref) {
    ref
        .read(databaseBackupControllerProvider(dbKey).notifier)
        .downloadAndShare(record);
  }

  void _openFileDir(BuildContext context, WidgetRef ref) {
    final path = record.fileDir.trim();
    if (path.isEmpty) {
      showAppWarningToast(context.l10n.databases_backupDirectoryEmpty);
      return;
    }

    final serverId = ref.read(activeServerIdProvider);
    Navigator.of(context).pop();
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (_) => ProviderScope(
          overrides: [activeServerIdProvider.overrideWithValue(serverId)],
          child: StandaloneFilesPage(initialPath: path),
        ),
      ),
    );
  }

  Future<void> _recover(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final notifier = ref.read(databaseBackupControllerProvider(dbKey).notifier);
    await _showDatabaseRecoverSecretSheet(
      context,
      onConfirm: (secret) async {
        try {
          final taskID = await notifier.recover(record, secret: secret);
          if (!context.mounted) return;
          await showTaskLogSheet(
            context,
            title: l10n.databases_restoreBackup,
            taskID: taskID,
            reader: (taskID) => notifier.readTaskLog(taskID, latest: true),
            onFinished: notifier.refresh,
          );
        } catch (error) {
          showAppErrorToast(
            l10n.databases_restoreBackupFailed,
            description: '$error',
          );
        }
      },
    );
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final confirmed = await showFrostedConfirmDialog(
      context,
      title: l10n.databases_deleteBackup,
      content: l10n.databases_deleteBackupConfirm(record.fileName),
      confirmText: l10n.common_delete,
      isDestructive: true,
    );
    if (confirmed != true) return;
    try {
      await ref
          .read(databaseBackupControllerProvider(dbKey).notifier)
          .delete(record);
      showAppSuccessToast(l10n.databases_deletedBackup);
    } catch (error) {
      showAppErrorToast(
        l10n.databases_deleteBackupFailed,
        description: '$error',
      );
    }
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status, required this.color});
  final String status;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 0.5),
      ),
      child: Text(
        status.isEmpty ? '--' : status.toUpperCase(),
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

class _MetaText extends StatelessWidget {
  const _MetaText(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(fontSize: 11, color: AppColors.tertiaryLabel(context)),
    );
  }
}

class _Dot extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 3,
      height: 3,
      decoration: BoxDecoration(
        color: AppColors.tertiaryLabel(context).withValues(alpha: 0.5),
        shape: BoxShape.circle,
      ),
    );
  }
}

class _CompactAction extends StatelessWidget {
  const _CompactAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      onPressed: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 15, color: color),
          if (label.isNotEmpty) ...[
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _BackupInput {
  const _BackupInput({
    required this.secret,
    required this.description,
    this.args = const [],
  });

  final String secret;
  final String description;
  final List<String> args;
}

const _mysqlDumpArgs = [
  '--single-transaction',
  '--quick',
  '--skip-lock-tables',
];

Future<void> _showDatabaseBackupInputSheet(
  BuildContext context, {
  required bool isMysql,
  required void Function(_BackupInput) onConfirm,
}) {
  return showActionSheet<void>(
    context: context,
    builder: (context) =>
        _DatabaseBackupInputSheet(isMysql: isMysql, onConfirm: onConfirm),
  );
}

class _DatabaseBackupInputSheet extends StatefulWidget {
  const _DatabaseBackupInputSheet({
    required this.isMysql,
    required this.onConfirm,
  });

  final bool isMysql;
  final void Function(_BackupInput) onConfirm;

  @override
  State<_DatabaseBackupInputSheet> createState() =>
      _DatabaseBackupInputSheetState();
}

class _DatabaseBackupInputSheetState extends State<_DatabaseBackupInputSheet> {
  final _secretController = TextEditingController();
  final _descController = TextEditingController();
  final _selectedArgs = <String>{};

  @override
  void dispose() {
    _secretController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ActionSheetScaffold(
      isAdaptive: true,
      showHandle: false,
      panelHeader: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 10, 8),
        child: Row(
          children: [
            Expanded(
              child: Text(
                context.l10n.databases_runBackup,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.label(context),
                ),
              ),
            ),
            CupertinoButton(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              onPressed: () => Navigator.pop(context),
              child: Text(
                context.l10n.common_cancel,
                style: TextStyle(
                  color: AppColors.secondaryLabel(context),
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _FormItem(
            label: context.l10n.databases_compressionPassword,
            icon: TablerIcons.key,
            child: SizedBox(
              height: 46,
              child: CupertinoTextField(
                controller: _secretController,
                placeholder: context.l10n.databases_optional,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                textAlignVertical: TextAlignVertical.center,
                decoration: BoxDecoration(
                  color: AppColors.tertiaryBackground(context),
                  borderRadius: BorderRadius.circular(12),
                ),
                style: TextStyle(fontSize: 16, color: AppColors.label(context)),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _FormItem(
            label: context.l10n.databases_remarkDescription,
            icon: TablerIcons.note,
            child: SizedBox(
              height: 46,
              child: CupertinoTextField(
                controller: _descController,
                placeholder: context.l10n.databases_optional,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                textAlignVertical: TextAlignVertical.center,
                decoration: BoxDecoration(
                  color: AppColors.tertiaryBackground(context),
                  borderRadius: BorderRadius.circular(12),
                ),
                style: TextStyle(fontSize: 16, color: AppColors.label(context)),
              ),
            ),
          ),
          if (widget.isMysql) ...[
            const SizedBox(height: 20),
            Text(
              context.l10n.databases_backupArgs,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.secondaryLabel(context),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: AppColors.tertiaryBackground(context),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: _mysqlDumpArgs.asMap().entries.map((entry) {
                  final arg = entry.value;
                  final isLast = entry.key == _mysqlDumpArgs.length - 1;
                  final selected = _selectedArgs.contains(arg);
                  return Column(
                    children: [
                      CupertinoButton(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        onPressed: () {
                          setState(() {
                            if (selected) {
                              _selectedArgs.remove(arg);
                            } else {
                              _selectedArgs.add(arg);
                            }
                          });
                        },
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                arg,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontFamily: 'monospace',
                                  color: AppColors.label(context),
                                ),
                              ),
                            ),
                            Icon(
                              selected
                                  ? TablerIcons.checkbox
                                  : TablerIcons.square,
                              size: 20,
                              color: selected
                                  ? CupertinoColors.activeBlue.resolveFrom(
                                      context,
                                    )
                                  : AppColors.tertiaryLabel(context),
                            ),
                          ],
                        ),
                      ),
                      if (!isLast)
                        Padding(
                          padding: const EdgeInsets.only(left: 14),
                          child: Container(
                            height: 0.5,
                            color: AppColors.separator(
                              context,
                            ).withValues(alpha: 0.1),
                          ),
                        ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: CupertinoButton(
              padding: EdgeInsets.zero,
              color: CupertinoColors.activeBlue.resolveFrom(context),
              borderRadius: BorderRadius.circular(14),
              onPressed: () {
                Navigator.pop(context);
                widget.onConfirm(
                  _BackupInput(
                    secret: _secretController.text.trim(),
                    description: _descController.text.trim(),
                    args: _selectedArgs.toList(),
                  ),
                );
              },
              child: Text(
                context.l10n.databases_startBackup,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: CupertinoColors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> _showDatabaseRecoverSecretSheet(
  BuildContext context, {
  required void Function(String) onConfirm,
}) {
  return showActionSheet<void>(
    context: context,
    builder: (context) => _DatabaseRecoverSecretSheet(onConfirm: onConfirm),
  );
}

class _DatabaseRecoverSecretSheet extends StatefulWidget {
  const _DatabaseRecoverSecretSheet({required this.onConfirm});
  final void Function(String) onConfirm;

  @override
  State<_DatabaseRecoverSecretSheet> createState() =>
      _DatabaseRecoverSecretSheetState();
}

class _DatabaseRecoverSecretSheetState
    extends State<_DatabaseRecoverSecretSheet> {
  final _secretController = TextEditingController();

  @override
  void dispose() {
    _secretController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ActionSheetScaffold(
      isAdaptive: true,
      showHandle: false,
      panelHeader: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 10, 8),
        child: Row(
          children: [
            Expanded(
              child: Text(
                context.l10n.databases_restoreBackup,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.label(context),
                ),
              ),
            ),
            CupertinoButton(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              onPressed: () => Navigator.pop(context),
              child: Text(
                context.l10n.common_cancel,
                style: TextStyle(
                  color: AppColors.secondaryLabel(context),
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            context.l10n.databases_restorePasswordHint,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.secondaryLabel(context),
            ),
          ),
          const SizedBox(height: 16),
          _FormItem(
            label: context.l10n.databases_restorePassword,
            icon: TablerIcons.key,
            child: SizedBox(
              height: 46,
              child: CupertinoTextField(
                controller: _secretController,
                placeholder: context.l10n.databases_optional,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                textAlignVertical: TextAlignVertical.center,
                decoration: BoxDecoration(
                  color: AppColors.tertiaryBackground(context),
                  borderRadius: BorderRadius.circular(12),
                ),
                style: TextStyle(fontSize: 16, color: AppColors.label(context)),
              ),
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: CupertinoButton(
              padding: EdgeInsets.zero,
              color: CupertinoColors.activeBlue.resolveFrom(context),
              borderRadius: BorderRadius.circular(14),
              onPressed: () {
                Navigator.pop(context);
                widget.onConfirm(_secretController.text.trim());
              },
              child: Text(
                context.l10n.databases_startRestore,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: CupertinoColors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FormItem extends StatelessWidget {
  const _FormItem({
    required this.label,
    required this.icon,
    required this.child,
  });

  final String label;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Row(
            children: [
              Icon(icon, size: 14, color: AppColors.secondaryLabel(context)),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.secondaryLabel(context),
                ),
              ),
            ],
          ),
        ),
        child,
      ],
    );
  }
}
