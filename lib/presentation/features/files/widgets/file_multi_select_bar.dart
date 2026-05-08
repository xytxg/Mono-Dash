import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import '../../../../core/localization/l10n_x.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../common/components/action_sheet_launcher.dart';
import '../../../common/components/action_sheet_scaffold.dart';
import '../providers/files_provider.dart';
import 'file_compress_sheet.dart';
import 'file_permission_sheet.dart';
import 'file_delete_sheet.dart';
import 'file_move_copy_sheet.dart';
import '../../server_detail/providers/active_server_provider.dart';
import '../providers/download_manager_provider.dart';
import 'download_progress_sheet.dart';
import '../../../common/app_toast.dart';
import '../../../../data/repositories_impl/file_repository_impl.dart';

class FileMultiSelectBar extends ConsumerWidget {
  const FileMultiSelectBar({super.key, this.isSheetHeader = false});

  final bool isSheetHeader;

  Widget _buildActionItem(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    final color = isDestructive
        ? CupertinoColors.systemRed
        : AppColors.label(context);

    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () {
        Navigator.pop(context);
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color:
                    (isDestructive
                            ? CupertinoColors.systemRed
                            : CupertinoColors.activeBlue)
                        .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 18,
                color: isDestructive
                    ? CupertinoColors.systemRed
                    : CupertinoColors.activeBlue,
              ),
            ),
            const SizedBox(width: 14),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
            const Spacer(),
            Icon(
              CupertinoIcons.chevron_right,
              size: 14,
              color: AppColors.tertiaryLabel(context).withValues(alpha: 0.3),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filesState = ref.watch(filesControllerProvider).valueOrNull;
    final isSelectionMode = filesState?.isSelectionMode ?? false;
    final selectedCount = filesState?.selectedPaths.length ?? 0;

    if (!isSheetHeader && (!isSelectionMode || selectedCount == 0)) {
      return const SizedBox.shrink();
    }

    final isDark = CupertinoTheme.brightnessOf(context) == Brightness.dark;
    final borderRadius = BorderRadius.circular(24);

    final bar = ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.secondaryBackground(context).withValues(alpha: 0.7)
                : CupertinoColors.white.withValues(alpha: 0.8),
            borderRadius: borderRadius,
            border: Border.all(
              color: isDark
                  ? CupertinoColors.white.withValues(alpha: 0.1)
                  : CupertinoColors.black.withValues(alpha: 0.05),
              width: 0.5,
            ),
            boxShadow: isSheetHeader
                ? null
                : [
                    BoxShadow(
                      color: CupertinoColors.black.withValues(
                        alpha: isDark ? 0.4 : 0.08,
                      ),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
          ),
          child: Row(
            children: [
              const Icon(
                TablerIcons.checkbox,
                color: CupertinoColors.activeBlue,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.files_selectedCount(selectedCount),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.label(context),
                        letterSpacing: -0.2,
                      ),
                    ),
                    Text(
                      isSheetHeader
                          ? context.l10n.files_chooseAction
                          : context.l10n.files_expandActionMenu,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppColors.secondaryLabel(
                          context,
                        ).withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CupertinoButton(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    onPressed: () {
                      final notifier = ref.read(
                        filesControllerProvider.notifier,
                      );
                      final totalCount = filesState?.items.length ?? 0;
                      if (selectedCount > 0 && selectedCount == totalCount) {
                        notifier.clearSelection();
                      } else {
                        notifier.selectAll();
                      }
                    },
                    child: Text(
                      (selectedCount > 0 &&
                              selectedCount == (filesState?.items.length ?? 0))
                          ? context.l10n.files_clearSelection
                          : context.l10n.files_selectAll,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: CupertinoColors.activeBlue,
                      ),
                    ),
                  ),
                  CupertinoButton(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    onPressed: () {
                      if (isSheetHeader) Navigator.of(context).pop();
                      ref
                          .read(filesControllerProvider.notifier)
                          .toggleSelectionMode();
                    },
                    child: Text(
                      context.l10n.common_cancel,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: CupertinoColors.activeBlue,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (isSheetHeader) return bar;

    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 0, 14, 20),
        child: TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 500),
          curve: Curves.elasticOut,
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, 40 * (1 - value)),
              child: Opacity(opacity: value.clamp(0.0, 1.0), child: child),
            );
          },
          child: GestureDetector(
            onTap: () => _showMultiActions(context, ref, selectedCount),
            child: bar,
          ),
        ),
      ),
    );
  }

  void _showMultiActions(BuildContext context, WidgetRef ref, int count) {
    final parentContext = context;
    final providerContainer = ProviderScope.containerOf(context);
    final filesState = ref.read(filesControllerProvider).valueOrNull;
    if (filesState == null) return;

    final selectedItems = filesState.items
        .where((item) => filesState.selectedPaths.contains(item.path))
        .toList();
    final allAreFiles = selectedItems.every((item) => !item.isDir);

    showActionSheet(
      context: context,
      builder: (context) => ActionSheetScaffold(
        isAdaptive: true,
        showHandle: false,
        isFloating: false,
        header: const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: FileMultiSelectBar(isSheetHeader: true),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.secondaryBackground(
              context,
            ).withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              _buildActionItem(
                context,
                TablerIcons.cut,
                context.l10n.files_actionMove,
                () {
                  FileMoveCopySheet.start(
                    context: parentContext,
                    container: providerContainer,
                    items: selectedItems,
                    type: FileOperationType.move,
                  );
                },
              ),
              _buildDivider(context),
              _buildActionItem(
                context,
                TablerIcons.copy,
                context.l10n.files_actionCopy,
                () {
                  FileMoveCopySheet.start(
                    context: parentContext,
                    container: providerContainer,
                    items: selectedItems,
                    type: FileOperationType.copy,
                  );
                },
              ),
              if (allAreFiles) ...[
                _buildDivider(context),
                _buildActionItem(
                  context,
                  TablerIcons.download,
                  selectedItems.length > 1
                      ? context.l10n.files_actionBatchDownload
                      : context.l10n.files_actionDownload,
                  () async {
                    final serverId = ref.read(activeServerIdProvider);
                    final manager = ref.read(downloadManagerProvider.notifier);

                    final taskIds = <String>[];
                    for (final item in selectedItems) {
                      final taskId = await manager.startDownload(
                        serverId: serverId,
                        remotePath: item.path,
                        fileName: item.name,
                        fileSize: item.size,
                      );
                      taskIds.add(taskId);
                    }

                    if (parentContext.mounted && taskIds.isNotEmpty) {
                      showDownloadProgressSheet(parentContext, taskIds);
                    }
                  },
                ),
              ],
              if (selectedItems.length > 1 || !allAreFiles) ...[
                _buildDivider(context),
                _buildActionItem(
                  context,
                  TablerIcons.package_export,
                  context.l10n.files_actionPackageDownload,
                  () async {
                    final serverId = ref.read(activeServerIdProvider);
                    final manager = ref.read(downloadManagerProvider.notifier);

                    final taskId = await manager.startBatchPackageDownload(
                      serverId: serverId,
                      remotePaths: selectedItems.map((e) => e.path).toList(),
                    );

                    if (parentContext.mounted) {
                      showDownloadProgressSheet(parentContext, [taskId]);
                    }
                  },
                ),
              ],
              _buildDivider(context),
              _buildActionItem(
                context,
                TablerIcons.lock,
                context.l10n.files_actionPermissions,
                () async {
                  if (selectedItems.isNotEmpty) {
                    await ref.read(fileRepositoryProvider.future);
                    if (context.mounted) {
                      FilePermissionSheet.showBatch(
                        context,
                        selectedItems,
                        providerContainer: providerContainer,
                      );
                    }
                  }
                },
              ),
              _buildDivider(context),
              _buildActionItem(
                context,
                TablerIcons.file_zip,
                context.l10n.files_actionCompress,
                () async {
                  if (selectedItems.isNotEmpty) {
                    await ref.read(fileRepositoryProvider.future);
                    if (context.mounted) {
                      FileCompressSheet.show(
                        context,
                        selectedItems,
                        providerContainer: providerContainer,
                      );
                    }
                  }
                },
              ),
              _buildDivider(context),
              _buildActionItem(
                context,
                TablerIcons.trash,
                context.l10n.files_actionDelete,
                () async {
                  final controller = ref.read(filesControllerProvider.notifier);
                  final recycleEnabled = await controller.getRecycleStatus();
                  if (!context.mounted) return;

                  final result = await FileDeleteSheet.showBatch(
                    context,
                    items: selectedItems,
                    recycleEnabled: recycleEnabled,
                  );

                  if (result?.confirmed == true) {
                    await controller.deleteFiles(
                      selectedItems,
                      forceDelete: result?.forceDelete ?? false,
                    );
                  }
                },
                isDestructive: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 54),
      child: Container(
        height: 0.5,
        color: AppColors.separator(context).withValues(alpha: 0.1),
      ),
    );
  }
}
