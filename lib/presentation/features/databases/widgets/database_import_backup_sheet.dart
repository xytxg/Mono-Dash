import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:file_picker/file_picker.dart';

import '../../../../core/localization/l10n_x.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/format_utils.dart';
import '../../../../data/dto/file/file_item_dto.dart';
import '../../../common/app_toast.dart';
import '../../../common/components/action_sheet_launcher.dart';
import '../../../common/components/action_sheet_scaffold.dart';
import '../../../common/components/app_empty_state.dart';
import '../../../common/components/file_browser_picker_sheet.dart';
import '../../../common/components/frosted_action_popup_menu.dart';
import '../../../common/components/frosted_dialog.dart';
import '../../../common/components/frosted_overlay_menu.dart';
import '../../../common/components/overlay_menu_mixin.dart';
import '../../../common/components/task_log_sheet.dart';
import '../providers/database_import_backup_provider.dart';

/// 显示导入备份 Sheet。
void showDatabaseImportBackupSheet(
  BuildContext context, {
  required String type,
  required String name,
  required String dbName,
  String remark = '',
}) {
  showActionSheet<void>(
    context: context,
    builder: (_) => _DatabaseImportBackupSheet(
      type: type,
      name: name,
      dbName: dbName,
      remark: remark,
    ),
  );
}

class _DatabaseImportBackupSheet extends ConsumerStatefulWidget {
  const _DatabaseImportBackupSheet({
    required this.type,
    required this.name,
    required this.dbName,
    this.remark = '',
  });

  final String type;
  final String name;
  final String dbName;
  final String remark;

  @override
  ConsumerState<_DatabaseImportBackupSheet> createState() =>
      _DatabaseImportBackupSheetState();
}

class _DatabaseImportBackupSheetState
    extends ConsumerState<_DatabaseImportBackupSheet>
    with OverlayMenuMixin {
  ({String type, String name, String dbName}) get _key =>
      (type: widget.type, name: widget.name, dbName: widget.dbName);

  final List<_UploadTask> _uploadTasks = [];

  void _showAddSourcePicker(BuildContext context, Offset tapOffset) {
    if (isOverlayMenuOpen) return;
    final l10n = context.l10n;

    final items = [
      FrostedMenuItem(
        text: l10n.databases_uploadFromLocal,
        icon: TablerIcons.device_mobile,
        action: _pickFromLocal,
      ),
      FrostedMenuItem(
        text: l10n.databases_chooseFromServer,
        icon: TablerIcons.server,
        action: _pickFromServer,
      ),
    ];

    showOverlayMenu(
      contentBuilder: (ctx) {
        const menuWidth = 180.0;
        final menuHeight = items.length * 48.0;
        final pos = OverlayMenuMixin.computeTapOffsetPosition(
          tapOffset: tapOffset,
          screenSize: MediaQuery.sizeOf(ctx),
          menuWidth: menuWidth,
          menuHeight: menuHeight,
          horizontalBias: -20,
        );
        return [
          Positioned(
            top: pos.top,
            left: pos.left,
            child: FrostedActionPopupMenu(
              width: menuWidth,
              items: items,
              alignment: pos.showAbove
                  ? Alignment.bottomLeft
                  : Alignment.topLeft,
              onSelect: (action) {
                hideOverlayMenu();
                action();
              },
            ),
          ),
        ];
      },
      dismissBuilder: (ctx, onDismiss) => Positioned.fill(
        child: GestureDetector(
          onTap: onDismiss,
          behavior: HitTestBehavior.translucent,
        ),
      ),
    );
  }

  Future<void> _pickFromLocal() async {
    final result = await FilePicker.pickFiles(type: FileType.any);
    if (!mounted) return;
    if (result == null || result.files.isEmpty) return;

    for (final file in result.files) {
      if (file.path == null) continue;
      final task = _UploadTask(
        filePath: file.path!,
        fileName: file.name,
        fileSize: file.size,
      );
      setState(() => _uploadTasks.add(task));
      _startUpload(task);
    }
  }

  Future<void> _startUpload(_UploadTask task) async {
    setState(() => task.status = _UploadStatus.uploading);
    try {
      final notifier = ref.read(databaseImportBackupProvider(_key).notifier);
      await notifier.uploadFromLocal(
        localPath: task.filePath,
        onProgress: (p) {
          if (mounted) setState(() => task.progress = p);
        },
      );
      if (mounted) {
        setState(() {
          task.status = _UploadStatus.success;
          task.progress = 1.0;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => task.status = _UploadStatus.failed);
        showAppErrorToast(
          context.l10n.databases_uploadFailed,
          description: '$e',
        );
      }
    }
  }

  Future<void> _pickFromServer() async {
    final result = await FileBrowserPickerSheet.show(
      context,
      initialPath: '/',
      title: context.l10n.databases_selectBackupFile,
      selectionMode: FilePickerSelectionMode.files,
      confirmText: context.l10n.common_select,
    );
    if (!mounted || result == null) return;

    final notifier = ref.read(databaseImportBackupProvider(_key).notifier);
    await notifier.copyFromServer(result.path);
  }

  @override
  Widget build(BuildContext context) {
    final asyncState = ref.watch(databaseImportBackupProvider(_key));

    return ActionSheetScaffold(
      maxHeightFactor: 0.85,
      isAdaptive: true,
      showHandle: true,
      panelHeader: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 10, 8),
        child: Row(
          children: [
            Icon(
              TablerIcons.file_import,
              size: 22,
              color: CupertinoColors.systemIndigo.resolveFrom(context),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                context.l10n.databases_importBackup,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.label(context),
                ),
              ),
            ),
            Builder(
              builder: (buttonContext) {
                return CupertinoButton(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(32, 32),
                  onPressed: () {
                    final box = buttonContext.findRenderObject() as RenderBox;
                    final offset = box.localToGlobal(Offset.zero);
                    _showAddSourcePicker(
                      context,
                      offset + Offset(0, box.size.height),
                    );
                  },
                  child: Icon(
                    TablerIcons.plus,
                    size: 22,
                    color: CupertinoColors.activeBlue.resolveFrom(context),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      child: asyncState.when(
        data: (state) {
          final allFiles = [
            ..._uploadTasks.where((t) => t.status != _UploadStatus.success),
            ...state.files.map(_UploadTask.fromServer),
          ];

          if (allFiles.isEmpty) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.remark.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    child: Text(
                      context.l10n.databases_supportedBackupFormats,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.tertiaryLabel(context),
                      ),
                    ),
                  ),
                AppEmptyState(
                  icon: TablerIcons.file_import,
                  title: context.l10n.databases_noBackupFiles,
                  subtitle: context.l10n.databases_addBackupFileHint,
                  useCardStyle: false,
                ),
              ],
            );
          }

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.remark.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  child: Text(
                    context.l10n.databases_supportedBackupFormats,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.tertiaryLabel(context),
                    ),
                  ),
                ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                itemCount: allFiles.length,
                itemBuilder: (context, index) {
                  final task = allFiles[index];
                  return _FileCard(
                    task: task,
                    onRecover: () => _recover(task),
                    onDelete: task.isServer ? () => _delete(task) : null,
                  );
                },
              ),
            ],
          );
        },
        loading: () => const Center(child: CupertinoActivityIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                TablerIcons.alert_triangle,
                size: 48,
                color: CupertinoColors.systemOrange.resolveFrom(context),
              ),
              const SizedBox(height: 16),
              Text(
                context.l10n.common_loadingFailed,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: AppColors.label(context),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '$error',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.secondaryLabel(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _recover(_UploadTask task) async {
    final l10n = context.l10n;
    final secret = await _showRecoverSecretDialog(context);
    if (secret == null || !mounted) return;

    try {
      final notifier = ref.read(databaseImportBackupProvider(_key).notifier);
      final taskID = await notifier.recoverFromFile(
        task.fileName,
        secret: secret,
      );
      if (!mounted) return;
      await showTaskLogSheet(
        context,
        title: l10n.databases_restoreBackup,
        taskID: taskID,
        reader: (id) => notifier.readTaskLog(id, latest: true),
        onFinished: notifier.refresh,
      );
    } catch (e) {
      showAppErrorToast(l10n.databases_restoreFailed, description: '$e');
    }
  }

  Future<void> _delete(_UploadTask task) async {
    final confirmed = await showFrostedConfirmDialog(
      context,
      title: context.l10n.databases_deleteFile,
      content: context.l10n.databases_deleteFileConfirm(task.fileName),
      confirmText: context.l10n.common_delete,
      isDestructive: true,
    );
    if (confirmed != true || !mounted) return;

    final notifier = ref.read(databaseImportBackupProvider(_key).notifier);
    await notifier.deleteFile(task.serverPath!);
  }
}

enum _UploadStatus { pending, uploading, success, failed }

class _UploadTask {
  _UploadTask({
    required this.filePath,
    required this.fileName,
    required this.fileSize,
    this.status = _UploadStatus.pending,
    this.progress = 0.0,
    this.isServer = false,
    this.serverPath,
  });

  factory _UploadTask.fromServer(FileItemDto file) {
    return _UploadTask(
      filePath: file.path,
      fileName: file.name,
      fileSize: file.size,
      status: _UploadStatus.success,
      progress: 1.0,
      isServer: true,
      serverPath: file.path,
    );
  }

  final String filePath;
  final String fileName;
  final int fileSize;
  _UploadStatus status;
  double progress;
  final bool isServer;
  final String? serverPath;
}

class _FileCard extends StatelessWidget {
  const _FileCard({required this.task, required this.onRecover, this.onDelete});

  final _UploadTask task;
  final VoidCallback onRecover;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
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
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        truncateMiddle(task.fileName, 32),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.label(context),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.visible,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            TablerIcons.database,
                            size: 11,
                            color: AppColors.tertiaryLabel(context),
                          ),
                          const SizedBox(width: 4),
                          _MetaText(formatBytes(task.fileSize)),
                          if (task.isServer) ...[
                            const SizedBox(width: 10),
                            _Dot(),
                            const SizedBox(width: 10),
                            Icon(
                              TablerIcons.server,
                              size: 11,
                              color: AppColors.tertiaryLabel(context),
                            ),
                            const SizedBox(width: 4),
                            _MetaText(context.l10n.databases_serverFile),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                if (task.status == _UploadStatus.uploading)
                  const CupertinoActivityIndicator(radius: 8),
              ],
            ),
          ),
          if (task.status == _UploadStatus.uploading)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: SizedBox(
                  height: 3,
                  child: Stack(
                    children: [
                      Container(
                        color: AppColors.separator(
                          context,
                        ).withValues(alpha: 0.15),
                      ),
                      FractionallySizedBox(
                        widthFactor: task.progress,
                        child: Container(
                          color: CupertinoColors.activeBlue.resolveFrom(
                            context,
                          ),
                        ),
                      ),
                    ],
                  ),
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
                  icon: TablerIcons.restore,
                  label: context.l10n.databases_restore,
                  color: CupertinoColors.activeBlue.resolveFrom(context),
                  onTap: task.status == _UploadStatus.success
                      ? onRecover
                      : null,
                ),
              ),
              if (onDelete != null) ...[
                Container(
                  width: 0.5,
                  height: 20,
                  color: AppColors.separator(context).withValues(alpha: 0.1),
                ),
                Expanded(
                  child: _CompactAction(
                    icon: TablerIcons.trash,
                    label: context.l10n.common_delete,
                    color: CupertinoColors.systemRed.resolveFrom(context),
                    onTap: onDelete,
                  ),
                ),
              ],
            ],
          ),
        ],
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
      style: TextStyle(
        fontSize: 11,
        color: AppColors.tertiaryLabel(context),
        height: 1.1,
      ),
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
    this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDisabled = onTap == null;
    final finalColor = isDisabled ? AppColors.tertiaryLabel(context) : color;

    return CupertinoButton(
      padding: const EdgeInsets.symmetric(vertical: 10),
      onPressed: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 16, color: finalColor),
          if (label.isNotEmpty) ...[
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: finalColor,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

Future<String?> _showRecoverSecretDialog(BuildContext context) {
  final secretController = TextEditingController();
  return showCupertinoDialog<String>(
    context: context,
    builder: (context) => FrostedDialog(
      title: context.l10n.databases_restoreBackup,
      icon: TablerIcons.restore,
      confirmText: context.l10n.databases_startRestore,
      onCancel: () => Navigator.of(context).pop(),
      onConfirm: () => Navigator.of(context).pop(secretController.text.trim()),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            context.l10n.databases_restorePasswordHint,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.secondaryLabel(context),
            ),
          ),
          const SizedBox(height: 12),
          CupertinoTextField(
            controller: secretController,
            placeholder: context.l10n.databases_restorePasswordOptional,
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
